
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
  800054:	68 c0 20 80 00       	push   $0x8020c0
  800059:	e8 53 01 00 00       	call   8001b1 <cprintf>
		ipc_send(who, 0, 0, 0);
  80005e:	6a 00                	push   $0x0
  800060:	6a 00                	push   $0x0
  800062:	6a 00                	push   $0x0
  800064:	ff 75 e4             	pushl  -0x1c(%ebp)
  800067:	e8 7f 0f 00 00       	call   800feb <ipc_send>
  80006c:	83 c4 20             	add    $0x20,%esp
	}

	while (1) {
		uint32_t i = ipc_recv(&who, 0, 0);
  80006f:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  800072:	83 ec 04             	sub    $0x4,%esp
  800075:	6a 00                	push   $0x0
  800077:	6a 00                	push   $0x0
  800079:	56                   	push   %esi
  80007a:	e8 05 0f 00 00       	call   800f84 <ipc_recv>
  80007f:	89 c3                	mov    %eax,%ebx
		cprintf("%x got %d from %x\n", sys_getenvid(), i, who);
  800081:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800084:	e8 72 0a 00 00       	call   800afb <sys_getenvid>
  800089:	57                   	push   %edi
  80008a:	53                   	push   %ebx
  80008b:	50                   	push   %eax
  80008c:	68 d6 20 80 00       	push   $0x8020d6
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
  8000a9:	e8 3d 0f 00 00       	call   800feb <ipc_send>
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
  80010a:	e8 34 11 00 00       	call   801243 <close_all>
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
  800214:	e8 17 1c 00 00       	call   801e30 <__udivdi3>
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
  800257:	e8 04 1d 00 00       	call   801f60 <__umoddi3>
  80025c:	83 c4 14             	add    $0x14,%esp
  80025f:	0f be 80 f3 20 80 00 	movsbl 0x8020f3(%eax),%eax
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
  80035b:	ff 24 85 40 22 80 00 	jmp    *0x802240(,%eax,4)
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
  80041f:	8b 14 85 a0 23 80 00 	mov    0x8023a0(,%eax,4),%edx
  800426:	85 d2                	test   %edx,%edx
  800428:	75 18                	jne    800442 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80042a:	50                   	push   %eax
  80042b:	68 0b 21 80 00       	push   $0x80210b
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
  800443:	68 c6 25 80 00       	push   $0x8025c6
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
  800467:	b8 04 21 80 00       	mov    $0x802104,%eax
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
  800ae2:	68 ff 23 80 00       	push   $0x8023ff
  800ae7:	6a 23                	push   $0x23
  800ae9:	68 1c 24 80 00       	push   $0x80241c
  800aee:	e8 43 12 00 00       	call   801d36 <_panic>

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
  800b63:	68 ff 23 80 00       	push   $0x8023ff
  800b68:	6a 23                	push   $0x23
  800b6a:	68 1c 24 80 00       	push   $0x80241c
  800b6f:	e8 c2 11 00 00       	call   801d36 <_panic>

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
  800ba5:	68 ff 23 80 00       	push   $0x8023ff
  800baa:	6a 23                	push   $0x23
  800bac:	68 1c 24 80 00       	push   $0x80241c
  800bb1:	e8 80 11 00 00       	call   801d36 <_panic>

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
  800be7:	68 ff 23 80 00       	push   $0x8023ff
  800bec:	6a 23                	push   $0x23
  800bee:	68 1c 24 80 00       	push   $0x80241c
  800bf3:	e8 3e 11 00 00       	call   801d36 <_panic>

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
  800c29:	68 ff 23 80 00       	push   $0x8023ff
  800c2e:	6a 23                	push   $0x23
  800c30:	68 1c 24 80 00       	push   $0x80241c
  800c35:	e8 fc 10 00 00       	call   801d36 <_panic>

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
  800c6b:	68 ff 23 80 00       	push   $0x8023ff
  800c70:	6a 23                	push   $0x23
  800c72:	68 1c 24 80 00       	push   $0x80241c
  800c77:	e8 ba 10 00 00       	call   801d36 <_panic>

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
  800cad:	68 ff 23 80 00       	push   $0x8023ff
  800cb2:	6a 23                	push   $0x23
  800cb4:	68 1c 24 80 00       	push   $0x80241c
  800cb9:	e8 78 10 00 00       	call   801d36 <_panic>

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
  800d11:	68 ff 23 80 00       	push   $0x8023ff
  800d16:	6a 23                	push   $0x23
  800d18:	68 1c 24 80 00       	push   $0x80241c
  800d1d:	e8 14 10 00 00       	call   801d36 <_panic>

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
  800d4e:	68 2c 24 80 00       	push   $0x80242c
  800d53:	6a 1e                	push   $0x1e
  800d55:	68 c0 24 80 00       	push   $0x8024c0
  800d5a:	e8 d7 0f 00 00       	call   801d36 <_panic>

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
  800d84:	68 58 24 80 00       	push   $0x802458
  800d89:	6a 31                	push   $0x31
  800d8b:	68 c0 24 80 00       	push   $0x8024c0
  800d90:	e8 a1 0f 00 00       	call   801d36 <_panic>
	
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
  800dc4:	68 7c 24 80 00       	push   $0x80247c
  800dc9:	6a 39                	push   $0x39
  800dcb:	68 c0 24 80 00       	push   $0x8024c0
  800dd0:	e8 61 0f 00 00       	call   801d36 <_panic>

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
  800deb:	68 a0 24 80 00       	push   $0x8024a0
  800df0:	6a 3e                	push   $0x3e
  800df2:	68 c0 24 80 00       	push   $0x8024c0
  800df7:	e8 3a 0f 00 00       	call   801d36 <_panic>
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
  800e11:	e8 66 0f 00 00       	call   801d7c <set_pgfault_handler>
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
  800e22:	0f 88 3a 01 00 00    	js     800f62 <fork+0x15f>
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
  800e4d:	b8 00 00 00 00       	mov    $0x0,%eax
  800e52:	e9 0b 01 00 00       	jmp    800f62 <fork+0x15f>
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
  800e6a:	0f 84 99 00 00 00    	je     800f09 <fork+0x106>
			
			// if real PTE exists
			if ((uvpt[PGNUM(addr)] & PTE_P) == PTE_P) {
  800e70:	89 d8                	mov    %ebx,%eax
  800e72:	c1 e8 0c             	shr    $0xc,%eax
  800e75:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800e7c:	f6 c2 01             	test   $0x1,%dl
  800e7f:	0f 84 84 00 00 00    	je     800f09 <fork+0x106>

				// For each writable or copy-on-write page
				if ((uvpt[PGNUM(addr)] & (PTE_W | PTE_COW)) != 0) {
  800e85:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800e8c:	a9 02 08 00 00       	test   $0x802,%eax
  800e91:	74 76                	je     800f09 <fork+0x106>
	// r = envid2env(envid, &env, 1);
	// if (r < 0)
	// 	return r;	// E_BAD_ENV
	// envid_t parent_envid = env->env_parent_id;
	
	if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {
  800e93:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800e9a:	a8 02                	test   $0x2,%al
  800e9c:	75 0c                	jne    800eaa <fork+0xa7>
  800e9e:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800ea5:	f6 c4 08             	test   $0x8,%ah
  800ea8:	74 3f                	je     800ee9 <fork+0xe6>

		// map the page copy-on-write into the address space of the child
        r = sys_page_map(0, (void *)va, envid, (void *)va, PTE_P|PTE_U|PTE_COW);
  800eaa:	83 ec 0c             	sub    $0xc,%esp
  800ead:	68 05 08 00 00       	push   $0x805
  800eb2:	53                   	push   %ebx
  800eb3:	57                   	push   %edi
  800eb4:	53                   	push   %ebx
  800eb5:	6a 00                	push   $0x0
  800eb7:	e8 c0 fc ff ff       	call   800b7c <sys_page_map>
		if (r < 0)
  800ebc:	83 c4 20             	add    $0x20,%esp
  800ebf:	85 c0                	test   %eax,%eax
  800ec1:	0f 88 9b 00 00 00    	js     800f62 <fork+0x15f>
            return r;

		// remap the page copy-on-write in its own(parent) address space
        r = sys_page_map(0, (void *)va, 0, (void *)va, PTE_P|PTE_U|PTE_COW);
  800ec7:	83 ec 0c             	sub    $0xc,%esp
  800eca:	68 05 08 00 00       	push   $0x805
  800ecf:	53                   	push   %ebx
  800ed0:	6a 00                	push   $0x0
  800ed2:	53                   	push   %ebx
  800ed3:	6a 00                	push   $0x0
  800ed5:	e8 a2 fc ff ff       	call   800b7c <sys_page_map>
  800eda:	83 c4 20             	add    $0x20,%esp
  800edd:	85 c0                	test   %eax,%eax
  800edf:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ee4:	0f 4f c1             	cmovg  %ecx,%eax
  800ee7:	eb 1c                	jmp    800f05 <fork+0x102>
		if (r < 0)
            return r;
    }
    else {
        r = sys_page_map(0, (void *)va, envid, (void *)va, PTE_P|PTE_U);
  800ee9:	83 ec 0c             	sub    $0xc,%esp
  800eec:	6a 05                	push   $0x5
  800eee:	53                   	push   %ebx
  800eef:	57                   	push   %edi
  800ef0:	53                   	push   %ebx
  800ef1:	6a 00                	push   $0x0
  800ef3:	e8 84 fc ff ff       	call   800b7c <sys_page_map>
  800ef8:	83 c4 20             	add    $0x20,%esp
  800efb:	85 c0                	test   %eax,%eax
  800efd:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f02:	0f 4f c1             	cmovg  %ecx,%eax
			if ((uvpt[PGNUM(addr)] & PTE_P) == PTE_P) {

				// For each writable or copy-on-write page
				if ((uvpt[PGNUM(addr)] & (PTE_W | PTE_COW)) != 0) {
					r = duppage(envid, pn);
					if (r < 0)
  800f05:	85 c0                	test   %eax,%eax
  800f07:	78 59                	js     800f62 <fork+0x15f>
        return 0;
	}

	// For each writable or copy-on-write page in its address space below UTOP, the parent calls duppage
	uint32_t addr;
	for (uint32_t pn = PGNUM(UTEXT); pn < PGNUM(USTACKTOP); pn++) {
  800f09:	83 c6 01             	add    $0x1,%esi
  800f0c:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  800f12:	81 fe fe eb 0e 00    	cmp    $0xeebfe,%esi
  800f18:	0f 85 3e ff ff ff    	jne    800e5c <fork+0x59>
  800f1e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
		}
	}

	// allocate a fresh page in the child for the exception stack
	r = sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U | PTE_P | PTE_W);
  800f21:	83 ec 04             	sub    $0x4,%esp
  800f24:	6a 07                	push   $0x7
  800f26:	68 00 f0 bf ee       	push   $0xeebff000
  800f2b:	57                   	push   %edi
  800f2c:	e8 08 fc ff ff       	call   800b39 <sys_page_alloc>
	if (r < 0)
  800f31:	83 c4 10             	add    $0x10,%esp
  800f34:	85 c0                	test   %eax,%eax
  800f36:	78 2a                	js     800f62 <fork+0x15f>
		return r;

	// The parent sets the user page fault entrypoint for the child to look like its own
	extern void _pgfault_upcall(void);
	r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  800f38:	83 ec 08             	sub    $0x8,%esp
  800f3b:	68 c3 1d 80 00       	push   $0x801dc3
  800f40:	57                   	push   %edi
  800f41:	e8 3e fd ff ff       	call   800c84 <sys_env_set_pgfault_upcall>
	if (r < 0)
  800f46:	83 c4 10             	add    $0x10,%esp
  800f49:	85 c0                	test   %eax,%eax
  800f4b:	78 15                	js     800f62 <fork+0x15f>
		return r;

	// The child is now ready to run, so the parent marks it runnable
	r = sys_env_set_status(envid, ENV_RUNNABLE);
  800f4d:	83 ec 08             	sub    $0x8,%esp
  800f50:	6a 02                	push   $0x2
  800f52:	57                   	push   %edi
  800f53:	e8 a8 fc ff ff       	call   800c00 <sys_env_set_status>
	if (r < 0)
  800f58:	83 c4 10             	add    $0x10,%esp
		return r;

	return envid;
  800f5b:	85 c0                	test   %eax,%eax
  800f5d:	0f 49 c7             	cmovns %edi,%eax
  800f60:	eb 00                	jmp    800f62 <fork+0x15f>
	// panic("fork not implemented");
}
  800f62:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f65:	5b                   	pop    %ebx
  800f66:	5e                   	pop    %esi
  800f67:	5f                   	pop    %edi
  800f68:	5d                   	pop    %ebp
  800f69:	c3                   	ret    

00800f6a <sfork>:

// Challenge!
int
sfork(void)
{
  800f6a:	55                   	push   %ebp
  800f6b:	89 e5                	mov    %esp,%ebp
  800f6d:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  800f70:	68 cb 24 80 00       	push   $0x8024cb
  800f75:	68 c3 00 00 00       	push   $0xc3
  800f7a:	68 c0 24 80 00       	push   $0x8024c0
  800f7f:	e8 b2 0d 00 00       	call   801d36 <_panic>

00800f84 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  800f84:	55                   	push   %ebp
  800f85:	89 e5                	mov    %esp,%ebp
  800f87:	56                   	push   %esi
  800f88:	53                   	push   %ebx
  800f89:	8b 75 08             	mov    0x8(%ebp),%esi
  800f8c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f8f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");

	// don't want to recv page
	if (pg == NULL)
  800f92:	85 c0                	test   %eax,%eax
		pg = (void *)UTOP;
  800f94:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  800f99:	0f 44 c2             	cmove  %edx,%eax

	int err = sys_ipc_recv(pg);
  800f9c:	83 ec 0c             	sub    $0xc,%esp
  800f9f:	50                   	push   %eax
  800fa0:	e8 44 fd ff ff       	call   800ce9 <sys_ipc_recv>

	if (from_env_store != NULL)
  800fa5:	83 c4 10             	add    $0x10,%esp
  800fa8:	85 f6                	test   %esi,%esi
  800faa:	74 14                	je     800fc0 <ipc_recv+0x3c>
		*from_env_store = err < 0? 0 : thisenv->env_ipc_from;
  800fac:	ba 00 00 00 00       	mov    $0x0,%edx
  800fb1:	85 c0                	test   %eax,%eax
  800fb3:	78 09                	js     800fbe <ipc_recv+0x3a>
  800fb5:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800fbb:	8b 52 74             	mov    0x74(%edx),%edx
  800fbe:	89 16                	mov    %edx,(%esi)
	
	if (perm_store != NULL)
  800fc0:	85 db                	test   %ebx,%ebx
  800fc2:	74 14                	je     800fd8 <ipc_recv+0x54>
		*perm_store = err < 0? 0 : thisenv->env_ipc_perm;
  800fc4:	ba 00 00 00 00       	mov    $0x0,%edx
  800fc9:	85 c0                	test   %eax,%eax
  800fcb:	78 09                	js     800fd6 <ipc_recv+0x52>
  800fcd:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800fd3:	8b 52 78             	mov    0x78(%edx),%edx
  800fd6:	89 13                	mov    %edx,(%ebx)

	if (err < 0)
  800fd8:	85 c0                	test   %eax,%eax
  800fda:	78 08                	js     800fe4 <ipc_recv+0x60>
		return err;
	return thisenv->env_ipc_value;
  800fdc:	a1 04 40 80 00       	mov    0x804004,%eax
  800fe1:	8b 40 70             	mov    0x70(%eax),%eax
}
  800fe4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800fe7:	5b                   	pop    %ebx
  800fe8:	5e                   	pop    %esi
  800fe9:	5d                   	pop    %ebp
  800fea:	c3                   	ret    

00800feb <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  800feb:	55                   	push   %ebp
  800fec:	89 e5                	mov    %esp,%ebp
  800fee:	57                   	push   %edi
  800fef:	56                   	push   %esi
  800ff0:	53                   	push   %ebx
  800ff1:	83 ec 0c             	sub    $0xc,%esp
  800ff4:	8b 7d 08             	mov    0x8(%ebp),%edi
  800ff7:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ffa:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");

	// don't want to send page
	if (pg == NULL)
  800ffd:	85 db                	test   %ebx,%ebx
		pg = (void *)UTOP;
  800fff:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801004:	0f 44 d8             	cmove  %eax,%ebx
	
	int err = 0;
	
	do {

		err = sys_ipc_try_send(to_env, val, pg, perm);
  801007:	ff 75 14             	pushl  0x14(%ebp)
  80100a:	53                   	push   %ebx
  80100b:	56                   	push   %esi
  80100c:	57                   	push   %edi
  80100d:	e8 b4 fc ff ff       	call   800cc6 <sys_ipc_try_send>

		if (err < 0) {
  801012:	83 c4 10             	add    $0x10,%esp
  801015:	85 c0                	test   %eax,%eax
  801017:	79 1e                	jns    801037 <ipc_send+0x4c>
			if (err == -E_IPC_NOT_RECV)
  801019:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80101c:	75 07                	jne    801025 <ipc_send+0x3a>
				sys_yield();
  80101e:	e8 f7 fa ff ff       	call   800b1a <sys_yield>
  801023:	eb e2                	jmp    801007 <ipc_send+0x1c>
			else 
				panic("ipc_send: %e", err);
  801025:	50                   	push   %eax
  801026:	68 e1 24 80 00       	push   $0x8024e1
  80102b:	6a 49                	push   $0x49
  80102d:	68 ee 24 80 00       	push   $0x8024ee
  801032:	e8 ff 0c 00 00       	call   801d36 <_panic>
		}

	} while (err < 0);

}
  801037:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80103a:	5b                   	pop    %ebx
  80103b:	5e                   	pop    %esi
  80103c:	5f                   	pop    %edi
  80103d:	5d                   	pop    %ebp
  80103e:	c3                   	ret    

0080103f <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80103f:	55                   	push   %ebp
  801040:	89 e5                	mov    %esp,%ebp
  801042:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801045:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80104a:	6b d0 7c             	imul   $0x7c,%eax,%edx
  80104d:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801053:	8b 52 50             	mov    0x50(%edx),%edx
  801056:	39 ca                	cmp    %ecx,%edx
  801058:	75 0d                	jne    801067 <ipc_find_env+0x28>
			return envs[i].env_id;
  80105a:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80105d:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801062:	8b 40 48             	mov    0x48(%eax),%eax
  801065:	eb 0f                	jmp    801076 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801067:	83 c0 01             	add    $0x1,%eax
  80106a:	3d 00 04 00 00       	cmp    $0x400,%eax
  80106f:	75 d9                	jne    80104a <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801071:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801076:	5d                   	pop    %ebp
  801077:	c3                   	ret    

00801078 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801078:	55                   	push   %ebp
  801079:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80107b:	8b 45 08             	mov    0x8(%ebp),%eax
  80107e:	05 00 00 00 30       	add    $0x30000000,%eax
  801083:	c1 e8 0c             	shr    $0xc,%eax
}
  801086:	5d                   	pop    %ebp
  801087:	c3                   	ret    

