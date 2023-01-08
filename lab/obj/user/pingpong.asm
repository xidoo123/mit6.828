
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
  80003c:	e8 e1 0d 00 00       	call   800e22 <fork>
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
  800054:	68 a0 25 80 00       	push   $0x8025a0
  800059:	e8 53 01 00 00       	call   8001b1 <cprintf>
		ipc_send(who, 0, 0, 0);
  80005e:	6a 00                	push   $0x0
  800060:	6a 00                	push   $0x0
  800062:	6a 00                	push   $0x0
  800064:	ff 75 e4             	pushl  -0x1c(%ebp)
  800067:	e8 d4 0f 00 00       	call   801040 <ipc_send>
  80006c:	83 c4 20             	add    $0x20,%esp
	}

	while (1) {
		uint32_t i = ipc_recv(&who, 0, 0);
  80006f:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  800072:	83 ec 04             	sub    $0x4,%esp
  800075:	6a 00                	push   $0x0
  800077:	6a 00                	push   $0x0
  800079:	56                   	push   %esi
  80007a:	e8 5a 0f 00 00       	call   800fd9 <ipc_recv>
  80007f:	89 c3                	mov    %eax,%ebx
		cprintf("%x got %d from %x\n", sys_getenvid(), i, who);
  800081:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800084:	e8 72 0a 00 00       	call   800afb <sys_getenvid>
  800089:	57                   	push   %edi
  80008a:	53                   	push   %ebx
  80008b:	50                   	push   %eax
  80008c:	68 b6 25 80 00       	push   $0x8025b6
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
  8000a9:	e8 92 0f 00 00       	call   801040 <ipc_send>
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
  8000db:	a3 08 40 80 00       	mov    %eax,0x804008

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
  80010a:	e8 89 11 00 00       	call   801298 <close_all>
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
  800214:	e8 e7 20 00 00       	call   802300 <__udivdi3>
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
  800257:	e8 d4 21 00 00       	call   802430 <__umoddi3>
  80025c:	83 c4 14             	add    $0x14,%esp
  80025f:	0f be 80 d3 25 80 00 	movsbl 0x8025d3(%eax),%eax
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
  80035b:	ff 24 85 20 27 80 00 	jmp    *0x802720(,%eax,4)
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
  80041f:	8b 14 85 80 28 80 00 	mov    0x802880(,%eax,4),%edx
  800426:	85 d2                	test   %edx,%edx
  800428:	75 18                	jne    800442 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80042a:	50                   	push   %eax
  80042b:	68 eb 25 80 00       	push   $0x8025eb
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
  800443:	68 81 2a 80 00       	push   $0x802a81
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
  800467:	b8 e4 25 80 00       	mov    $0x8025e4,%eax
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
  800ae2:	68 df 28 80 00       	push   $0x8028df
  800ae7:	6a 23                	push   $0x23
  800ae9:	68 fc 28 80 00       	push   $0x8028fc
  800aee:	e8 1e 17 00 00       	call   802211 <_panic>

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
  800b63:	68 df 28 80 00       	push   $0x8028df
  800b68:	6a 23                	push   $0x23
  800b6a:	68 fc 28 80 00       	push   $0x8028fc
  800b6f:	e8 9d 16 00 00       	call   802211 <_panic>

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
  800ba5:	68 df 28 80 00       	push   $0x8028df
  800baa:	6a 23                	push   $0x23
  800bac:	68 fc 28 80 00       	push   $0x8028fc
  800bb1:	e8 5b 16 00 00       	call   802211 <_panic>

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
  800be7:	68 df 28 80 00       	push   $0x8028df
  800bec:	6a 23                	push   $0x23
  800bee:	68 fc 28 80 00       	push   $0x8028fc
  800bf3:	e8 19 16 00 00       	call   802211 <_panic>

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
  800c29:	68 df 28 80 00       	push   $0x8028df
  800c2e:	6a 23                	push   $0x23
  800c30:	68 fc 28 80 00       	push   $0x8028fc
  800c35:	e8 d7 15 00 00       	call   802211 <_panic>

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
  800c6b:	68 df 28 80 00       	push   $0x8028df
  800c70:	6a 23                	push   $0x23
  800c72:	68 fc 28 80 00       	push   $0x8028fc
  800c77:	e8 95 15 00 00       	call   802211 <_panic>

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
  800cad:	68 df 28 80 00       	push   $0x8028df
  800cb2:	6a 23                	push   $0x23
  800cb4:	68 fc 28 80 00       	push   $0x8028fc
  800cb9:	e8 53 15 00 00       	call   802211 <_panic>

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
  800d11:	68 df 28 80 00       	push   $0x8028df
  800d16:	6a 23                	push   $0x23
  800d18:	68 fc 28 80 00       	push   $0x8028fc
  800d1d:	e8 ef 14 00 00       	call   802211 <_panic>

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

00800d2a <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800d2a:	55                   	push   %ebp
  800d2b:	89 e5                	mov    %esp,%ebp
  800d2d:	57                   	push   %edi
  800d2e:	56                   	push   %esi
  800d2f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d30:	ba 00 00 00 00       	mov    $0x0,%edx
  800d35:	b8 0e 00 00 00       	mov    $0xe,%eax
  800d3a:	89 d1                	mov    %edx,%ecx
  800d3c:	89 d3                	mov    %edx,%ebx
  800d3e:	89 d7                	mov    %edx,%edi
  800d40:	89 d6                	mov    %edx,%esi
  800d42:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800d44:	5b                   	pop    %ebx
  800d45:	5e                   	pop    %esi
  800d46:	5f                   	pop    %edi
  800d47:	5d                   	pop    %ebp
  800d48:	c3                   	ret    

00800d49 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800d49:	55                   	push   %ebp
  800d4a:	89 e5                	mov    %esp,%ebp
  800d4c:	56                   	push   %esi
  800d4d:	53                   	push   %ebx
  800d4e:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800d51:	8b 18                	mov    (%eax),%ebx
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.

	if ((err & FEC_WR) != FEC_WR && ((uvpt[PGNUM(addr)] & PTE_COW) != PTE_COW)) {
  800d53:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800d57:	75 25                	jne    800d7e <pgfault+0x35>
  800d59:	89 d8                	mov    %ebx,%eax
  800d5b:	c1 e8 0c             	shr    $0xc,%eax
  800d5e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800d65:	f6 c4 08             	test   $0x8,%ah
  800d68:	75 14                	jne    800d7e <pgfault+0x35>
		panic("pgfault: not due to a write or a COW page");
  800d6a:	83 ec 04             	sub    $0x4,%esp
  800d6d:	68 0c 29 80 00       	push   $0x80290c
  800d72:	6a 1e                	push   $0x1e
  800d74:	68 a0 29 80 00       	push   $0x8029a0
  800d79:	e8 93 14 00 00       	call   802211 <_panic>

	// LAB 4: Your code here.

	// panic("pgfault not implemented");

	addr = ROUNDDOWN(addr, PGSIZE);
  800d7e:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	envid_t envid = sys_getenvid();
  800d84:	e8 72 fd ff ff       	call   800afb <sys_getenvid>
  800d89:	89 c6                	mov    %eax,%esi

	// envid = 0;

	// Allocate a new page, map it at a temporary location (PFTEMP)
	r = sys_page_alloc(envid, (void *)PFTEMP, PTE_U | PTE_P | PTE_W);
  800d8b:	83 ec 04             	sub    $0x4,%esp
  800d8e:	6a 07                	push   $0x7
  800d90:	68 00 f0 7f 00       	push   $0x7ff000
  800d95:	50                   	push   %eax
  800d96:	e8 9e fd ff ff       	call   800b39 <sys_page_alloc>
	if (r < 0)
  800d9b:	83 c4 10             	add    $0x10,%esp
  800d9e:	85 c0                	test   %eax,%eax
  800da0:	79 12                	jns    800db4 <pgfault+0x6b>
		panic("pgfault: sys_page_alloc failed: %e\n", r);
  800da2:	50                   	push   %eax
  800da3:	68 38 29 80 00       	push   $0x802938
  800da8:	6a 33                	push   $0x33
  800daa:	68 a0 29 80 00       	push   $0x8029a0
  800daf:	e8 5d 14 00 00       	call   802211 <_panic>
	
	// copy the data from the old page to the new page
	memcpy((void *) PFTEMP, (const void *) addr, PGSIZE);
  800db4:	83 ec 04             	sub    $0x4,%esp
  800db7:	68 00 10 00 00       	push   $0x1000
  800dbc:	53                   	push   %ebx
  800dbd:	68 00 f0 7f 00       	push   $0x7ff000
  800dc2:	e8 69 fb ff ff       	call   800930 <memcpy>

	// move the new page to the old page's address
	r = sys_page_map(envid, (void *) PFTEMP, envid, addr, PTE_U | PTE_P | PTE_W);
  800dc7:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800dce:	53                   	push   %ebx
  800dcf:	56                   	push   %esi
  800dd0:	68 00 f0 7f 00       	push   $0x7ff000
  800dd5:	56                   	push   %esi
  800dd6:	e8 a1 fd ff ff       	call   800b7c <sys_page_map>
	if (r < 0)
  800ddb:	83 c4 20             	add    $0x20,%esp
  800dde:	85 c0                	test   %eax,%eax
  800de0:	79 12                	jns    800df4 <pgfault+0xab>
		panic("pgfault: sys_page_map failed: %e\n", r);
  800de2:	50                   	push   %eax
  800de3:	68 5c 29 80 00       	push   $0x80295c
  800de8:	6a 3b                	push   $0x3b
  800dea:	68 a0 29 80 00       	push   $0x8029a0
  800def:	e8 1d 14 00 00       	call   802211 <_panic>

	// unmap temporary region
	r = sys_page_unmap(envid, (void *) PFTEMP);
  800df4:	83 ec 08             	sub    $0x8,%esp
  800df7:	68 00 f0 7f 00       	push   $0x7ff000
  800dfc:	56                   	push   %esi
  800dfd:	e8 bc fd ff ff       	call   800bbe <sys_page_unmap>
	if (r < 0)
  800e02:	83 c4 10             	add    $0x10,%esp
  800e05:	85 c0                	test   %eax,%eax
  800e07:	79 12                	jns    800e1b <pgfault+0xd2>
        panic("pgfault: page unmap failed: %e\n", r);
  800e09:	50                   	push   %eax
  800e0a:	68 80 29 80 00       	push   $0x802980
  800e0f:	6a 40                	push   $0x40
  800e11:	68 a0 29 80 00       	push   $0x8029a0
  800e16:	e8 f6 13 00 00       	call   802211 <_panic>
}
  800e1b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e1e:	5b                   	pop    %ebx
  800e1f:	5e                   	pop    %esi
  800e20:	5d                   	pop    %ebp
  800e21:	c3                   	ret    

00800e22 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800e22:	55                   	push   %ebp
  800e23:	89 e5                	mov    %esp,%ebp
  800e25:	57                   	push   %edi
  800e26:	56                   	push   %esi
  800e27:	53                   	push   %ebx
  800e28:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	// cprintf("[fork]\n");
	int r;

	set_pgfault_handler(pgfault);
  800e2b:	68 49 0d 80 00       	push   $0x800d49
  800e30:	e8 22 14 00 00       	call   802257 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800e35:	b8 07 00 00 00       	mov    $0x7,%eax
  800e3a:	cd 30                	int    $0x30

	envid_t envid = sys_exofork();
	if (envid < 0)
  800e3c:	83 c4 10             	add    $0x10,%esp
  800e3f:	85 c0                	test   %eax,%eax
  800e41:	0f 88 64 01 00 00    	js     800fab <fork+0x189>
  800e47:	bb 00 00 80 00       	mov    $0x800000,%ebx
  800e4c:	be 00 08 00 00       	mov    $0x800,%esi
		return envid;

	// fix "thisenv" in the child process
	if (envid == 0) {
  800e51:	85 c0                	test   %eax,%eax
  800e53:	75 21                	jne    800e76 <fork+0x54>
		thisenv = &envs[ENVX(sys_getenvid())];
  800e55:	e8 a1 fc ff ff       	call   800afb <sys_getenvid>
  800e5a:	25 ff 03 00 00       	and    $0x3ff,%eax
  800e5f:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800e62:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800e67:	a3 08 40 80 00       	mov    %eax,0x804008
        return 0;
  800e6c:	ba 00 00 00 00       	mov    $0x0,%edx
  800e71:	e9 3f 01 00 00       	jmp    800fb5 <fork+0x193>
  800e76:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800e79:	89 c7                	mov    %eax,%edi
	for (uint32_t pn = PGNUM(UTEXT); pn < PGNUM(USTACKTOP); pn++) {

		addr = pn * PGSIZE;

		// if level-2 page exists
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P) {
  800e7b:	89 d8                	mov    %ebx,%eax
  800e7d:	c1 e8 16             	shr    $0x16,%eax
  800e80:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800e87:	a8 01                	test   $0x1,%al
  800e89:	0f 84 bd 00 00 00    	je     800f4c <fork+0x12a>
			
			// if real PTE exists
			if ((uvpt[PGNUM(addr)] & PTE_P) == PTE_P) {
  800e8f:	89 d8                	mov    %ebx,%eax
  800e91:	c1 e8 0c             	shr    $0xc,%eax
  800e94:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800e9b:	f6 c2 01             	test   $0x1,%dl
  800e9e:	0f 84 a8 00 00 00    	je     800f4c <fork+0x12a>

				// For each writable or copy-on-write page
				// if ((uvpt[PGNUM(addr)] & (PTE_W | PTE_COW)) != 0) {
				if ((uvpt[PGNUM(addr)] & PTE_U) != 0) {
  800ea4:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800eab:	a8 04                	test   $0x4,%al
  800ead:	0f 84 99 00 00 00    	je     800f4c <fork+0x12a>
	// r = envid2env(envid, &env, 1);
	// if (r < 0)
	// 	return r;	// E_BAD_ENV
	// envid_t parent_envid = env->env_parent_id;

	if (uvpt[pn] & PTE_SHARE) {
  800eb3:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800eba:	f6 c4 04             	test   $0x4,%ah
  800ebd:	74 17                	je     800ed6 <fork+0xb4>
		sys_page_map(0, (void *)va, envid, (void *)va, PTE_SYSCALL);
  800ebf:	83 ec 0c             	sub    $0xc,%esp
  800ec2:	68 07 0e 00 00       	push   $0xe07
  800ec7:	53                   	push   %ebx
  800ec8:	57                   	push   %edi
  800ec9:	53                   	push   %ebx
  800eca:	6a 00                	push   $0x0
  800ecc:	e8 ab fc ff ff       	call   800b7c <sys_page_map>
  800ed1:	83 c4 20             	add    $0x20,%esp
  800ed4:	eb 76                	jmp    800f4c <fork+0x12a>
	}
	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {
  800ed6:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800edd:	a8 02                	test   $0x2,%al
  800edf:	75 0c                	jne    800eed <fork+0xcb>
  800ee1:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800ee8:	f6 c4 08             	test   $0x8,%ah
  800eeb:	74 3f                	je     800f2c <fork+0x10a>

		// map the page copy-on-write into the address space of the child
        r = sys_page_map(0, (void *)va, envid, (void *)va, PTE_P|PTE_U|PTE_COW);
  800eed:	83 ec 0c             	sub    $0xc,%esp
  800ef0:	68 05 08 00 00       	push   $0x805
  800ef5:	53                   	push   %ebx
  800ef6:	57                   	push   %edi
  800ef7:	53                   	push   %ebx
  800ef8:	6a 00                	push   $0x0
  800efa:	e8 7d fc ff ff       	call   800b7c <sys_page_map>
		if (r < 0)
  800eff:	83 c4 20             	add    $0x20,%esp
  800f02:	85 c0                	test   %eax,%eax
  800f04:	0f 88 a5 00 00 00    	js     800faf <fork+0x18d>
            return r;

		// remap the page copy-on-write in its own(parent) address space
        r = sys_page_map(0, (void *)va, 0, (void *)va, PTE_P|PTE_U|PTE_COW);
  800f0a:	83 ec 0c             	sub    $0xc,%esp
  800f0d:	68 05 08 00 00       	push   $0x805
  800f12:	53                   	push   %ebx
  800f13:	6a 00                	push   $0x0
  800f15:	53                   	push   %ebx
  800f16:	6a 00                	push   $0x0
  800f18:	e8 5f fc ff ff       	call   800b7c <sys_page_map>
  800f1d:	83 c4 20             	add    $0x20,%esp
  800f20:	85 c0                	test   %eax,%eax
  800f22:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f27:	0f 4f c1             	cmovg  %ecx,%eax
  800f2a:	eb 1c                	jmp    800f48 <fork+0x126>
		if (r < 0)
            return r;
    }
    else {
        r = sys_page_map(0, (void *)va, envid, (void *)va, PTE_P|PTE_U);
  800f2c:	83 ec 0c             	sub    $0xc,%esp
  800f2f:	6a 05                	push   $0x5
  800f31:	53                   	push   %ebx
  800f32:	57                   	push   %edi
  800f33:	53                   	push   %ebx
  800f34:	6a 00                	push   $0x0
  800f36:	e8 41 fc ff ff       	call   800b7c <sys_page_map>
  800f3b:	83 c4 20             	add    $0x20,%esp
  800f3e:	85 c0                	test   %eax,%eax
  800f40:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f45:	0f 4f c1             	cmovg  %ecx,%eax

				// For each writable or copy-on-write page
				// if ((uvpt[PGNUM(addr)] & (PTE_W | PTE_COW)) != 0) {
				if ((uvpt[PGNUM(addr)] & PTE_U) != 0) {
					r = duppage(envid, pn);
					if (r < 0)
  800f48:	85 c0                	test   %eax,%eax
  800f4a:	78 67                	js     800fb3 <fork+0x191>
        return 0;
	}

	// For each writable or copy-on-write page in its address space below UTOP, the parent calls duppage
	uint32_t addr;
	for (uint32_t pn = PGNUM(UTEXT); pn < PGNUM(USTACKTOP); pn++) {
  800f4c:	83 c6 01             	add    $0x1,%esi
  800f4f:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  800f55:	81 fe fe eb 0e 00    	cmp    $0xeebfe,%esi
  800f5b:	0f 85 1a ff ff ff    	jne    800e7b <fork+0x59>
  800f61:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
		}
	}

	// allocate a fresh page in the child for the exception stack
	r = sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U | PTE_P | PTE_W);
  800f64:	83 ec 04             	sub    $0x4,%esp
  800f67:	6a 07                	push   $0x7
  800f69:	68 00 f0 bf ee       	push   $0xeebff000
  800f6e:	57                   	push   %edi
  800f6f:	e8 c5 fb ff ff       	call   800b39 <sys_page_alloc>
	if (r < 0)
  800f74:	83 c4 10             	add    $0x10,%esp
		return r;
  800f77:	89 c2                	mov    %eax,%edx
		}
	}

	// allocate a fresh page in the child for the exception stack
	r = sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U | PTE_P | PTE_W);
	if (r < 0)
  800f79:	85 c0                	test   %eax,%eax
  800f7b:	78 38                	js     800fb5 <fork+0x193>
		return r;

	// The parent sets the user page fault entrypoint for the child to look like its own
	extern void _pgfault_upcall(void);
	r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  800f7d:	83 ec 08             	sub    $0x8,%esp
  800f80:	68 9e 22 80 00       	push   $0x80229e
  800f85:	57                   	push   %edi
  800f86:	e8 f9 fc ff ff       	call   800c84 <sys_env_set_pgfault_upcall>
	if (r < 0)
  800f8b:	83 c4 10             	add    $0x10,%esp
		return r;
  800f8e:	89 c2                	mov    %eax,%edx
		return r;

	// The parent sets the user page fault entrypoint for the child to look like its own
	extern void _pgfault_upcall(void);
	r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
	if (r < 0)
  800f90:	85 c0                	test   %eax,%eax
  800f92:	78 21                	js     800fb5 <fork+0x193>
		return r;

	// The child is now ready to run, so the parent marks it runnable
	r = sys_env_set_status(envid, ENV_RUNNABLE);
  800f94:	83 ec 08             	sub    $0x8,%esp
  800f97:	6a 02                	push   $0x2
  800f99:	57                   	push   %edi
  800f9a:	e8 61 fc ff ff       	call   800c00 <sys_env_set_status>
	if (r < 0)
  800f9f:	83 c4 10             	add    $0x10,%esp
		return r;

	return envid;
  800fa2:	85 c0                	test   %eax,%eax
  800fa4:	0f 48 f8             	cmovs  %eax,%edi
  800fa7:	89 fa                	mov    %edi,%edx
  800fa9:	eb 0a                	jmp    800fb5 <fork+0x193>

	set_pgfault_handler(pgfault);

	envid_t envid = sys_exofork();
	if (envid < 0)
		return envid;
  800fab:	89 c2                	mov    %eax,%edx
  800fad:	eb 06                	jmp    800fb5 <fork+0x193>
		sys_page_map(0, (void *)va, envid, (void *)va, PTE_SYSCALL);
	}
	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {

		// map the page copy-on-write into the address space of the child
        r = sys_page_map(0, (void *)va, envid, (void *)va, PTE_P|PTE_U|PTE_COW);
  800faf:	89 c2                	mov    %eax,%edx
  800fb1:	eb 02                	jmp    800fb5 <fork+0x193>
  800fb3:	89 c2                	mov    %eax,%edx
	if (r < 0)
		return r;

	return envid;
	// panic("fork not implemented");
}
  800fb5:	89 d0                	mov    %edx,%eax
  800fb7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fba:	5b                   	pop    %ebx
  800fbb:	5e                   	pop    %esi
  800fbc:	5f                   	pop    %edi
  800fbd:	5d                   	pop    %ebp
  800fbe:	c3                   	ret    

00800fbf <sfork>:

// Challenge!
int
sfork(void)
{
  800fbf:	55                   	push   %ebp
  800fc0:	89 e5                	mov    %esp,%ebp
  800fc2:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  800fc5:	68 ab 29 80 00       	push   $0x8029ab
  800fca:	68 c9 00 00 00       	push   $0xc9
  800fcf:	68 a0 29 80 00       	push   $0x8029a0
  800fd4:	e8 38 12 00 00       	call   802211 <_panic>

00800fd9 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  800fd9:	55                   	push   %ebp
  800fda:	89 e5                	mov    %esp,%ebp
  800fdc:	56                   	push   %esi
  800fdd:	53                   	push   %ebx
  800fde:	8b 75 08             	mov    0x8(%ebp),%esi
  800fe1:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fe4:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");

	// don't want to recv page
	if (pg == NULL)
  800fe7:	85 c0                	test   %eax,%eax
		pg = (void *)UTOP;
  800fe9:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  800fee:	0f 44 c2             	cmove  %edx,%eax

	int err = sys_ipc_recv(pg);
  800ff1:	83 ec 0c             	sub    $0xc,%esp
  800ff4:	50                   	push   %eax
  800ff5:	e8 ef fc ff ff       	call   800ce9 <sys_ipc_recv>

	if (from_env_store != NULL)
  800ffa:	83 c4 10             	add    $0x10,%esp
  800ffd:	85 f6                	test   %esi,%esi
  800fff:	74 14                	je     801015 <ipc_recv+0x3c>
		*from_env_store = err < 0? 0 : thisenv->env_ipc_from;
  801001:	ba 00 00 00 00       	mov    $0x0,%edx
  801006:	85 c0                	test   %eax,%eax
  801008:	78 09                	js     801013 <ipc_recv+0x3a>
  80100a:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801010:	8b 52 74             	mov    0x74(%edx),%edx
  801013:	89 16                	mov    %edx,(%esi)
	
	if (perm_store != NULL)
  801015:	85 db                	test   %ebx,%ebx
  801017:	74 14                	je     80102d <ipc_recv+0x54>
		*perm_store = err < 0? 0 : thisenv->env_ipc_perm;
  801019:	ba 00 00 00 00       	mov    $0x0,%edx
  80101e:	85 c0                	test   %eax,%eax
  801020:	78 09                	js     80102b <ipc_recv+0x52>
  801022:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801028:	8b 52 78             	mov    0x78(%edx),%edx
  80102b:	89 13                	mov    %edx,(%ebx)

	if (err < 0)
  80102d:	85 c0                	test   %eax,%eax
  80102f:	78 08                	js     801039 <ipc_recv+0x60>
		return err;
	return thisenv->env_ipc_value;
  801031:	a1 08 40 80 00       	mov    0x804008,%eax
  801036:	8b 40 70             	mov    0x70(%eax),%eax
}
  801039:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80103c:	5b                   	pop    %ebx
  80103d:	5e                   	pop    %esi
  80103e:	5d                   	pop    %ebp
  80103f:	c3                   	ret    

00801040 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801040:	55                   	push   %ebp
  801041:	89 e5                	mov    %esp,%ebp
  801043:	57                   	push   %edi
  801044:	56                   	push   %esi
  801045:	53                   	push   %ebx
  801046:	83 ec 0c             	sub    $0xc,%esp
  801049:	8b 7d 08             	mov    0x8(%ebp),%edi
  80104c:	8b 75 0c             	mov    0xc(%ebp),%esi
  80104f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");

	// don't want to send page
	if (pg == NULL)
  801052:	85 db                	test   %ebx,%ebx
		pg = (void *)UTOP;
  801054:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801059:	0f 44 d8             	cmove  %eax,%ebx
	
	int err = 0;
	
	do {

		err = sys_ipc_try_send(to_env, val, pg, perm);
  80105c:	ff 75 14             	pushl  0x14(%ebp)
  80105f:	53                   	push   %ebx
  801060:	56                   	push   %esi
  801061:	57                   	push   %edi
  801062:	e8 5f fc ff ff       	call   800cc6 <sys_ipc_try_send>

		if (err < 0) {
  801067:	83 c4 10             	add    $0x10,%esp
  80106a:	85 c0                	test   %eax,%eax
  80106c:	79 1e                	jns    80108c <ipc_send+0x4c>
			if (err == -E_IPC_NOT_RECV)
  80106e:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801071:	75 07                	jne    80107a <ipc_send+0x3a>
				sys_yield();
  801073:	e8 a2 fa ff ff       	call   800b1a <sys_yield>
  801078:	eb e2                	jmp    80105c <ipc_send+0x1c>
			else 
				panic("ipc_send: %e", err);
  80107a:	50                   	push   %eax
  80107b:	68 c1 29 80 00       	push   $0x8029c1
  801080:	6a 49                	push   $0x49
  801082:	68 ce 29 80 00       	push   $0x8029ce
  801087:	e8 85 11 00 00       	call   802211 <_panic>
		}

	} while (err < 0);

}
  80108c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80108f:	5b                   	pop    %ebx
  801090:	5e                   	pop    %esi
  801091:	5f                   	pop    %edi
  801092:	5d                   	pop    %ebp
  801093:	c3                   	ret    

00801094 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801094:	55                   	push   %ebp
  801095:	89 e5                	mov    %esp,%ebp
  801097:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80109a:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80109f:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8010a2:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8010a8:	8b 52 50             	mov    0x50(%edx),%edx
  8010ab:	39 ca                	cmp    %ecx,%edx
  8010ad:	75 0d                	jne    8010bc <ipc_find_env+0x28>
			return envs[i].env_id;
  8010af:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8010b2:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8010b7:	8b 40 48             	mov    0x48(%eax),%eax
  8010ba:	eb 0f                	jmp    8010cb <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8010bc:	83 c0 01             	add    $0x1,%eax
  8010bf:	3d 00 04 00 00       	cmp    $0x400,%eax
  8010c4:	75 d9                	jne    80109f <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8010c6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8010cb:	5d                   	pop    %ebp
  8010cc:	c3                   	ret    

008010cd <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8010cd:	55                   	push   %ebp
  8010ce:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8010d0:	8b 45 08             	mov    0x8(%ebp),%eax
  8010d3:	05 00 00 00 30       	add    $0x30000000,%eax
  8010d8:	c1 e8 0c             	shr    $0xc,%eax
}
  8010db:	5d                   	pop    %ebp
  8010dc:	c3                   	ret    

008010dd <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8010dd:	55                   	push   %ebp
  8010de:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8010e0:	8b 45 08             	mov    0x8(%ebp),%eax
  8010e3:	05 00 00 00 30       	add    $0x30000000,%eax
  8010e8:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8010ed:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8010f2:	5d                   	pop    %ebp
  8010f3:	c3                   	ret    