00801088 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801088:	55                   	push   %ebp
  801089:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  80108b:	8b 45 08             	mov    0x8(%ebp),%eax
  80108e:	05 00 00 00 30       	add    $0x30000000,%eax
  801093:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801098:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80109d:	5d                   	pop    %ebp
  80109e:	c3                   	ret    

0080109f <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80109f:	55                   	push   %ebp
  8010a0:	89 e5                	mov    %esp,%ebp
  8010a2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010a5:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8010aa:	89 c2                	mov    %eax,%edx
  8010ac:	c1 ea 16             	shr    $0x16,%edx
  8010af:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8010b6:	f6 c2 01             	test   $0x1,%dl
  8010b9:	74 11                	je     8010cc <fd_alloc+0x2d>
  8010bb:	89 c2                	mov    %eax,%edx
  8010bd:	c1 ea 0c             	shr    $0xc,%edx
  8010c0:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8010c7:	f6 c2 01             	test   $0x1,%dl
  8010ca:	75 09                	jne    8010d5 <fd_alloc+0x36>
			*fd_store = fd;
  8010cc:	89 01                	mov    %eax,(%ecx)
			return 0;
  8010ce:	b8 00 00 00 00       	mov    $0x0,%eax
  8010d3:	eb 17                	jmp    8010ec <fd_alloc+0x4d>
  8010d5:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8010da:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8010df:	75 c9                	jne    8010aa <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8010e1:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8010e7:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8010ec:	5d                   	pop    %ebp
  8010ed:	c3                   	ret    

008010ee <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8010ee:	55                   	push   %ebp
  8010ef:	89 e5                	mov    %esp,%ebp
  8010f1:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8010f4:	83 f8 1f             	cmp    $0x1f,%eax
  8010f7:	77 36                	ja     80112f <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8010f9:	c1 e0 0c             	shl    $0xc,%eax
  8010fc:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801101:	89 c2                	mov    %eax,%edx
  801103:	c1 ea 16             	shr    $0x16,%edx
  801106:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80110d:	f6 c2 01             	test   $0x1,%dl
  801110:	74 24                	je     801136 <fd_lookup+0x48>
  801112:	89 c2                	mov    %eax,%edx
  801114:	c1 ea 0c             	shr    $0xc,%edx
  801117:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80111e:	f6 c2 01             	test   $0x1,%dl
  801121:	74 1a                	je     80113d <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801123:	8b 55 0c             	mov    0xc(%ebp),%edx
  801126:	89 02                	mov    %eax,(%edx)
	return 0;
  801128:	b8 00 00 00 00       	mov    $0x0,%eax
  80112d:	eb 13                	jmp    801142 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80112f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801134:	eb 0c                	jmp    801142 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801136:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80113b:	eb 05                	jmp    801142 <fd_lookup+0x54>
  80113d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801142:	5d                   	pop    %ebp
  801143:	c3                   	ret    

00801144 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801144:	55                   	push   %ebp
  801145:	89 e5                	mov    %esp,%ebp
  801147:	83 ec 08             	sub    $0x8,%esp
  80114a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80114d:	ba 74 25 80 00       	mov    $0x802574,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801152:	eb 13                	jmp    801167 <dev_lookup+0x23>
  801154:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801157:	39 08                	cmp    %ecx,(%eax)
  801159:	75 0c                	jne    801167 <dev_lookup+0x23>
			*dev = devtab[i];
  80115b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80115e:	89 01                	mov    %eax,(%ecx)
			return 0;
  801160:	b8 00 00 00 00       	mov    $0x0,%eax
  801165:	eb 2e                	jmp    801195 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801167:	8b 02                	mov    (%edx),%eax
  801169:	85 c0                	test   %eax,%eax
  80116b:	75 e7                	jne    801154 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80116d:	a1 04 40 80 00       	mov    0x804004,%eax
  801172:	8b 40 48             	mov    0x48(%eax),%eax
  801175:	83 ec 04             	sub    $0x4,%esp
  801178:	51                   	push   %ecx
  801179:	50                   	push   %eax
  80117a:	68 f8 24 80 00       	push   $0x8024f8
  80117f:	e8 2d f0 ff ff       	call   8001b1 <cprintf>
	*dev = 0;
  801184:	8b 45 0c             	mov    0xc(%ebp),%eax
  801187:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80118d:	83 c4 10             	add    $0x10,%esp
  801190:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801195:	c9                   	leave  
  801196:	c3                   	ret    