008010f4 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8010f4:	55                   	push   %ebp
  8010f5:	89 e5                	mov    %esp,%ebp
  8010f7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010fa:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8010ff:	89 c2                	mov    %eax,%edx
  801101:	c1 ea 16             	shr    $0x16,%edx
  801104:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80110b:	f6 c2 01             	test   $0x1,%dl
  80110e:	74 11                	je     801121 <fd_alloc+0x2d>
  801110:	89 c2                	mov    %eax,%edx
  801112:	c1 ea 0c             	shr    $0xc,%edx
  801115:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80111c:	f6 c2 01             	test   $0x1,%dl
  80111f:	75 09                	jne    80112a <fd_alloc+0x36>
			*fd_store = fd;
  801121:	89 01                	mov    %eax,(%ecx)
			return 0;
  801123:	b8 00 00 00 00       	mov    $0x0,%eax
  801128:	eb 17                	jmp    801141 <fd_alloc+0x4d>
  80112a:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80112f:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801134:	75 c9                	jne    8010ff <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801136:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  80113c:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801141:	5d                   	pop    %ebp
  801142:	c3                   	ret    

00801143 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801143:	55                   	push   %ebp
  801144:	89 e5                	mov    %esp,%ebp
  801146:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801149:	83 f8 1f             	cmp    $0x1f,%eax
  80114c:	77 36                	ja     801184 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80114e:	c1 e0 0c             	shl    $0xc,%eax
  801151:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801156:	89 c2                	mov    %eax,%edx
  801158:	c1 ea 16             	shr    $0x16,%edx
  80115b:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801162:	f6 c2 01             	test   $0x1,%dl
  801165:	74 24                	je     80118b <fd_lookup+0x48>
  801167:	89 c2                	mov    %eax,%edx
  801169:	c1 ea 0c             	shr    $0xc,%edx
  80116c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801173:	f6 c2 01             	test   $0x1,%dl
  801176:	74 1a                	je     801192 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801178:	8b 55 0c             	mov    0xc(%ebp),%edx
  80117b:	89 02                	mov    %eax,(%edx)
	return 0;
  80117d:	b8 00 00 00 00       	mov    $0x0,%eax
  801182:	eb 13                	jmp    801197 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801184:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801189:	eb 0c                	jmp    801197 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80118b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801190:	eb 05                	jmp    801197 <fd_lookup+0x54>
  801192:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801197:	5d                   	pop    %ebp
  801198:	c3                   	ret    

00801199 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801199:	55                   	push   %ebp
  80119a:	89 e5                	mov    %esp,%ebp
  80119c:	83 ec 08             	sub    $0x8,%esp
  80119f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011a2:	ba 54 2a 80 00       	mov    $0x802a54,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8011a7:	eb 13                	jmp    8011bc <dev_lookup+0x23>
  8011a9:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8011ac:	39 08                	cmp    %ecx,(%eax)
  8011ae:	75 0c                	jne    8011bc <dev_lookup+0x23>
			*dev = devtab[i];
  8011b0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011b3:	89 01                	mov    %eax,(%ecx)
			return 0;
  8011b5:	b8 00 00 00 00       	mov    $0x0,%eax
  8011ba:	eb 2e                	jmp    8011ea <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8011bc:	8b 02                	mov    (%edx),%eax
  8011be:	85 c0                	test   %eax,%eax
  8011c0:	75 e7                	jne    8011a9 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8011c2:	a1 08 40 80 00       	mov    0x804008,%eax
  8011c7:	8b 40 48             	mov    0x48(%eax),%eax
  8011ca:	83 ec 04             	sub    $0x4,%esp
  8011cd:	51                   	push   %ecx
  8011ce:	50                   	push   %eax
  8011cf:	68 d8 29 80 00       	push   $0x8029d8
  8011d4:	e8 d8 ef ff ff       	call   8001b1 <cprintf>
	*dev = 0;
  8011d9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8011dc:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8011e2:	83 c4 10             	add    $0x10,%esp
  8011e5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8011ea:	c9                   	leave  
  8011eb:	c3                   	ret    

008011ec <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8011ec:	55                   	push   %ebp
  8011ed:	89 e5                	mov    %esp,%ebp
  8011ef:	56                   	push   %esi
  8011f0:	53                   	push   %ebx
  8011f1:	83 ec 10             	sub    $0x10,%esp
  8011f4:	8b 75 08             	mov    0x8(%ebp),%esi
  8011f7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8011fa:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011fd:	50                   	push   %eax
  8011fe:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801204:	c1 e8 0c             	shr    $0xc,%eax
  801207:	50                   	push   %eax
  801208:	e8 36 ff ff ff       	call   801143 <fd_lookup>
  80120d:	83 c4 08             	add    $0x8,%esp
  801210:	85 c0                	test   %eax,%eax
  801212:	78 05                	js     801219 <fd_close+0x2d>
	    || fd != fd2)
  801214:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801217:	74 0c                	je     801225 <fd_close+0x39>
		return (must_exist ? r : 0);
  801219:	84 db                	test   %bl,%bl
  80121b:	ba 00 00 00 00       	mov    $0x0,%edx
  801220:	0f 44 c2             	cmove  %edx,%eax
  801223:	eb 41                	jmp    801266 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801225:	83 ec 08             	sub    $0x8,%esp
  801228:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80122b:	50                   	push   %eax
  80122c:	ff 36                	pushl  (%esi)
  80122e:	e8 66 ff ff ff       	call   801199 <dev_lookup>
  801233:	89 c3                	mov    %eax,%ebx
  801235:	83 c4 10             	add    $0x10,%esp
  801238:	85 c0                	test   %eax,%eax
  80123a:	78 1a                	js     801256 <fd_close+0x6a>
		if (dev->dev_close)
  80123c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80123f:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801242:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801247:	85 c0                	test   %eax,%eax
  801249:	74 0b                	je     801256 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80124b:	83 ec 0c             	sub    $0xc,%esp
  80124e:	56                   	push   %esi
  80124f:	ff d0                	call   *%eax
  801251:	89 c3                	mov    %eax,%ebx
  801253:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801256:	83 ec 08             	sub    $0x8,%esp
  801259:	56                   	push   %esi
  80125a:	6a 00                	push   $0x0
  80125c:	e8 5d f9 ff ff       	call   800bbe <sys_page_unmap>
	return r;
  801261:	83 c4 10             	add    $0x10,%esp
  801264:	89 d8                	mov    %ebx,%eax
}
  801266:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801269:	5b                   	pop    %ebx
  80126a:	5e                   	pop    %esi
  80126b:	5d                   	pop    %ebp
  80126c:	c3                   	ret    

0080126d <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80126d:	55                   	push   %ebp
  80126e:	89 e5                	mov    %esp,%ebp
  801270:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801273:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801276:	50                   	push   %eax
  801277:	ff 75 08             	pushl  0x8(%ebp)
  80127a:	e8 c4 fe ff ff       	call   801143 <fd_lookup>
  80127f:	83 c4 08             	add    $0x8,%esp
  801282:	85 c0                	test   %eax,%eax
  801284:	78 10                	js     801296 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801286:	83 ec 08             	sub    $0x8,%esp
  801289:	6a 01                	push   $0x1
  80128b:	ff 75 f4             	pushl  -0xc(%ebp)
  80128e:	e8 59 ff ff ff       	call   8011ec <fd_close>
  801293:	83 c4 10             	add    $0x10,%esp
}
  801296:	c9                   	leave  
  801297:	c3                   	ret    

00801298 <close_all>:

void
close_all(void)
{
  801298:	55                   	push   %ebp
  801299:	89 e5                	mov    %esp,%ebp
  80129b:	53                   	push   %ebx
  80129c:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80129f:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8012a4:	83 ec 0c             	sub    $0xc,%esp
  8012a7:	53                   	push   %ebx
  8012a8:	e8 c0 ff ff ff       	call   80126d <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8012ad:	83 c3 01             	add    $0x1,%ebx
  8012b0:	83 c4 10             	add    $0x10,%esp
  8012b3:	83 fb 20             	cmp    $0x20,%ebx
  8012b6:	75 ec                	jne    8012a4 <close_all+0xc>
		close(i);
}
  8012b8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012bb:	c9                   	leave  
  8012bc:	c3                   	ret    

008012bd <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8012bd:	55                   	push   %ebp
  8012be:	89 e5                	mov    %esp,%ebp
  8012c0:	57                   	push   %edi
  8012c1:	56                   	push   %esi
  8012c2:	53                   	push   %ebx
  8012c3:	83 ec 2c             	sub    $0x2c,%esp
  8012c6:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8012c9:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8012cc:	50                   	push   %eax
  8012cd:	ff 75 08             	pushl  0x8(%ebp)
  8012d0:	e8 6e fe ff ff       	call   801143 <fd_lookup>
  8012d5:	83 c4 08             	add    $0x8,%esp
  8012d8:	85 c0                	test   %eax,%eax
  8012da:	0f 88 c1 00 00 00    	js     8013a1 <dup+0xe4>
		return r;
	close(newfdnum);
  8012e0:	83 ec 0c             	sub    $0xc,%esp
  8012e3:	56                   	push   %esi
  8012e4:	e8 84 ff ff ff       	call   80126d <close>

	newfd = INDEX2FD(newfdnum);
  8012e9:	89 f3                	mov    %esi,%ebx
  8012eb:	c1 e3 0c             	shl    $0xc,%ebx
  8012ee:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8012f4:	83 c4 04             	add    $0x4,%esp
  8012f7:	ff 75 e4             	pushl  -0x1c(%ebp)
  8012fa:	e8 de fd ff ff       	call   8010dd <fd2data>
  8012ff:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801301:	89 1c 24             	mov    %ebx,(%esp)
  801304:	e8 d4 fd ff ff       	call   8010dd <fd2data>
  801309:	83 c4 10             	add    $0x10,%esp
  80130c:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80130f:	89 f8                	mov    %edi,%eax
  801311:	c1 e8 16             	shr    $0x16,%eax
  801314:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80131b:	a8 01                	test   $0x1,%al
  80131d:	74 37                	je     801356 <dup+0x99>
  80131f:	89 f8                	mov    %edi,%eax
  801321:	c1 e8 0c             	shr    $0xc,%eax
  801324:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80132b:	f6 c2 01             	test   $0x1,%dl
  80132e:	74 26                	je     801356 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801330:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801337:	83 ec 0c             	sub    $0xc,%esp
  80133a:	25 07 0e 00 00       	and    $0xe07,%eax
  80133f:	50                   	push   %eax
  801340:	ff 75 d4             	pushl  -0x2c(%ebp)
  801343:	6a 00                	push   $0x0
  801345:	57                   	push   %edi
  801346:	6a 00                	push   $0x0
  801348:	e8 2f f8 ff ff       	call   800b7c <sys_page_map>
  80134d:	89 c7                	mov    %eax,%edi
  80134f:	83 c4 20             	add    $0x20,%esp
  801352:	85 c0                	test   %eax,%eax
  801354:	78 2e                	js     801384 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801356:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801359:	89 d0                	mov    %edx,%eax
  80135b:	c1 e8 0c             	shr    $0xc,%eax
  80135e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801365:	83 ec 0c             	sub    $0xc,%esp
  801368:	25 07 0e 00 00       	and    $0xe07,%eax
  80136d:	50                   	push   %eax
  80136e:	53                   	push   %ebx
  80136f:	6a 00                	push   $0x0
  801371:	52                   	push   %edx
  801372:	6a 00                	push   $0x0
  801374:	e8 03 f8 ff ff       	call   800b7c <sys_page_map>
  801379:	89 c7                	mov    %eax,%edi
  80137b:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80137e:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801380:	85 ff                	test   %edi,%edi
  801382:	79 1d                	jns    8013a1 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801384:	83 ec 08             	sub    $0x8,%esp
  801387:	53                   	push   %ebx
  801388:	6a 00                	push   $0x0
  80138a:	e8 2f f8 ff ff       	call   800bbe <sys_page_unmap>
	sys_page_unmap(0, nva);
  80138f:	83 c4 08             	add    $0x8,%esp
  801392:	ff 75 d4             	pushl  -0x2c(%ebp)
  801395:	6a 00                	push   $0x0
  801397:	e8 22 f8 ff ff       	call   800bbe <sys_page_unmap>
	return r;
  80139c:	83 c4 10             	add    $0x10,%esp
  80139f:	89 f8                	mov    %edi,%eax
}
  8013a1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013a4:	5b                   	pop    %ebx
  8013a5:	5e                   	pop    %esi
  8013a6:	5f                   	pop    %edi
  8013a7:	5d                   	pop    %ebp
  8013a8:	c3                   	ret    

008013a9 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8013a9:	55                   	push   %ebp
  8013aa:	89 e5                	mov    %esp,%ebp
  8013ac:	53                   	push   %ebx
  8013ad:	83 ec 14             	sub    $0x14,%esp
  8013b0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013b3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013b6:	50                   	push   %eax
  8013b7:	53                   	push   %ebx
  8013b8:	e8 86 fd ff ff       	call   801143 <fd_lookup>
  8013bd:	83 c4 08             	add    $0x8,%esp
  8013c0:	89 c2                	mov    %eax,%edx
  8013c2:	85 c0                	test   %eax,%eax
  8013c4:	78 6d                	js     801433 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013c6:	83 ec 08             	sub    $0x8,%esp
  8013c9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013cc:	50                   	push   %eax
  8013cd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013d0:	ff 30                	pushl  (%eax)
  8013d2:	e8 c2 fd ff ff       	call   801199 <dev_lookup>
  8013d7:	83 c4 10             	add    $0x10,%esp
  8013da:	85 c0                	test   %eax,%eax
  8013dc:	78 4c                	js     80142a <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8013de:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8013e1:	8b 42 08             	mov    0x8(%edx),%eax
  8013e4:	83 e0 03             	and    $0x3,%eax
  8013e7:	83 f8 01             	cmp    $0x1,%eax
  8013ea:	75 21                	jne    80140d <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8013ec:	a1 08 40 80 00       	mov    0x804008,%eax
  8013f1:	8b 40 48             	mov    0x48(%eax),%eax
  8013f4:	83 ec 04             	sub    $0x4,%esp
  8013f7:	53                   	push   %ebx
  8013f8:	50                   	push   %eax
  8013f9:	68 19 2a 80 00       	push   $0x802a19
  8013fe:	e8 ae ed ff ff       	call   8001b1 <cprintf>
		return -E_INVAL;
  801403:	83 c4 10             	add    $0x10,%esp
  801406:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80140b:	eb 26                	jmp    801433 <read+0x8a>
	}
	if (!dev->dev_read)
  80140d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801410:	8b 40 08             	mov    0x8(%eax),%eax
  801413:	85 c0                	test   %eax,%eax
  801415:	74 17                	je     80142e <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801417:	83 ec 04             	sub    $0x4,%esp
  80141a:	ff 75 10             	pushl  0x10(%ebp)
  80141d:	ff 75 0c             	pushl  0xc(%ebp)
  801420:	52                   	push   %edx
  801421:	ff d0                	call   *%eax
  801423:	89 c2                	mov    %eax,%edx
  801425:	83 c4 10             	add    $0x10,%esp
  801428:	eb 09                	jmp    801433 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80142a:	89 c2                	mov    %eax,%edx
  80142c:	eb 05                	jmp    801433 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80142e:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801433:	89 d0                	mov    %edx,%eax
  801435:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801438:	c9                   	leave  
  801439:	c3                   	ret    