00801197 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801197:	55                   	push   %ebp
  801198:	89 e5                	mov    %esp,%ebp
  80119a:	56                   	push   %esi
  80119b:	53                   	push   %ebx
  80119c:	83 ec 10             	sub    $0x10,%esp
  80119f:	8b 75 08             	mov    0x8(%ebp),%esi
  8011a2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8011a5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011a8:	50                   	push   %eax
  8011a9:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8011af:	c1 e8 0c             	shr    $0xc,%eax
  8011b2:	50                   	push   %eax
  8011b3:	e8 36 ff ff ff       	call   8010ee <fd_lookup>
  8011b8:	83 c4 08             	add    $0x8,%esp
  8011bb:	85 c0                	test   %eax,%eax
  8011bd:	78 05                	js     8011c4 <fd_close+0x2d>
	    || fd != fd2)
  8011bf:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8011c2:	74 0c                	je     8011d0 <fd_close+0x39>
		return (must_exist ? r : 0);
  8011c4:	84 db                	test   %bl,%bl
  8011c6:	ba 00 00 00 00       	mov    $0x0,%edx
  8011cb:	0f 44 c2             	cmove  %edx,%eax
  8011ce:	eb 41                	jmp    801211 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8011d0:	83 ec 08             	sub    $0x8,%esp
  8011d3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011d6:	50                   	push   %eax
  8011d7:	ff 36                	pushl  (%esi)
  8011d9:	e8 66 ff ff ff       	call   801144 <dev_lookup>
  8011de:	89 c3                	mov    %eax,%ebx
  8011e0:	83 c4 10             	add    $0x10,%esp
  8011e3:	85 c0                	test   %eax,%eax
  8011e5:	78 1a                	js     801201 <fd_close+0x6a>
		if (dev->dev_close)
  8011e7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011ea:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8011ed:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8011f2:	85 c0                	test   %eax,%eax
  8011f4:	74 0b                	je     801201 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8011f6:	83 ec 0c             	sub    $0xc,%esp
  8011f9:	56                   	push   %esi
  8011fa:	ff d0                	call   *%eax
  8011fc:	89 c3                	mov    %eax,%ebx
  8011fe:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801201:	83 ec 08             	sub    $0x8,%esp
  801204:	56                   	push   %esi
  801205:	6a 00                	push   $0x0
  801207:	e8 b2 f9 ff ff       	call   800bbe <sys_page_unmap>
	return r;
  80120c:	83 c4 10             	add    $0x10,%esp
  80120f:	89 d8                	mov    %ebx,%eax
}
  801211:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801214:	5b                   	pop    %ebx
  801215:	5e                   	pop    %esi
  801216:	5d                   	pop    %ebp
  801217:	c3                   	ret    

00801218 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801218:	55                   	push   %ebp
  801219:	89 e5                	mov    %esp,%ebp
  80121b:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80121e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801221:	50                   	push   %eax
  801222:	ff 75 08             	pushl  0x8(%ebp)
  801225:	e8 c4 fe ff ff       	call   8010ee <fd_lookup>
  80122a:	83 c4 08             	add    $0x8,%esp
  80122d:	85 c0                	test   %eax,%eax
  80122f:	78 10                	js     801241 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801231:	83 ec 08             	sub    $0x8,%esp
  801234:	6a 01                	push   $0x1
  801236:	ff 75 f4             	pushl  -0xc(%ebp)
  801239:	e8 59 ff ff ff       	call   801197 <fd_close>
  80123e:	83 c4 10             	add    $0x10,%esp
}
  801241:	c9                   	leave  
  801242:	c3                   	ret    

00801243 <close_all>:

void
close_all(void)
{
  801243:	55                   	push   %ebp
  801244:	89 e5                	mov    %esp,%ebp
  801246:	53                   	push   %ebx
  801247:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80124a:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80124f:	83 ec 0c             	sub    $0xc,%esp
  801252:	53                   	push   %ebx
  801253:	e8 c0 ff ff ff       	call   801218 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801258:	83 c3 01             	add    $0x1,%ebx
  80125b:	83 c4 10             	add    $0x10,%esp
  80125e:	83 fb 20             	cmp    $0x20,%ebx
  801261:	75 ec                	jne    80124f <close_all+0xc>
		close(i);
}
  801263:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801266:	c9                   	leave  
  801267:	c3                   	ret    

00801268 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801268:	55                   	push   %ebp
  801269:	89 e5                	mov    %esp,%ebp
  80126b:	57                   	push   %edi
  80126c:	56                   	push   %esi
  80126d:	53                   	push   %ebx
  80126e:	83 ec 2c             	sub    $0x2c,%esp
  801271:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801274:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801277:	50                   	push   %eax
  801278:	ff 75 08             	pushl  0x8(%ebp)
  80127b:	e8 6e fe ff ff       	call   8010ee <fd_lookup>
  801280:	83 c4 08             	add    $0x8,%esp
  801283:	85 c0                	test   %eax,%eax
  801285:	0f 88 c1 00 00 00    	js     80134c <dup+0xe4>
		return r;
	close(newfdnum);
  80128b:	83 ec 0c             	sub    $0xc,%esp
  80128e:	56                   	push   %esi
  80128f:	e8 84 ff ff ff       	call   801218 <close>

	newfd = INDEX2FD(newfdnum);
  801294:	89 f3                	mov    %esi,%ebx
  801296:	c1 e3 0c             	shl    $0xc,%ebx
  801299:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  80129f:	83 c4 04             	add    $0x4,%esp
  8012a2:	ff 75 e4             	pushl  -0x1c(%ebp)
  8012a5:	e8 de fd ff ff       	call   801088 <fd2data>
  8012aa:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8012ac:	89 1c 24             	mov    %ebx,(%esp)
  8012af:	e8 d4 fd ff ff       	call   801088 <fd2data>
  8012b4:	83 c4 10             	add    $0x10,%esp
  8012b7:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8012ba:	89 f8                	mov    %edi,%eax
  8012bc:	c1 e8 16             	shr    $0x16,%eax
  8012bf:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8012c6:	a8 01                	test   $0x1,%al
  8012c8:	74 37                	je     801301 <dup+0x99>
  8012ca:	89 f8                	mov    %edi,%eax
  8012cc:	c1 e8 0c             	shr    $0xc,%eax
  8012cf:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8012d6:	f6 c2 01             	test   $0x1,%dl
  8012d9:	74 26                	je     801301 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8012db:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8012e2:	83 ec 0c             	sub    $0xc,%esp
  8012e5:	25 07 0e 00 00       	and    $0xe07,%eax
  8012ea:	50                   	push   %eax
  8012eb:	ff 75 d4             	pushl  -0x2c(%ebp)
  8012ee:	6a 00                	push   $0x0
  8012f0:	57                   	push   %edi
  8012f1:	6a 00                	push   $0x0
  8012f3:	e8 84 f8 ff ff       	call   800b7c <sys_page_map>
  8012f8:	89 c7                	mov    %eax,%edi
  8012fa:	83 c4 20             	add    $0x20,%esp
  8012fd:	85 c0                	test   %eax,%eax
  8012ff:	78 2e                	js     80132f <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801301:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801304:	89 d0                	mov    %edx,%eax
  801306:	c1 e8 0c             	shr    $0xc,%eax
  801309:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801310:	83 ec 0c             	sub    $0xc,%esp
  801313:	25 07 0e 00 00       	and    $0xe07,%eax
  801318:	50                   	push   %eax
  801319:	53                   	push   %ebx
  80131a:	6a 00                	push   $0x0
  80131c:	52                   	push   %edx
  80131d:	6a 00                	push   $0x0
  80131f:	e8 58 f8 ff ff       	call   800b7c <sys_page_map>
  801324:	89 c7                	mov    %eax,%edi
  801326:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801329:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80132b:	85 ff                	test   %edi,%edi
  80132d:	79 1d                	jns    80134c <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80132f:	83 ec 08             	sub    $0x8,%esp
  801332:	53                   	push   %ebx
  801333:	6a 00                	push   $0x0
  801335:	e8 84 f8 ff ff       	call   800bbe <sys_page_unmap>
	sys_page_unmap(0, nva);
  80133a:	83 c4 08             	add    $0x8,%esp
  80133d:	ff 75 d4             	pushl  -0x2c(%ebp)
  801340:	6a 00                	push   $0x0
  801342:	e8 77 f8 ff ff       	call   800bbe <sys_page_unmap>
	return r;
  801347:	83 c4 10             	add    $0x10,%esp
  80134a:	89 f8                	mov    %edi,%eax
}
  80134c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80134f:	5b                   	pop    %ebx
  801350:	5e                   	pop    %esi
  801351:	5f                   	pop    %edi
  801352:	5d                   	pop    %ebp
  801353:	c3                   	ret    

00801354 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801354:	55                   	push   %ebp
  801355:	89 e5                	mov    %esp,%ebp
  801357:	53                   	push   %ebx
  801358:	83 ec 14             	sub    $0x14,%esp
  80135b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80135e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801361:	50                   	push   %eax
  801362:	53                   	push   %ebx
  801363:	e8 86 fd ff ff       	call   8010ee <fd_lookup>
  801368:	83 c4 08             	add    $0x8,%esp
  80136b:	89 c2                	mov    %eax,%edx
  80136d:	85 c0                	test   %eax,%eax
  80136f:	78 6d                	js     8013de <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801371:	83 ec 08             	sub    $0x8,%esp
  801374:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801377:	50                   	push   %eax
  801378:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80137b:	ff 30                	pushl  (%eax)
  80137d:	e8 c2 fd ff ff       	call   801144 <dev_lookup>
  801382:	83 c4 10             	add    $0x10,%esp
  801385:	85 c0                	test   %eax,%eax
  801387:	78 4c                	js     8013d5 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801389:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80138c:	8b 42 08             	mov    0x8(%edx),%eax
  80138f:	83 e0 03             	and    $0x3,%eax
  801392:	83 f8 01             	cmp    $0x1,%eax
  801395:	75 21                	jne    8013b8 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801397:	a1 04 40 80 00       	mov    0x804004,%eax
  80139c:	8b 40 48             	mov    0x48(%eax),%eax
  80139f:	83 ec 04             	sub    $0x4,%esp
  8013a2:	53                   	push   %ebx
  8013a3:	50                   	push   %eax
  8013a4:	68 39 25 80 00       	push   $0x802539
  8013a9:	e8 03 ee ff ff       	call   8001b1 <cprintf>
		return -E_INVAL;
  8013ae:	83 c4 10             	add    $0x10,%esp
  8013b1:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8013b6:	eb 26                	jmp    8013de <read+0x8a>
	}
	if (!dev->dev_read)
  8013b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013bb:	8b 40 08             	mov    0x8(%eax),%eax
  8013be:	85 c0                	test   %eax,%eax
  8013c0:	74 17                	je     8013d9 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8013c2:	83 ec 04             	sub    $0x4,%esp
  8013c5:	ff 75 10             	pushl  0x10(%ebp)
  8013c8:	ff 75 0c             	pushl  0xc(%ebp)
  8013cb:	52                   	push   %edx
  8013cc:	ff d0                	call   *%eax
  8013ce:	89 c2                	mov    %eax,%edx
  8013d0:	83 c4 10             	add    $0x10,%esp
  8013d3:	eb 09                	jmp    8013de <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013d5:	89 c2                	mov    %eax,%edx
  8013d7:	eb 05                	jmp    8013de <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8013d9:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8013de:	89 d0                	mov    %edx,%eax
  8013e0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013e3:	c9                   	leave  
  8013e4:	c3                   	ret    

008013e5 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8013e5:	55                   	push   %ebp
  8013e6:	89 e5                	mov    %esp,%ebp
  8013e8:	57                   	push   %edi
  8013e9:	56                   	push   %esi
  8013ea:	53                   	push   %ebx
  8013eb:	83 ec 0c             	sub    $0xc,%esp
  8013ee:	8b 7d 08             	mov    0x8(%ebp),%edi
  8013f1:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8013f4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8013f9:	eb 21                	jmp    80141c <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8013fb:	83 ec 04             	sub    $0x4,%esp
  8013fe:	89 f0                	mov    %esi,%eax
  801400:	29 d8                	sub    %ebx,%eax
  801402:	50                   	push   %eax
  801403:	89 d8                	mov    %ebx,%eax
  801405:	03 45 0c             	add    0xc(%ebp),%eax
  801408:	50                   	push   %eax
  801409:	57                   	push   %edi
  80140a:	e8 45 ff ff ff       	call   801354 <read>
		if (m < 0)
  80140f:	83 c4 10             	add    $0x10,%esp
  801412:	85 c0                	test   %eax,%eax
  801414:	78 10                	js     801426 <readn+0x41>
			return m;
		if (m == 0)
  801416:	85 c0                	test   %eax,%eax
  801418:	74 0a                	je     801424 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80141a:	01 c3                	add    %eax,%ebx
  80141c:	39 f3                	cmp    %esi,%ebx
  80141e:	72 db                	jb     8013fb <readn+0x16>
  801420:	89 d8                	mov    %ebx,%eax
  801422:	eb 02                	jmp    801426 <readn+0x41>
  801424:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801426:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801429:	5b                   	pop    %ebx
  80142a:	5e                   	pop    %esi
  80142b:	5f                   	pop    %edi
  80142c:	5d                   	pop    %ebp
  80142d:	c3                   	ret    

0080142e <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80142e:	55                   	push   %ebp
  80142f:	89 e5                	mov    %esp,%ebp
  801431:	53                   	push   %ebx
  801432:	83 ec 14             	sub    $0x14,%esp
  801435:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801438:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80143b:	50                   	push   %eax
  80143c:	53                   	push   %ebx
  80143d:	e8 ac fc ff ff       	call   8010ee <fd_lookup>
  801442:	83 c4 08             	add    $0x8,%esp
  801445:	89 c2                	mov    %eax,%edx
  801447:	85 c0                	test   %eax,%eax
  801449:	78 68                	js     8014b3 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80144b:	83 ec 08             	sub    $0x8,%esp
  80144e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801451:	50                   	push   %eax
  801452:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801455:	ff 30                	pushl  (%eax)
  801457:	e8 e8 fc ff ff       	call   801144 <dev_lookup>
  80145c:	83 c4 10             	add    $0x10,%esp
  80145f:	85 c0                	test   %eax,%eax
  801461:	78 47                	js     8014aa <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801463:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801466:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80146a:	75 21                	jne    80148d <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80146c:	a1 04 40 80 00       	mov    0x804004,%eax
  801471:	8b 40 48             	mov    0x48(%eax),%eax
  801474:	83 ec 04             	sub    $0x4,%esp
  801477:	53                   	push   %ebx
  801478:	50                   	push   %eax
  801479:	68 55 25 80 00       	push   $0x802555
  80147e:	e8 2e ed ff ff       	call   8001b1 <cprintf>
		return -E_INVAL;
  801483:	83 c4 10             	add    $0x10,%esp
  801486:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80148b:	eb 26                	jmp    8014b3 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80148d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801490:	8b 52 0c             	mov    0xc(%edx),%edx
  801493:	85 d2                	test   %edx,%edx
  801495:	74 17                	je     8014ae <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801497:	83 ec 04             	sub    $0x4,%esp
  80149a:	ff 75 10             	pushl  0x10(%ebp)
  80149d:	ff 75 0c             	pushl  0xc(%ebp)
  8014a0:	50                   	push   %eax
  8014a1:	ff d2                	call   *%edx
  8014a3:	89 c2                	mov    %eax,%edx
  8014a5:	83 c4 10             	add    $0x10,%esp
  8014a8:	eb 09                	jmp    8014b3 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014aa:	89 c2                	mov    %eax,%edx
  8014ac:	eb 05                	jmp    8014b3 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8014ae:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8014b3:	89 d0                	mov    %edx,%eax
  8014b5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014b8:	c9                   	leave  
  8014b9:	c3                   	ret    

008014ba <seek>:

int
seek(int fdnum, off_t offset)
{
  8014ba:	55                   	push   %ebp
  8014bb:	89 e5                	mov    %esp,%ebp
  8014bd:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8014c0:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8014c3:	50                   	push   %eax
  8014c4:	ff 75 08             	pushl  0x8(%ebp)
  8014c7:	e8 22 fc ff ff       	call   8010ee <fd_lookup>
  8014cc:	83 c4 08             	add    $0x8,%esp
  8014cf:	85 c0                	test   %eax,%eax
  8014d1:	78 0e                	js     8014e1 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8014d3:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8014d6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8014d9:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8014dc:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8014e1:	c9                   	leave  
  8014e2:	c3                   	ret    

008014e3 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8014e3:	55                   	push   %ebp
  8014e4:	89 e5                	mov    %esp,%ebp
  8014e6:	53                   	push   %ebx
  8014e7:	83 ec 14             	sub    $0x14,%esp
  8014ea:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014ed:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014f0:	50                   	push   %eax
  8014f1:	53                   	push   %ebx
  8014f2:	e8 f7 fb ff ff       	call   8010ee <fd_lookup>
  8014f7:	83 c4 08             	add    $0x8,%esp
  8014fa:	89 c2                	mov    %eax,%edx
  8014fc:	85 c0                	test   %eax,%eax
  8014fe:	78 65                	js     801565 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801500:	83 ec 08             	sub    $0x8,%esp
  801503:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801506:	50                   	push   %eax
  801507:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80150a:	ff 30                	pushl  (%eax)
  80150c:	e8 33 fc ff ff       	call   801144 <dev_lookup>
  801511:	83 c4 10             	add    $0x10,%esp
  801514:	85 c0                	test   %eax,%eax
  801516:	78 44                	js     80155c <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801518:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80151b:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80151f:	75 21                	jne    801542 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801521:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801526:	8b 40 48             	mov    0x48(%eax),%eax
  801529:	83 ec 04             	sub    $0x4,%esp
  80152c:	53                   	push   %ebx
  80152d:	50                   	push   %eax
  80152e:	68 18 25 80 00       	push   $0x802518
  801533:	e8 79 ec ff ff       	call   8001b1 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801538:	83 c4 10             	add    $0x10,%esp
  80153b:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801540:	eb 23                	jmp    801565 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801542:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801545:	8b 52 18             	mov    0x18(%edx),%edx
  801548:	85 d2                	test   %edx,%edx
  80154a:	74 14                	je     801560 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80154c:	83 ec 08             	sub    $0x8,%esp
  80154f:	ff 75 0c             	pushl  0xc(%ebp)
  801552:	50                   	push   %eax
  801553:	ff d2                	call   *%edx
  801555:	89 c2                	mov    %eax,%edx
  801557:	83 c4 10             	add    $0x10,%esp
  80155a:	eb 09                	jmp    801565 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80155c:	89 c2                	mov    %eax,%edx
  80155e:	eb 05                	jmp    801565 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801560:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801565:	89 d0                	mov    %edx,%eax
  801567:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80156a:	c9                   	leave  
  80156b:	c3                   	ret    

0080156c <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80156c:	55                   	push   %ebp
  80156d:	89 e5                	mov    %esp,%ebp
  80156f:	53                   	push   %ebx
  801570:	83 ec 14             	sub    $0x14,%esp
  801573:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801576:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801579:	50                   	push   %eax
  80157a:	ff 75 08             	pushl  0x8(%ebp)
  80157d:	e8 6c fb ff ff       	call   8010ee <fd_lookup>
  801582:	83 c4 08             	add    $0x8,%esp
  801585:	89 c2                	mov    %eax,%edx
  801587:	85 c0                	test   %eax,%eax
  801589:	78 58                	js     8015e3 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80158b:	83 ec 08             	sub    $0x8,%esp
  80158e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801591:	50                   	push   %eax
  801592:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801595:	ff 30                	pushl  (%eax)
  801597:	e8 a8 fb ff ff       	call   801144 <dev_lookup>
  80159c:	83 c4 10             	add    $0x10,%esp
  80159f:	85 c0                	test   %eax,%eax
  8015a1:	78 37                	js     8015da <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8015a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015a6:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8015aa:	74 32                	je     8015de <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8015ac:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8015af:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8015b6:	00 00 00 
	stat->st_isdir = 0;
  8015b9:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8015c0:	00 00 00 
	stat->st_dev = dev;
  8015c3:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8015c9:	83 ec 08             	sub    $0x8,%esp
  8015cc:	53                   	push   %ebx
  8015cd:	ff 75 f0             	pushl  -0x10(%ebp)
  8015d0:	ff 50 14             	call   *0x14(%eax)
  8015d3:	89 c2                	mov    %eax,%edx
  8015d5:	83 c4 10             	add    $0x10,%esp
  8015d8:	eb 09                	jmp    8015e3 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015da:	89 c2                	mov    %eax,%edx
  8015dc:	eb 05                	jmp    8015e3 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8015de:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8015e3:	89 d0                	mov    %edx,%eax
  8015e5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015e8:	c9                   	leave  
  8015e9:	c3                   	ret    

008015ea <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8015ea:	55                   	push   %ebp
  8015eb:	89 e5                	mov    %esp,%ebp
  8015ed:	56                   	push   %esi
  8015ee:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8015ef:	83 ec 08             	sub    $0x8,%esp
  8015f2:	6a 00                	push   $0x0
  8015f4:	ff 75 08             	pushl  0x8(%ebp)
  8015f7:	e8 b7 01 00 00       	call   8017b3 <open>
  8015fc:	89 c3                	mov    %eax,%ebx
  8015fe:	83 c4 10             	add    $0x10,%esp
  801601:	85 c0                	test   %eax,%eax
  801603:	78 1b                	js     801620 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801605:	83 ec 08             	sub    $0x8,%esp
  801608:	ff 75 0c             	pushl  0xc(%ebp)
  80160b:	50                   	push   %eax
  80160c:	e8 5b ff ff ff       	call   80156c <fstat>
  801611:	89 c6                	mov    %eax,%esi
	close(fd);
  801613:	89 1c 24             	mov    %ebx,(%esp)
  801616:	e8 fd fb ff ff       	call   801218 <close>
	return r;
  80161b:	83 c4 10             	add    $0x10,%esp
  80161e:	89 f0                	mov    %esi,%eax
}
  801620:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801623:	5b                   	pop    %ebx
  801624:	5e                   	pop    %esi
  801625:	5d                   	pop    %ebp
  801626:	c3                   	ret    

00801627 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801627:	55                   	push   %ebp
  801628:	89 e5                	mov    %esp,%ebp
  80162a:	56                   	push   %esi
  80162b:	53                   	push   %ebx
  80162c:	89 c6                	mov    %eax,%esi
  80162e:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801630:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801637:	75 12                	jne    80164b <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801639:	83 ec 0c             	sub    $0xc,%esp
  80163c:	6a 01                	push   $0x1
  80163e:	e8 fc f9 ff ff       	call   80103f <ipc_find_env>
  801643:	a3 00 40 80 00       	mov    %eax,0x804000
  801648:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80164b:	6a 07                	push   $0x7
  80164d:	68 00 50 80 00       	push   $0x805000
  801652:	56                   	push   %esi
  801653:	ff 35 00 40 80 00    	pushl  0x804000
  801659:	e8 8d f9 ff ff       	call   800feb <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80165e:	83 c4 0c             	add    $0xc,%esp
  801661:	6a 00                	push   $0x0
  801663:	53                   	push   %ebx
  801664:	6a 00                	push   $0x0
  801666:	e8 19 f9 ff ff       	call   800f84 <ipc_recv>
}
  80166b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80166e:	5b                   	pop    %ebx
  80166f:	5e                   	pop    %esi
  801670:	5d                   	pop    %ebp
  801671:	c3                   	ret    

00801672 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801672:	55                   	push   %ebp
  801673:	89 e5                	mov    %esp,%ebp
  801675:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801678:	8b 45 08             	mov    0x8(%ebp),%eax
  80167b:	8b 40 0c             	mov    0xc(%eax),%eax
  80167e:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801683:	8b 45 0c             	mov    0xc(%ebp),%eax
  801686:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80168b:	ba 00 00 00 00       	mov    $0x0,%edx
  801690:	b8 02 00 00 00       	mov    $0x2,%eax
  801695:	e8 8d ff ff ff       	call   801627 <fsipc>
}
  80169a:	c9                   	leave  
  80169b:	c3                   	ret    

0080169c <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80169c:	55                   	push   %ebp
  80169d:	89 e5                	mov    %esp,%ebp
  80169f:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8016a2:	8b 45 08             	mov    0x8(%ebp),%eax
  8016a5:	8b 40 0c             	mov    0xc(%eax),%eax
  8016a8:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8016ad:	ba 00 00 00 00       	mov    $0x0,%edx
  8016b2:	b8 06 00 00 00       	mov    $0x6,%eax
  8016b7:	e8 6b ff ff ff       	call   801627 <fsipc>
}
  8016bc:	c9                   	leave  
  8016bd:	c3                   	ret    

008016be <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8016be:	55                   	push   %ebp
  8016bf:	89 e5                	mov    %esp,%ebp
  8016c1:	53                   	push   %ebx
  8016c2:	83 ec 04             	sub    $0x4,%esp
  8016c5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8016c8:	8b 45 08             	mov    0x8(%ebp),%eax
  8016cb:	8b 40 0c             	mov    0xc(%eax),%eax
  8016ce:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8016d3:	ba 00 00 00 00       	mov    $0x0,%edx
  8016d8:	b8 05 00 00 00       	mov    $0x5,%eax
  8016dd:	e8 45 ff ff ff       	call   801627 <fsipc>
  8016e2:	85 c0                	test   %eax,%eax
  8016e4:	78 2c                	js     801712 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8016e6:	83 ec 08             	sub    $0x8,%esp
  8016e9:	68 00 50 80 00       	push   $0x805000
  8016ee:	53                   	push   %ebx
  8016ef:	e8 42 f0 ff ff       	call   800736 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8016f4:	a1 80 50 80 00       	mov    0x805080,%eax
  8016f9:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8016ff:	a1 84 50 80 00       	mov    0x805084,%eax
  801704:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80170a:	83 c4 10             	add    $0x10,%esp
  80170d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801712:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801715:	c9                   	leave  
  801716:	c3                   	ret    