0080143a <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80143a:	55                   	push   %ebp
  80143b:	89 e5                	mov    %esp,%ebp
  80143d:	57                   	push   %edi
  80143e:	56                   	push   %esi
  80143f:	53                   	push   %ebx
  801440:	83 ec 0c             	sub    $0xc,%esp
  801443:	8b 7d 08             	mov    0x8(%ebp),%edi
  801446:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801449:	bb 00 00 00 00       	mov    $0x0,%ebx
  80144e:	eb 21                	jmp    801471 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801450:	83 ec 04             	sub    $0x4,%esp
  801453:	89 f0                	mov    %esi,%eax
  801455:	29 d8                	sub    %ebx,%eax
  801457:	50                   	push   %eax
  801458:	89 d8                	mov    %ebx,%eax
  80145a:	03 45 0c             	add    0xc(%ebp),%eax
  80145d:	50                   	push   %eax
  80145e:	57                   	push   %edi
  80145f:	e8 45 ff ff ff       	call   8013a9 <read>
		if (m < 0)
  801464:	83 c4 10             	add    $0x10,%esp
  801467:	85 c0                	test   %eax,%eax
  801469:	78 10                	js     80147b <readn+0x41>
			return m;
		if (m == 0)
  80146b:	85 c0                	test   %eax,%eax
  80146d:	74 0a                	je     801479 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80146f:	01 c3                	add    %eax,%ebx
  801471:	39 f3                	cmp    %esi,%ebx
  801473:	72 db                	jb     801450 <readn+0x16>
  801475:	89 d8                	mov    %ebx,%eax
  801477:	eb 02                	jmp    80147b <readn+0x41>
  801479:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80147b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80147e:	5b                   	pop    %ebx
  80147f:	5e                   	pop    %esi
  801480:	5f                   	pop    %edi
  801481:	5d                   	pop    %ebp
  801482:	c3                   	ret    

00801483 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801483:	55                   	push   %ebp
  801484:	89 e5                	mov    %esp,%ebp
  801486:	53                   	push   %ebx
  801487:	83 ec 14             	sub    $0x14,%esp
  80148a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80148d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801490:	50                   	push   %eax
  801491:	53                   	push   %ebx
  801492:	e8 ac fc ff ff       	call   801143 <fd_lookup>
  801497:	83 c4 08             	add    $0x8,%esp
  80149a:	89 c2                	mov    %eax,%edx
  80149c:	85 c0                	test   %eax,%eax
  80149e:	78 68                	js     801508 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014a0:	83 ec 08             	sub    $0x8,%esp
  8014a3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014a6:	50                   	push   %eax
  8014a7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014aa:	ff 30                	pushl  (%eax)
  8014ac:	e8 e8 fc ff ff       	call   801199 <dev_lookup>
  8014b1:	83 c4 10             	add    $0x10,%esp
  8014b4:	85 c0                	test   %eax,%eax
  8014b6:	78 47                	js     8014ff <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8014b8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014bb:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8014bf:	75 21                	jne    8014e2 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8014c1:	a1 08 40 80 00       	mov    0x804008,%eax
  8014c6:	8b 40 48             	mov    0x48(%eax),%eax
  8014c9:	83 ec 04             	sub    $0x4,%esp
  8014cc:	53                   	push   %ebx
  8014cd:	50                   	push   %eax
  8014ce:	68 35 2a 80 00       	push   $0x802a35
  8014d3:	e8 d9 ec ff ff       	call   8001b1 <cprintf>
		return -E_INVAL;
  8014d8:	83 c4 10             	add    $0x10,%esp
  8014db:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8014e0:	eb 26                	jmp    801508 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8014e2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8014e5:	8b 52 0c             	mov    0xc(%edx),%edx
  8014e8:	85 d2                	test   %edx,%edx
  8014ea:	74 17                	je     801503 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8014ec:	83 ec 04             	sub    $0x4,%esp
  8014ef:	ff 75 10             	pushl  0x10(%ebp)
  8014f2:	ff 75 0c             	pushl  0xc(%ebp)
  8014f5:	50                   	push   %eax
  8014f6:	ff d2                	call   *%edx
  8014f8:	89 c2                	mov    %eax,%edx
  8014fa:	83 c4 10             	add    $0x10,%esp
  8014fd:	eb 09                	jmp    801508 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014ff:	89 c2                	mov    %eax,%edx
  801501:	eb 05                	jmp    801508 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801503:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801508:	89 d0                	mov    %edx,%eax
  80150a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80150d:	c9                   	leave  
  80150e:	c3                   	ret    

0080150f <seek>:

int
seek(int fdnum, off_t offset)
{
  80150f:	55                   	push   %ebp
  801510:	89 e5                	mov    %esp,%ebp
  801512:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801515:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801518:	50                   	push   %eax
  801519:	ff 75 08             	pushl  0x8(%ebp)
  80151c:	e8 22 fc ff ff       	call   801143 <fd_lookup>
  801521:	83 c4 08             	add    $0x8,%esp
  801524:	85 c0                	test   %eax,%eax
  801526:	78 0e                	js     801536 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801528:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80152b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80152e:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801531:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801536:	c9                   	leave  
  801537:	c3                   	ret    

00801538 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801538:	55                   	push   %ebp
  801539:	89 e5                	mov    %esp,%ebp
  80153b:	53                   	push   %ebx
  80153c:	83 ec 14             	sub    $0x14,%esp
  80153f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801542:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801545:	50                   	push   %eax
  801546:	53                   	push   %ebx
  801547:	e8 f7 fb ff ff       	call   801143 <fd_lookup>
  80154c:	83 c4 08             	add    $0x8,%esp
  80154f:	89 c2                	mov    %eax,%edx
  801551:	85 c0                	test   %eax,%eax
  801553:	78 65                	js     8015ba <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801555:	83 ec 08             	sub    $0x8,%esp
  801558:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80155b:	50                   	push   %eax
  80155c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80155f:	ff 30                	pushl  (%eax)
  801561:	e8 33 fc ff ff       	call   801199 <dev_lookup>
  801566:	83 c4 10             	add    $0x10,%esp
  801569:	85 c0                	test   %eax,%eax
  80156b:	78 44                	js     8015b1 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80156d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801570:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801574:	75 21                	jne    801597 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801576:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80157b:	8b 40 48             	mov    0x48(%eax),%eax
  80157e:	83 ec 04             	sub    $0x4,%esp
  801581:	53                   	push   %ebx
  801582:	50                   	push   %eax
  801583:	68 f8 29 80 00       	push   $0x8029f8
  801588:	e8 24 ec ff ff       	call   8001b1 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80158d:	83 c4 10             	add    $0x10,%esp
  801590:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801595:	eb 23                	jmp    8015ba <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801597:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80159a:	8b 52 18             	mov    0x18(%edx),%edx
  80159d:	85 d2                	test   %edx,%edx
  80159f:	74 14                	je     8015b5 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8015a1:	83 ec 08             	sub    $0x8,%esp
  8015a4:	ff 75 0c             	pushl  0xc(%ebp)
  8015a7:	50                   	push   %eax
  8015a8:	ff d2                	call   *%edx
  8015aa:	89 c2                	mov    %eax,%edx
  8015ac:	83 c4 10             	add    $0x10,%esp
  8015af:	eb 09                	jmp    8015ba <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015b1:	89 c2                	mov    %eax,%edx
  8015b3:	eb 05                	jmp    8015ba <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8015b5:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8015ba:	89 d0                	mov    %edx,%eax
  8015bc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015bf:	c9                   	leave  
  8015c0:	c3                   	ret    

008015c1 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8015c1:	55                   	push   %ebp
  8015c2:	89 e5                	mov    %esp,%ebp
  8015c4:	53                   	push   %ebx
  8015c5:	83 ec 14             	sub    $0x14,%esp
  8015c8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015cb:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015ce:	50                   	push   %eax
  8015cf:	ff 75 08             	pushl  0x8(%ebp)
  8015d2:	e8 6c fb ff ff       	call   801143 <fd_lookup>
  8015d7:	83 c4 08             	add    $0x8,%esp
  8015da:	89 c2                	mov    %eax,%edx
  8015dc:	85 c0                	test   %eax,%eax
  8015de:	78 58                	js     801638 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015e0:	83 ec 08             	sub    $0x8,%esp
  8015e3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015e6:	50                   	push   %eax
  8015e7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015ea:	ff 30                	pushl  (%eax)
  8015ec:	e8 a8 fb ff ff       	call   801199 <dev_lookup>
  8015f1:	83 c4 10             	add    $0x10,%esp
  8015f4:	85 c0                	test   %eax,%eax
  8015f6:	78 37                	js     80162f <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8015f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015fb:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8015ff:	74 32                	je     801633 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801601:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801604:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80160b:	00 00 00 
	stat->st_isdir = 0;
  80160e:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801615:	00 00 00 
	stat->st_dev = dev;
  801618:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80161e:	83 ec 08             	sub    $0x8,%esp
  801621:	53                   	push   %ebx
  801622:	ff 75 f0             	pushl  -0x10(%ebp)
  801625:	ff 50 14             	call   *0x14(%eax)
  801628:	89 c2                	mov    %eax,%edx
  80162a:	83 c4 10             	add    $0x10,%esp
  80162d:	eb 09                	jmp    801638 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80162f:	89 c2                	mov    %eax,%edx
  801631:	eb 05                	jmp    801638 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801633:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801638:	89 d0                	mov    %edx,%eax
  80163a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80163d:	c9                   	leave  
  80163e:	c3                   	ret    

0080163f <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80163f:	55                   	push   %ebp
  801640:	89 e5                	mov    %esp,%ebp
  801642:	56                   	push   %esi
  801643:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801644:	83 ec 08             	sub    $0x8,%esp
  801647:	6a 00                	push   $0x0
  801649:	ff 75 08             	pushl  0x8(%ebp)
  80164c:	e8 d6 01 00 00       	call   801827 <open>
  801651:	89 c3                	mov    %eax,%ebx
  801653:	83 c4 10             	add    $0x10,%esp
  801656:	85 c0                	test   %eax,%eax
  801658:	78 1b                	js     801675 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80165a:	83 ec 08             	sub    $0x8,%esp
  80165d:	ff 75 0c             	pushl  0xc(%ebp)
  801660:	50                   	push   %eax
  801661:	e8 5b ff ff ff       	call   8015c1 <fstat>
  801666:	89 c6                	mov    %eax,%esi
	close(fd);
  801668:	89 1c 24             	mov    %ebx,(%esp)
  80166b:	e8 fd fb ff ff       	call   80126d <close>
	return r;
  801670:	83 c4 10             	add    $0x10,%esp
  801673:	89 f0                	mov    %esi,%eax
}
  801675:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801678:	5b                   	pop    %ebx
  801679:	5e                   	pop    %esi
  80167a:	5d                   	pop    %ebp
  80167b:	c3                   	ret    

0080167c <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80167c:	55                   	push   %ebp
  80167d:	89 e5                	mov    %esp,%ebp
  80167f:	56                   	push   %esi
  801680:	53                   	push   %ebx
  801681:	89 c6                	mov    %eax,%esi
  801683:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801685:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80168c:	75 12                	jne    8016a0 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80168e:	83 ec 0c             	sub    $0xc,%esp
  801691:	6a 01                	push   $0x1
  801693:	e8 fc f9 ff ff       	call   801094 <ipc_find_env>
  801698:	a3 00 40 80 00       	mov    %eax,0x804000
  80169d:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8016a0:	6a 07                	push   $0x7
  8016a2:	68 00 50 80 00       	push   $0x805000
  8016a7:	56                   	push   %esi
  8016a8:	ff 35 00 40 80 00    	pushl  0x804000
  8016ae:	e8 8d f9 ff ff       	call   801040 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8016b3:	83 c4 0c             	add    $0xc,%esp
  8016b6:	6a 00                	push   $0x0
  8016b8:	53                   	push   %ebx
  8016b9:	6a 00                	push   $0x0
  8016bb:	e8 19 f9 ff ff       	call   800fd9 <ipc_recv>
}
  8016c0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016c3:	5b                   	pop    %ebx
  8016c4:	5e                   	pop    %esi
  8016c5:	5d                   	pop    %ebp
  8016c6:	c3                   	ret    

008016c7 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8016c7:	55                   	push   %ebp
  8016c8:	89 e5                	mov    %esp,%ebp
  8016ca:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8016cd:	8b 45 08             	mov    0x8(%ebp),%eax
  8016d0:	8b 40 0c             	mov    0xc(%eax),%eax
  8016d3:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8016d8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8016db:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8016e0:	ba 00 00 00 00       	mov    $0x0,%edx
  8016e5:	b8 02 00 00 00       	mov    $0x2,%eax
  8016ea:	e8 8d ff ff ff       	call   80167c <fsipc>
}
  8016ef:	c9                   	leave  
  8016f0:	c3                   	ret    