00801717 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801717:	55                   	push   %ebp
  801718:	89 e5                	mov    %esp,%ebp
  80171a:	83 ec 0c             	sub    $0xc,%esp
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	panic("devfile_write not implemented");
  80171d:	68 84 25 80 00       	push   $0x802584
  801722:	68 90 00 00 00       	push   $0x90
  801727:	68 a2 25 80 00       	push   $0x8025a2
  80172c:	e8 05 06 00 00       	call   801d36 <_panic>

00801731 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801731:	55                   	push   %ebp
  801732:	89 e5                	mov    %esp,%ebp
  801734:	56                   	push   %esi
  801735:	53                   	push   %ebx
  801736:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801739:	8b 45 08             	mov    0x8(%ebp),%eax
  80173c:	8b 40 0c             	mov    0xc(%eax),%eax
  80173f:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801744:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80174a:	ba 00 00 00 00       	mov    $0x0,%edx
  80174f:	b8 03 00 00 00       	mov    $0x3,%eax
  801754:	e8 ce fe ff ff       	call   801627 <fsipc>
  801759:	89 c3                	mov    %eax,%ebx
  80175b:	85 c0                	test   %eax,%eax
  80175d:	78 4b                	js     8017aa <devfile_read+0x79>
		return r;
	assert(r <= n);
  80175f:	39 c6                	cmp    %eax,%esi
  801761:	73 16                	jae    801779 <devfile_read+0x48>
  801763:	68 ad 25 80 00       	push   $0x8025ad
  801768:	68 b4 25 80 00       	push   $0x8025b4
  80176d:	6a 7c                	push   $0x7c
  80176f:	68 a2 25 80 00       	push   $0x8025a2
  801774:	e8 bd 05 00 00       	call   801d36 <_panic>
	assert(r <= PGSIZE);
  801779:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80177e:	7e 16                	jle    801796 <devfile_read+0x65>
  801780:	68 c9 25 80 00       	push   $0x8025c9
  801785:	68 b4 25 80 00       	push   $0x8025b4
  80178a:	6a 7d                	push   $0x7d
  80178c:	68 a2 25 80 00       	push   $0x8025a2
  801791:	e8 a0 05 00 00       	call   801d36 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801796:	83 ec 04             	sub    $0x4,%esp
  801799:	50                   	push   %eax
  80179a:	68 00 50 80 00       	push   $0x805000
  80179f:	ff 75 0c             	pushl  0xc(%ebp)
  8017a2:	e8 21 f1 ff ff       	call   8008c8 <memmove>
	return r;
  8017a7:	83 c4 10             	add    $0x10,%esp
}
  8017aa:	89 d8                	mov    %ebx,%eax
  8017ac:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017af:	5b                   	pop    %ebx
  8017b0:	5e                   	pop    %esi
  8017b1:	5d                   	pop    %ebp
  8017b2:	c3                   	ret    

008017b3 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8017b3:	55                   	push   %ebp
  8017b4:	89 e5                	mov    %esp,%ebp
  8017b6:	53                   	push   %ebx
  8017b7:	83 ec 20             	sub    $0x20,%esp
  8017ba:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8017bd:	53                   	push   %ebx
  8017be:	e8 3a ef ff ff       	call   8006fd <strlen>
  8017c3:	83 c4 10             	add    $0x10,%esp
  8017c6:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8017cb:	7f 67                	jg     801834 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8017cd:	83 ec 0c             	sub    $0xc,%esp
  8017d0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017d3:	50                   	push   %eax
  8017d4:	e8 c6 f8 ff ff       	call   80109f <fd_alloc>
  8017d9:	83 c4 10             	add    $0x10,%esp
		return r;
  8017dc:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8017de:	85 c0                	test   %eax,%eax
  8017e0:	78 57                	js     801839 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8017e2:	83 ec 08             	sub    $0x8,%esp
  8017e5:	53                   	push   %ebx
  8017e6:	68 00 50 80 00       	push   $0x805000
  8017eb:	e8 46 ef ff ff       	call   800736 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8017f0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017f3:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8017f8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8017fb:	b8 01 00 00 00       	mov    $0x1,%eax
  801800:	e8 22 fe ff ff       	call   801627 <fsipc>
  801805:	89 c3                	mov    %eax,%ebx
  801807:	83 c4 10             	add    $0x10,%esp
  80180a:	85 c0                	test   %eax,%eax
  80180c:	79 14                	jns    801822 <open+0x6f>
		fd_close(fd, 0);
  80180e:	83 ec 08             	sub    $0x8,%esp
  801811:	6a 00                	push   $0x0
  801813:	ff 75 f4             	pushl  -0xc(%ebp)
  801816:	e8 7c f9 ff ff       	call   801197 <fd_close>
		return r;
  80181b:	83 c4 10             	add    $0x10,%esp
  80181e:	89 da                	mov    %ebx,%edx
  801820:	eb 17                	jmp    801839 <open+0x86>
	}

	return fd2num(fd);
  801822:	83 ec 0c             	sub    $0xc,%esp
  801825:	ff 75 f4             	pushl  -0xc(%ebp)
  801828:	e8 4b f8 ff ff       	call   801078 <fd2num>
  80182d:	89 c2                	mov    %eax,%edx
  80182f:	83 c4 10             	add    $0x10,%esp
  801832:	eb 05                	jmp    801839 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801834:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801839:	89 d0                	mov    %edx,%eax
  80183b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80183e:	c9                   	leave  
  80183f:	c3                   	ret    

00801840 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801840:	55                   	push   %ebp
  801841:	89 e5                	mov    %esp,%ebp
  801843:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801846:	ba 00 00 00 00       	mov    $0x0,%edx
  80184b:	b8 08 00 00 00       	mov    $0x8,%eax
  801850:	e8 d2 fd ff ff       	call   801627 <fsipc>
}
  801855:	c9                   	leave  
  801856:	c3                   	ret    

00801857 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801857:	55                   	push   %ebp
  801858:	89 e5                	mov    %esp,%ebp
  80185a:	56                   	push   %esi
  80185b:	53                   	push   %ebx
  80185c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  80185f:	83 ec 0c             	sub    $0xc,%esp
  801862:	ff 75 08             	pushl  0x8(%ebp)
  801865:	e8 1e f8 ff ff       	call   801088 <fd2data>
  80186a:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  80186c:	83 c4 08             	add    $0x8,%esp
  80186f:	68 d5 25 80 00       	push   $0x8025d5
  801874:	53                   	push   %ebx
  801875:	e8 bc ee ff ff       	call   800736 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  80187a:	8b 46 04             	mov    0x4(%esi),%eax
  80187d:	2b 06                	sub    (%esi),%eax
  80187f:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801885:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80188c:	00 00 00 
	stat->st_dev = &devpipe;
  80188f:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801896:	30 80 00 
	return 0;
}
  801899:	b8 00 00 00 00       	mov    $0x0,%eax
  80189e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018a1:	5b                   	pop    %ebx
  8018a2:	5e                   	pop    %esi
  8018a3:	5d                   	pop    %ebp
  8018a4:	c3                   	ret    

008018a5 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8018a5:	55                   	push   %ebp
  8018a6:	89 e5                	mov    %esp,%ebp
  8018a8:	53                   	push   %ebx
  8018a9:	83 ec 0c             	sub    $0xc,%esp
  8018ac:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8018af:	53                   	push   %ebx
  8018b0:	6a 00                	push   $0x0
  8018b2:	e8 07 f3 ff ff       	call   800bbe <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8018b7:	89 1c 24             	mov    %ebx,(%esp)
  8018ba:	e8 c9 f7 ff ff       	call   801088 <fd2data>
  8018bf:	83 c4 08             	add    $0x8,%esp
  8018c2:	50                   	push   %eax
  8018c3:	6a 00                	push   $0x0
  8018c5:	e8 f4 f2 ff ff       	call   800bbe <sys_page_unmap>
}
  8018ca:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018cd:	c9                   	leave  
  8018ce:	c3                   	ret    

008018cf <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8018cf:	55                   	push   %ebp
  8018d0:	89 e5                	mov    %esp,%ebp
  8018d2:	57                   	push   %edi
  8018d3:	56                   	push   %esi
  8018d4:	53                   	push   %ebx
  8018d5:	83 ec 1c             	sub    $0x1c,%esp
  8018d8:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8018db:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8018dd:	a1 04 40 80 00       	mov    0x804004,%eax
  8018e2:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  8018e5:	83 ec 0c             	sub    $0xc,%esp
  8018e8:	ff 75 e0             	pushl  -0x20(%ebp)
  8018eb:	e8 f7 04 00 00       	call   801de7 <pageref>
  8018f0:	89 c3                	mov    %eax,%ebx
  8018f2:	89 3c 24             	mov    %edi,(%esp)
  8018f5:	e8 ed 04 00 00       	call   801de7 <pageref>
  8018fa:	83 c4 10             	add    $0x10,%esp
  8018fd:	39 c3                	cmp    %eax,%ebx
  8018ff:	0f 94 c1             	sete   %cl
  801902:	0f b6 c9             	movzbl %cl,%ecx
  801905:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801908:	8b 15 04 40 80 00    	mov    0x804004,%edx
  80190e:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801911:	39 ce                	cmp    %ecx,%esi
  801913:	74 1b                	je     801930 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801915:	39 c3                	cmp    %eax,%ebx
  801917:	75 c4                	jne    8018dd <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801919:	8b 42 58             	mov    0x58(%edx),%eax
  80191c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80191f:	50                   	push   %eax
  801920:	56                   	push   %esi
  801921:	68 dc 25 80 00       	push   $0x8025dc
  801926:	e8 86 e8 ff ff       	call   8001b1 <cprintf>
  80192b:	83 c4 10             	add    $0x10,%esp
  80192e:	eb ad                	jmp    8018dd <_pipeisclosed+0xe>
	}
}
  801930:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801933:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801936:	5b                   	pop    %ebx
  801937:	5e                   	pop    %esi
  801938:	5f                   	pop    %edi
  801939:	5d                   	pop    %ebp
  80193a:	c3                   	ret    

0080193b <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80193b:	55                   	push   %ebp
  80193c:	89 e5                	mov    %esp,%ebp
  80193e:	57                   	push   %edi
  80193f:	56                   	push   %esi
  801940:	53                   	push   %ebx
  801941:	83 ec 28             	sub    $0x28,%esp
  801944:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801947:	56                   	push   %esi
  801948:	e8 3b f7 ff ff       	call   801088 <fd2data>
  80194d:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80194f:	83 c4 10             	add    $0x10,%esp
  801952:	bf 00 00 00 00       	mov    $0x0,%edi
  801957:	eb 4b                	jmp    8019a4 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801959:	89 da                	mov    %ebx,%edx
  80195b:	89 f0                	mov    %esi,%eax
  80195d:	e8 6d ff ff ff       	call   8018cf <_pipeisclosed>
  801962:	85 c0                	test   %eax,%eax
  801964:	75 48                	jne    8019ae <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801966:	e8 af f1 ff ff       	call   800b1a <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80196b:	8b 43 04             	mov    0x4(%ebx),%eax
  80196e:	8b 0b                	mov    (%ebx),%ecx
  801970:	8d 51 20             	lea    0x20(%ecx),%edx
  801973:	39 d0                	cmp    %edx,%eax
  801975:	73 e2                	jae    801959 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801977:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80197a:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  80197e:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801981:	89 c2                	mov    %eax,%edx
  801983:	c1 fa 1f             	sar    $0x1f,%edx
  801986:	89 d1                	mov    %edx,%ecx
  801988:	c1 e9 1b             	shr    $0x1b,%ecx
  80198b:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  80198e:	83 e2 1f             	and    $0x1f,%edx
  801991:	29 ca                	sub    %ecx,%edx
  801993:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801997:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  80199b:	83 c0 01             	add    $0x1,%eax
  80199e:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8019a1:	83 c7 01             	add    $0x1,%edi
  8019a4:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8019a7:	75 c2                	jne    80196b <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8019a9:	8b 45 10             	mov    0x10(%ebp),%eax
  8019ac:	eb 05                	jmp    8019b3 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8019ae:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8019b3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8019b6:	5b                   	pop    %ebx
  8019b7:	5e                   	pop    %esi
  8019b8:	5f                   	pop    %edi
  8019b9:	5d                   	pop    %ebp
  8019ba:	c3                   	ret    