008016f1 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8016f1:	55                   	push   %ebp
  8016f2:	89 e5                	mov    %esp,%ebp
  8016f4:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8016f7:	8b 45 08             	mov    0x8(%ebp),%eax
  8016fa:	8b 40 0c             	mov    0xc(%eax),%eax
  8016fd:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801702:	ba 00 00 00 00       	mov    $0x0,%edx
  801707:	b8 06 00 00 00       	mov    $0x6,%eax
  80170c:	e8 6b ff ff ff       	call   80167c <fsipc>
}
  801711:	c9                   	leave  
  801712:	c3                   	ret    

00801713 <devfile_stat>:

}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801713:	55                   	push   %ebp
  801714:	89 e5                	mov    %esp,%ebp
  801716:	53                   	push   %ebx
  801717:	83 ec 04             	sub    $0x4,%esp
  80171a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80171d:	8b 45 08             	mov    0x8(%ebp),%eax
  801720:	8b 40 0c             	mov    0xc(%eax),%eax
  801723:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801728:	ba 00 00 00 00       	mov    $0x0,%edx
  80172d:	b8 05 00 00 00       	mov    $0x5,%eax
  801732:	e8 45 ff ff ff       	call   80167c <fsipc>
  801737:	85 c0                	test   %eax,%eax
  801739:	78 2c                	js     801767 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80173b:	83 ec 08             	sub    $0x8,%esp
  80173e:	68 00 50 80 00       	push   $0x805000
  801743:	53                   	push   %ebx
  801744:	e8 ed ef ff ff       	call   800736 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801749:	a1 80 50 80 00       	mov    0x805080,%eax
  80174e:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801754:	a1 84 50 80 00       	mov    0x805084,%eax
  801759:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80175f:	83 c4 10             	add    $0x10,%esp
  801762:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801767:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80176a:	c9                   	leave  
  80176b:	c3                   	ret    

0080176c <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  80176c:	55                   	push   %ebp
  80176d:	89 e5                	mov    %esp,%ebp
  80176f:	83 ec 0c             	sub    $0xc,%esp
  801772:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	// panic("devfile_write not implemented");

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801775:	8b 55 08             	mov    0x8(%ebp),%edx
  801778:	8b 52 0c             	mov    0xc(%edx),%edx
  80177b:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  801781:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  801786:	50                   	push   %eax
  801787:	ff 75 0c             	pushl  0xc(%ebp)
  80178a:	68 08 50 80 00       	push   $0x805008
  80178f:	e8 34 f1 ff ff       	call   8008c8 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  801794:	ba 00 00 00 00       	mov    $0x0,%edx
  801799:	b8 04 00 00 00       	mov    $0x4,%eax
  80179e:	e8 d9 fe ff ff       	call   80167c <fsipc>

}
  8017a3:	c9                   	leave  
  8017a4:	c3                   	ret    

008017a5 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8017a5:	55                   	push   %ebp
  8017a6:	89 e5                	mov    %esp,%ebp
  8017a8:	56                   	push   %esi
  8017a9:	53                   	push   %ebx
  8017aa:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8017ad:	8b 45 08             	mov    0x8(%ebp),%eax
  8017b0:	8b 40 0c             	mov    0xc(%eax),%eax
  8017b3:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8017b8:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8017be:	ba 00 00 00 00       	mov    $0x0,%edx
  8017c3:	b8 03 00 00 00       	mov    $0x3,%eax
  8017c8:	e8 af fe ff ff       	call   80167c <fsipc>
  8017cd:	89 c3                	mov    %eax,%ebx
  8017cf:	85 c0                	test   %eax,%eax
  8017d1:	78 4b                	js     80181e <devfile_read+0x79>
		return r;
	assert(r <= n);
  8017d3:	39 c6                	cmp    %eax,%esi
  8017d5:	73 16                	jae    8017ed <devfile_read+0x48>
  8017d7:	68 68 2a 80 00       	push   $0x802a68
  8017dc:	68 6f 2a 80 00       	push   $0x802a6f
  8017e1:	6a 7c                	push   $0x7c
  8017e3:	68 84 2a 80 00       	push   $0x802a84
  8017e8:	e8 24 0a 00 00       	call   802211 <_panic>
	assert(r <= PGSIZE);
  8017ed:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8017f2:	7e 16                	jle    80180a <devfile_read+0x65>
  8017f4:	68 8f 2a 80 00       	push   $0x802a8f
  8017f9:	68 6f 2a 80 00       	push   $0x802a6f
  8017fe:	6a 7d                	push   $0x7d
  801800:	68 84 2a 80 00       	push   $0x802a84
  801805:	e8 07 0a 00 00       	call   802211 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80180a:	83 ec 04             	sub    $0x4,%esp
  80180d:	50                   	push   %eax
  80180e:	68 00 50 80 00       	push   $0x805000
  801813:	ff 75 0c             	pushl  0xc(%ebp)
  801816:	e8 ad f0 ff ff       	call   8008c8 <memmove>
	return r;
  80181b:	83 c4 10             	add    $0x10,%esp
}
  80181e:	89 d8                	mov    %ebx,%eax
  801820:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801823:	5b                   	pop    %ebx
  801824:	5e                   	pop    %esi
  801825:	5d                   	pop    %ebp
  801826:	c3                   	ret    

00801827 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801827:	55                   	push   %ebp
  801828:	89 e5                	mov    %esp,%ebp
  80182a:	53                   	push   %ebx
  80182b:	83 ec 20             	sub    $0x20,%esp
  80182e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801831:	53                   	push   %ebx
  801832:	e8 c6 ee ff ff       	call   8006fd <strlen>
  801837:	83 c4 10             	add    $0x10,%esp
  80183a:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80183f:	7f 67                	jg     8018a8 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801841:	83 ec 0c             	sub    $0xc,%esp
  801844:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801847:	50                   	push   %eax
  801848:	e8 a7 f8 ff ff       	call   8010f4 <fd_alloc>
  80184d:	83 c4 10             	add    $0x10,%esp
		return r;
  801850:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801852:	85 c0                	test   %eax,%eax
  801854:	78 57                	js     8018ad <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801856:	83 ec 08             	sub    $0x8,%esp
  801859:	53                   	push   %ebx
  80185a:	68 00 50 80 00       	push   $0x805000
  80185f:	e8 d2 ee ff ff       	call   800736 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801864:	8b 45 0c             	mov    0xc(%ebp),%eax
  801867:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80186c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80186f:	b8 01 00 00 00       	mov    $0x1,%eax
  801874:	e8 03 fe ff ff       	call   80167c <fsipc>
  801879:	89 c3                	mov    %eax,%ebx
  80187b:	83 c4 10             	add    $0x10,%esp
  80187e:	85 c0                	test   %eax,%eax
  801880:	79 14                	jns    801896 <open+0x6f>
		fd_close(fd, 0);
  801882:	83 ec 08             	sub    $0x8,%esp
  801885:	6a 00                	push   $0x0
  801887:	ff 75 f4             	pushl  -0xc(%ebp)
  80188a:	e8 5d f9 ff ff       	call   8011ec <fd_close>
		return r;
  80188f:	83 c4 10             	add    $0x10,%esp
  801892:	89 da                	mov    %ebx,%edx
  801894:	eb 17                	jmp    8018ad <open+0x86>
	}

	return fd2num(fd);
  801896:	83 ec 0c             	sub    $0xc,%esp
  801899:	ff 75 f4             	pushl  -0xc(%ebp)
  80189c:	e8 2c f8 ff ff       	call   8010cd <fd2num>
  8018a1:	89 c2                	mov    %eax,%edx
  8018a3:	83 c4 10             	add    $0x10,%esp
  8018a6:	eb 05                	jmp    8018ad <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8018a8:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8018ad:	89 d0                	mov    %edx,%eax
  8018af:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018b2:	c9                   	leave  
  8018b3:	c3                   	ret    

008018b4 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8018b4:	55                   	push   %ebp
  8018b5:	89 e5                	mov    %esp,%ebp
  8018b7:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8018ba:	ba 00 00 00 00       	mov    $0x0,%edx
  8018bf:	b8 08 00 00 00       	mov    $0x8,%eax
  8018c4:	e8 b3 fd ff ff       	call   80167c <fsipc>
}
  8018c9:	c9                   	leave  
  8018ca:	c3                   	ret    

008018cb <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  8018cb:	55                   	push   %ebp
  8018cc:	89 e5                	mov    %esp,%ebp
  8018ce:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  8018d1:	68 9b 2a 80 00       	push   $0x802a9b
  8018d6:	ff 75 0c             	pushl  0xc(%ebp)
  8018d9:	e8 58 ee ff ff       	call   800736 <strcpy>
	return 0;
}
  8018de:	b8 00 00 00 00       	mov    $0x0,%eax
  8018e3:	c9                   	leave  
  8018e4:	c3                   	ret    

008018e5 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  8018e5:	55                   	push   %ebp
  8018e6:	89 e5                	mov    %esp,%ebp
  8018e8:	53                   	push   %ebx
  8018e9:	83 ec 10             	sub    $0x10,%esp
  8018ec:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  8018ef:	53                   	push   %ebx
  8018f0:	e8 cd 09 00 00       	call   8022c2 <pageref>
  8018f5:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  8018f8:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  8018fd:	83 f8 01             	cmp    $0x1,%eax
  801900:	75 10                	jne    801912 <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  801902:	83 ec 0c             	sub    $0xc,%esp
  801905:	ff 73 0c             	pushl  0xc(%ebx)
  801908:	e8 c0 02 00 00       	call   801bcd <nsipc_close>
  80190d:	89 c2                	mov    %eax,%edx
  80190f:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  801912:	89 d0                	mov    %edx,%eax
  801914:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801917:	c9                   	leave  
  801918:	c3                   	ret    

00801919 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801919:	55                   	push   %ebp
  80191a:	89 e5                	mov    %esp,%ebp
  80191c:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  80191f:	6a 00                	push   $0x0
  801921:	ff 75 10             	pushl  0x10(%ebp)
  801924:	ff 75 0c             	pushl  0xc(%ebp)
  801927:	8b 45 08             	mov    0x8(%ebp),%eax
  80192a:	ff 70 0c             	pushl  0xc(%eax)
  80192d:	e8 78 03 00 00       	call   801caa <nsipc_send>
}
  801932:	c9                   	leave  
  801933:	c3                   	ret    

00801934 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801934:	55                   	push   %ebp
  801935:	89 e5                	mov    %esp,%ebp
  801937:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  80193a:	6a 00                	push   $0x0
  80193c:	ff 75 10             	pushl  0x10(%ebp)
  80193f:	ff 75 0c             	pushl  0xc(%ebp)
  801942:	8b 45 08             	mov    0x8(%ebp),%eax
  801945:	ff 70 0c             	pushl  0xc(%eax)
  801948:	e8 f1 02 00 00       	call   801c3e <nsipc_recv>
}
  80194d:	c9                   	leave  
  80194e:	c3                   	ret    

0080194f <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  80194f:	55                   	push   %ebp
  801950:	89 e5                	mov    %esp,%ebp
  801952:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801955:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801958:	52                   	push   %edx
  801959:	50                   	push   %eax
  80195a:	e8 e4 f7 ff ff       	call   801143 <fd_lookup>
  80195f:	83 c4 10             	add    $0x10,%esp
  801962:	85 c0                	test   %eax,%eax
  801964:	78 17                	js     80197d <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801966:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801969:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  80196f:	39 08                	cmp    %ecx,(%eax)
  801971:	75 05                	jne    801978 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801973:	8b 40 0c             	mov    0xc(%eax),%eax
  801976:	eb 05                	jmp    80197d <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801978:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  80197d:	c9                   	leave  
  80197e:	c3                   	ret    

0080197f <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  80197f:	55                   	push   %ebp
  801980:	89 e5                	mov    %esp,%ebp
  801982:	56                   	push   %esi
  801983:	53                   	push   %ebx
  801984:	83 ec 1c             	sub    $0x1c,%esp
  801987:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801989:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80198c:	50                   	push   %eax
  80198d:	e8 62 f7 ff ff       	call   8010f4 <fd_alloc>
  801992:	89 c3                	mov    %eax,%ebx
  801994:	83 c4 10             	add    $0x10,%esp
  801997:	85 c0                	test   %eax,%eax
  801999:	78 1b                	js     8019b6 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  80199b:	83 ec 04             	sub    $0x4,%esp
  80199e:	68 07 04 00 00       	push   $0x407
  8019a3:	ff 75 f4             	pushl  -0xc(%ebp)
  8019a6:	6a 00                	push   $0x0
  8019a8:	e8 8c f1 ff ff       	call   800b39 <sys_page_alloc>
  8019ad:	89 c3                	mov    %eax,%ebx
  8019af:	83 c4 10             	add    $0x10,%esp
  8019b2:	85 c0                	test   %eax,%eax
  8019b4:	79 10                	jns    8019c6 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  8019b6:	83 ec 0c             	sub    $0xc,%esp
  8019b9:	56                   	push   %esi
  8019ba:	e8 0e 02 00 00       	call   801bcd <nsipc_close>
		return r;
  8019bf:	83 c4 10             	add    $0x10,%esp
  8019c2:	89 d8                	mov    %ebx,%eax
  8019c4:	eb 24                	jmp    8019ea <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  8019c6:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8019cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019cf:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  8019d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019d4:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  8019db:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  8019de:	83 ec 0c             	sub    $0xc,%esp
  8019e1:	50                   	push   %eax
  8019e2:	e8 e6 f6 ff ff       	call   8010cd <fd2num>
  8019e7:	83 c4 10             	add    $0x10,%esp
}
  8019ea:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019ed:	5b                   	pop    %ebx
  8019ee:	5e                   	pop    %esi
  8019ef:	5d                   	pop    %ebp
  8019f0:	c3                   	ret    

008019f1 <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  8019f1:	55                   	push   %ebp
  8019f2:	89 e5                	mov    %esp,%ebp
  8019f4:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8019f7:	8b 45 08             	mov    0x8(%ebp),%eax
  8019fa:	e8 50 ff ff ff       	call   80194f <fd2sockid>
		return r;
  8019ff:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  801a01:	85 c0                	test   %eax,%eax
  801a03:	78 1f                	js     801a24 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801a05:	83 ec 04             	sub    $0x4,%esp
  801a08:	ff 75 10             	pushl  0x10(%ebp)
  801a0b:	ff 75 0c             	pushl  0xc(%ebp)
  801a0e:	50                   	push   %eax
  801a0f:	e8 12 01 00 00       	call   801b26 <nsipc_accept>
  801a14:	83 c4 10             	add    $0x10,%esp
		return r;
  801a17:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801a19:	85 c0                	test   %eax,%eax
  801a1b:	78 07                	js     801a24 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  801a1d:	e8 5d ff ff ff       	call   80197f <alloc_sockfd>
  801a22:	89 c1                	mov    %eax,%ecx
}
  801a24:	89 c8                	mov    %ecx,%eax
  801a26:	c9                   	leave  
  801a27:	c3                   	ret    

00801a28 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801a28:	55                   	push   %ebp
  801a29:	89 e5                	mov    %esp,%ebp
  801a2b:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801a2e:	8b 45 08             	mov    0x8(%ebp),%eax
  801a31:	e8 19 ff ff ff       	call   80194f <fd2sockid>
  801a36:	85 c0                	test   %eax,%eax
  801a38:	78 12                	js     801a4c <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  801a3a:	83 ec 04             	sub    $0x4,%esp
  801a3d:	ff 75 10             	pushl  0x10(%ebp)
  801a40:	ff 75 0c             	pushl  0xc(%ebp)
  801a43:	50                   	push   %eax
  801a44:	e8 2d 01 00 00       	call   801b76 <nsipc_bind>
  801a49:	83 c4 10             	add    $0x10,%esp
}
  801a4c:	c9                   	leave  
  801a4d:	c3                   	ret    

00801a4e <shutdown>:

int
shutdown(int s, int how)
{
  801a4e:	55                   	push   %ebp
  801a4f:	89 e5                	mov    %esp,%ebp
  801a51:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801a54:	8b 45 08             	mov    0x8(%ebp),%eax
  801a57:	e8 f3 fe ff ff       	call   80194f <fd2sockid>
  801a5c:	85 c0                	test   %eax,%eax
  801a5e:	78 0f                	js     801a6f <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801a60:	83 ec 08             	sub    $0x8,%esp
  801a63:	ff 75 0c             	pushl  0xc(%ebp)
  801a66:	50                   	push   %eax
  801a67:	e8 3f 01 00 00       	call   801bab <nsipc_shutdown>
  801a6c:	83 c4 10             	add    $0x10,%esp
}
  801a6f:	c9                   	leave  
  801a70:	c3                   	ret    

00801a71 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801a71:	55                   	push   %ebp
  801a72:	89 e5                	mov    %esp,%ebp
  801a74:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801a77:	8b 45 08             	mov    0x8(%ebp),%eax
  801a7a:	e8 d0 fe ff ff       	call   80194f <fd2sockid>
  801a7f:	85 c0                	test   %eax,%eax
  801a81:	78 12                	js     801a95 <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  801a83:	83 ec 04             	sub    $0x4,%esp
  801a86:	ff 75 10             	pushl  0x10(%ebp)
  801a89:	ff 75 0c             	pushl  0xc(%ebp)
  801a8c:	50                   	push   %eax
  801a8d:	e8 55 01 00 00       	call   801be7 <nsipc_connect>
  801a92:	83 c4 10             	add    $0x10,%esp
}
  801a95:	c9                   	leave  
  801a96:	c3                   	ret    

00801a97 <listen>:

int
listen(int s, int backlog)
{
  801a97:	55                   	push   %ebp
  801a98:	89 e5                	mov    %esp,%ebp
  801a9a:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801a9d:	8b 45 08             	mov    0x8(%ebp),%eax
  801aa0:	e8 aa fe ff ff       	call   80194f <fd2sockid>
  801aa5:	85 c0                	test   %eax,%eax
  801aa7:	78 0f                	js     801ab8 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801aa9:	83 ec 08             	sub    $0x8,%esp
  801aac:	ff 75 0c             	pushl  0xc(%ebp)
  801aaf:	50                   	push   %eax
  801ab0:	e8 67 01 00 00       	call   801c1c <nsipc_listen>
  801ab5:	83 c4 10             	add    $0x10,%esp
}
  801ab8:	c9                   	leave  
  801ab9:	c3                   	ret    

00801aba <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801aba:	55                   	push   %ebp
  801abb:	89 e5                	mov    %esp,%ebp
  801abd:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801ac0:	ff 75 10             	pushl  0x10(%ebp)
  801ac3:	ff 75 0c             	pushl  0xc(%ebp)
  801ac6:	ff 75 08             	pushl  0x8(%ebp)
  801ac9:	e8 3a 02 00 00       	call   801d08 <nsipc_socket>
  801ace:	83 c4 10             	add    $0x10,%esp
  801ad1:	85 c0                	test   %eax,%eax
  801ad3:	78 05                	js     801ada <socket+0x20>
		return r;
	return alloc_sockfd(r);
  801ad5:	e8 a5 fe ff ff       	call   80197f <alloc_sockfd>
}
  801ada:	c9                   	leave  
  801adb:	c3                   	ret    

00801adc <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801adc:	55                   	push   %ebp
  801add:	89 e5                	mov    %esp,%ebp
  801adf:	53                   	push   %ebx
  801ae0:	83 ec 04             	sub    $0x4,%esp
  801ae3:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801ae5:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801aec:	75 12                	jne    801b00 <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801aee:	83 ec 0c             	sub    $0xc,%esp
  801af1:	6a 02                	push   $0x2
  801af3:	e8 9c f5 ff ff       	call   801094 <ipc_find_env>
  801af8:	a3 04 40 80 00       	mov    %eax,0x804004
  801afd:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801b00:	6a 07                	push   $0x7
  801b02:	68 00 60 80 00       	push   $0x806000
  801b07:	53                   	push   %ebx
  801b08:	ff 35 04 40 80 00    	pushl  0x804004
  801b0e:	e8 2d f5 ff ff       	call   801040 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801b13:	83 c4 0c             	add    $0xc,%esp
  801b16:	6a 00                	push   $0x0
  801b18:	6a 00                	push   $0x0
  801b1a:	6a 00                	push   $0x0
  801b1c:	e8 b8 f4 ff ff       	call   800fd9 <ipc_recv>
}
  801b21:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b24:	c9                   	leave  
  801b25:	c3                   	ret    

00801b26 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801b26:	55                   	push   %ebp
  801b27:	89 e5                	mov    %esp,%ebp
  801b29:	56                   	push   %esi
  801b2a:	53                   	push   %ebx
  801b2b:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801b2e:	8b 45 08             	mov    0x8(%ebp),%eax
  801b31:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801b36:	8b 06                	mov    (%esi),%eax
  801b38:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801b3d:	b8 01 00 00 00       	mov    $0x1,%eax
  801b42:	e8 95 ff ff ff       	call   801adc <nsipc>
  801b47:	89 c3                	mov    %eax,%ebx
  801b49:	85 c0                	test   %eax,%eax
  801b4b:	78 20                	js     801b6d <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801b4d:	83 ec 04             	sub    $0x4,%esp
  801b50:	ff 35 10 60 80 00    	pushl  0x806010
  801b56:	68 00 60 80 00       	push   $0x806000
  801b5b:	ff 75 0c             	pushl  0xc(%ebp)
  801b5e:	e8 65 ed ff ff       	call   8008c8 <memmove>
		*addrlen = ret->ret_addrlen;
  801b63:	a1 10 60 80 00       	mov    0x806010,%eax
  801b68:	89 06                	mov    %eax,(%esi)
  801b6a:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  801b6d:	89 d8                	mov    %ebx,%eax
  801b6f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b72:	5b                   	pop    %ebx
  801b73:	5e                   	pop    %esi
  801b74:	5d                   	pop    %ebp
  801b75:	c3                   	ret    

00801b76 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801b76:	55                   	push   %ebp
  801b77:	89 e5                	mov    %esp,%ebp
  801b79:	53                   	push   %ebx
  801b7a:	83 ec 08             	sub    $0x8,%esp
  801b7d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801b80:	8b 45 08             	mov    0x8(%ebp),%eax
  801b83:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801b88:	53                   	push   %ebx
  801b89:	ff 75 0c             	pushl  0xc(%ebp)
  801b8c:	68 04 60 80 00       	push   $0x806004
  801b91:	e8 32 ed ff ff       	call   8008c8 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801b96:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801b9c:	b8 02 00 00 00       	mov    $0x2,%eax
  801ba1:	e8 36 ff ff ff       	call   801adc <nsipc>
}
  801ba6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ba9:	c9                   	leave  
  801baa:	c3                   	ret    

00801bab <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801bab:	55                   	push   %ebp
  801bac:	89 e5                	mov    %esp,%ebp
  801bae:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801bb1:	8b 45 08             	mov    0x8(%ebp),%eax
  801bb4:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801bb9:	8b 45 0c             	mov    0xc(%ebp),%eax
  801bbc:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801bc1:	b8 03 00 00 00       	mov    $0x3,%eax
  801bc6:	e8 11 ff ff ff       	call   801adc <nsipc>
}
  801bcb:	c9                   	leave  
  801bcc:	c3                   	ret    

00801bcd <nsipc_close>:

int
nsipc_close(int s)
{
  801bcd:	55                   	push   %ebp
  801bce:	89 e5                	mov    %esp,%ebp
  801bd0:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801bd3:	8b 45 08             	mov    0x8(%ebp),%eax
  801bd6:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801bdb:	b8 04 00 00 00       	mov    $0x4,%eax
  801be0:	e8 f7 fe ff ff       	call   801adc <nsipc>
}
  801be5:	c9                   	leave  
  801be6:	c3                   	ret    

00801be7 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801be7:	55                   	push   %ebp
  801be8:	89 e5                	mov    %esp,%ebp
  801bea:	53                   	push   %ebx
  801beb:	83 ec 08             	sub    $0x8,%esp
  801bee:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801bf1:	8b 45 08             	mov    0x8(%ebp),%eax
  801bf4:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801bf9:	53                   	push   %ebx
  801bfa:	ff 75 0c             	pushl  0xc(%ebp)
  801bfd:	68 04 60 80 00       	push   $0x806004
  801c02:	e8 c1 ec ff ff       	call   8008c8 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801c07:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801c0d:	b8 05 00 00 00       	mov    $0x5,%eax
  801c12:	e8 c5 fe ff ff       	call   801adc <nsipc>
}
  801c17:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c1a:	c9                   	leave  
  801c1b:	c3                   	ret    

00801c1c <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801c1c:	55                   	push   %ebp
  801c1d:	89 e5                	mov    %esp,%ebp
  801c1f:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801c22:	8b 45 08             	mov    0x8(%ebp),%eax
  801c25:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801c2a:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c2d:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801c32:	b8 06 00 00 00       	mov    $0x6,%eax
  801c37:	e8 a0 fe ff ff       	call   801adc <nsipc>
}
  801c3c:	c9                   	leave  
  801c3d:	c3                   	ret    

00801c3e <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801c3e:	55                   	push   %ebp
  801c3f:	89 e5                	mov    %esp,%ebp
  801c41:	56                   	push   %esi
  801c42:	53                   	push   %ebx
  801c43:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801c46:	8b 45 08             	mov    0x8(%ebp),%eax
  801c49:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801c4e:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801c54:	8b 45 14             	mov    0x14(%ebp),%eax
  801c57:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801c5c:	b8 07 00 00 00       	mov    $0x7,%eax
  801c61:	e8 76 fe ff ff       	call   801adc <nsipc>
  801c66:	89 c3                	mov    %eax,%ebx
  801c68:	85 c0                	test   %eax,%eax
  801c6a:	78 35                	js     801ca1 <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  801c6c:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801c71:	7f 04                	jg     801c77 <nsipc_recv+0x39>
  801c73:	39 c6                	cmp    %eax,%esi
  801c75:	7d 16                	jge    801c8d <nsipc_recv+0x4f>
  801c77:	68 a7 2a 80 00       	push   $0x802aa7
  801c7c:	68 6f 2a 80 00       	push   $0x802a6f
  801c81:	6a 62                	push   $0x62
  801c83:	68 bc 2a 80 00       	push   $0x802abc
  801c88:	e8 84 05 00 00       	call   802211 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801c8d:	83 ec 04             	sub    $0x4,%esp
  801c90:	50                   	push   %eax
  801c91:	68 00 60 80 00       	push   $0x806000
  801c96:	ff 75 0c             	pushl  0xc(%ebp)
  801c99:	e8 2a ec ff ff       	call   8008c8 <memmove>
  801c9e:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801ca1:	89 d8                	mov    %ebx,%eax
  801ca3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ca6:	5b                   	pop    %ebx
  801ca7:	5e                   	pop    %esi
  801ca8:	5d                   	pop    %ebp
  801ca9:	c3                   	ret    

00801caa <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801caa:	55                   	push   %ebp
  801cab:	89 e5                	mov    %esp,%ebp
  801cad:	53                   	push   %ebx
  801cae:	83 ec 04             	sub    $0x4,%esp
  801cb1:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801cb4:	8b 45 08             	mov    0x8(%ebp),%eax
  801cb7:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801cbc:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801cc2:	7e 16                	jle    801cda <nsipc_send+0x30>
  801cc4:	68 c8 2a 80 00       	push   $0x802ac8
  801cc9:	68 6f 2a 80 00       	push   $0x802a6f
  801cce:	6a 6d                	push   $0x6d
  801cd0:	68 bc 2a 80 00       	push   $0x802abc
  801cd5:	e8 37 05 00 00       	call   802211 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801cda:	83 ec 04             	sub    $0x4,%esp
  801cdd:	53                   	push   %ebx
  801cde:	ff 75 0c             	pushl  0xc(%ebp)
  801ce1:	68 0c 60 80 00       	push   $0x80600c
  801ce6:	e8 dd eb ff ff       	call   8008c8 <memmove>
	nsipcbuf.send.req_size = size;
  801ceb:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801cf1:	8b 45 14             	mov    0x14(%ebp),%eax
  801cf4:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801cf9:	b8 08 00 00 00       	mov    $0x8,%eax
  801cfe:	e8 d9 fd ff ff       	call   801adc <nsipc>
}
  801d03:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801d06:	c9                   	leave  
  801d07:	c3                   	ret    