008019bb <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8019bb:	55                   	push   %ebp
  8019bc:	89 e5                	mov    %esp,%ebp
  8019be:	57                   	push   %edi
  8019bf:	56                   	push   %esi
  8019c0:	53                   	push   %ebx
  8019c1:	83 ec 18             	sub    $0x18,%esp
  8019c4:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8019c7:	57                   	push   %edi
  8019c8:	e8 bb f6 ff ff       	call   801088 <fd2data>
  8019cd:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8019cf:	83 c4 10             	add    $0x10,%esp
  8019d2:	bb 00 00 00 00       	mov    $0x0,%ebx
  8019d7:	eb 3d                	jmp    801a16 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8019d9:	85 db                	test   %ebx,%ebx
  8019db:	74 04                	je     8019e1 <devpipe_read+0x26>
				return i;
  8019dd:	89 d8                	mov    %ebx,%eax
  8019df:	eb 44                	jmp    801a25 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8019e1:	89 f2                	mov    %esi,%edx
  8019e3:	89 f8                	mov    %edi,%eax
  8019e5:	e8 e5 fe ff ff       	call   8018cf <_pipeisclosed>
  8019ea:	85 c0                	test   %eax,%eax
  8019ec:	75 32                	jne    801a20 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8019ee:	e8 27 f1 ff ff       	call   800b1a <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8019f3:	8b 06                	mov    (%esi),%eax
  8019f5:	3b 46 04             	cmp    0x4(%esi),%eax
  8019f8:	74 df                	je     8019d9 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8019fa:	99                   	cltd   
  8019fb:	c1 ea 1b             	shr    $0x1b,%edx
  8019fe:	01 d0                	add    %edx,%eax
  801a00:	83 e0 1f             	and    $0x1f,%eax
  801a03:	29 d0                	sub    %edx,%eax
  801a05:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801a0a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a0d:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801a10:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a13:	83 c3 01             	add    $0x1,%ebx
  801a16:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801a19:	75 d8                	jne    8019f3 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801a1b:	8b 45 10             	mov    0x10(%ebp),%eax
  801a1e:	eb 05                	jmp    801a25 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801a20:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801a25:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a28:	5b                   	pop    %ebx
  801a29:	5e                   	pop    %esi
  801a2a:	5f                   	pop    %edi
  801a2b:	5d                   	pop    %ebp
  801a2c:	c3                   	ret    

00801a2d <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801a2d:	55                   	push   %ebp
  801a2e:	89 e5                	mov    %esp,%ebp
  801a30:	56                   	push   %esi
  801a31:	53                   	push   %ebx
  801a32:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801a35:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a38:	50                   	push   %eax
  801a39:	e8 61 f6 ff ff       	call   80109f <fd_alloc>
  801a3e:	83 c4 10             	add    $0x10,%esp
  801a41:	89 c2                	mov    %eax,%edx
  801a43:	85 c0                	test   %eax,%eax
  801a45:	0f 88 2c 01 00 00    	js     801b77 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a4b:	83 ec 04             	sub    $0x4,%esp
  801a4e:	68 07 04 00 00       	push   $0x407
  801a53:	ff 75 f4             	pushl  -0xc(%ebp)
  801a56:	6a 00                	push   $0x0
  801a58:	e8 dc f0 ff ff       	call   800b39 <sys_page_alloc>
  801a5d:	83 c4 10             	add    $0x10,%esp
  801a60:	89 c2                	mov    %eax,%edx
  801a62:	85 c0                	test   %eax,%eax
  801a64:	0f 88 0d 01 00 00    	js     801b77 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801a6a:	83 ec 0c             	sub    $0xc,%esp
  801a6d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801a70:	50                   	push   %eax
  801a71:	e8 29 f6 ff ff       	call   80109f <fd_alloc>
  801a76:	89 c3                	mov    %eax,%ebx
  801a78:	83 c4 10             	add    $0x10,%esp
  801a7b:	85 c0                	test   %eax,%eax
  801a7d:	0f 88 e2 00 00 00    	js     801b65 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a83:	83 ec 04             	sub    $0x4,%esp
  801a86:	68 07 04 00 00       	push   $0x407
  801a8b:	ff 75 f0             	pushl  -0x10(%ebp)
  801a8e:	6a 00                	push   $0x0
  801a90:	e8 a4 f0 ff ff       	call   800b39 <sys_page_alloc>
  801a95:	89 c3                	mov    %eax,%ebx
  801a97:	83 c4 10             	add    $0x10,%esp
  801a9a:	85 c0                	test   %eax,%eax
  801a9c:	0f 88 c3 00 00 00    	js     801b65 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801aa2:	83 ec 0c             	sub    $0xc,%esp
  801aa5:	ff 75 f4             	pushl  -0xc(%ebp)
  801aa8:	e8 db f5 ff ff       	call   801088 <fd2data>
  801aad:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801aaf:	83 c4 0c             	add    $0xc,%esp
  801ab2:	68 07 04 00 00       	push   $0x407
  801ab7:	50                   	push   %eax
  801ab8:	6a 00                	push   $0x0
  801aba:	e8 7a f0 ff ff       	call   800b39 <sys_page_alloc>
  801abf:	89 c3                	mov    %eax,%ebx
  801ac1:	83 c4 10             	add    $0x10,%esp
  801ac4:	85 c0                	test   %eax,%eax
  801ac6:	0f 88 89 00 00 00    	js     801b55 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801acc:	83 ec 0c             	sub    $0xc,%esp
  801acf:	ff 75 f0             	pushl  -0x10(%ebp)
  801ad2:	e8 b1 f5 ff ff       	call   801088 <fd2data>
  801ad7:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801ade:	50                   	push   %eax
  801adf:	6a 00                	push   $0x0
  801ae1:	56                   	push   %esi
  801ae2:	6a 00                	push   $0x0
  801ae4:	e8 93 f0 ff ff       	call   800b7c <sys_page_map>
  801ae9:	89 c3                	mov    %eax,%ebx
  801aeb:	83 c4 20             	add    $0x20,%esp
  801aee:	85 c0                	test   %eax,%eax
  801af0:	78 55                	js     801b47 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801af2:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801af8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801afb:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801afd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b00:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801b07:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801b0d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b10:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801b12:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b15:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801b1c:	83 ec 0c             	sub    $0xc,%esp
  801b1f:	ff 75 f4             	pushl  -0xc(%ebp)
  801b22:	e8 51 f5 ff ff       	call   801078 <fd2num>
  801b27:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b2a:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801b2c:	83 c4 04             	add    $0x4,%esp
  801b2f:	ff 75 f0             	pushl  -0x10(%ebp)
  801b32:	e8 41 f5 ff ff       	call   801078 <fd2num>
  801b37:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b3a:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801b3d:	83 c4 10             	add    $0x10,%esp
  801b40:	ba 00 00 00 00       	mov    $0x0,%edx
  801b45:	eb 30                	jmp    801b77 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801b47:	83 ec 08             	sub    $0x8,%esp
  801b4a:	56                   	push   %esi
  801b4b:	6a 00                	push   $0x0
  801b4d:	e8 6c f0 ff ff       	call   800bbe <sys_page_unmap>
  801b52:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801b55:	83 ec 08             	sub    $0x8,%esp
  801b58:	ff 75 f0             	pushl  -0x10(%ebp)
  801b5b:	6a 00                	push   $0x0
  801b5d:	e8 5c f0 ff ff       	call   800bbe <sys_page_unmap>
  801b62:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801b65:	83 ec 08             	sub    $0x8,%esp
  801b68:	ff 75 f4             	pushl  -0xc(%ebp)
  801b6b:	6a 00                	push   $0x0
  801b6d:	e8 4c f0 ff ff       	call   800bbe <sys_page_unmap>
  801b72:	83 c4 10             	add    $0x10,%esp
  801b75:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801b77:	89 d0                	mov    %edx,%eax
  801b79:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b7c:	5b                   	pop    %ebx
  801b7d:	5e                   	pop    %esi
  801b7e:	5d                   	pop    %ebp
  801b7f:	c3                   	ret    

00801b80 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801b80:	55                   	push   %ebp
  801b81:	89 e5                	mov    %esp,%ebp
  801b83:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801b86:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b89:	50                   	push   %eax
  801b8a:	ff 75 08             	pushl  0x8(%ebp)
  801b8d:	e8 5c f5 ff ff       	call   8010ee <fd_lookup>
  801b92:	83 c4 10             	add    $0x10,%esp
  801b95:	85 c0                	test   %eax,%eax
  801b97:	78 18                	js     801bb1 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801b99:	83 ec 0c             	sub    $0xc,%esp
  801b9c:	ff 75 f4             	pushl  -0xc(%ebp)
  801b9f:	e8 e4 f4 ff ff       	call   801088 <fd2data>
	return _pipeisclosed(fd, p);
  801ba4:	89 c2                	mov    %eax,%edx
  801ba6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ba9:	e8 21 fd ff ff       	call   8018cf <_pipeisclosed>
  801bae:	83 c4 10             	add    $0x10,%esp
}
  801bb1:	c9                   	leave  
  801bb2:	c3                   	ret    

00801bb3 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801bb3:	55                   	push   %ebp
  801bb4:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801bb6:	b8 00 00 00 00       	mov    $0x0,%eax
  801bbb:	5d                   	pop    %ebp
  801bbc:	c3                   	ret    

00801bbd <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801bbd:	55                   	push   %ebp
  801bbe:	89 e5                	mov    %esp,%ebp
  801bc0:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801bc3:	68 f4 25 80 00       	push   $0x8025f4
  801bc8:	ff 75 0c             	pushl  0xc(%ebp)
  801bcb:	e8 66 eb ff ff       	call   800736 <strcpy>
	return 0;
}
  801bd0:	b8 00 00 00 00       	mov    $0x0,%eax
  801bd5:	c9                   	leave  
  801bd6:	c3                   	ret    

00801bd7 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801bd7:	55                   	push   %ebp
  801bd8:	89 e5                	mov    %esp,%ebp
  801bda:	57                   	push   %edi
  801bdb:	56                   	push   %esi
  801bdc:	53                   	push   %ebx
  801bdd:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801be3:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801be8:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801bee:	eb 2d                	jmp    801c1d <devcons_write+0x46>
		m = n - tot;
  801bf0:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801bf3:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801bf5:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801bf8:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801bfd:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801c00:	83 ec 04             	sub    $0x4,%esp
  801c03:	53                   	push   %ebx
  801c04:	03 45 0c             	add    0xc(%ebp),%eax
  801c07:	50                   	push   %eax
  801c08:	57                   	push   %edi
  801c09:	e8 ba ec ff ff       	call   8008c8 <memmove>
		sys_cputs(buf, m);
  801c0e:	83 c4 08             	add    $0x8,%esp
  801c11:	53                   	push   %ebx
  801c12:	57                   	push   %edi
  801c13:	e8 65 ee ff ff       	call   800a7d <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801c18:	01 de                	add    %ebx,%esi
  801c1a:	83 c4 10             	add    $0x10,%esp
  801c1d:	89 f0                	mov    %esi,%eax
  801c1f:	3b 75 10             	cmp    0x10(%ebp),%esi
  801c22:	72 cc                	jb     801bf0 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801c24:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c27:	5b                   	pop    %ebx
  801c28:	5e                   	pop    %esi
  801c29:	5f                   	pop    %edi
  801c2a:	5d                   	pop    %ebp
  801c2b:	c3                   	ret    