00801d08 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801d08:	55                   	push   %ebp
  801d09:	89 e5                	mov    %esp,%ebp
  801d0b:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801d0e:	8b 45 08             	mov    0x8(%ebp),%eax
  801d11:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801d16:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d19:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801d1e:	8b 45 10             	mov    0x10(%ebp),%eax
  801d21:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801d26:	b8 09 00 00 00       	mov    $0x9,%eax
  801d2b:	e8 ac fd ff ff       	call   801adc <nsipc>
}
  801d30:	c9                   	leave  
  801d31:	c3                   	ret    

00801d32 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801d32:	55                   	push   %ebp
  801d33:	89 e5                	mov    %esp,%ebp
  801d35:	56                   	push   %esi
  801d36:	53                   	push   %ebx
  801d37:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801d3a:	83 ec 0c             	sub    $0xc,%esp
  801d3d:	ff 75 08             	pushl  0x8(%ebp)
  801d40:	e8 98 f3 ff ff       	call   8010dd <fd2data>
  801d45:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801d47:	83 c4 08             	add    $0x8,%esp
  801d4a:	68 d4 2a 80 00       	push   $0x802ad4
  801d4f:	53                   	push   %ebx
  801d50:	e8 e1 e9 ff ff       	call   800736 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801d55:	8b 46 04             	mov    0x4(%esi),%eax
  801d58:	2b 06                	sub    (%esi),%eax
  801d5a:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801d60:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801d67:	00 00 00 
	stat->st_dev = &devpipe;
  801d6a:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801d71:	30 80 00 
	return 0;
}
  801d74:	b8 00 00 00 00       	mov    $0x0,%eax
  801d79:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d7c:	5b                   	pop    %ebx
  801d7d:	5e                   	pop    %esi
  801d7e:	5d                   	pop    %ebp
  801d7f:	c3                   	ret    

00801d80 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801d80:	55                   	push   %ebp
  801d81:	89 e5                	mov    %esp,%ebp
  801d83:	53                   	push   %ebx
  801d84:	83 ec 0c             	sub    $0xc,%esp
  801d87:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801d8a:	53                   	push   %ebx
  801d8b:	6a 00                	push   $0x0
  801d8d:	e8 2c ee ff ff       	call   800bbe <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801d92:	89 1c 24             	mov    %ebx,(%esp)
  801d95:	e8 43 f3 ff ff       	call   8010dd <fd2data>
  801d9a:	83 c4 08             	add    $0x8,%esp
  801d9d:	50                   	push   %eax
  801d9e:	6a 00                	push   $0x0
  801da0:	e8 19 ee ff ff       	call   800bbe <sys_page_unmap>
}
  801da5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801da8:	c9                   	leave  
  801da9:	c3                   	ret    

00801daa <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801daa:	55                   	push   %ebp
  801dab:	89 e5                	mov    %esp,%ebp
  801dad:	57                   	push   %edi
  801dae:	56                   	push   %esi
  801daf:	53                   	push   %ebx
  801db0:	83 ec 1c             	sub    $0x1c,%esp
  801db3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801db6:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801db8:	a1 08 40 80 00       	mov    0x804008,%eax
  801dbd:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801dc0:	83 ec 0c             	sub    $0xc,%esp
  801dc3:	ff 75 e0             	pushl  -0x20(%ebp)
  801dc6:	e8 f7 04 00 00       	call   8022c2 <pageref>
  801dcb:	89 c3                	mov    %eax,%ebx
  801dcd:	89 3c 24             	mov    %edi,(%esp)
  801dd0:	e8 ed 04 00 00       	call   8022c2 <pageref>
  801dd5:	83 c4 10             	add    $0x10,%esp
  801dd8:	39 c3                	cmp    %eax,%ebx
  801dda:	0f 94 c1             	sete   %cl
  801ddd:	0f b6 c9             	movzbl %cl,%ecx
  801de0:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801de3:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801de9:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801dec:	39 ce                	cmp    %ecx,%esi
  801dee:	74 1b                	je     801e0b <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801df0:	39 c3                	cmp    %eax,%ebx
  801df2:	75 c4                	jne    801db8 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801df4:	8b 42 58             	mov    0x58(%edx),%eax
  801df7:	ff 75 e4             	pushl  -0x1c(%ebp)
  801dfa:	50                   	push   %eax
  801dfb:	56                   	push   %esi
  801dfc:	68 db 2a 80 00       	push   $0x802adb
  801e01:	e8 ab e3 ff ff       	call   8001b1 <cprintf>
  801e06:	83 c4 10             	add    $0x10,%esp
  801e09:	eb ad                	jmp    801db8 <_pipeisclosed+0xe>
	}
}
  801e0b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801e0e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e11:	5b                   	pop    %ebx
  801e12:	5e                   	pop    %esi
  801e13:	5f                   	pop    %edi
  801e14:	5d                   	pop    %ebp
  801e15:	c3                   	ret    

00801e16 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801e16:	55                   	push   %ebp
  801e17:	89 e5                	mov    %esp,%ebp
  801e19:	57                   	push   %edi
  801e1a:	56                   	push   %esi
  801e1b:	53                   	push   %ebx
  801e1c:	83 ec 28             	sub    $0x28,%esp
  801e1f:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801e22:	56                   	push   %esi
  801e23:	e8 b5 f2 ff ff       	call   8010dd <fd2data>
  801e28:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801e2a:	83 c4 10             	add    $0x10,%esp
  801e2d:	bf 00 00 00 00       	mov    $0x0,%edi
  801e32:	eb 4b                	jmp    801e7f <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801e34:	89 da                	mov    %ebx,%edx
  801e36:	89 f0                	mov    %esi,%eax
  801e38:	e8 6d ff ff ff       	call   801daa <_pipeisclosed>
  801e3d:	85 c0                	test   %eax,%eax
  801e3f:	75 48                	jne    801e89 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801e41:	e8 d4 ec ff ff       	call   800b1a <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801e46:	8b 43 04             	mov    0x4(%ebx),%eax
  801e49:	8b 0b                	mov    (%ebx),%ecx
  801e4b:	8d 51 20             	lea    0x20(%ecx),%edx
  801e4e:	39 d0                	cmp    %edx,%eax
  801e50:	73 e2                	jae    801e34 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801e52:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801e55:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801e59:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801e5c:	89 c2                	mov    %eax,%edx
  801e5e:	c1 fa 1f             	sar    $0x1f,%edx
  801e61:	89 d1                	mov    %edx,%ecx
  801e63:	c1 e9 1b             	shr    $0x1b,%ecx
  801e66:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801e69:	83 e2 1f             	and    $0x1f,%edx
  801e6c:	29 ca                	sub    %ecx,%edx
  801e6e:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801e72:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801e76:	83 c0 01             	add    $0x1,%eax
  801e79:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801e7c:	83 c7 01             	add    $0x1,%edi
  801e7f:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801e82:	75 c2                	jne    801e46 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801e84:	8b 45 10             	mov    0x10(%ebp),%eax
  801e87:	eb 05                	jmp    801e8e <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801e89:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801e8e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e91:	5b                   	pop    %ebx
  801e92:	5e                   	pop    %esi
  801e93:	5f                   	pop    %edi
  801e94:	5d                   	pop    %ebp
  801e95:	c3                   	ret    

00801e96 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801e96:	55                   	push   %ebp
  801e97:	89 e5                	mov    %esp,%ebp
  801e99:	57                   	push   %edi
  801e9a:	56                   	push   %esi
  801e9b:	53                   	push   %ebx
  801e9c:	83 ec 18             	sub    $0x18,%esp
  801e9f:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801ea2:	57                   	push   %edi
  801ea3:	e8 35 f2 ff ff       	call   8010dd <fd2data>
  801ea8:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801eaa:	83 c4 10             	add    $0x10,%esp
  801ead:	bb 00 00 00 00       	mov    $0x0,%ebx
  801eb2:	eb 3d                	jmp    801ef1 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801eb4:	85 db                	test   %ebx,%ebx
  801eb6:	74 04                	je     801ebc <devpipe_read+0x26>
				return i;
  801eb8:	89 d8                	mov    %ebx,%eax
  801eba:	eb 44                	jmp    801f00 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801ebc:	89 f2                	mov    %esi,%edx
  801ebe:	89 f8                	mov    %edi,%eax
  801ec0:	e8 e5 fe ff ff       	call   801daa <_pipeisclosed>
  801ec5:	85 c0                	test   %eax,%eax
  801ec7:	75 32                	jne    801efb <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801ec9:	e8 4c ec ff ff       	call   800b1a <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801ece:	8b 06                	mov    (%esi),%eax
  801ed0:	3b 46 04             	cmp    0x4(%esi),%eax
  801ed3:	74 df                	je     801eb4 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801ed5:	99                   	cltd   
  801ed6:	c1 ea 1b             	shr    $0x1b,%edx
  801ed9:	01 d0                	add    %edx,%eax
  801edb:	83 e0 1f             	and    $0x1f,%eax
  801ede:	29 d0                	sub    %edx,%eax
  801ee0:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801ee5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801ee8:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801eeb:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801eee:	83 c3 01             	add    $0x1,%ebx
  801ef1:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801ef4:	75 d8                	jne    801ece <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801ef6:	8b 45 10             	mov    0x10(%ebp),%eax
  801ef9:	eb 05                	jmp    801f00 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801efb:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801f00:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f03:	5b                   	pop    %ebx
  801f04:	5e                   	pop    %esi
  801f05:	5f                   	pop    %edi
  801f06:	5d                   	pop    %ebp
  801f07:	c3                   	ret    

00801f08 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801f08:	55                   	push   %ebp
  801f09:	89 e5                	mov    %esp,%ebp
  801f0b:	56                   	push   %esi
  801f0c:	53                   	push   %ebx
  801f0d:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801f10:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f13:	50                   	push   %eax
  801f14:	e8 db f1 ff ff       	call   8010f4 <fd_alloc>
  801f19:	83 c4 10             	add    $0x10,%esp
  801f1c:	89 c2                	mov    %eax,%edx
  801f1e:	85 c0                	test   %eax,%eax
  801f20:	0f 88 2c 01 00 00    	js     802052 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801f26:	83 ec 04             	sub    $0x4,%esp
  801f29:	68 07 04 00 00       	push   $0x407
  801f2e:	ff 75 f4             	pushl  -0xc(%ebp)
  801f31:	6a 00                	push   $0x0
  801f33:	e8 01 ec ff ff       	call   800b39 <sys_page_alloc>
  801f38:	83 c4 10             	add    $0x10,%esp
  801f3b:	89 c2                	mov    %eax,%edx
  801f3d:	85 c0                	test   %eax,%eax
  801f3f:	0f 88 0d 01 00 00    	js     802052 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801f45:	83 ec 0c             	sub    $0xc,%esp
  801f48:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801f4b:	50                   	push   %eax
  801f4c:	e8 a3 f1 ff ff       	call   8010f4 <fd_alloc>
  801f51:	89 c3                	mov    %eax,%ebx
  801f53:	83 c4 10             	add    $0x10,%esp
  801f56:	85 c0                	test   %eax,%eax
  801f58:	0f 88 e2 00 00 00    	js     802040 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801f5e:	83 ec 04             	sub    $0x4,%esp
  801f61:	68 07 04 00 00       	push   $0x407
  801f66:	ff 75 f0             	pushl  -0x10(%ebp)
  801f69:	6a 00                	push   $0x0
  801f6b:	e8 c9 eb ff ff       	call   800b39 <sys_page_alloc>
  801f70:	89 c3                	mov    %eax,%ebx
  801f72:	83 c4 10             	add    $0x10,%esp
  801f75:	85 c0                	test   %eax,%eax
  801f77:	0f 88 c3 00 00 00    	js     802040 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801f7d:	83 ec 0c             	sub    $0xc,%esp
  801f80:	ff 75 f4             	pushl  -0xc(%ebp)
  801f83:	e8 55 f1 ff ff       	call   8010dd <fd2data>
  801f88:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801f8a:	83 c4 0c             	add    $0xc,%esp
  801f8d:	68 07 04 00 00       	push   $0x407
  801f92:	50                   	push   %eax
  801f93:	6a 00                	push   $0x0
  801f95:	e8 9f eb ff ff       	call   800b39 <sys_page_alloc>
  801f9a:	89 c3                	mov    %eax,%ebx
  801f9c:	83 c4 10             	add    $0x10,%esp
  801f9f:	85 c0                	test   %eax,%eax
  801fa1:	0f 88 89 00 00 00    	js     802030 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801fa7:	83 ec 0c             	sub    $0xc,%esp
  801faa:	ff 75 f0             	pushl  -0x10(%ebp)
  801fad:	e8 2b f1 ff ff       	call   8010dd <fd2data>
  801fb2:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801fb9:	50                   	push   %eax
  801fba:	6a 00                	push   $0x0
  801fbc:	56                   	push   %esi
  801fbd:	6a 00                	push   $0x0
  801fbf:	e8 b8 eb ff ff       	call   800b7c <sys_page_map>
  801fc4:	89 c3                	mov    %eax,%ebx
  801fc6:	83 c4 20             	add    $0x20,%esp
  801fc9:	85 c0                	test   %eax,%eax
  801fcb:	78 55                	js     802022 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801fcd:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801fd3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fd6:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801fd8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fdb:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801fe2:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801fe8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801feb:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801fed:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ff0:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801ff7:	83 ec 0c             	sub    $0xc,%esp
  801ffa:	ff 75 f4             	pushl  -0xc(%ebp)
  801ffd:	e8 cb f0 ff ff       	call   8010cd <fd2num>
  802002:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802005:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  802007:	83 c4 04             	add    $0x4,%esp
  80200a:	ff 75 f0             	pushl  -0x10(%ebp)
  80200d:	e8 bb f0 ff ff       	call   8010cd <fd2num>
  802012:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802015:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  802018:	83 c4 10             	add    $0x10,%esp
  80201b:	ba 00 00 00 00       	mov    $0x0,%edx
  802020:	eb 30                	jmp    802052 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  802022:	83 ec 08             	sub    $0x8,%esp
  802025:	56                   	push   %esi
  802026:	6a 00                	push   $0x0
  802028:	e8 91 eb ff ff       	call   800bbe <sys_page_unmap>
  80202d:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  802030:	83 ec 08             	sub    $0x8,%esp
  802033:	ff 75 f0             	pushl  -0x10(%ebp)
  802036:	6a 00                	push   $0x0
  802038:	e8 81 eb ff ff       	call   800bbe <sys_page_unmap>
  80203d:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  802040:	83 ec 08             	sub    $0x8,%esp
  802043:	ff 75 f4             	pushl  -0xc(%ebp)
  802046:	6a 00                	push   $0x0
  802048:	e8 71 eb ff ff       	call   800bbe <sys_page_unmap>
  80204d:	83 c4 10             	add    $0x10,%esp
  802050:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  802052:	89 d0                	mov    %edx,%eax
  802054:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802057:	5b                   	pop    %ebx
  802058:	5e                   	pop    %esi
  802059:	5d                   	pop    %ebp
  80205a:	c3                   	ret    

0080205b <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  80205b:	55                   	push   %ebp
  80205c:	89 e5                	mov    %esp,%ebp
  80205e:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802061:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802064:	50                   	push   %eax
  802065:	ff 75 08             	pushl  0x8(%ebp)
  802068:	e8 d6 f0 ff ff       	call   801143 <fd_lookup>
  80206d:	83 c4 10             	add    $0x10,%esp
  802070:	85 c0                	test   %eax,%eax
  802072:	78 18                	js     80208c <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  802074:	83 ec 0c             	sub    $0xc,%esp
  802077:	ff 75 f4             	pushl  -0xc(%ebp)
  80207a:	e8 5e f0 ff ff       	call   8010dd <fd2data>
	return _pipeisclosed(fd, p);
  80207f:	89 c2                	mov    %eax,%edx
  802081:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802084:	e8 21 fd ff ff       	call   801daa <_pipeisclosed>
  802089:	83 c4 10             	add    $0x10,%esp
}
  80208c:	c9                   	leave  
  80208d:	c3                   	ret    

0080208e <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  80208e:	55                   	push   %ebp
  80208f:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  802091:	b8 00 00 00 00       	mov    $0x0,%eax
  802096:	5d                   	pop    %ebp
  802097:	c3                   	ret    

00802098 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  802098:	55                   	push   %ebp
  802099:	89 e5                	mov    %esp,%ebp
  80209b:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  80209e:	68 f3 2a 80 00       	push   $0x802af3
  8020a3:	ff 75 0c             	pushl  0xc(%ebp)
  8020a6:	e8 8b e6 ff ff       	call   800736 <strcpy>
	return 0;
}
  8020ab:	b8 00 00 00 00       	mov    $0x0,%eax
  8020b0:	c9                   	leave  
  8020b1:	c3                   	ret    

008020b2 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8020b2:	55                   	push   %ebp
  8020b3:	89 e5                	mov    %esp,%ebp
  8020b5:	57                   	push   %edi
  8020b6:	56                   	push   %esi
  8020b7:	53                   	push   %ebx
  8020b8:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8020be:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8020c3:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8020c9:	eb 2d                	jmp    8020f8 <devcons_write+0x46>
		m = n - tot;
  8020cb:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8020ce:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  8020d0:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8020d3:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8020d8:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8020db:	83 ec 04             	sub    $0x4,%esp
  8020de:	53                   	push   %ebx
  8020df:	03 45 0c             	add    0xc(%ebp),%eax
  8020e2:	50                   	push   %eax
  8020e3:	57                   	push   %edi
  8020e4:	e8 df e7 ff ff       	call   8008c8 <memmove>
		sys_cputs(buf, m);
  8020e9:	83 c4 08             	add    $0x8,%esp
  8020ec:	53                   	push   %ebx
  8020ed:	57                   	push   %edi
  8020ee:	e8 8a e9 ff ff       	call   800a7d <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8020f3:	01 de                	add    %ebx,%esi
  8020f5:	83 c4 10             	add    $0x10,%esp
  8020f8:	89 f0                	mov    %esi,%eax
  8020fa:	3b 75 10             	cmp    0x10(%ebp),%esi
  8020fd:	72 cc                	jb     8020cb <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8020ff:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802102:	5b                   	pop    %ebx
  802103:	5e                   	pop    %esi
  802104:	5f                   	pop    %edi
  802105:	5d                   	pop    %ebp
  802106:	c3                   	ret    

00802107 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  802107:	55                   	push   %ebp
  802108:	89 e5                	mov    %esp,%ebp
  80210a:	83 ec 08             	sub    $0x8,%esp
  80210d:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  802112:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802116:	74 2a                	je     802142 <devcons_read+0x3b>
  802118:	eb 05                	jmp    80211f <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  80211a:	e8 fb e9 ff ff       	call   800b1a <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  80211f:	e8 77 e9 ff ff       	call   800a9b <sys_cgetc>
  802124:	85 c0                	test   %eax,%eax
  802126:	74 f2                	je     80211a <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  802128:	85 c0                	test   %eax,%eax
  80212a:	78 16                	js     802142 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  80212c:	83 f8 04             	cmp    $0x4,%eax
  80212f:	74 0c                	je     80213d <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  802131:	8b 55 0c             	mov    0xc(%ebp),%edx
  802134:	88 02                	mov    %al,(%edx)
	return 1;
  802136:	b8 01 00 00 00       	mov    $0x1,%eax
  80213b:	eb 05                	jmp    802142 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  80213d:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  802142:	c9                   	leave  
  802143:	c3                   	ret    

00802144 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  802144:	55                   	push   %ebp
  802145:	89 e5                	mov    %esp,%ebp
  802147:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  80214a:	8b 45 08             	mov    0x8(%ebp),%eax
  80214d:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  802150:	6a 01                	push   $0x1
  802152:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802155:	50                   	push   %eax
  802156:	e8 22 e9 ff ff       	call   800a7d <sys_cputs>
}
  80215b:	83 c4 10             	add    $0x10,%esp
  80215e:	c9                   	leave  
  80215f:	c3                   	ret    

00802160 <getchar>:

int
getchar(void)
{
  802160:	55                   	push   %ebp
  802161:	89 e5                	mov    %esp,%ebp
  802163:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  802166:	6a 01                	push   $0x1
  802168:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80216b:	50                   	push   %eax
  80216c:	6a 00                	push   $0x0
  80216e:	e8 36 f2 ff ff       	call   8013a9 <read>
	if (r < 0)
  802173:	83 c4 10             	add    $0x10,%esp
  802176:	85 c0                	test   %eax,%eax
  802178:	78 0f                	js     802189 <getchar+0x29>
		return r;
	if (r < 1)
  80217a:	85 c0                	test   %eax,%eax
  80217c:	7e 06                	jle    802184 <getchar+0x24>
		return -E_EOF;
	return c;
  80217e:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  802182:	eb 05                	jmp    802189 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  802184:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  802189:	c9                   	leave  
  80218a:	c3                   	ret    

0080218b <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  80218b:	55                   	push   %ebp
  80218c:	89 e5                	mov    %esp,%ebp
  80218e:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802191:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802194:	50                   	push   %eax
  802195:	ff 75 08             	pushl  0x8(%ebp)
  802198:	e8 a6 ef ff ff       	call   801143 <fd_lookup>
  80219d:	83 c4 10             	add    $0x10,%esp
  8021a0:	85 c0                	test   %eax,%eax
  8021a2:	78 11                	js     8021b5 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8021a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021a7:	8b 15 58 30 80 00    	mov    0x803058,%edx
  8021ad:	39 10                	cmp    %edx,(%eax)
  8021af:	0f 94 c0             	sete   %al
  8021b2:	0f b6 c0             	movzbl %al,%eax
}
  8021b5:	c9                   	leave  
  8021b6:	c3                   	ret    

008021b7 <opencons>:

int
opencons(void)
{
  8021b7:	55                   	push   %ebp
  8021b8:	89 e5                	mov    %esp,%ebp
  8021ba:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8021bd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8021c0:	50                   	push   %eax
  8021c1:	e8 2e ef ff ff       	call   8010f4 <fd_alloc>
  8021c6:	83 c4 10             	add    $0x10,%esp
		return r;
  8021c9:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8021cb:	85 c0                	test   %eax,%eax
  8021cd:	78 3e                	js     80220d <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8021cf:	83 ec 04             	sub    $0x4,%esp
  8021d2:	68 07 04 00 00       	push   $0x407
  8021d7:	ff 75 f4             	pushl  -0xc(%ebp)
  8021da:	6a 00                	push   $0x0
  8021dc:	e8 58 e9 ff ff       	call   800b39 <sys_page_alloc>
  8021e1:	83 c4 10             	add    $0x10,%esp
		return r;
  8021e4:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8021e6:	85 c0                	test   %eax,%eax
  8021e8:	78 23                	js     80220d <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8021ea:	8b 15 58 30 80 00    	mov    0x803058,%edx
  8021f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021f3:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8021f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021f8:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8021ff:	83 ec 0c             	sub    $0xc,%esp
  802202:	50                   	push   %eax
  802203:	e8 c5 ee ff ff       	call   8010cd <fd2num>
  802208:	89 c2                	mov    %eax,%edx
  80220a:	83 c4 10             	add    $0x10,%esp
}
  80220d:	89 d0                	mov    %edx,%eax
  80220f:	c9                   	leave  
  802210:	c3                   	ret    

00802211 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  802211:	55                   	push   %ebp
  802212:	89 e5                	mov    %esp,%ebp
  802214:	56                   	push   %esi
  802215:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  802216:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  802219:	8b 35 00 30 80 00    	mov    0x803000,%esi
  80221f:	e8 d7 e8 ff ff       	call   800afb <sys_getenvid>
  802224:	83 ec 0c             	sub    $0xc,%esp
  802227:	ff 75 0c             	pushl  0xc(%ebp)
  80222a:	ff 75 08             	pushl  0x8(%ebp)
  80222d:	56                   	push   %esi
  80222e:	50                   	push   %eax
  80222f:	68 00 2b 80 00       	push   $0x802b00
  802234:	e8 78 df ff ff       	call   8001b1 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  802239:	83 c4 18             	add    $0x18,%esp
  80223c:	53                   	push   %ebx
  80223d:	ff 75 10             	pushl  0x10(%ebp)
  802240:	e8 1b df ff ff       	call   800160 <vcprintf>
	cprintf("\n");
  802245:	c7 04 24 ec 2a 80 00 	movl   $0x802aec,(%esp)
  80224c:	e8 60 df ff ff       	call   8001b1 <cprintf>
  802251:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  802254:	cc                   	int3   
  802255:	eb fd                	jmp    802254 <_panic+0x43>

00802257 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802257:	55                   	push   %ebp
  802258:	89 e5                	mov    %esp,%ebp
  80225a:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  80225d:	83 3d 00 70 80 00 00 	cmpl   $0x0,0x807000
  802264:	75 2e                	jne    802294 <set_pgfault_handler+0x3d>
		// First time through!
		// LAB 4: Your code here.
		// panic("set_pgfault_handler not implemented");

		sys_page_alloc(sys_getenvid(), (void *) (UXSTACKTOP - PGSIZE), PTE_SYSCALL);
  802266:	e8 90 e8 ff ff       	call   800afb <sys_getenvid>
  80226b:	83 ec 04             	sub    $0x4,%esp
  80226e:	68 07 0e 00 00       	push   $0xe07
  802273:	68 00 f0 bf ee       	push   $0xeebff000
  802278:	50                   	push   %eax
  802279:	e8 bb e8 ff ff       	call   800b39 <sys_page_alloc>
		sys_env_set_pgfault_upcall(sys_getenvid(), _pgfault_upcall);
  80227e:	e8 78 e8 ff ff       	call   800afb <sys_getenvid>
  802283:	83 c4 08             	add    $0x8,%esp
  802286:	68 9e 22 80 00       	push   $0x80229e
  80228b:	50                   	push   %eax
  80228c:	e8 f3 e9 ff ff       	call   800c84 <sys_env_set_pgfault_upcall>
  802291:	83 c4 10             	add    $0x10,%esp
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802294:	8b 45 08             	mov    0x8(%ebp),%eax
  802297:	a3 00 70 80 00       	mov    %eax,0x807000
}
  80229c:	c9                   	leave  
  80229d:	c3                   	ret    

0080229e <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  80229e:	54                   	push   %esp
	movl _pgfault_handler, %eax
  80229f:	a1 00 70 80 00       	mov    0x807000,%eax
	call *%eax
  8022a4:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8022a6:	83 c4 04             	add    $0x4,%esp
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.

	movl 48(%esp), %eax		// trap-time esp
  8022a9:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl 40(%esp), %ebx		// trap-time eip
  8022ad:	8b 5c 24 28          	mov    0x28(%esp),%ebx

	// load eip into esp-4
	// in order to return to trap-time eip later, in the meantime not changing trap-time esp
	movl %ebx, -4(%eax)	
  8022b1:	89 58 fc             	mov    %ebx,-0x4(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.

	addl $8, %esp 			// esp now points to trap-time registers
  8022b4:	83 c4 08             	add    $0x8,%esp
	popal					// pop to all registers
  8022b7:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

	addl $4, %esp			// esp now points to trap-time eflags
  8022b8:	83 c4 04             	add    $0x4,%esp
	popfl					// pop to eflags
  8022bb:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.

	popl %esp				// pop to esp
  8022bc:	5c                   	pop    %esp
	// subl $4, %esp		// arithmetic operation will change eflags!!!
	lea -4(%esp), %esp		// subl $4, %esp
  8022bd:	8d 64 24 fc          	lea    -0x4(%esp),%esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.

	ret
  8022c1:	c3                   	ret    

008022c2 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8022c2:	55                   	push   %ebp
  8022c3:	89 e5                	mov    %esp,%ebp
  8022c5:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8022c8:	89 d0                	mov    %edx,%eax
  8022ca:	c1 e8 16             	shr    $0x16,%eax
  8022cd:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8022d4:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8022d9:	f6 c1 01             	test   $0x1,%cl
  8022dc:	74 1d                	je     8022fb <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  8022de:	c1 ea 0c             	shr    $0xc,%edx
  8022e1:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  8022e8:	f6 c2 01             	test   $0x1,%dl
  8022eb:	74 0e                	je     8022fb <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8022ed:	c1 ea 0c             	shr    $0xc,%edx
  8022f0:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8022f7:	ef 
  8022f8:	0f b7 c0             	movzwl %ax,%eax
}
  8022fb:	5d                   	pop    %ebp
  8022fc:	c3                   	ret    
  8022fd:	66 90                	xchg   %ax,%ax
  8022ff:	90                   	nop

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