00801c2c <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801c2c:	55                   	push   %ebp
  801c2d:	89 e5                	mov    %esp,%ebp
  801c2f:	83 ec 08             	sub    $0x8,%esp
  801c32:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801c37:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801c3b:	74 2a                	je     801c67 <devcons_read+0x3b>
  801c3d:	eb 05                	jmp    801c44 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801c3f:	e8 d6 ee ff ff       	call   800b1a <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801c44:	e8 52 ee ff ff       	call   800a9b <sys_cgetc>
  801c49:	85 c0                	test   %eax,%eax
  801c4b:	74 f2                	je     801c3f <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801c4d:	85 c0                	test   %eax,%eax
  801c4f:	78 16                	js     801c67 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801c51:	83 f8 04             	cmp    $0x4,%eax
  801c54:	74 0c                	je     801c62 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801c56:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c59:	88 02                	mov    %al,(%edx)
	return 1;
  801c5b:	b8 01 00 00 00       	mov    $0x1,%eax
  801c60:	eb 05                	jmp    801c67 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801c62:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801c67:	c9                   	leave  
  801c68:	c3                   	ret    

00801c69 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801c69:	55                   	push   %ebp
  801c6a:	89 e5                	mov    %esp,%ebp
  801c6c:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801c6f:	8b 45 08             	mov    0x8(%ebp),%eax
  801c72:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801c75:	6a 01                	push   $0x1
  801c77:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801c7a:	50                   	push   %eax
  801c7b:	e8 fd ed ff ff       	call   800a7d <sys_cputs>
}
  801c80:	83 c4 10             	add    $0x10,%esp
  801c83:	c9                   	leave  
  801c84:	c3                   	ret    

00801c85 <getchar>:

int
getchar(void)
{
  801c85:	55                   	push   %ebp
  801c86:	89 e5                	mov    %esp,%ebp
  801c88:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801c8b:	6a 01                	push   $0x1
  801c8d:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801c90:	50                   	push   %eax
  801c91:	6a 00                	push   $0x0
  801c93:	e8 bc f6 ff ff       	call   801354 <read>
	if (r < 0)
  801c98:	83 c4 10             	add    $0x10,%esp
  801c9b:	85 c0                	test   %eax,%eax
  801c9d:	78 0f                	js     801cae <getchar+0x29>
		return r;
	if (r < 1)
  801c9f:	85 c0                	test   %eax,%eax
  801ca1:	7e 06                	jle    801ca9 <getchar+0x24>
		return -E_EOF;
	return c;
  801ca3:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801ca7:	eb 05                	jmp    801cae <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801ca9:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801cae:	c9                   	leave  
  801caf:	c3                   	ret    

00801cb0 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801cb0:	55                   	push   %ebp
  801cb1:	89 e5                	mov    %esp,%ebp
  801cb3:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801cb6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801cb9:	50                   	push   %eax
  801cba:	ff 75 08             	pushl  0x8(%ebp)
  801cbd:	e8 2c f4 ff ff       	call   8010ee <fd_lookup>
  801cc2:	83 c4 10             	add    $0x10,%esp
  801cc5:	85 c0                	test   %eax,%eax
  801cc7:	78 11                	js     801cda <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801cc9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ccc:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801cd2:	39 10                	cmp    %edx,(%eax)
  801cd4:	0f 94 c0             	sete   %al
  801cd7:	0f b6 c0             	movzbl %al,%eax
}
  801cda:	c9                   	leave  
  801cdb:	c3                   	ret    

00801cdc <opencons>:

int
opencons(void)
{
  801cdc:	55                   	push   %ebp
  801cdd:	89 e5                	mov    %esp,%ebp
  801cdf:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801ce2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ce5:	50                   	push   %eax
  801ce6:	e8 b4 f3 ff ff       	call   80109f <fd_alloc>
  801ceb:	83 c4 10             	add    $0x10,%esp
		return r;
  801cee:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801cf0:	85 c0                	test   %eax,%eax
  801cf2:	78 3e                	js     801d32 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801cf4:	83 ec 04             	sub    $0x4,%esp
  801cf7:	68 07 04 00 00       	push   $0x407
  801cfc:	ff 75 f4             	pushl  -0xc(%ebp)
  801cff:	6a 00                	push   $0x0
  801d01:	e8 33 ee ff ff       	call   800b39 <sys_page_alloc>
  801d06:	83 c4 10             	add    $0x10,%esp
		return r;
  801d09:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801d0b:	85 c0                	test   %eax,%eax
  801d0d:	78 23                	js     801d32 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801d0f:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801d15:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d18:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801d1a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d1d:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801d24:	83 ec 0c             	sub    $0xc,%esp
  801d27:	50                   	push   %eax
  801d28:	e8 4b f3 ff ff       	call   801078 <fd2num>
  801d2d:	89 c2                	mov    %eax,%edx
  801d2f:	83 c4 10             	add    $0x10,%esp
}
  801d32:	89 d0                	mov    %edx,%eax
  801d34:	c9                   	leave  
  801d35:	c3                   	ret    

00801d36 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801d36:	55                   	push   %ebp
  801d37:	89 e5                	mov    %esp,%ebp
  801d39:	56                   	push   %esi
  801d3a:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801d3b:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801d3e:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801d44:	e8 b2 ed ff ff       	call   800afb <sys_getenvid>
  801d49:	83 ec 0c             	sub    $0xc,%esp
  801d4c:	ff 75 0c             	pushl  0xc(%ebp)
  801d4f:	ff 75 08             	pushl  0x8(%ebp)
  801d52:	56                   	push   %esi
  801d53:	50                   	push   %eax
  801d54:	68 00 26 80 00       	push   $0x802600
  801d59:	e8 53 e4 ff ff       	call   8001b1 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801d5e:	83 c4 18             	add    $0x18,%esp
  801d61:	53                   	push   %ebx
  801d62:	ff 75 10             	pushl  0x10(%ebp)
  801d65:	e8 f6 e3 ff ff       	call   800160 <vcprintf>
	cprintf("\n");
  801d6a:	c7 04 24 ed 25 80 00 	movl   $0x8025ed,(%esp)
  801d71:	e8 3b e4 ff ff       	call   8001b1 <cprintf>
  801d76:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801d79:	cc                   	int3   
  801d7a:	eb fd                	jmp    801d79 <_panic+0x43>

00801d7c <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801d7c:	55                   	push   %ebp
  801d7d:	89 e5                	mov    %esp,%ebp
  801d7f:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801d82:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801d89:	75 2e                	jne    801db9 <set_pgfault_handler+0x3d>
		// First time through!
		// LAB 4: Your code here.
		// panic("set_pgfault_handler not implemented");

		sys_page_alloc(sys_getenvid(), (void *) (UXSTACKTOP - PGSIZE), PTE_SYSCALL);
  801d8b:	e8 6b ed ff ff       	call   800afb <sys_getenvid>
  801d90:	83 ec 04             	sub    $0x4,%esp
  801d93:	68 07 0e 00 00       	push   $0xe07
  801d98:	68 00 f0 bf ee       	push   $0xeebff000
  801d9d:	50                   	push   %eax
  801d9e:	e8 96 ed ff ff       	call   800b39 <sys_page_alloc>
		sys_env_set_pgfault_upcall(sys_getenvid(), _pgfault_upcall);
  801da3:	e8 53 ed ff ff       	call   800afb <sys_getenvid>
  801da8:	83 c4 08             	add    $0x8,%esp
  801dab:	68 c3 1d 80 00       	push   $0x801dc3
  801db0:	50                   	push   %eax
  801db1:	e8 ce ee ff ff       	call   800c84 <sys_env_set_pgfault_upcall>
  801db6:	83 c4 10             	add    $0x10,%esp
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801db9:	8b 45 08             	mov    0x8(%ebp),%eax
  801dbc:	a3 00 60 80 00       	mov    %eax,0x806000
}
  801dc1:	c9                   	leave  
  801dc2:	c3                   	ret    

00801dc3 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801dc3:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801dc4:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801dc9:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801dcb:	83 c4 04             	add    $0x4,%esp
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.

	movl 48(%esp), %eax		// trap-time esp
  801dce:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl 40(%esp), %ebx		// trap-time eip
  801dd2:	8b 5c 24 28          	mov    0x28(%esp),%ebx

	// load eip into esp-4
	// in order to return to trap-time eip later, in the meantime not changing trap-time esp
	movl %ebx, -4(%eax)	
  801dd6:	89 58 fc             	mov    %ebx,-0x4(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.

	addl $8, %esp 			// esp now points to trap-time registers
  801dd9:	83 c4 08             	add    $0x8,%esp
	popal					// pop to all registers
  801ddc:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

	addl $4, %esp			// esp now points to trap-time eflags
  801ddd:	83 c4 04             	add    $0x4,%esp
	popfl					// pop to eflags
  801de0:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.

	popl %esp				// pop to esp
  801de1:	5c                   	pop    %esp
	// subl $4, %esp		// arithmetic operation will change eflags!!!
	lea -4(%esp), %esp		// subl $4, %esp
  801de2:	8d 64 24 fc          	lea    -0x4(%esp),%esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.

	ret
  801de6:	c3                   	ret    

00801de7 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801de7:	55                   	push   %ebp
  801de8:	89 e5                	mov    %esp,%ebp
  801dea:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801ded:	89 d0                	mov    %edx,%eax
  801def:	c1 e8 16             	shr    $0x16,%eax
  801df2:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801df9:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801dfe:	f6 c1 01             	test   $0x1,%cl
  801e01:	74 1d                	je     801e20 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801e03:	c1 ea 0c             	shr    $0xc,%edx
  801e06:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801e0d:	f6 c2 01             	test   $0x1,%dl
  801e10:	74 0e                	je     801e20 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801e12:	c1 ea 0c             	shr    $0xc,%edx
  801e15:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801e1c:	ef 
  801e1d:	0f b7 c0             	movzwl %ax,%eax
}
  801e20:	5d                   	pop    %ebp
  801e21:	c3                   	ret    
  801e22:	66 90                	xchg   %ax,%ax
  801e24:	66 90                	xchg   %ax,%ax
  801e26:	66 90                	xchg   %ax,%ax
  801e28:	66 90                	xchg   %ax,%ax
  801e2a:	66 90                	xchg   %ax,%ax
  801e2c:	66 90                	xchg   %ax,%ax
  801e2e:	66 90                	xchg   %ax,%ax

00801e30 <__udivdi3>:
  801e30:	55                   	push   %ebp
  801e31:	57                   	push   %edi
  801e32:	56                   	push   %esi
  801e33:	53                   	push   %ebx
  801e34:	83 ec 1c             	sub    $0x1c,%esp
  801e37:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801e3b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801e3f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801e43:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801e47:	85 f6                	test   %esi,%esi
  801e49:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801e4d:	89 ca                	mov    %ecx,%edx
  801e4f:	89 f8                	mov    %edi,%eax
  801e51:	75 3d                	jne    801e90 <__udivdi3+0x60>
  801e53:	39 cf                	cmp    %ecx,%edi
  801e55:	0f 87 c5 00 00 00    	ja     801f20 <__udivdi3+0xf0>
  801e5b:	85 ff                	test   %edi,%edi
  801e5d:	89 fd                	mov    %edi,%ebp
  801e5f:	75 0b                	jne    801e6c <__udivdi3+0x3c>
  801e61:	b8 01 00 00 00       	mov    $0x1,%eax
  801e66:	31 d2                	xor    %edx,%edx
  801e68:	f7 f7                	div    %edi
  801e6a:	89 c5                	mov    %eax,%ebp
  801e6c:	89 c8                	mov    %ecx,%eax
  801e6e:	31 d2                	xor    %edx,%edx
  801e70:	f7 f5                	div    %ebp
  801e72:	89 c1                	mov    %eax,%ecx
  801e74:	89 d8                	mov    %ebx,%eax
  801e76:	89 cf                	mov    %ecx,%edi
  801e78:	f7 f5                	div    %ebp
  801e7a:	89 c3                	mov    %eax,%ebx
  801e7c:	89 d8                	mov    %ebx,%eax
  801e7e:	89 fa                	mov    %edi,%edx
  801e80:	83 c4 1c             	add    $0x1c,%esp
  801e83:	5b                   	pop    %ebx
  801e84:	5e                   	pop    %esi
  801e85:	5f                   	pop    %edi
  801e86:	5d                   	pop    %ebp
  801e87:	c3                   	ret    
  801e88:	90                   	nop
  801e89:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801e90:	39 ce                	cmp    %ecx,%esi
  801e92:	77 74                	ja     801f08 <__udivdi3+0xd8>
  801e94:	0f bd fe             	bsr    %esi,%edi
  801e97:	83 f7 1f             	xor    $0x1f,%edi
  801e9a:	0f 84 98 00 00 00    	je     801f38 <__udivdi3+0x108>
  801ea0:	bb 20 00 00 00       	mov    $0x20,%ebx
  801ea5:	89 f9                	mov    %edi,%ecx
  801ea7:	89 c5                	mov    %eax,%ebp
  801ea9:	29 fb                	sub    %edi,%ebx
  801eab:	d3 e6                	shl    %cl,%esi
  801ead:	89 d9                	mov    %ebx,%ecx
  801eaf:	d3 ed                	shr    %cl,%ebp
  801eb1:	89 f9                	mov    %edi,%ecx
  801eb3:	d3 e0                	shl    %cl,%eax
  801eb5:	09 ee                	or     %ebp,%esi
  801eb7:	89 d9                	mov    %ebx,%ecx
  801eb9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801ebd:	89 d5                	mov    %edx,%ebp
  801ebf:	8b 44 24 08          	mov    0x8(%esp),%eax
  801ec3:	d3 ed                	shr    %cl,%ebp
  801ec5:	89 f9                	mov    %edi,%ecx
  801ec7:	d3 e2                	shl    %cl,%edx
  801ec9:	89 d9                	mov    %ebx,%ecx
  801ecb:	d3 e8                	shr    %cl,%eax
  801ecd:	09 c2                	or     %eax,%edx
  801ecf:	89 d0                	mov    %edx,%eax
  801ed1:	89 ea                	mov    %ebp,%edx
  801ed3:	f7 f6                	div    %esi
  801ed5:	89 d5                	mov    %edx,%ebp
  801ed7:	89 c3                	mov    %eax,%ebx
  801ed9:	f7 64 24 0c          	mull   0xc(%esp)
  801edd:	39 d5                	cmp    %edx,%ebp
  801edf:	72 10                	jb     801ef1 <__udivdi3+0xc1>
  801ee1:	8b 74 24 08          	mov    0x8(%esp),%esi
  801ee5:	89 f9                	mov    %edi,%ecx
  801ee7:	d3 e6                	shl    %cl,%esi
  801ee9:	39 c6                	cmp    %eax,%esi
  801eeb:	73 07                	jae    801ef4 <__udivdi3+0xc4>
  801eed:	39 d5                	cmp    %edx,%ebp
  801eef:	75 03                	jne    801ef4 <__udivdi3+0xc4>
  801ef1:	83 eb 01             	sub    $0x1,%ebx
  801ef4:	31 ff                	xor    %edi,%edi
  801ef6:	89 d8                	mov    %ebx,%eax
  801ef8:	89 fa                	mov    %edi,%edx
  801efa:	83 c4 1c             	add    $0x1c,%esp
  801efd:	5b                   	pop    %ebx
  801efe:	5e                   	pop    %esi
  801eff:	5f                   	pop    %edi
  801f00:	5d                   	pop    %ebp
  801f01:	c3                   	ret    
  801f02:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801f08:	31 ff                	xor    %edi,%edi
  801f0a:	31 db                	xor    %ebx,%ebx
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
  801f20:	89 d8                	mov    %ebx,%eax
  801f22:	f7 f7                	div    %edi
  801f24:	31 ff                	xor    %edi,%edi
  801f26:	89 c3                	mov    %eax,%ebx
  801f28:	89 d8                	mov    %ebx,%eax
  801f2a:	89 fa                	mov    %edi,%edx
  801f2c:	83 c4 1c             	add    $0x1c,%esp
  801f2f:	5b                   	pop    %ebx
  801f30:	5e                   	pop    %esi
  801f31:	5f                   	pop    %edi
  801f32:	5d                   	pop    %ebp
  801f33:	c3                   	ret    
  801f34:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801f38:	39 ce                	cmp    %ecx,%esi
  801f3a:	72 0c                	jb     801f48 <__udivdi3+0x118>
  801f3c:	31 db                	xor    %ebx,%ebx
  801f3e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801f42:	0f 87 34 ff ff ff    	ja     801e7c <__udivdi3+0x4c>
  801f48:	bb 01 00 00 00       	mov    $0x1,%ebx
  801f4d:	e9 2a ff ff ff       	jmp    801e7c <__udivdi3+0x4c>
  801f52:	66 90                	xchg   %ax,%ax
  801f54:	66 90                	xchg   %ax,%ax
  801f56:	66 90                	xchg   %ax,%ax
  801f58:	66 90                	xchg   %ax,%ax
  801f5a:	66 90                	xchg   %ax,%ax
  801f5c:	66 90                	xchg   %ax,%ax
  801f5e:	66 90                	xchg   %ax,%ax

00801f60 <__umoddi3>:
  801f60:	55                   	push   %ebp
  801f61:	57                   	push   %edi
  801f62:	56                   	push   %esi
  801f63:	53                   	push   %ebx
  801f64:	83 ec 1c             	sub    $0x1c,%esp
  801f67:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801f6b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801f6f:	8b 74 24 34          	mov    0x34(%esp),%esi
  801f73:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801f77:	85 d2                	test   %edx,%edx
  801f79:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801f7d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801f81:	89 f3                	mov    %esi,%ebx
  801f83:	89 3c 24             	mov    %edi,(%esp)
  801f86:	89 74 24 04          	mov    %esi,0x4(%esp)
  801f8a:	75 1c                	jne    801fa8 <__umoddi3+0x48>
  801f8c:	39 f7                	cmp    %esi,%edi
  801f8e:	76 50                	jbe    801fe0 <__umoddi3+0x80>
  801f90:	89 c8                	mov    %ecx,%eax
  801f92:	89 f2                	mov    %esi,%edx
  801f94:	f7 f7                	div    %edi
  801f96:	89 d0                	mov    %edx,%eax
  801f98:	31 d2                	xor    %edx,%edx
  801f9a:	83 c4 1c             	add    $0x1c,%esp
  801f9d:	5b                   	pop    %ebx
  801f9e:	5e                   	pop    %esi
  801f9f:	5f                   	pop    %edi
  801fa0:	5d                   	pop    %ebp
  801fa1:	c3                   	ret    
  801fa2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801fa8:	39 f2                	cmp    %esi,%edx
  801faa:	89 d0                	mov    %edx,%eax
  801fac:	77 52                	ja     802000 <__umoddi3+0xa0>
  801fae:	0f bd ea             	bsr    %edx,%ebp
  801fb1:	83 f5 1f             	xor    $0x1f,%ebp
  801fb4:	75 5a                	jne    802010 <__umoddi3+0xb0>
  801fb6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  801fba:	0f 82 e0 00 00 00    	jb     8020a0 <__umoddi3+0x140>
  801fc0:	39 0c 24             	cmp    %ecx,(%esp)
  801fc3:	0f 86 d7 00 00 00    	jbe    8020a0 <__umoddi3+0x140>
  801fc9:	8b 44 24 08          	mov    0x8(%esp),%eax
  801fcd:	8b 54 24 04          	mov    0x4(%esp),%edx
  801fd1:	83 c4 1c             	add    $0x1c,%esp
  801fd4:	5b                   	pop    %ebx
  801fd5:	5e                   	pop    %esi
  801fd6:	5f                   	pop    %edi
  801fd7:	5d                   	pop    %ebp
  801fd8:	c3                   	ret    
  801fd9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801fe0:	85 ff                	test   %edi,%edi
  801fe2:	89 fd                	mov    %edi,%ebp
  801fe4:	75 0b                	jne    801ff1 <__umoddi3+0x91>
  801fe6:	b8 01 00 00 00       	mov    $0x1,%eax
  801feb:	31 d2                	xor    %edx,%edx
  801fed:	f7 f7                	div    %edi
  801fef:	89 c5                	mov    %eax,%ebp
  801ff1:	89 f0                	mov    %esi,%eax
  801ff3:	31 d2                	xor    %edx,%edx
  801ff5:	f7 f5                	div    %ebp
  801ff7:	89 c8                	mov    %ecx,%eax
  801ff9:	f7 f5                	div    %ebp
  801ffb:	89 d0                	mov    %edx,%eax
  801ffd:	eb 99                	jmp    801f98 <__umoddi3+0x38>
  801fff:	90                   	nop
  802000:	89 c8                	mov    %ecx,%eax
  802002:	89 f2                	mov    %esi,%edx
  802004:	83 c4 1c             	add    $0x1c,%esp
  802007:	5b                   	pop    %ebx
  802008:	5e                   	pop    %esi
  802009:	5f                   	pop    %edi
  80200a:	5d                   	pop    %ebp
  80200b:	c3                   	ret    
  80200c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802010:	8b 34 24             	mov    (%esp),%esi
  802013:	bf 20 00 00 00       	mov    $0x20,%edi
  802018:	89 e9                	mov    %ebp,%ecx
  80201a:	29 ef                	sub    %ebp,%edi
  80201c:	d3 e0                	shl    %cl,%eax
  80201e:	89 f9                	mov    %edi,%ecx
  802020:	89 f2                	mov    %esi,%edx
  802022:	d3 ea                	shr    %cl,%edx
  802024:	89 e9                	mov    %ebp,%ecx
  802026:	09 c2                	or     %eax,%edx
  802028:	89 d8                	mov    %ebx,%eax
  80202a:	89 14 24             	mov    %edx,(%esp)
  80202d:	89 f2                	mov    %esi,%edx
  80202f:	d3 e2                	shl    %cl,%edx
  802031:	89 f9                	mov    %edi,%ecx
  802033:	89 54 24 04          	mov    %edx,0x4(%esp)
  802037:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80203b:	d3 e8                	shr    %cl,%eax
  80203d:	89 e9                	mov    %ebp,%ecx
  80203f:	89 c6                	mov    %eax,%esi
  802041:	d3 e3                	shl    %cl,%ebx
  802043:	89 f9                	mov    %edi,%ecx
  802045:	89 d0                	mov    %edx,%eax
  802047:	d3 e8                	shr    %cl,%eax
  802049:	89 e9                	mov    %ebp,%ecx
  80204b:	09 d8                	or     %ebx,%eax
  80204d:	89 d3                	mov    %edx,%ebx
  80204f:	89 f2                	mov    %esi,%edx
  802051:	f7 34 24             	divl   (%esp)
  802054:	89 d6                	mov    %edx,%esi
  802056:	d3 e3                	shl    %cl,%ebx
  802058:	f7 64 24 04          	mull   0x4(%esp)
  80205c:	39 d6                	cmp    %edx,%esi
  80205e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802062:	89 d1                	mov    %edx,%ecx
  802064:	89 c3                	mov    %eax,%ebx
  802066:	72 08                	jb     802070 <__umoddi3+0x110>
  802068:	75 11                	jne    80207b <__umoddi3+0x11b>
  80206a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80206e:	73 0b                	jae    80207b <__umoddi3+0x11b>
  802070:	2b 44 24 04          	sub    0x4(%esp),%eax
  802074:	1b 14 24             	sbb    (%esp),%edx
  802077:	89 d1                	mov    %edx,%ecx
  802079:	89 c3                	mov    %eax,%ebx
  80207b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80207f:	29 da                	sub    %ebx,%edx
  802081:	19 ce                	sbb    %ecx,%esi
  802083:	89 f9                	mov    %edi,%ecx
  802085:	89 f0                	mov    %esi,%eax
  802087:	d3 e0                	shl    %cl,%eax
  802089:	89 e9                	mov    %ebp,%ecx
  80208b:	d3 ea                	shr    %cl,%edx
  80208d:	89 e9                	mov    %ebp,%ecx
  80208f:	d3 ee                	shr    %cl,%esi
  802091:	09 d0                	or     %edx,%eax
  802093:	89 f2                	mov    %esi,%edx
  802095:	83 c4 1c             	add    $0x1c,%esp
  802098:	5b                   	pop    %ebx
  802099:	5e                   	pop    %esi
  80209a:	5f                   	pop    %edi
  80209b:	5d                   	pop    %ebp
  80209c:	c3                   	ret    
  80209d:	8d 76 00             	lea    0x0(%esi),%esi
  8020a0:	29 f9                	sub    %edi,%ecx
  8020a2:	19 d6                	sbb    %edx,%esi
  8020a4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8020a8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8020ac:	e9 18 ff ff ff       	jmp    801fc9 <__umoddi3+0x69>
