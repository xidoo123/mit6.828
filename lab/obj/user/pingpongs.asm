
obj/user/pingpongs.debug:     file format elf32-i386


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
  80002c:	e8 cd 00 00 00       	call   8000fe <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

uint32_t val;

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 2c             	sub    $0x2c,%esp
	envid_t who;
	uint32_t i;

	i = 0;
	if ((who = sfork()) != 0) {
  80003c:	e8 e0 0f 00 00       	call   801021 <sfork>
  800041:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800044:	85 c0                	test   %eax,%eax
  800046:	74 42                	je     80008a <umain+0x57>
		cprintf("i am %08x; thisenv is %p\n", sys_getenvid(), thisenv);
  800048:	8b 1d 08 40 80 00    	mov    0x804008,%ebx
  80004e:	e8 e8 0a 00 00       	call   800b3b <sys_getenvid>
  800053:	83 ec 04             	sub    $0x4,%esp
  800056:	53                   	push   %ebx
  800057:	50                   	push   %eax
  800058:	68 a0 21 80 00       	push   $0x8021a0
  80005d:	e8 8f 01 00 00       	call   8001f1 <cprintf>
		// get the ball rolling
		cprintf("send 0 from %x to %x\n", sys_getenvid(), who);
  800062:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800065:	e8 d1 0a 00 00       	call   800b3b <sys_getenvid>
  80006a:	83 c4 0c             	add    $0xc,%esp
  80006d:	53                   	push   %ebx
  80006e:	50                   	push   %eax
  80006f:	68 ba 21 80 00       	push   $0x8021ba
  800074:	e8 78 01 00 00       	call   8001f1 <cprintf>
		ipc_send(who, 0, 0, 0);
  800079:	6a 00                	push   $0x0
  80007b:	6a 00                	push   $0x0
  80007d:	6a 00                	push   $0x0
  80007f:	ff 75 e4             	pushl  -0x1c(%ebp)
  800082:	e8 1b 10 00 00       	call   8010a2 <ipc_send>
  800087:	83 c4 20             	add    $0x20,%esp
	}

	while (1) {
		ipc_recv(&who, 0, 0);
  80008a:	83 ec 04             	sub    $0x4,%esp
  80008d:	6a 00                	push   $0x0
  80008f:	6a 00                	push   $0x0
  800091:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800094:	50                   	push   %eax
  800095:	e8 a1 0f 00 00       	call   80103b <ipc_recv>
		cprintf("%x got %d from %x (thisenv is %p %x)\n", sys_getenvid(), val, who, thisenv, thisenv->env_id);
  80009a:	8b 1d 08 40 80 00    	mov    0x804008,%ebx
  8000a0:	8b 7b 48             	mov    0x48(%ebx),%edi
  8000a3:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8000a6:	a1 04 40 80 00       	mov    0x804004,%eax
  8000ab:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8000ae:	e8 88 0a 00 00       	call   800b3b <sys_getenvid>
  8000b3:	83 c4 08             	add    $0x8,%esp
  8000b6:	57                   	push   %edi
  8000b7:	53                   	push   %ebx
  8000b8:	56                   	push   %esi
  8000b9:	ff 75 d4             	pushl  -0x2c(%ebp)
  8000bc:	50                   	push   %eax
  8000bd:	68 d0 21 80 00       	push   $0x8021d0
  8000c2:	e8 2a 01 00 00       	call   8001f1 <cprintf>
		if (val == 10)
  8000c7:	a1 04 40 80 00       	mov    0x804004,%eax
  8000cc:	83 c4 20             	add    $0x20,%esp
  8000cf:	83 f8 0a             	cmp    $0xa,%eax
  8000d2:	74 22                	je     8000f6 <umain+0xc3>
			return;
		++val;
  8000d4:	83 c0 01             	add    $0x1,%eax
  8000d7:	a3 04 40 80 00       	mov    %eax,0x804004
		ipc_send(who, 0, 0, 0);
  8000dc:	6a 00                	push   $0x0
  8000de:	6a 00                	push   $0x0
  8000e0:	6a 00                	push   $0x0
  8000e2:	ff 75 e4             	pushl  -0x1c(%ebp)
  8000e5:	e8 b8 0f 00 00       	call   8010a2 <ipc_send>
		if (val == 10)
  8000ea:	83 c4 10             	add    $0x10,%esp
  8000ed:	83 3d 04 40 80 00 0a 	cmpl   $0xa,0x804004
  8000f4:	75 94                	jne    80008a <umain+0x57>
			return;
	}

}
  8000f6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000f9:	5b                   	pop    %ebx
  8000fa:	5e                   	pop    %esi
  8000fb:	5f                   	pop    %edi
  8000fc:	5d                   	pop    %ebp
  8000fd:	c3                   	ret    

008000fe <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000fe:	55                   	push   %ebp
  8000ff:	89 e5                	mov    %esp,%ebp
  800101:	56                   	push   %esi
  800102:	53                   	push   %ebx
  800103:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800106:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800109:	e8 2d 0a 00 00       	call   800b3b <sys_getenvid>
  80010e:	25 ff 03 00 00       	and    $0x3ff,%eax
  800113:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800116:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80011b:	a3 08 40 80 00       	mov    %eax,0x804008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800120:	85 db                	test   %ebx,%ebx
  800122:	7e 07                	jle    80012b <libmain+0x2d>
		binaryname = argv[0];
  800124:	8b 06                	mov    (%esi),%eax
  800126:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80012b:	83 ec 08             	sub    $0x8,%esp
  80012e:	56                   	push   %esi
  80012f:	53                   	push   %ebx
  800130:	e8 fe fe ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800135:	e8 0a 00 00 00       	call   800144 <exit>
}
  80013a:	83 c4 10             	add    $0x10,%esp
  80013d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800140:	5b                   	pop    %ebx
  800141:	5e                   	pop    %esi
  800142:	5d                   	pop    %ebp
  800143:	c3                   	ret    

00800144 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800144:	55                   	push   %ebp
  800145:	89 e5                	mov    %esp,%ebp
  800147:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80014a:	e8 ab 11 00 00       	call   8012fa <close_all>
	sys_env_destroy(0);
  80014f:	83 ec 0c             	sub    $0xc,%esp
  800152:	6a 00                	push   $0x0
  800154:	e8 a1 09 00 00       	call   800afa <sys_env_destroy>
}
  800159:	83 c4 10             	add    $0x10,%esp
  80015c:	c9                   	leave  
  80015d:	c3                   	ret    

0080015e <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80015e:	55                   	push   %ebp
  80015f:	89 e5                	mov    %esp,%ebp
  800161:	53                   	push   %ebx
  800162:	83 ec 04             	sub    $0x4,%esp
  800165:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800168:	8b 13                	mov    (%ebx),%edx
  80016a:	8d 42 01             	lea    0x1(%edx),%eax
  80016d:	89 03                	mov    %eax,(%ebx)
  80016f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800172:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800176:	3d ff 00 00 00       	cmp    $0xff,%eax
  80017b:	75 1a                	jne    800197 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80017d:	83 ec 08             	sub    $0x8,%esp
  800180:	68 ff 00 00 00       	push   $0xff
  800185:	8d 43 08             	lea    0x8(%ebx),%eax
  800188:	50                   	push   %eax
  800189:	e8 2f 09 00 00       	call   800abd <sys_cputs>
		b->idx = 0;
  80018e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800194:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800197:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80019b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80019e:	c9                   	leave  
  80019f:	c3                   	ret    

008001a0 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001a0:	55                   	push   %ebp
  8001a1:	89 e5                	mov    %esp,%ebp
  8001a3:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001a9:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001b0:	00 00 00 
	b.cnt = 0;
  8001b3:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001ba:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001bd:	ff 75 0c             	pushl  0xc(%ebp)
  8001c0:	ff 75 08             	pushl  0x8(%ebp)
  8001c3:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001c9:	50                   	push   %eax
  8001ca:	68 5e 01 80 00       	push   $0x80015e
  8001cf:	e8 54 01 00 00       	call   800328 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001d4:	83 c4 08             	add    $0x8,%esp
  8001d7:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001dd:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001e3:	50                   	push   %eax
  8001e4:	e8 d4 08 00 00       	call   800abd <sys_cputs>

	return b.cnt;
}
  8001e9:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001ef:	c9                   	leave  
  8001f0:	c3                   	ret    

008001f1 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001f1:	55                   	push   %ebp
  8001f2:	89 e5                	mov    %esp,%ebp
  8001f4:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001f7:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001fa:	50                   	push   %eax
  8001fb:	ff 75 08             	pushl  0x8(%ebp)
  8001fe:	e8 9d ff ff ff       	call   8001a0 <vcprintf>
	va_end(ap);

	return cnt;
}
  800203:	c9                   	leave  
  800204:	c3                   	ret    

00800205 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800205:	55                   	push   %ebp
  800206:	89 e5                	mov    %esp,%ebp
  800208:	57                   	push   %edi
  800209:	56                   	push   %esi
  80020a:	53                   	push   %ebx
  80020b:	83 ec 1c             	sub    $0x1c,%esp
  80020e:	89 c7                	mov    %eax,%edi
  800210:	89 d6                	mov    %edx,%esi
  800212:	8b 45 08             	mov    0x8(%ebp),%eax
  800215:	8b 55 0c             	mov    0xc(%ebp),%edx
  800218:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80021b:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80021e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800221:	bb 00 00 00 00       	mov    $0x0,%ebx
  800226:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800229:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80022c:	39 d3                	cmp    %edx,%ebx
  80022e:	72 05                	jb     800235 <printnum+0x30>
  800230:	39 45 10             	cmp    %eax,0x10(%ebp)
  800233:	77 45                	ja     80027a <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800235:	83 ec 0c             	sub    $0xc,%esp
  800238:	ff 75 18             	pushl  0x18(%ebp)
  80023b:	8b 45 14             	mov    0x14(%ebp),%eax
  80023e:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800241:	53                   	push   %ebx
  800242:	ff 75 10             	pushl  0x10(%ebp)
  800245:	83 ec 08             	sub    $0x8,%esp
  800248:	ff 75 e4             	pushl  -0x1c(%ebp)
  80024b:	ff 75 e0             	pushl  -0x20(%ebp)
  80024e:	ff 75 dc             	pushl  -0x24(%ebp)
  800251:	ff 75 d8             	pushl  -0x28(%ebp)
  800254:	e8 a7 1c 00 00       	call   801f00 <__udivdi3>
  800259:	83 c4 18             	add    $0x18,%esp
  80025c:	52                   	push   %edx
  80025d:	50                   	push   %eax
  80025e:	89 f2                	mov    %esi,%edx
  800260:	89 f8                	mov    %edi,%eax
  800262:	e8 9e ff ff ff       	call   800205 <printnum>
  800267:	83 c4 20             	add    $0x20,%esp
  80026a:	eb 18                	jmp    800284 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80026c:	83 ec 08             	sub    $0x8,%esp
  80026f:	56                   	push   %esi
  800270:	ff 75 18             	pushl  0x18(%ebp)
  800273:	ff d7                	call   *%edi
  800275:	83 c4 10             	add    $0x10,%esp
  800278:	eb 03                	jmp    80027d <printnum+0x78>
  80027a:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80027d:	83 eb 01             	sub    $0x1,%ebx
  800280:	85 db                	test   %ebx,%ebx
  800282:	7f e8                	jg     80026c <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800284:	83 ec 08             	sub    $0x8,%esp
  800287:	56                   	push   %esi
  800288:	83 ec 04             	sub    $0x4,%esp
  80028b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80028e:	ff 75 e0             	pushl  -0x20(%ebp)
  800291:	ff 75 dc             	pushl  -0x24(%ebp)
  800294:	ff 75 d8             	pushl  -0x28(%ebp)
  800297:	e8 94 1d 00 00       	call   802030 <__umoddi3>
  80029c:	83 c4 14             	add    $0x14,%esp
  80029f:	0f be 80 00 22 80 00 	movsbl 0x802200(%eax),%eax
  8002a6:	50                   	push   %eax
  8002a7:	ff d7                	call   *%edi
}
  8002a9:	83 c4 10             	add    $0x10,%esp
  8002ac:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002af:	5b                   	pop    %ebx
  8002b0:	5e                   	pop    %esi
  8002b1:	5f                   	pop    %edi
  8002b2:	5d                   	pop    %ebp
  8002b3:	c3                   	ret    

008002b4 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002b4:	55                   	push   %ebp
  8002b5:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002b7:	83 fa 01             	cmp    $0x1,%edx
  8002ba:	7e 0e                	jle    8002ca <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002bc:	8b 10                	mov    (%eax),%edx
  8002be:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002c1:	89 08                	mov    %ecx,(%eax)
  8002c3:	8b 02                	mov    (%edx),%eax
  8002c5:	8b 52 04             	mov    0x4(%edx),%edx
  8002c8:	eb 22                	jmp    8002ec <getuint+0x38>
	else if (lflag)
  8002ca:	85 d2                	test   %edx,%edx
  8002cc:	74 10                	je     8002de <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002ce:	8b 10                	mov    (%eax),%edx
  8002d0:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002d3:	89 08                	mov    %ecx,(%eax)
  8002d5:	8b 02                	mov    (%edx),%eax
  8002d7:	ba 00 00 00 00       	mov    $0x0,%edx
  8002dc:	eb 0e                	jmp    8002ec <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002de:	8b 10                	mov    (%eax),%edx
  8002e0:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002e3:	89 08                	mov    %ecx,(%eax)
  8002e5:	8b 02                	mov    (%edx),%eax
  8002e7:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002ec:	5d                   	pop    %ebp
  8002ed:	c3                   	ret    

008002ee <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002ee:	55                   	push   %ebp
  8002ef:	89 e5                	mov    %esp,%ebp
  8002f1:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002f4:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002f8:	8b 10                	mov    (%eax),%edx
  8002fa:	3b 50 04             	cmp    0x4(%eax),%edx
  8002fd:	73 0a                	jae    800309 <sprintputch+0x1b>
		*b->buf++ = ch;
  8002ff:	8d 4a 01             	lea    0x1(%edx),%ecx
  800302:	89 08                	mov    %ecx,(%eax)
  800304:	8b 45 08             	mov    0x8(%ebp),%eax
  800307:	88 02                	mov    %al,(%edx)
}
  800309:	5d                   	pop    %ebp
  80030a:	c3                   	ret    

0080030b <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80030b:	55                   	push   %ebp
  80030c:	89 e5                	mov    %esp,%ebp
  80030e:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800311:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800314:	50                   	push   %eax
  800315:	ff 75 10             	pushl  0x10(%ebp)
  800318:	ff 75 0c             	pushl  0xc(%ebp)
  80031b:	ff 75 08             	pushl  0x8(%ebp)
  80031e:	e8 05 00 00 00       	call   800328 <vprintfmt>
	va_end(ap);
}
  800323:	83 c4 10             	add    $0x10,%esp
  800326:	c9                   	leave  
  800327:	c3                   	ret    

00800328 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800328:	55                   	push   %ebp
  800329:	89 e5                	mov    %esp,%ebp
  80032b:	57                   	push   %edi
  80032c:	56                   	push   %esi
  80032d:	53                   	push   %ebx
  80032e:	83 ec 2c             	sub    $0x2c,%esp
  800331:	8b 75 08             	mov    0x8(%ebp),%esi
  800334:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800337:	8b 7d 10             	mov    0x10(%ebp),%edi
  80033a:	eb 12                	jmp    80034e <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80033c:	85 c0                	test   %eax,%eax
  80033e:	0f 84 89 03 00 00    	je     8006cd <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  800344:	83 ec 08             	sub    $0x8,%esp
  800347:	53                   	push   %ebx
  800348:	50                   	push   %eax
  800349:	ff d6                	call   *%esi
  80034b:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80034e:	83 c7 01             	add    $0x1,%edi
  800351:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800355:	83 f8 25             	cmp    $0x25,%eax
  800358:	75 e2                	jne    80033c <vprintfmt+0x14>
  80035a:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80035e:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800365:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80036c:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800373:	ba 00 00 00 00       	mov    $0x0,%edx
  800378:	eb 07                	jmp    800381 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80037a:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80037d:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800381:	8d 47 01             	lea    0x1(%edi),%eax
  800384:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800387:	0f b6 07             	movzbl (%edi),%eax
  80038a:	0f b6 c8             	movzbl %al,%ecx
  80038d:	83 e8 23             	sub    $0x23,%eax
  800390:	3c 55                	cmp    $0x55,%al
  800392:	0f 87 1a 03 00 00    	ja     8006b2 <vprintfmt+0x38a>
  800398:	0f b6 c0             	movzbl %al,%eax
  80039b:	ff 24 85 40 23 80 00 	jmp    *0x802340(,%eax,4)
  8003a2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003a5:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8003a9:	eb d6                	jmp    800381 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ab:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003ae:	b8 00 00 00 00       	mov    $0x0,%eax
  8003b3:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003b6:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003b9:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8003bd:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8003c0:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8003c3:	83 fa 09             	cmp    $0x9,%edx
  8003c6:	77 39                	ja     800401 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003c8:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003cb:	eb e9                	jmp    8003b6 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003cd:	8b 45 14             	mov    0x14(%ebp),%eax
  8003d0:	8d 48 04             	lea    0x4(%eax),%ecx
  8003d3:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8003d6:	8b 00                	mov    (%eax),%eax
  8003d8:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003db:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003de:	eb 27                	jmp    800407 <vprintfmt+0xdf>
  8003e0:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003e3:	85 c0                	test   %eax,%eax
  8003e5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003ea:	0f 49 c8             	cmovns %eax,%ecx
  8003ed:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003f0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003f3:	eb 8c                	jmp    800381 <vprintfmt+0x59>
  8003f5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003f8:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8003ff:	eb 80                	jmp    800381 <vprintfmt+0x59>
  800401:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800404:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800407:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80040b:	0f 89 70 ff ff ff    	jns    800381 <vprintfmt+0x59>
				width = precision, precision = -1;
  800411:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800414:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800417:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80041e:	e9 5e ff ff ff       	jmp    800381 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800423:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800426:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800429:	e9 53 ff ff ff       	jmp    800381 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80042e:	8b 45 14             	mov    0x14(%ebp),%eax
  800431:	8d 50 04             	lea    0x4(%eax),%edx
  800434:	89 55 14             	mov    %edx,0x14(%ebp)
  800437:	83 ec 08             	sub    $0x8,%esp
  80043a:	53                   	push   %ebx
  80043b:	ff 30                	pushl  (%eax)
  80043d:	ff d6                	call   *%esi
			break;
  80043f:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800442:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800445:	e9 04 ff ff ff       	jmp    80034e <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80044a:	8b 45 14             	mov    0x14(%ebp),%eax
  80044d:	8d 50 04             	lea    0x4(%eax),%edx
  800450:	89 55 14             	mov    %edx,0x14(%ebp)
  800453:	8b 00                	mov    (%eax),%eax
  800455:	99                   	cltd   
  800456:	31 d0                	xor    %edx,%eax
  800458:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80045a:	83 f8 0f             	cmp    $0xf,%eax
  80045d:	7f 0b                	jg     80046a <vprintfmt+0x142>
  80045f:	8b 14 85 a0 24 80 00 	mov    0x8024a0(,%eax,4),%edx
  800466:	85 d2                	test   %edx,%edx
  800468:	75 18                	jne    800482 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80046a:	50                   	push   %eax
  80046b:	68 18 22 80 00       	push   $0x802218
  800470:	53                   	push   %ebx
  800471:	56                   	push   %esi
  800472:	e8 94 fe ff ff       	call   80030b <printfmt>
  800477:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80047a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80047d:	e9 cc fe ff ff       	jmp    80034e <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800482:	52                   	push   %edx
  800483:	68 bd 26 80 00       	push   $0x8026bd
  800488:	53                   	push   %ebx
  800489:	56                   	push   %esi
  80048a:	e8 7c fe ff ff       	call   80030b <printfmt>
  80048f:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800492:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800495:	e9 b4 fe ff ff       	jmp    80034e <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80049a:	8b 45 14             	mov    0x14(%ebp),%eax
  80049d:	8d 50 04             	lea    0x4(%eax),%edx
  8004a0:	89 55 14             	mov    %edx,0x14(%ebp)
  8004a3:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8004a5:	85 ff                	test   %edi,%edi
  8004a7:	b8 11 22 80 00       	mov    $0x802211,%eax
  8004ac:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8004af:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004b3:	0f 8e 94 00 00 00    	jle    80054d <vprintfmt+0x225>
  8004b9:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8004bd:	0f 84 98 00 00 00    	je     80055b <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004c3:	83 ec 08             	sub    $0x8,%esp
  8004c6:	ff 75 d0             	pushl  -0x30(%ebp)
  8004c9:	57                   	push   %edi
  8004ca:	e8 86 02 00 00       	call   800755 <strnlen>
  8004cf:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004d2:	29 c1                	sub    %eax,%ecx
  8004d4:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8004d7:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8004da:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8004de:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004e1:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8004e4:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004e6:	eb 0f                	jmp    8004f7 <vprintfmt+0x1cf>
					putch(padc, putdat);
  8004e8:	83 ec 08             	sub    $0x8,%esp
  8004eb:	53                   	push   %ebx
  8004ec:	ff 75 e0             	pushl  -0x20(%ebp)
  8004ef:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004f1:	83 ef 01             	sub    $0x1,%edi
  8004f4:	83 c4 10             	add    $0x10,%esp
  8004f7:	85 ff                	test   %edi,%edi
  8004f9:	7f ed                	jg     8004e8 <vprintfmt+0x1c0>
  8004fb:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8004fe:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800501:	85 c9                	test   %ecx,%ecx
  800503:	b8 00 00 00 00       	mov    $0x0,%eax
  800508:	0f 49 c1             	cmovns %ecx,%eax
  80050b:	29 c1                	sub    %eax,%ecx
  80050d:	89 75 08             	mov    %esi,0x8(%ebp)
  800510:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800513:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800516:	89 cb                	mov    %ecx,%ebx
  800518:	eb 4d                	jmp    800567 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80051a:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80051e:	74 1b                	je     80053b <vprintfmt+0x213>
  800520:	0f be c0             	movsbl %al,%eax
  800523:	83 e8 20             	sub    $0x20,%eax
  800526:	83 f8 5e             	cmp    $0x5e,%eax
  800529:	76 10                	jbe    80053b <vprintfmt+0x213>
					putch('?', putdat);
  80052b:	83 ec 08             	sub    $0x8,%esp
  80052e:	ff 75 0c             	pushl  0xc(%ebp)
  800531:	6a 3f                	push   $0x3f
  800533:	ff 55 08             	call   *0x8(%ebp)
  800536:	83 c4 10             	add    $0x10,%esp
  800539:	eb 0d                	jmp    800548 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  80053b:	83 ec 08             	sub    $0x8,%esp
  80053e:	ff 75 0c             	pushl  0xc(%ebp)
  800541:	52                   	push   %edx
  800542:	ff 55 08             	call   *0x8(%ebp)
  800545:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800548:	83 eb 01             	sub    $0x1,%ebx
  80054b:	eb 1a                	jmp    800567 <vprintfmt+0x23f>
  80054d:	89 75 08             	mov    %esi,0x8(%ebp)
  800550:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800553:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800556:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800559:	eb 0c                	jmp    800567 <vprintfmt+0x23f>
  80055b:	89 75 08             	mov    %esi,0x8(%ebp)
  80055e:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800561:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800564:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800567:	83 c7 01             	add    $0x1,%edi
  80056a:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80056e:	0f be d0             	movsbl %al,%edx
  800571:	85 d2                	test   %edx,%edx
  800573:	74 23                	je     800598 <vprintfmt+0x270>
  800575:	85 f6                	test   %esi,%esi
  800577:	78 a1                	js     80051a <vprintfmt+0x1f2>
  800579:	83 ee 01             	sub    $0x1,%esi
  80057c:	79 9c                	jns    80051a <vprintfmt+0x1f2>
  80057e:	89 df                	mov    %ebx,%edi
  800580:	8b 75 08             	mov    0x8(%ebp),%esi
  800583:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800586:	eb 18                	jmp    8005a0 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800588:	83 ec 08             	sub    $0x8,%esp
  80058b:	53                   	push   %ebx
  80058c:	6a 20                	push   $0x20
  80058e:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800590:	83 ef 01             	sub    $0x1,%edi
  800593:	83 c4 10             	add    $0x10,%esp
  800596:	eb 08                	jmp    8005a0 <vprintfmt+0x278>
  800598:	89 df                	mov    %ebx,%edi
  80059a:	8b 75 08             	mov    0x8(%ebp),%esi
  80059d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005a0:	85 ff                	test   %edi,%edi
  8005a2:	7f e4                	jg     800588 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005a4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005a7:	e9 a2 fd ff ff       	jmp    80034e <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005ac:	83 fa 01             	cmp    $0x1,%edx
  8005af:	7e 16                	jle    8005c7 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8005b1:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b4:	8d 50 08             	lea    0x8(%eax),%edx
  8005b7:	89 55 14             	mov    %edx,0x14(%ebp)
  8005ba:	8b 50 04             	mov    0x4(%eax),%edx
  8005bd:	8b 00                	mov    (%eax),%eax
  8005bf:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005c2:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005c5:	eb 32                	jmp    8005f9 <vprintfmt+0x2d1>
	else if (lflag)
  8005c7:	85 d2                	test   %edx,%edx
  8005c9:	74 18                	je     8005e3 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8005cb:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ce:	8d 50 04             	lea    0x4(%eax),%edx
  8005d1:	89 55 14             	mov    %edx,0x14(%ebp)
  8005d4:	8b 00                	mov    (%eax),%eax
  8005d6:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005d9:	89 c1                	mov    %eax,%ecx
  8005db:	c1 f9 1f             	sar    $0x1f,%ecx
  8005de:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005e1:	eb 16                	jmp    8005f9 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8005e3:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e6:	8d 50 04             	lea    0x4(%eax),%edx
  8005e9:	89 55 14             	mov    %edx,0x14(%ebp)
  8005ec:	8b 00                	mov    (%eax),%eax
  8005ee:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005f1:	89 c1                	mov    %eax,%ecx
  8005f3:	c1 f9 1f             	sar    $0x1f,%ecx
  8005f6:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005f9:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005fc:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005ff:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800604:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800608:	79 74                	jns    80067e <vprintfmt+0x356>
				putch('-', putdat);
  80060a:	83 ec 08             	sub    $0x8,%esp
  80060d:	53                   	push   %ebx
  80060e:	6a 2d                	push   $0x2d
  800610:	ff d6                	call   *%esi
				num = -(long long) num;
  800612:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800615:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800618:	f7 d8                	neg    %eax
  80061a:	83 d2 00             	adc    $0x0,%edx
  80061d:	f7 da                	neg    %edx
  80061f:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800622:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800627:	eb 55                	jmp    80067e <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800629:	8d 45 14             	lea    0x14(%ebp),%eax
  80062c:	e8 83 fc ff ff       	call   8002b4 <getuint>
			base = 10;
  800631:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800636:	eb 46                	jmp    80067e <vprintfmt+0x356>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
  800638:	8d 45 14             	lea    0x14(%ebp),%eax
  80063b:	e8 74 fc ff ff       	call   8002b4 <getuint>
			base = 8;
  800640:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800645:	eb 37                	jmp    80067e <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  800647:	83 ec 08             	sub    $0x8,%esp
  80064a:	53                   	push   %ebx
  80064b:	6a 30                	push   $0x30
  80064d:	ff d6                	call   *%esi
			putch('x', putdat);
  80064f:	83 c4 08             	add    $0x8,%esp
  800652:	53                   	push   %ebx
  800653:	6a 78                	push   $0x78
  800655:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800657:	8b 45 14             	mov    0x14(%ebp),%eax
  80065a:	8d 50 04             	lea    0x4(%eax),%edx
  80065d:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800660:	8b 00                	mov    (%eax),%eax
  800662:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800667:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80066a:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  80066f:	eb 0d                	jmp    80067e <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800671:	8d 45 14             	lea    0x14(%ebp),%eax
  800674:	e8 3b fc ff ff       	call   8002b4 <getuint>
			base = 16;
  800679:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  80067e:	83 ec 0c             	sub    $0xc,%esp
  800681:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800685:	57                   	push   %edi
  800686:	ff 75 e0             	pushl  -0x20(%ebp)
  800689:	51                   	push   %ecx
  80068a:	52                   	push   %edx
  80068b:	50                   	push   %eax
  80068c:	89 da                	mov    %ebx,%edx
  80068e:	89 f0                	mov    %esi,%eax
  800690:	e8 70 fb ff ff       	call   800205 <printnum>
			break;
  800695:	83 c4 20             	add    $0x20,%esp
  800698:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80069b:	e9 ae fc ff ff       	jmp    80034e <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006a0:	83 ec 08             	sub    $0x8,%esp
  8006a3:	53                   	push   %ebx
  8006a4:	51                   	push   %ecx
  8006a5:	ff d6                	call   *%esi
			break;
  8006a7:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006aa:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006ad:	e9 9c fc ff ff       	jmp    80034e <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006b2:	83 ec 08             	sub    $0x8,%esp
  8006b5:	53                   	push   %ebx
  8006b6:	6a 25                	push   $0x25
  8006b8:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006ba:	83 c4 10             	add    $0x10,%esp
  8006bd:	eb 03                	jmp    8006c2 <vprintfmt+0x39a>
  8006bf:	83 ef 01             	sub    $0x1,%edi
  8006c2:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8006c6:	75 f7                	jne    8006bf <vprintfmt+0x397>
  8006c8:	e9 81 fc ff ff       	jmp    80034e <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8006cd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006d0:	5b                   	pop    %ebx
  8006d1:	5e                   	pop    %esi
  8006d2:	5f                   	pop    %edi
  8006d3:	5d                   	pop    %ebp
  8006d4:	c3                   	ret    

008006d5 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006d5:	55                   	push   %ebp
  8006d6:	89 e5                	mov    %esp,%ebp
  8006d8:	83 ec 18             	sub    $0x18,%esp
  8006db:	8b 45 08             	mov    0x8(%ebp),%eax
  8006de:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006e1:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006e4:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006e8:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006eb:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006f2:	85 c0                	test   %eax,%eax
  8006f4:	74 26                	je     80071c <vsnprintf+0x47>
  8006f6:	85 d2                	test   %edx,%edx
  8006f8:	7e 22                	jle    80071c <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006fa:	ff 75 14             	pushl  0x14(%ebp)
  8006fd:	ff 75 10             	pushl  0x10(%ebp)
  800700:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800703:	50                   	push   %eax
  800704:	68 ee 02 80 00       	push   $0x8002ee
  800709:	e8 1a fc ff ff       	call   800328 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80070e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800711:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800714:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800717:	83 c4 10             	add    $0x10,%esp
  80071a:	eb 05                	jmp    800721 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80071c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800721:	c9                   	leave  
  800722:	c3                   	ret    

00800723 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800723:	55                   	push   %ebp
  800724:	89 e5                	mov    %esp,%ebp
  800726:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800729:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80072c:	50                   	push   %eax
  80072d:	ff 75 10             	pushl  0x10(%ebp)
  800730:	ff 75 0c             	pushl  0xc(%ebp)
  800733:	ff 75 08             	pushl  0x8(%ebp)
  800736:	e8 9a ff ff ff       	call   8006d5 <vsnprintf>
	va_end(ap);

	return rc;
}
  80073b:	c9                   	leave  
  80073c:	c3                   	ret    

0080073d <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80073d:	55                   	push   %ebp
  80073e:	89 e5                	mov    %esp,%ebp
  800740:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800743:	b8 00 00 00 00       	mov    $0x0,%eax
  800748:	eb 03                	jmp    80074d <strlen+0x10>
		n++;
  80074a:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80074d:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800751:	75 f7                	jne    80074a <strlen+0xd>
		n++;
	return n;
}
  800753:	5d                   	pop    %ebp
  800754:	c3                   	ret    

00800755 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800755:	55                   	push   %ebp
  800756:	89 e5                	mov    %esp,%ebp
  800758:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80075b:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80075e:	ba 00 00 00 00       	mov    $0x0,%edx
  800763:	eb 03                	jmp    800768 <strnlen+0x13>
		n++;
  800765:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800768:	39 c2                	cmp    %eax,%edx
  80076a:	74 08                	je     800774 <strnlen+0x1f>
  80076c:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800770:	75 f3                	jne    800765 <strnlen+0x10>
  800772:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800774:	5d                   	pop    %ebp
  800775:	c3                   	ret    

00800776 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800776:	55                   	push   %ebp
  800777:	89 e5                	mov    %esp,%ebp
  800779:	53                   	push   %ebx
  80077a:	8b 45 08             	mov    0x8(%ebp),%eax
  80077d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800780:	89 c2                	mov    %eax,%edx
  800782:	83 c2 01             	add    $0x1,%edx
  800785:	83 c1 01             	add    $0x1,%ecx
  800788:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80078c:	88 5a ff             	mov    %bl,-0x1(%edx)
  80078f:	84 db                	test   %bl,%bl
  800791:	75 ef                	jne    800782 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800793:	5b                   	pop    %ebx
  800794:	5d                   	pop    %ebp
  800795:	c3                   	ret    

00800796 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800796:	55                   	push   %ebp
  800797:	89 e5                	mov    %esp,%ebp
  800799:	53                   	push   %ebx
  80079a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80079d:	53                   	push   %ebx
  80079e:	e8 9a ff ff ff       	call   80073d <strlen>
  8007a3:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007a6:	ff 75 0c             	pushl  0xc(%ebp)
  8007a9:	01 d8                	add    %ebx,%eax
  8007ab:	50                   	push   %eax
  8007ac:	e8 c5 ff ff ff       	call   800776 <strcpy>
	return dst;
}
  8007b1:	89 d8                	mov    %ebx,%eax
  8007b3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007b6:	c9                   	leave  
  8007b7:	c3                   	ret    

008007b8 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007b8:	55                   	push   %ebp
  8007b9:	89 e5                	mov    %esp,%ebp
  8007bb:	56                   	push   %esi
  8007bc:	53                   	push   %ebx
  8007bd:	8b 75 08             	mov    0x8(%ebp),%esi
  8007c0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007c3:	89 f3                	mov    %esi,%ebx
  8007c5:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007c8:	89 f2                	mov    %esi,%edx
  8007ca:	eb 0f                	jmp    8007db <strncpy+0x23>
		*dst++ = *src;
  8007cc:	83 c2 01             	add    $0x1,%edx
  8007cf:	0f b6 01             	movzbl (%ecx),%eax
  8007d2:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007d5:	80 39 01             	cmpb   $0x1,(%ecx)
  8007d8:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007db:	39 da                	cmp    %ebx,%edx
  8007dd:	75 ed                	jne    8007cc <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007df:	89 f0                	mov    %esi,%eax
  8007e1:	5b                   	pop    %ebx
  8007e2:	5e                   	pop    %esi
  8007e3:	5d                   	pop    %ebp
  8007e4:	c3                   	ret    

008007e5 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007e5:	55                   	push   %ebp
  8007e6:	89 e5                	mov    %esp,%ebp
  8007e8:	56                   	push   %esi
  8007e9:	53                   	push   %ebx
  8007ea:	8b 75 08             	mov    0x8(%ebp),%esi
  8007ed:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007f0:	8b 55 10             	mov    0x10(%ebp),%edx
  8007f3:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007f5:	85 d2                	test   %edx,%edx
  8007f7:	74 21                	je     80081a <strlcpy+0x35>
  8007f9:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8007fd:	89 f2                	mov    %esi,%edx
  8007ff:	eb 09                	jmp    80080a <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800801:	83 c2 01             	add    $0x1,%edx
  800804:	83 c1 01             	add    $0x1,%ecx
  800807:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80080a:	39 c2                	cmp    %eax,%edx
  80080c:	74 09                	je     800817 <strlcpy+0x32>
  80080e:	0f b6 19             	movzbl (%ecx),%ebx
  800811:	84 db                	test   %bl,%bl
  800813:	75 ec                	jne    800801 <strlcpy+0x1c>
  800815:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800817:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80081a:	29 f0                	sub    %esi,%eax
}
  80081c:	5b                   	pop    %ebx
  80081d:	5e                   	pop    %esi
  80081e:	5d                   	pop    %ebp
  80081f:	c3                   	ret    

00800820 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800820:	55                   	push   %ebp
  800821:	89 e5                	mov    %esp,%ebp
  800823:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800826:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800829:	eb 06                	jmp    800831 <strcmp+0x11>
		p++, q++;
  80082b:	83 c1 01             	add    $0x1,%ecx
  80082e:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800831:	0f b6 01             	movzbl (%ecx),%eax
  800834:	84 c0                	test   %al,%al
  800836:	74 04                	je     80083c <strcmp+0x1c>
  800838:	3a 02                	cmp    (%edx),%al
  80083a:	74 ef                	je     80082b <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80083c:	0f b6 c0             	movzbl %al,%eax
  80083f:	0f b6 12             	movzbl (%edx),%edx
  800842:	29 d0                	sub    %edx,%eax
}
  800844:	5d                   	pop    %ebp
  800845:	c3                   	ret    

00800846 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800846:	55                   	push   %ebp
  800847:	89 e5                	mov    %esp,%ebp
  800849:	53                   	push   %ebx
  80084a:	8b 45 08             	mov    0x8(%ebp),%eax
  80084d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800850:	89 c3                	mov    %eax,%ebx
  800852:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800855:	eb 06                	jmp    80085d <strncmp+0x17>
		n--, p++, q++;
  800857:	83 c0 01             	add    $0x1,%eax
  80085a:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80085d:	39 d8                	cmp    %ebx,%eax
  80085f:	74 15                	je     800876 <strncmp+0x30>
  800861:	0f b6 08             	movzbl (%eax),%ecx
  800864:	84 c9                	test   %cl,%cl
  800866:	74 04                	je     80086c <strncmp+0x26>
  800868:	3a 0a                	cmp    (%edx),%cl
  80086a:	74 eb                	je     800857 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80086c:	0f b6 00             	movzbl (%eax),%eax
  80086f:	0f b6 12             	movzbl (%edx),%edx
  800872:	29 d0                	sub    %edx,%eax
  800874:	eb 05                	jmp    80087b <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800876:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80087b:	5b                   	pop    %ebx
  80087c:	5d                   	pop    %ebp
  80087d:	c3                   	ret    

0080087e <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80087e:	55                   	push   %ebp
  80087f:	89 e5                	mov    %esp,%ebp
  800881:	8b 45 08             	mov    0x8(%ebp),%eax
  800884:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800888:	eb 07                	jmp    800891 <strchr+0x13>
		if (*s == c)
  80088a:	38 ca                	cmp    %cl,%dl
  80088c:	74 0f                	je     80089d <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80088e:	83 c0 01             	add    $0x1,%eax
  800891:	0f b6 10             	movzbl (%eax),%edx
  800894:	84 d2                	test   %dl,%dl
  800896:	75 f2                	jne    80088a <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800898:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80089d:	5d                   	pop    %ebp
  80089e:	c3                   	ret    

0080089f <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80089f:	55                   	push   %ebp
  8008a0:	89 e5                	mov    %esp,%ebp
  8008a2:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a5:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008a9:	eb 03                	jmp    8008ae <strfind+0xf>
  8008ab:	83 c0 01             	add    $0x1,%eax
  8008ae:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008b1:	38 ca                	cmp    %cl,%dl
  8008b3:	74 04                	je     8008b9 <strfind+0x1a>
  8008b5:	84 d2                	test   %dl,%dl
  8008b7:	75 f2                	jne    8008ab <strfind+0xc>
			break;
	return (char *) s;
}
  8008b9:	5d                   	pop    %ebp
  8008ba:	c3                   	ret    

008008bb <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008bb:	55                   	push   %ebp
  8008bc:	89 e5                	mov    %esp,%ebp
  8008be:	57                   	push   %edi
  8008bf:	56                   	push   %esi
  8008c0:	53                   	push   %ebx
  8008c1:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008c4:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008c7:	85 c9                	test   %ecx,%ecx
  8008c9:	74 36                	je     800901 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008cb:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008d1:	75 28                	jne    8008fb <memset+0x40>
  8008d3:	f6 c1 03             	test   $0x3,%cl
  8008d6:	75 23                	jne    8008fb <memset+0x40>
		c &= 0xFF;
  8008d8:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008dc:	89 d3                	mov    %edx,%ebx
  8008de:	c1 e3 08             	shl    $0x8,%ebx
  8008e1:	89 d6                	mov    %edx,%esi
  8008e3:	c1 e6 18             	shl    $0x18,%esi
  8008e6:	89 d0                	mov    %edx,%eax
  8008e8:	c1 e0 10             	shl    $0x10,%eax
  8008eb:	09 f0                	or     %esi,%eax
  8008ed:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8008ef:	89 d8                	mov    %ebx,%eax
  8008f1:	09 d0                	or     %edx,%eax
  8008f3:	c1 e9 02             	shr    $0x2,%ecx
  8008f6:	fc                   	cld    
  8008f7:	f3 ab                	rep stos %eax,%es:(%edi)
  8008f9:	eb 06                	jmp    800901 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008fb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008fe:	fc                   	cld    
  8008ff:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800901:	89 f8                	mov    %edi,%eax
  800903:	5b                   	pop    %ebx
  800904:	5e                   	pop    %esi
  800905:	5f                   	pop    %edi
  800906:	5d                   	pop    %ebp
  800907:	c3                   	ret    

00800908 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800908:	55                   	push   %ebp
  800909:	89 e5                	mov    %esp,%ebp
  80090b:	57                   	push   %edi
  80090c:	56                   	push   %esi
  80090d:	8b 45 08             	mov    0x8(%ebp),%eax
  800910:	8b 75 0c             	mov    0xc(%ebp),%esi
  800913:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800916:	39 c6                	cmp    %eax,%esi
  800918:	73 35                	jae    80094f <memmove+0x47>
  80091a:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80091d:	39 d0                	cmp    %edx,%eax
  80091f:	73 2e                	jae    80094f <memmove+0x47>
		s += n;
		d += n;
  800921:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800924:	89 d6                	mov    %edx,%esi
  800926:	09 fe                	or     %edi,%esi
  800928:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80092e:	75 13                	jne    800943 <memmove+0x3b>
  800930:	f6 c1 03             	test   $0x3,%cl
  800933:	75 0e                	jne    800943 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800935:	83 ef 04             	sub    $0x4,%edi
  800938:	8d 72 fc             	lea    -0x4(%edx),%esi
  80093b:	c1 e9 02             	shr    $0x2,%ecx
  80093e:	fd                   	std    
  80093f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800941:	eb 09                	jmp    80094c <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800943:	83 ef 01             	sub    $0x1,%edi
  800946:	8d 72 ff             	lea    -0x1(%edx),%esi
  800949:	fd                   	std    
  80094a:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80094c:	fc                   	cld    
  80094d:	eb 1d                	jmp    80096c <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80094f:	89 f2                	mov    %esi,%edx
  800951:	09 c2                	or     %eax,%edx
  800953:	f6 c2 03             	test   $0x3,%dl
  800956:	75 0f                	jne    800967 <memmove+0x5f>
  800958:	f6 c1 03             	test   $0x3,%cl
  80095b:	75 0a                	jne    800967 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  80095d:	c1 e9 02             	shr    $0x2,%ecx
  800960:	89 c7                	mov    %eax,%edi
  800962:	fc                   	cld    
  800963:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800965:	eb 05                	jmp    80096c <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800967:	89 c7                	mov    %eax,%edi
  800969:	fc                   	cld    
  80096a:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80096c:	5e                   	pop    %esi
  80096d:	5f                   	pop    %edi
  80096e:	5d                   	pop    %ebp
  80096f:	c3                   	ret    

00800970 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800970:	55                   	push   %ebp
  800971:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800973:	ff 75 10             	pushl  0x10(%ebp)
  800976:	ff 75 0c             	pushl  0xc(%ebp)
  800979:	ff 75 08             	pushl  0x8(%ebp)
  80097c:	e8 87 ff ff ff       	call   800908 <memmove>
}
  800981:	c9                   	leave  
  800982:	c3                   	ret    

00800983 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800983:	55                   	push   %ebp
  800984:	89 e5                	mov    %esp,%ebp
  800986:	56                   	push   %esi
  800987:	53                   	push   %ebx
  800988:	8b 45 08             	mov    0x8(%ebp),%eax
  80098b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80098e:	89 c6                	mov    %eax,%esi
  800990:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800993:	eb 1a                	jmp    8009af <memcmp+0x2c>
		if (*s1 != *s2)
  800995:	0f b6 08             	movzbl (%eax),%ecx
  800998:	0f b6 1a             	movzbl (%edx),%ebx
  80099b:	38 d9                	cmp    %bl,%cl
  80099d:	74 0a                	je     8009a9 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  80099f:	0f b6 c1             	movzbl %cl,%eax
  8009a2:	0f b6 db             	movzbl %bl,%ebx
  8009a5:	29 d8                	sub    %ebx,%eax
  8009a7:	eb 0f                	jmp    8009b8 <memcmp+0x35>
		s1++, s2++;
  8009a9:	83 c0 01             	add    $0x1,%eax
  8009ac:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009af:	39 f0                	cmp    %esi,%eax
  8009b1:	75 e2                	jne    800995 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009b3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009b8:	5b                   	pop    %ebx
  8009b9:	5e                   	pop    %esi
  8009ba:	5d                   	pop    %ebp
  8009bb:	c3                   	ret    

008009bc <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009bc:	55                   	push   %ebp
  8009bd:	89 e5                	mov    %esp,%ebp
  8009bf:	53                   	push   %ebx
  8009c0:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8009c3:	89 c1                	mov    %eax,%ecx
  8009c5:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  8009c8:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009cc:	eb 0a                	jmp    8009d8 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009ce:	0f b6 10             	movzbl (%eax),%edx
  8009d1:	39 da                	cmp    %ebx,%edx
  8009d3:	74 07                	je     8009dc <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009d5:	83 c0 01             	add    $0x1,%eax
  8009d8:	39 c8                	cmp    %ecx,%eax
  8009da:	72 f2                	jb     8009ce <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8009dc:	5b                   	pop    %ebx
  8009dd:	5d                   	pop    %ebp
  8009de:	c3                   	ret    

008009df <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009df:	55                   	push   %ebp
  8009e0:	89 e5                	mov    %esp,%ebp
  8009e2:	57                   	push   %edi
  8009e3:	56                   	push   %esi
  8009e4:	53                   	push   %ebx
  8009e5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009e8:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009eb:	eb 03                	jmp    8009f0 <strtol+0x11>
		s++;
  8009ed:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009f0:	0f b6 01             	movzbl (%ecx),%eax
  8009f3:	3c 20                	cmp    $0x20,%al
  8009f5:	74 f6                	je     8009ed <strtol+0xe>
  8009f7:	3c 09                	cmp    $0x9,%al
  8009f9:	74 f2                	je     8009ed <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8009fb:	3c 2b                	cmp    $0x2b,%al
  8009fd:	75 0a                	jne    800a09 <strtol+0x2a>
		s++;
  8009ff:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a02:	bf 00 00 00 00       	mov    $0x0,%edi
  800a07:	eb 11                	jmp    800a1a <strtol+0x3b>
  800a09:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a0e:	3c 2d                	cmp    $0x2d,%al
  800a10:	75 08                	jne    800a1a <strtol+0x3b>
		s++, neg = 1;
  800a12:	83 c1 01             	add    $0x1,%ecx
  800a15:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a1a:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a20:	75 15                	jne    800a37 <strtol+0x58>
  800a22:	80 39 30             	cmpb   $0x30,(%ecx)
  800a25:	75 10                	jne    800a37 <strtol+0x58>
  800a27:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a2b:	75 7c                	jne    800aa9 <strtol+0xca>
		s += 2, base = 16;
  800a2d:	83 c1 02             	add    $0x2,%ecx
  800a30:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a35:	eb 16                	jmp    800a4d <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800a37:	85 db                	test   %ebx,%ebx
  800a39:	75 12                	jne    800a4d <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a3b:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a40:	80 39 30             	cmpb   $0x30,(%ecx)
  800a43:	75 08                	jne    800a4d <strtol+0x6e>
		s++, base = 8;
  800a45:	83 c1 01             	add    $0x1,%ecx
  800a48:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a4d:	b8 00 00 00 00       	mov    $0x0,%eax
  800a52:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a55:	0f b6 11             	movzbl (%ecx),%edx
  800a58:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a5b:	89 f3                	mov    %esi,%ebx
  800a5d:	80 fb 09             	cmp    $0x9,%bl
  800a60:	77 08                	ja     800a6a <strtol+0x8b>
			dig = *s - '0';
  800a62:	0f be d2             	movsbl %dl,%edx
  800a65:	83 ea 30             	sub    $0x30,%edx
  800a68:	eb 22                	jmp    800a8c <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800a6a:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a6d:	89 f3                	mov    %esi,%ebx
  800a6f:	80 fb 19             	cmp    $0x19,%bl
  800a72:	77 08                	ja     800a7c <strtol+0x9d>
			dig = *s - 'a' + 10;
  800a74:	0f be d2             	movsbl %dl,%edx
  800a77:	83 ea 57             	sub    $0x57,%edx
  800a7a:	eb 10                	jmp    800a8c <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800a7c:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a7f:	89 f3                	mov    %esi,%ebx
  800a81:	80 fb 19             	cmp    $0x19,%bl
  800a84:	77 16                	ja     800a9c <strtol+0xbd>
			dig = *s - 'A' + 10;
  800a86:	0f be d2             	movsbl %dl,%edx
  800a89:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800a8c:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a8f:	7d 0b                	jge    800a9c <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800a91:	83 c1 01             	add    $0x1,%ecx
  800a94:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a98:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800a9a:	eb b9                	jmp    800a55 <strtol+0x76>

	if (endptr)
  800a9c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800aa0:	74 0d                	je     800aaf <strtol+0xd0>
		*endptr = (char *) s;
  800aa2:	8b 75 0c             	mov    0xc(%ebp),%esi
  800aa5:	89 0e                	mov    %ecx,(%esi)
  800aa7:	eb 06                	jmp    800aaf <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800aa9:	85 db                	test   %ebx,%ebx
  800aab:	74 98                	je     800a45 <strtol+0x66>
  800aad:	eb 9e                	jmp    800a4d <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800aaf:	89 c2                	mov    %eax,%edx
  800ab1:	f7 da                	neg    %edx
  800ab3:	85 ff                	test   %edi,%edi
  800ab5:	0f 45 c2             	cmovne %edx,%eax
}
  800ab8:	5b                   	pop    %ebx
  800ab9:	5e                   	pop    %esi
  800aba:	5f                   	pop    %edi
  800abb:	5d                   	pop    %ebp
  800abc:	c3                   	ret    

00800abd <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800abd:	55                   	push   %ebp
  800abe:	89 e5                	mov    %esp,%ebp
  800ac0:	57                   	push   %edi
  800ac1:	56                   	push   %esi
  800ac2:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ac3:	b8 00 00 00 00       	mov    $0x0,%eax
  800ac8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800acb:	8b 55 08             	mov    0x8(%ebp),%edx
  800ace:	89 c3                	mov    %eax,%ebx
  800ad0:	89 c7                	mov    %eax,%edi
  800ad2:	89 c6                	mov    %eax,%esi
  800ad4:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800ad6:	5b                   	pop    %ebx
  800ad7:	5e                   	pop    %esi
  800ad8:	5f                   	pop    %edi
  800ad9:	5d                   	pop    %ebp
  800ada:	c3                   	ret    

00800adb <sys_cgetc>:

int
sys_cgetc(void)
{
  800adb:	55                   	push   %ebp
  800adc:	89 e5                	mov    %esp,%ebp
  800ade:	57                   	push   %edi
  800adf:	56                   	push   %esi
  800ae0:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ae1:	ba 00 00 00 00       	mov    $0x0,%edx
  800ae6:	b8 01 00 00 00       	mov    $0x1,%eax
  800aeb:	89 d1                	mov    %edx,%ecx
  800aed:	89 d3                	mov    %edx,%ebx
  800aef:	89 d7                	mov    %edx,%edi
  800af1:	89 d6                	mov    %edx,%esi
  800af3:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800af5:	5b                   	pop    %ebx
  800af6:	5e                   	pop    %esi
  800af7:	5f                   	pop    %edi
  800af8:	5d                   	pop    %ebp
  800af9:	c3                   	ret    

00800afa <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800afa:	55                   	push   %ebp
  800afb:	89 e5                	mov    %esp,%ebp
  800afd:	57                   	push   %edi
  800afe:	56                   	push   %esi
  800aff:	53                   	push   %ebx
  800b00:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b03:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b08:	b8 03 00 00 00       	mov    $0x3,%eax
  800b0d:	8b 55 08             	mov    0x8(%ebp),%edx
  800b10:	89 cb                	mov    %ecx,%ebx
  800b12:	89 cf                	mov    %ecx,%edi
  800b14:	89 ce                	mov    %ecx,%esi
  800b16:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b18:	85 c0                	test   %eax,%eax
  800b1a:	7e 17                	jle    800b33 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b1c:	83 ec 0c             	sub    $0xc,%esp
  800b1f:	50                   	push   %eax
  800b20:	6a 03                	push   $0x3
  800b22:	68 ff 24 80 00       	push   $0x8024ff
  800b27:	6a 23                	push   $0x23
  800b29:	68 1c 25 80 00       	push   $0x80251c
  800b2e:	e8 d9 12 00 00       	call   801e0c <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b33:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b36:	5b                   	pop    %ebx
  800b37:	5e                   	pop    %esi
  800b38:	5f                   	pop    %edi
  800b39:	5d                   	pop    %ebp
  800b3a:	c3                   	ret    

00800b3b <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b3b:	55                   	push   %ebp
  800b3c:	89 e5                	mov    %esp,%ebp
  800b3e:	57                   	push   %edi
  800b3f:	56                   	push   %esi
  800b40:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b41:	ba 00 00 00 00       	mov    $0x0,%edx
  800b46:	b8 02 00 00 00       	mov    $0x2,%eax
  800b4b:	89 d1                	mov    %edx,%ecx
  800b4d:	89 d3                	mov    %edx,%ebx
  800b4f:	89 d7                	mov    %edx,%edi
  800b51:	89 d6                	mov    %edx,%esi
  800b53:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b55:	5b                   	pop    %ebx
  800b56:	5e                   	pop    %esi
  800b57:	5f                   	pop    %edi
  800b58:	5d                   	pop    %ebp
  800b59:	c3                   	ret    

00800b5a <sys_yield>:

void
sys_yield(void)
{
  800b5a:	55                   	push   %ebp
  800b5b:	89 e5                	mov    %esp,%ebp
  800b5d:	57                   	push   %edi
  800b5e:	56                   	push   %esi
  800b5f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b60:	ba 00 00 00 00       	mov    $0x0,%edx
  800b65:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b6a:	89 d1                	mov    %edx,%ecx
  800b6c:	89 d3                	mov    %edx,%ebx
  800b6e:	89 d7                	mov    %edx,%edi
  800b70:	89 d6                	mov    %edx,%esi
  800b72:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b74:	5b                   	pop    %ebx
  800b75:	5e                   	pop    %esi
  800b76:	5f                   	pop    %edi
  800b77:	5d                   	pop    %ebp
  800b78:	c3                   	ret    

00800b79 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b79:	55                   	push   %ebp
  800b7a:	89 e5                	mov    %esp,%ebp
  800b7c:	57                   	push   %edi
  800b7d:	56                   	push   %esi
  800b7e:	53                   	push   %ebx
  800b7f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b82:	be 00 00 00 00       	mov    $0x0,%esi
  800b87:	b8 04 00 00 00       	mov    $0x4,%eax
  800b8c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b8f:	8b 55 08             	mov    0x8(%ebp),%edx
  800b92:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b95:	89 f7                	mov    %esi,%edi
  800b97:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b99:	85 c0                	test   %eax,%eax
  800b9b:	7e 17                	jle    800bb4 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b9d:	83 ec 0c             	sub    $0xc,%esp
  800ba0:	50                   	push   %eax
  800ba1:	6a 04                	push   $0x4
  800ba3:	68 ff 24 80 00       	push   $0x8024ff
  800ba8:	6a 23                	push   $0x23
  800baa:	68 1c 25 80 00       	push   $0x80251c
  800baf:	e8 58 12 00 00       	call   801e0c <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800bb4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bb7:	5b                   	pop    %ebx
  800bb8:	5e                   	pop    %esi
  800bb9:	5f                   	pop    %edi
  800bba:	5d                   	pop    %ebp
  800bbb:	c3                   	ret    

00800bbc <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800bbc:	55                   	push   %ebp
  800bbd:	89 e5                	mov    %esp,%ebp
  800bbf:	57                   	push   %edi
  800bc0:	56                   	push   %esi
  800bc1:	53                   	push   %ebx
  800bc2:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bc5:	b8 05 00 00 00       	mov    $0x5,%eax
  800bca:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bcd:	8b 55 08             	mov    0x8(%ebp),%edx
  800bd0:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bd3:	8b 7d 14             	mov    0x14(%ebp),%edi
  800bd6:	8b 75 18             	mov    0x18(%ebp),%esi
  800bd9:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bdb:	85 c0                	test   %eax,%eax
  800bdd:	7e 17                	jle    800bf6 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bdf:	83 ec 0c             	sub    $0xc,%esp
  800be2:	50                   	push   %eax
  800be3:	6a 05                	push   $0x5
  800be5:	68 ff 24 80 00       	push   $0x8024ff
  800bea:	6a 23                	push   $0x23
  800bec:	68 1c 25 80 00       	push   $0x80251c
  800bf1:	e8 16 12 00 00       	call   801e0c <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800bf6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bf9:	5b                   	pop    %ebx
  800bfa:	5e                   	pop    %esi
  800bfb:	5f                   	pop    %edi
  800bfc:	5d                   	pop    %ebp
  800bfd:	c3                   	ret    

00800bfe <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800bfe:	55                   	push   %ebp
  800bff:	89 e5                	mov    %esp,%ebp
  800c01:	57                   	push   %edi
  800c02:	56                   	push   %esi
  800c03:	53                   	push   %ebx
  800c04:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c07:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c0c:	b8 06 00 00 00       	mov    $0x6,%eax
  800c11:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c14:	8b 55 08             	mov    0x8(%ebp),%edx
  800c17:	89 df                	mov    %ebx,%edi
  800c19:	89 de                	mov    %ebx,%esi
  800c1b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c1d:	85 c0                	test   %eax,%eax
  800c1f:	7e 17                	jle    800c38 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c21:	83 ec 0c             	sub    $0xc,%esp
  800c24:	50                   	push   %eax
  800c25:	6a 06                	push   $0x6
  800c27:	68 ff 24 80 00       	push   $0x8024ff
  800c2c:	6a 23                	push   $0x23
  800c2e:	68 1c 25 80 00       	push   $0x80251c
  800c33:	e8 d4 11 00 00       	call   801e0c <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c38:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c3b:	5b                   	pop    %ebx
  800c3c:	5e                   	pop    %esi
  800c3d:	5f                   	pop    %edi
  800c3e:	5d                   	pop    %ebp
  800c3f:	c3                   	ret    

00800c40 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c40:	55                   	push   %ebp
  800c41:	89 e5                	mov    %esp,%ebp
  800c43:	57                   	push   %edi
  800c44:	56                   	push   %esi
  800c45:	53                   	push   %ebx
  800c46:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c49:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c4e:	b8 08 00 00 00       	mov    $0x8,%eax
  800c53:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c56:	8b 55 08             	mov    0x8(%ebp),%edx
  800c59:	89 df                	mov    %ebx,%edi
  800c5b:	89 de                	mov    %ebx,%esi
  800c5d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c5f:	85 c0                	test   %eax,%eax
  800c61:	7e 17                	jle    800c7a <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c63:	83 ec 0c             	sub    $0xc,%esp
  800c66:	50                   	push   %eax
  800c67:	6a 08                	push   $0x8
  800c69:	68 ff 24 80 00       	push   $0x8024ff
  800c6e:	6a 23                	push   $0x23
  800c70:	68 1c 25 80 00       	push   $0x80251c
  800c75:	e8 92 11 00 00       	call   801e0c <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c7a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c7d:	5b                   	pop    %ebx
  800c7e:	5e                   	pop    %esi
  800c7f:	5f                   	pop    %edi
  800c80:	5d                   	pop    %ebp
  800c81:	c3                   	ret    

00800c82 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c82:	55                   	push   %ebp
  800c83:	89 e5                	mov    %esp,%ebp
  800c85:	57                   	push   %edi
  800c86:	56                   	push   %esi
  800c87:	53                   	push   %ebx
  800c88:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c8b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c90:	b8 09 00 00 00       	mov    $0x9,%eax
  800c95:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c98:	8b 55 08             	mov    0x8(%ebp),%edx
  800c9b:	89 df                	mov    %ebx,%edi
  800c9d:	89 de                	mov    %ebx,%esi
  800c9f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ca1:	85 c0                	test   %eax,%eax
  800ca3:	7e 17                	jle    800cbc <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ca5:	83 ec 0c             	sub    $0xc,%esp
  800ca8:	50                   	push   %eax
  800ca9:	6a 09                	push   $0x9
  800cab:	68 ff 24 80 00       	push   $0x8024ff
  800cb0:	6a 23                	push   $0x23
  800cb2:	68 1c 25 80 00       	push   $0x80251c
  800cb7:	e8 50 11 00 00       	call   801e0c <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800cbc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cbf:	5b                   	pop    %ebx
  800cc0:	5e                   	pop    %esi
  800cc1:	5f                   	pop    %edi
  800cc2:	5d                   	pop    %ebp
  800cc3:	c3                   	ret    

00800cc4 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800cc4:	55                   	push   %ebp
  800cc5:	89 e5                	mov    %esp,%ebp
  800cc7:	57                   	push   %edi
  800cc8:	56                   	push   %esi
  800cc9:	53                   	push   %ebx
  800cca:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ccd:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cd2:	b8 0a 00 00 00       	mov    $0xa,%eax
  800cd7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cda:	8b 55 08             	mov    0x8(%ebp),%edx
  800cdd:	89 df                	mov    %ebx,%edi
  800cdf:	89 de                	mov    %ebx,%esi
  800ce1:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ce3:	85 c0                	test   %eax,%eax
  800ce5:	7e 17                	jle    800cfe <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ce7:	83 ec 0c             	sub    $0xc,%esp
  800cea:	50                   	push   %eax
  800ceb:	6a 0a                	push   $0xa
  800ced:	68 ff 24 80 00       	push   $0x8024ff
  800cf2:	6a 23                	push   $0x23
  800cf4:	68 1c 25 80 00       	push   $0x80251c
  800cf9:	e8 0e 11 00 00       	call   801e0c <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800cfe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d01:	5b                   	pop    %ebx
  800d02:	5e                   	pop    %esi
  800d03:	5f                   	pop    %edi
  800d04:	5d                   	pop    %ebp
  800d05:	c3                   	ret    

00800d06 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d06:	55                   	push   %ebp
  800d07:	89 e5                	mov    %esp,%ebp
  800d09:	57                   	push   %edi
  800d0a:	56                   	push   %esi
  800d0b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d0c:	be 00 00 00 00       	mov    $0x0,%esi
  800d11:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d16:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d19:	8b 55 08             	mov    0x8(%ebp),%edx
  800d1c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d1f:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d22:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d24:	5b                   	pop    %ebx
  800d25:	5e                   	pop    %esi
  800d26:	5f                   	pop    %edi
  800d27:	5d                   	pop    %ebp
  800d28:	c3                   	ret    

00800d29 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d29:	55                   	push   %ebp
  800d2a:	89 e5                	mov    %esp,%ebp
  800d2c:	57                   	push   %edi
  800d2d:	56                   	push   %esi
  800d2e:	53                   	push   %ebx
  800d2f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d32:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d37:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d3c:	8b 55 08             	mov    0x8(%ebp),%edx
  800d3f:	89 cb                	mov    %ecx,%ebx
  800d41:	89 cf                	mov    %ecx,%edi
  800d43:	89 ce                	mov    %ecx,%esi
  800d45:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d47:	85 c0                	test   %eax,%eax
  800d49:	7e 17                	jle    800d62 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d4b:	83 ec 0c             	sub    $0xc,%esp
  800d4e:	50                   	push   %eax
  800d4f:	6a 0d                	push   $0xd
  800d51:	68 ff 24 80 00       	push   $0x8024ff
  800d56:	6a 23                	push   $0x23
  800d58:	68 1c 25 80 00       	push   $0x80251c
  800d5d:	e8 aa 10 00 00       	call   801e0c <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d62:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d65:	5b                   	pop    %ebx
  800d66:	5e                   	pop    %esi
  800d67:	5f                   	pop    %edi
  800d68:	5d                   	pop    %ebp
  800d69:	c3                   	ret    

00800d6a <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800d6a:	55                   	push   %ebp
  800d6b:	89 e5                	mov    %esp,%ebp
  800d6d:	57                   	push   %edi
  800d6e:	56                   	push   %esi
  800d6f:	53                   	push   %ebx
  800d70:	83 ec 0c             	sub    $0xc,%esp
  800d73:	8b 75 08             	mov    0x8(%ebp),%esi
	void *addr = (void *) utf->utf_fault_va;
  800d76:	8b 1e                	mov    (%esi),%ebx
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.

	if ((err & FEC_WR) != FEC_WR && ((uvpt[PGNUM(addr)] & PTE_COW) != PTE_COW)) {
  800d78:	f6 46 04 02          	testb  $0x2,0x4(%esi)
  800d7c:	75 25                	jne    800da3 <pgfault+0x39>
  800d7e:	89 d8                	mov    %ebx,%eax
  800d80:	c1 e8 0c             	shr    $0xc,%eax
  800d83:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800d8a:	f6 c4 08             	test   $0x8,%ah
  800d8d:	75 14                	jne    800da3 <pgfault+0x39>
		panic("pgfault: not due to a write or a COW page");
  800d8f:	83 ec 04             	sub    $0x4,%esp
  800d92:	68 2c 25 80 00       	push   $0x80252c
  800d97:	6a 1e                	push   $0x1e
  800d99:	68 c0 25 80 00       	push   $0x8025c0
  800d9e:	e8 69 10 00 00       	call   801e0c <_panic>

	// LAB 4: Your code here.

	// panic("pgfault not implemented");

	addr = ROUNDDOWN(addr, PGSIZE);
  800da3:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	envid_t envid = sys_getenvid();
  800da9:	e8 8d fd ff ff       	call   800b3b <sys_getenvid>
  800dae:	89 c7                	mov    %eax,%edi

	if ( (uint32_t)addr ==  0xeebfd000) {
  800db0:	81 fb 00 d0 bf ee    	cmp    $0xeebfd000,%ebx
  800db6:	75 31                	jne    800de9 <pgfault+0x7f>
		cprintf("[hit %e]\n", utf->utf_err);
  800db8:	83 ec 08             	sub    $0x8,%esp
  800dbb:	ff 76 04             	pushl  0x4(%esi)
  800dbe:	68 cb 25 80 00       	push   $0x8025cb
  800dc3:	e8 29 f4 ff ff       	call   8001f1 <cprintf>
		cprintf("[hit 0x%x]\n", utf->utf_eip);
  800dc8:	83 c4 08             	add    $0x8,%esp
  800dcb:	ff 76 28             	pushl  0x28(%esi)
  800dce:	68 d5 25 80 00       	push   $0x8025d5
  800dd3:	e8 19 f4 ff ff       	call   8001f1 <cprintf>
		cprintf("[hit %d]\n", envid);
  800dd8:	83 c4 08             	add    $0x8,%esp
  800ddb:	57                   	push   %edi
  800ddc:	68 e1 25 80 00       	push   $0x8025e1
  800de1:	e8 0b f4 ff ff       	call   8001f1 <cprintf>
  800de6:	83 c4 10             	add    $0x10,%esp
	}

	// envid = 0;

	// Allocate a new page, map it at a temporary location (PFTEMP)
	r = sys_page_alloc(envid, (void *)PFTEMP, PTE_U | PTE_P | PTE_W);
  800de9:	83 ec 04             	sub    $0x4,%esp
  800dec:	6a 07                	push   $0x7
  800dee:	68 00 f0 7f 00       	push   $0x7ff000
  800df3:	57                   	push   %edi
  800df4:	e8 80 fd ff ff       	call   800b79 <sys_page_alloc>
	if (r < 0)
  800df9:	83 c4 10             	add    $0x10,%esp
  800dfc:	85 c0                	test   %eax,%eax
  800dfe:	79 12                	jns    800e12 <pgfault+0xa8>
		panic("pgfault: sys_page_alloc failed: %e\n", r);
  800e00:	50                   	push   %eax
  800e01:	68 58 25 80 00       	push   $0x802558
  800e06:	6a 39                	push   $0x39
  800e08:	68 c0 25 80 00       	push   $0x8025c0
  800e0d:	e8 fa 0f 00 00       	call   801e0c <_panic>
	
	// copy the data from the old page to the new page
	memcpy((void *) PFTEMP, (const void *) addr, PGSIZE);
  800e12:	83 ec 04             	sub    $0x4,%esp
  800e15:	68 00 10 00 00       	push   $0x1000
  800e1a:	53                   	push   %ebx
  800e1b:	68 00 f0 7f 00       	push   $0x7ff000
  800e20:	e8 4b fb ff ff       	call   800970 <memcpy>

	// move the new page to the old page's address
	r = sys_page_map(envid, (void *) PFTEMP, envid, addr, PTE_U | PTE_P | PTE_W);
  800e25:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800e2c:	53                   	push   %ebx
  800e2d:	57                   	push   %edi
  800e2e:	68 00 f0 7f 00       	push   $0x7ff000
  800e33:	57                   	push   %edi
  800e34:	e8 83 fd ff ff       	call   800bbc <sys_page_map>
	if (r < 0)
  800e39:	83 c4 20             	add    $0x20,%esp
  800e3c:	85 c0                	test   %eax,%eax
  800e3e:	79 12                	jns    800e52 <pgfault+0xe8>
		panic("pgfault: sys_page_map failed: %e\n", r);
  800e40:	50                   	push   %eax
  800e41:	68 7c 25 80 00       	push   $0x80257c
  800e46:	6a 41                	push   $0x41
  800e48:	68 c0 25 80 00       	push   $0x8025c0
  800e4d:	e8 ba 0f 00 00       	call   801e0c <_panic>

	// unmap temporary region
	r = sys_page_unmap(envid, (void *) PFTEMP);
  800e52:	83 ec 08             	sub    $0x8,%esp
  800e55:	68 00 f0 7f 00       	push   $0x7ff000
  800e5a:	57                   	push   %edi
  800e5b:	e8 9e fd ff ff       	call   800bfe <sys_page_unmap>
	if (r < 0)
  800e60:	83 c4 10             	add    $0x10,%esp
  800e63:	85 c0                	test   %eax,%eax
  800e65:	79 12                	jns    800e79 <pgfault+0x10f>
        panic("pgfault: page unmap failed: %e\n", r);
  800e67:	50                   	push   %eax
  800e68:	68 a0 25 80 00       	push   $0x8025a0
  800e6d:	6a 46                	push   $0x46
  800e6f:	68 c0 25 80 00       	push   $0x8025c0
  800e74:	e8 93 0f 00 00       	call   801e0c <_panic>
}
  800e79:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e7c:	5b                   	pop    %ebx
  800e7d:	5e                   	pop    %esi
  800e7e:	5f                   	pop    %edi
  800e7f:	5d                   	pop    %ebp
  800e80:	c3                   	ret    

00800e81 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800e81:	55                   	push   %ebp
  800e82:	89 e5                	mov    %esp,%ebp
  800e84:	57                   	push   %edi
  800e85:	56                   	push   %esi
  800e86:	53                   	push   %ebx
  800e87:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	// cprintf("[fork]\n");
	int r;

	set_pgfault_handler(pgfault);
  800e8a:	68 6a 0d 80 00       	push   $0x800d6a
  800e8f:	e8 be 0f 00 00       	call   801e52 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800e94:	b8 07 00 00 00       	mov    $0x7,%eax
  800e99:	cd 30                	int    $0x30

	envid_t envid = sys_exofork();
	if (envid < 0)
  800e9b:	83 c4 10             	add    $0x10,%esp
  800e9e:	85 c0                	test   %eax,%eax
  800ea0:	0f 88 67 01 00 00    	js     80100d <fork+0x18c>
  800ea6:	bb 00 00 80 00       	mov    $0x800000,%ebx
  800eab:	be 00 08 00 00       	mov    $0x800,%esi
		return envid;

	// fix "thisenv" in the child process
	if (envid == 0) {
  800eb0:	85 c0                	test   %eax,%eax
  800eb2:	75 21                	jne    800ed5 <fork+0x54>
		thisenv = &envs[ENVX(sys_getenvid())];
  800eb4:	e8 82 fc ff ff       	call   800b3b <sys_getenvid>
  800eb9:	25 ff 03 00 00       	and    $0x3ff,%eax
  800ebe:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800ec1:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800ec6:	a3 08 40 80 00       	mov    %eax,0x804008
        return 0;
  800ecb:	ba 00 00 00 00       	mov    $0x0,%edx
  800ed0:	e9 42 01 00 00       	jmp    801017 <fork+0x196>
  800ed5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800ed8:	89 c7                	mov    %eax,%edi
	for (uint32_t pn = PGNUM(UTEXT); pn < PGNUM(USTACKTOP); pn++) {

		addr = pn * PGSIZE;

		// if level-2 page exists
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P) {
  800eda:	89 d8                	mov    %ebx,%eax
  800edc:	c1 e8 16             	shr    $0x16,%eax
  800edf:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800ee6:	a8 01                	test   $0x1,%al
  800ee8:	0f 84 c0 00 00 00    	je     800fae <fork+0x12d>
			
			// if real PTE exists
			if ((uvpt[PGNUM(addr)] & PTE_P) == PTE_P) {
  800eee:	89 d8                	mov    %ebx,%eax
  800ef0:	c1 e8 0c             	shr    $0xc,%eax
  800ef3:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800efa:	f6 c2 01             	test   $0x1,%dl
  800efd:	0f 84 ab 00 00 00    	je     800fae <fork+0x12d>

				// For each writable or copy-on-write page
				if ((uvpt[PGNUM(addr)] & (PTE_W | PTE_COW)) != 0) {
  800f03:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f0a:	a9 02 08 00 00       	test   $0x802,%eax
  800f0f:	0f 84 99 00 00 00    	je     800fae <fork+0x12d>
	// r = envid2env(envid, &env, 1);
	// if (r < 0)
	// 	return r;	// E_BAD_ENV
	// envid_t parent_envid = env->env_parent_id;

	if (uvpt[pn] & PTE_SHARE) {
  800f15:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800f1c:	f6 c4 04             	test   $0x4,%ah
  800f1f:	74 17                	je     800f38 <fork+0xb7>
		sys_page_map(0, (void *)va, envid, (void *)va, PTE_SYSCALL);
  800f21:	83 ec 0c             	sub    $0xc,%esp
  800f24:	68 07 0e 00 00       	push   $0xe07
  800f29:	53                   	push   %ebx
  800f2a:	57                   	push   %edi
  800f2b:	53                   	push   %ebx
  800f2c:	6a 00                	push   $0x0
  800f2e:	e8 89 fc ff ff       	call   800bbc <sys_page_map>
  800f33:	83 c4 20             	add    $0x20,%esp
  800f36:	eb 76                	jmp    800fae <fork+0x12d>
	}
	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {
  800f38:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800f3f:	a8 02                	test   $0x2,%al
  800f41:	75 0c                	jne    800f4f <fork+0xce>
  800f43:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800f4a:	f6 c4 08             	test   $0x8,%ah
  800f4d:	74 3f                	je     800f8e <fork+0x10d>

		// map the page copy-on-write into the address space of the child
        r = sys_page_map(0, (void *)va, envid, (void *)va, PTE_P|PTE_U|PTE_COW);
  800f4f:	83 ec 0c             	sub    $0xc,%esp
  800f52:	68 05 08 00 00       	push   $0x805
  800f57:	53                   	push   %ebx
  800f58:	57                   	push   %edi
  800f59:	53                   	push   %ebx
  800f5a:	6a 00                	push   $0x0
  800f5c:	e8 5b fc ff ff       	call   800bbc <sys_page_map>
		if (r < 0)
  800f61:	83 c4 20             	add    $0x20,%esp
  800f64:	85 c0                	test   %eax,%eax
  800f66:	0f 88 a5 00 00 00    	js     801011 <fork+0x190>
            return r;

		// remap the page copy-on-write in its own(parent) address space
        r = sys_page_map(0, (void *)va, 0, (void *)va, PTE_P|PTE_U|PTE_COW);
  800f6c:	83 ec 0c             	sub    $0xc,%esp
  800f6f:	68 05 08 00 00       	push   $0x805
  800f74:	53                   	push   %ebx
  800f75:	6a 00                	push   $0x0
  800f77:	53                   	push   %ebx
  800f78:	6a 00                	push   $0x0
  800f7a:	e8 3d fc ff ff       	call   800bbc <sys_page_map>
  800f7f:	83 c4 20             	add    $0x20,%esp
  800f82:	85 c0                	test   %eax,%eax
  800f84:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f89:	0f 4f c1             	cmovg  %ecx,%eax
  800f8c:	eb 1c                	jmp    800faa <fork+0x129>
		if (r < 0)
            return r;
    }
    else {
        r = sys_page_map(0, (void *)va, envid, (void *)va, PTE_P|PTE_U);
  800f8e:	83 ec 0c             	sub    $0xc,%esp
  800f91:	6a 05                	push   $0x5
  800f93:	53                   	push   %ebx
  800f94:	57                   	push   %edi
  800f95:	53                   	push   %ebx
  800f96:	6a 00                	push   $0x0
  800f98:	e8 1f fc ff ff       	call   800bbc <sys_page_map>
  800f9d:	83 c4 20             	add    $0x20,%esp
  800fa0:	85 c0                	test   %eax,%eax
  800fa2:	b9 00 00 00 00       	mov    $0x0,%ecx
  800fa7:	0f 4f c1             	cmovg  %ecx,%eax
			if ((uvpt[PGNUM(addr)] & PTE_P) == PTE_P) {

				// For each writable or copy-on-write page
				if ((uvpt[PGNUM(addr)] & (PTE_W | PTE_COW)) != 0) {
					r = duppage(envid, pn);
					if (r < 0)
  800faa:	85 c0                	test   %eax,%eax
  800fac:	78 67                	js     801015 <fork+0x194>
        return 0;
	}

	// For each writable or copy-on-write page in its address space below UTOP, the parent calls duppage
	uint32_t addr;
	for (uint32_t pn = PGNUM(UTEXT); pn < PGNUM(USTACKTOP); pn++) {
  800fae:	83 c6 01             	add    $0x1,%esi
  800fb1:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  800fb7:	81 fe fe eb 0e 00    	cmp    $0xeebfe,%esi
  800fbd:	0f 85 17 ff ff ff    	jne    800eda <fork+0x59>
  800fc3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
		}
	}

	// allocate a fresh page in the child for the exception stack
	r = sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U | PTE_P | PTE_W);
  800fc6:	83 ec 04             	sub    $0x4,%esp
  800fc9:	6a 07                	push   $0x7
  800fcb:	68 00 f0 bf ee       	push   $0xeebff000
  800fd0:	57                   	push   %edi
  800fd1:	e8 a3 fb ff ff       	call   800b79 <sys_page_alloc>
	if (r < 0)
  800fd6:	83 c4 10             	add    $0x10,%esp
		return r;
  800fd9:	89 c2                	mov    %eax,%edx
		}
	}

	// allocate a fresh page in the child for the exception stack
	r = sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U | PTE_P | PTE_W);
	if (r < 0)
  800fdb:	85 c0                	test   %eax,%eax
  800fdd:	78 38                	js     801017 <fork+0x196>
		return r;

	// The parent sets the user page fault entrypoint for the child to look like its own
	extern void _pgfault_upcall(void);
	r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  800fdf:	83 ec 08             	sub    $0x8,%esp
  800fe2:	68 99 1e 80 00       	push   $0x801e99
  800fe7:	57                   	push   %edi
  800fe8:	e8 d7 fc ff ff       	call   800cc4 <sys_env_set_pgfault_upcall>
	if (r < 0)
  800fed:	83 c4 10             	add    $0x10,%esp
		return r;
  800ff0:	89 c2                	mov    %eax,%edx
		return r;

	// The parent sets the user page fault entrypoint for the child to look like its own
	extern void _pgfault_upcall(void);
	r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
	if (r < 0)
  800ff2:	85 c0                	test   %eax,%eax
  800ff4:	78 21                	js     801017 <fork+0x196>
		return r;

	// The child is now ready to run, so the parent marks it runnable
	r = sys_env_set_status(envid, ENV_RUNNABLE);
  800ff6:	83 ec 08             	sub    $0x8,%esp
  800ff9:	6a 02                	push   $0x2
  800ffb:	57                   	push   %edi
  800ffc:	e8 3f fc ff ff       	call   800c40 <sys_env_set_status>
	if (r < 0)
  801001:	83 c4 10             	add    $0x10,%esp
		return r;

	return envid;
  801004:	85 c0                	test   %eax,%eax
  801006:	0f 48 f8             	cmovs  %eax,%edi
  801009:	89 fa                	mov    %edi,%edx
  80100b:	eb 0a                	jmp    801017 <fork+0x196>

	set_pgfault_handler(pgfault);

	envid_t envid = sys_exofork();
	if (envid < 0)
		return envid;
  80100d:	89 c2                	mov    %eax,%edx
  80100f:	eb 06                	jmp    801017 <fork+0x196>
		sys_page_map(0, (void *)va, envid, (void *)va, PTE_SYSCALL);
	}
	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {

		// map the page copy-on-write into the address space of the child
        r = sys_page_map(0, (void *)va, envid, (void *)va, PTE_P|PTE_U|PTE_COW);
  801011:	89 c2                	mov    %eax,%edx
  801013:	eb 02                	jmp    801017 <fork+0x196>
  801015:	89 c2                	mov    %eax,%edx
	if (r < 0)
		return r;

	return envid;
	// panic("fork not implemented");
}
  801017:	89 d0                	mov    %edx,%eax
  801019:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80101c:	5b                   	pop    %ebx
  80101d:	5e                   	pop    %esi
  80101e:	5f                   	pop    %edi
  80101f:	5d                   	pop    %ebp
  801020:	c3                   	ret    

00801021 <sfork>:

// Challenge!
int
sfork(void)
{
  801021:	55                   	push   %ebp
  801022:	89 e5                	mov    %esp,%ebp
  801024:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801027:	68 eb 25 80 00       	push   $0x8025eb
  80102c:	68 ce 00 00 00       	push   $0xce
  801031:	68 c0 25 80 00       	push   $0x8025c0
  801036:	e8 d1 0d 00 00       	call   801e0c <_panic>

0080103b <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80103b:	55                   	push   %ebp
  80103c:	89 e5                	mov    %esp,%ebp
  80103e:	56                   	push   %esi
  80103f:	53                   	push   %ebx
  801040:	8b 75 08             	mov    0x8(%ebp),%esi
  801043:	8b 45 0c             	mov    0xc(%ebp),%eax
  801046:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");

	// don't want to recv page
	if (pg == NULL)
  801049:	85 c0                	test   %eax,%eax
		pg = (void *)UTOP;
  80104b:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801050:	0f 44 c2             	cmove  %edx,%eax

	int err = sys_ipc_recv(pg);
  801053:	83 ec 0c             	sub    $0xc,%esp
  801056:	50                   	push   %eax
  801057:	e8 cd fc ff ff       	call   800d29 <sys_ipc_recv>

	if (from_env_store != NULL)
  80105c:	83 c4 10             	add    $0x10,%esp
  80105f:	85 f6                	test   %esi,%esi
  801061:	74 14                	je     801077 <ipc_recv+0x3c>
		*from_env_store = err < 0? 0 : thisenv->env_ipc_from;
  801063:	ba 00 00 00 00       	mov    $0x0,%edx
  801068:	85 c0                	test   %eax,%eax
  80106a:	78 09                	js     801075 <ipc_recv+0x3a>
  80106c:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801072:	8b 52 74             	mov    0x74(%edx),%edx
  801075:	89 16                	mov    %edx,(%esi)
	
	if (perm_store != NULL)
  801077:	85 db                	test   %ebx,%ebx
  801079:	74 14                	je     80108f <ipc_recv+0x54>
		*perm_store = err < 0? 0 : thisenv->env_ipc_perm;
  80107b:	ba 00 00 00 00       	mov    $0x0,%edx
  801080:	85 c0                	test   %eax,%eax
  801082:	78 09                	js     80108d <ipc_recv+0x52>
  801084:	8b 15 08 40 80 00    	mov    0x804008,%edx
  80108a:	8b 52 78             	mov    0x78(%edx),%edx
  80108d:	89 13                	mov    %edx,(%ebx)

	if (err < 0)
  80108f:	85 c0                	test   %eax,%eax
  801091:	78 08                	js     80109b <ipc_recv+0x60>
		return err;
	return thisenv->env_ipc_value;
  801093:	a1 08 40 80 00       	mov    0x804008,%eax
  801098:	8b 40 70             	mov    0x70(%eax),%eax
}
  80109b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80109e:	5b                   	pop    %ebx
  80109f:	5e                   	pop    %esi
  8010a0:	5d                   	pop    %ebp
  8010a1:	c3                   	ret    

008010a2 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8010a2:	55                   	push   %ebp
  8010a3:	89 e5                	mov    %esp,%ebp
  8010a5:	57                   	push   %edi
  8010a6:	56                   	push   %esi
  8010a7:	53                   	push   %ebx
  8010a8:	83 ec 0c             	sub    $0xc,%esp
  8010ab:	8b 7d 08             	mov    0x8(%ebp),%edi
  8010ae:	8b 75 0c             	mov    0xc(%ebp),%esi
  8010b1:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");

	// don't want to send page
	if (pg == NULL)
  8010b4:	85 db                	test   %ebx,%ebx
		pg = (void *)UTOP;
  8010b6:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  8010bb:	0f 44 d8             	cmove  %eax,%ebx
	
	int err = 0;
	
	do {

		err = sys_ipc_try_send(to_env, val, pg, perm);
  8010be:	ff 75 14             	pushl  0x14(%ebp)
  8010c1:	53                   	push   %ebx
  8010c2:	56                   	push   %esi
  8010c3:	57                   	push   %edi
  8010c4:	e8 3d fc ff ff       	call   800d06 <sys_ipc_try_send>

		if (err < 0) {
  8010c9:	83 c4 10             	add    $0x10,%esp
  8010cc:	85 c0                	test   %eax,%eax
  8010ce:	79 1e                	jns    8010ee <ipc_send+0x4c>
			if (err == -E_IPC_NOT_RECV)
  8010d0:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8010d3:	75 07                	jne    8010dc <ipc_send+0x3a>
				sys_yield();
  8010d5:	e8 80 fa ff ff       	call   800b5a <sys_yield>
  8010da:	eb e2                	jmp    8010be <ipc_send+0x1c>
			else 
				panic("ipc_send: %e", err);
  8010dc:	50                   	push   %eax
  8010dd:	68 01 26 80 00       	push   $0x802601
  8010e2:	6a 49                	push   $0x49
  8010e4:	68 0e 26 80 00       	push   $0x80260e
  8010e9:	e8 1e 0d 00 00       	call   801e0c <_panic>
		}

	} while (err < 0);

}
  8010ee:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010f1:	5b                   	pop    %ebx
  8010f2:	5e                   	pop    %esi
  8010f3:	5f                   	pop    %edi
  8010f4:	5d                   	pop    %ebp
  8010f5:	c3                   	ret    

008010f6 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8010f6:	55                   	push   %ebp
  8010f7:	89 e5                	mov    %esp,%ebp
  8010f9:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8010fc:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801101:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801104:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80110a:	8b 52 50             	mov    0x50(%edx),%edx
  80110d:	39 ca                	cmp    %ecx,%edx
  80110f:	75 0d                	jne    80111e <ipc_find_env+0x28>
			return envs[i].env_id;
  801111:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801114:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801119:	8b 40 48             	mov    0x48(%eax),%eax
  80111c:	eb 0f                	jmp    80112d <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80111e:	83 c0 01             	add    $0x1,%eax
  801121:	3d 00 04 00 00       	cmp    $0x400,%eax
  801126:	75 d9                	jne    801101 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801128:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80112d:	5d                   	pop    %ebp
  80112e:	c3                   	ret    

0080112f <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80112f:	55                   	push   %ebp
  801130:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801132:	8b 45 08             	mov    0x8(%ebp),%eax
  801135:	05 00 00 00 30       	add    $0x30000000,%eax
  80113a:	c1 e8 0c             	shr    $0xc,%eax
}
  80113d:	5d                   	pop    %ebp
  80113e:	c3                   	ret    

0080113f <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80113f:	55                   	push   %ebp
  801140:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801142:	8b 45 08             	mov    0x8(%ebp),%eax
  801145:	05 00 00 00 30       	add    $0x30000000,%eax
  80114a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80114f:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801154:	5d                   	pop    %ebp
  801155:	c3                   	ret    

00801156 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801156:	55                   	push   %ebp
  801157:	89 e5                	mov    %esp,%ebp
  801159:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80115c:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801161:	89 c2                	mov    %eax,%edx
  801163:	c1 ea 16             	shr    $0x16,%edx
  801166:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80116d:	f6 c2 01             	test   $0x1,%dl
  801170:	74 11                	je     801183 <fd_alloc+0x2d>
  801172:	89 c2                	mov    %eax,%edx
  801174:	c1 ea 0c             	shr    $0xc,%edx
  801177:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80117e:	f6 c2 01             	test   $0x1,%dl
  801181:	75 09                	jne    80118c <fd_alloc+0x36>
			*fd_store = fd;
  801183:	89 01                	mov    %eax,(%ecx)
			return 0;
  801185:	b8 00 00 00 00       	mov    $0x0,%eax
  80118a:	eb 17                	jmp    8011a3 <fd_alloc+0x4d>
  80118c:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801191:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801196:	75 c9                	jne    801161 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801198:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  80119e:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8011a3:	5d                   	pop    %ebp
  8011a4:	c3                   	ret    

008011a5 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8011a5:	55                   	push   %ebp
  8011a6:	89 e5                	mov    %esp,%ebp
  8011a8:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8011ab:	83 f8 1f             	cmp    $0x1f,%eax
  8011ae:	77 36                	ja     8011e6 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8011b0:	c1 e0 0c             	shl    $0xc,%eax
  8011b3:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8011b8:	89 c2                	mov    %eax,%edx
  8011ba:	c1 ea 16             	shr    $0x16,%edx
  8011bd:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8011c4:	f6 c2 01             	test   $0x1,%dl
  8011c7:	74 24                	je     8011ed <fd_lookup+0x48>
  8011c9:	89 c2                	mov    %eax,%edx
  8011cb:	c1 ea 0c             	shr    $0xc,%edx
  8011ce:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8011d5:	f6 c2 01             	test   $0x1,%dl
  8011d8:	74 1a                	je     8011f4 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8011da:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011dd:	89 02                	mov    %eax,(%edx)
	return 0;
  8011df:	b8 00 00 00 00       	mov    $0x0,%eax
  8011e4:	eb 13                	jmp    8011f9 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8011e6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011eb:	eb 0c                	jmp    8011f9 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8011ed:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011f2:	eb 05                	jmp    8011f9 <fd_lookup+0x54>
  8011f4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8011f9:	5d                   	pop    %ebp
  8011fa:	c3                   	ret    

008011fb <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8011fb:	55                   	push   %ebp
  8011fc:	89 e5                	mov    %esp,%ebp
  8011fe:	83 ec 08             	sub    $0x8,%esp
  801201:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801204:	ba 94 26 80 00       	mov    $0x802694,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801209:	eb 13                	jmp    80121e <dev_lookup+0x23>
  80120b:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80120e:	39 08                	cmp    %ecx,(%eax)
  801210:	75 0c                	jne    80121e <dev_lookup+0x23>
			*dev = devtab[i];
  801212:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801215:	89 01                	mov    %eax,(%ecx)
			return 0;
  801217:	b8 00 00 00 00       	mov    $0x0,%eax
  80121c:	eb 2e                	jmp    80124c <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80121e:	8b 02                	mov    (%edx),%eax
  801220:	85 c0                	test   %eax,%eax
  801222:	75 e7                	jne    80120b <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801224:	a1 08 40 80 00       	mov    0x804008,%eax
  801229:	8b 40 48             	mov    0x48(%eax),%eax
  80122c:	83 ec 04             	sub    $0x4,%esp
  80122f:	51                   	push   %ecx
  801230:	50                   	push   %eax
  801231:	68 18 26 80 00       	push   $0x802618
  801236:	e8 b6 ef ff ff       	call   8001f1 <cprintf>
	*dev = 0;
  80123b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80123e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801244:	83 c4 10             	add    $0x10,%esp
  801247:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80124c:	c9                   	leave  
  80124d:	c3                   	ret    

0080124e <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80124e:	55                   	push   %ebp
  80124f:	89 e5                	mov    %esp,%ebp
  801251:	56                   	push   %esi
  801252:	53                   	push   %ebx
  801253:	83 ec 10             	sub    $0x10,%esp
  801256:	8b 75 08             	mov    0x8(%ebp),%esi
  801259:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80125c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80125f:	50                   	push   %eax
  801260:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801266:	c1 e8 0c             	shr    $0xc,%eax
  801269:	50                   	push   %eax
  80126a:	e8 36 ff ff ff       	call   8011a5 <fd_lookup>
  80126f:	83 c4 08             	add    $0x8,%esp
  801272:	85 c0                	test   %eax,%eax
  801274:	78 05                	js     80127b <fd_close+0x2d>
	    || fd != fd2)
  801276:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801279:	74 0c                	je     801287 <fd_close+0x39>
		return (must_exist ? r : 0);
  80127b:	84 db                	test   %bl,%bl
  80127d:	ba 00 00 00 00       	mov    $0x0,%edx
  801282:	0f 44 c2             	cmove  %edx,%eax
  801285:	eb 41                	jmp    8012c8 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801287:	83 ec 08             	sub    $0x8,%esp
  80128a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80128d:	50                   	push   %eax
  80128e:	ff 36                	pushl  (%esi)
  801290:	e8 66 ff ff ff       	call   8011fb <dev_lookup>
  801295:	89 c3                	mov    %eax,%ebx
  801297:	83 c4 10             	add    $0x10,%esp
  80129a:	85 c0                	test   %eax,%eax
  80129c:	78 1a                	js     8012b8 <fd_close+0x6a>
		if (dev->dev_close)
  80129e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012a1:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8012a4:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8012a9:	85 c0                	test   %eax,%eax
  8012ab:	74 0b                	je     8012b8 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8012ad:	83 ec 0c             	sub    $0xc,%esp
  8012b0:	56                   	push   %esi
  8012b1:	ff d0                	call   *%eax
  8012b3:	89 c3                	mov    %eax,%ebx
  8012b5:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8012b8:	83 ec 08             	sub    $0x8,%esp
  8012bb:	56                   	push   %esi
  8012bc:	6a 00                	push   $0x0
  8012be:	e8 3b f9 ff ff       	call   800bfe <sys_page_unmap>
	return r;
  8012c3:	83 c4 10             	add    $0x10,%esp
  8012c6:	89 d8                	mov    %ebx,%eax
}
  8012c8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012cb:	5b                   	pop    %ebx
  8012cc:	5e                   	pop    %esi
  8012cd:	5d                   	pop    %ebp
  8012ce:	c3                   	ret    

008012cf <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8012cf:	55                   	push   %ebp
  8012d0:	89 e5                	mov    %esp,%ebp
  8012d2:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8012d5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012d8:	50                   	push   %eax
  8012d9:	ff 75 08             	pushl  0x8(%ebp)
  8012dc:	e8 c4 fe ff ff       	call   8011a5 <fd_lookup>
  8012e1:	83 c4 08             	add    $0x8,%esp
  8012e4:	85 c0                	test   %eax,%eax
  8012e6:	78 10                	js     8012f8 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8012e8:	83 ec 08             	sub    $0x8,%esp
  8012eb:	6a 01                	push   $0x1
  8012ed:	ff 75 f4             	pushl  -0xc(%ebp)
  8012f0:	e8 59 ff ff ff       	call   80124e <fd_close>
  8012f5:	83 c4 10             	add    $0x10,%esp
}
  8012f8:	c9                   	leave  
  8012f9:	c3                   	ret    

008012fa <close_all>:

void
close_all(void)
{
  8012fa:	55                   	push   %ebp
  8012fb:	89 e5                	mov    %esp,%ebp
  8012fd:	53                   	push   %ebx
  8012fe:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801301:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801306:	83 ec 0c             	sub    $0xc,%esp
  801309:	53                   	push   %ebx
  80130a:	e8 c0 ff ff ff       	call   8012cf <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80130f:	83 c3 01             	add    $0x1,%ebx
  801312:	83 c4 10             	add    $0x10,%esp
  801315:	83 fb 20             	cmp    $0x20,%ebx
  801318:	75 ec                	jne    801306 <close_all+0xc>
		close(i);
}
  80131a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80131d:	c9                   	leave  
  80131e:	c3                   	ret    

0080131f <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80131f:	55                   	push   %ebp
  801320:	89 e5                	mov    %esp,%ebp
  801322:	57                   	push   %edi
  801323:	56                   	push   %esi
  801324:	53                   	push   %ebx
  801325:	83 ec 2c             	sub    $0x2c,%esp
  801328:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80132b:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80132e:	50                   	push   %eax
  80132f:	ff 75 08             	pushl  0x8(%ebp)
  801332:	e8 6e fe ff ff       	call   8011a5 <fd_lookup>
  801337:	83 c4 08             	add    $0x8,%esp
  80133a:	85 c0                	test   %eax,%eax
  80133c:	0f 88 c1 00 00 00    	js     801403 <dup+0xe4>
		return r;
	close(newfdnum);
  801342:	83 ec 0c             	sub    $0xc,%esp
  801345:	56                   	push   %esi
  801346:	e8 84 ff ff ff       	call   8012cf <close>

	newfd = INDEX2FD(newfdnum);
  80134b:	89 f3                	mov    %esi,%ebx
  80134d:	c1 e3 0c             	shl    $0xc,%ebx
  801350:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801356:	83 c4 04             	add    $0x4,%esp
  801359:	ff 75 e4             	pushl  -0x1c(%ebp)
  80135c:	e8 de fd ff ff       	call   80113f <fd2data>
  801361:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801363:	89 1c 24             	mov    %ebx,(%esp)
  801366:	e8 d4 fd ff ff       	call   80113f <fd2data>
  80136b:	83 c4 10             	add    $0x10,%esp
  80136e:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801371:	89 f8                	mov    %edi,%eax
  801373:	c1 e8 16             	shr    $0x16,%eax
  801376:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80137d:	a8 01                	test   $0x1,%al
  80137f:	74 37                	je     8013b8 <dup+0x99>
  801381:	89 f8                	mov    %edi,%eax
  801383:	c1 e8 0c             	shr    $0xc,%eax
  801386:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80138d:	f6 c2 01             	test   $0x1,%dl
  801390:	74 26                	je     8013b8 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801392:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801399:	83 ec 0c             	sub    $0xc,%esp
  80139c:	25 07 0e 00 00       	and    $0xe07,%eax
  8013a1:	50                   	push   %eax
  8013a2:	ff 75 d4             	pushl  -0x2c(%ebp)
  8013a5:	6a 00                	push   $0x0
  8013a7:	57                   	push   %edi
  8013a8:	6a 00                	push   $0x0
  8013aa:	e8 0d f8 ff ff       	call   800bbc <sys_page_map>
  8013af:	89 c7                	mov    %eax,%edi
  8013b1:	83 c4 20             	add    $0x20,%esp
  8013b4:	85 c0                	test   %eax,%eax
  8013b6:	78 2e                	js     8013e6 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8013b8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8013bb:	89 d0                	mov    %edx,%eax
  8013bd:	c1 e8 0c             	shr    $0xc,%eax
  8013c0:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8013c7:	83 ec 0c             	sub    $0xc,%esp
  8013ca:	25 07 0e 00 00       	and    $0xe07,%eax
  8013cf:	50                   	push   %eax
  8013d0:	53                   	push   %ebx
  8013d1:	6a 00                	push   $0x0
  8013d3:	52                   	push   %edx
  8013d4:	6a 00                	push   $0x0
  8013d6:	e8 e1 f7 ff ff       	call   800bbc <sys_page_map>
  8013db:	89 c7                	mov    %eax,%edi
  8013dd:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8013e0:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8013e2:	85 ff                	test   %edi,%edi
  8013e4:	79 1d                	jns    801403 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8013e6:	83 ec 08             	sub    $0x8,%esp
  8013e9:	53                   	push   %ebx
  8013ea:	6a 00                	push   $0x0
  8013ec:	e8 0d f8 ff ff       	call   800bfe <sys_page_unmap>
	sys_page_unmap(0, nva);
  8013f1:	83 c4 08             	add    $0x8,%esp
  8013f4:	ff 75 d4             	pushl  -0x2c(%ebp)
  8013f7:	6a 00                	push   $0x0
  8013f9:	e8 00 f8 ff ff       	call   800bfe <sys_page_unmap>
	return r;
  8013fe:	83 c4 10             	add    $0x10,%esp
  801401:	89 f8                	mov    %edi,%eax
}
  801403:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801406:	5b                   	pop    %ebx
  801407:	5e                   	pop    %esi
  801408:	5f                   	pop    %edi
  801409:	5d                   	pop    %ebp
  80140a:	c3                   	ret    

0080140b <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80140b:	55                   	push   %ebp
  80140c:	89 e5                	mov    %esp,%ebp
  80140e:	53                   	push   %ebx
  80140f:	83 ec 14             	sub    $0x14,%esp
  801412:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801415:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801418:	50                   	push   %eax
  801419:	53                   	push   %ebx
  80141a:	e8 86 fd ff ff       	call   8011a5 <fd_lookup>
  80141f:	83 c4 08             	add    $0x8,%esp
  801422:	89 c2                	mov    %eax,%edx
  801424:	85 c0                	test   %eax,%eax
  801426:	78 6d                	js     801495 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801428:	83 ec 08             	sub    $0x8,%esp
  80142b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80142e:	50                   	push   %eax
  80142f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801432:	ff 30                	pushl  (%eax)
  801434:	e8 c2 fd ff ff       	call   8011fb <dev_lookup>
  801439:	83 c4 10             	add    $0x10,%esp
  80143c:	85 c0                	test   %eax,%eax
  80143e:	78 4c                	js     80148c <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801440:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801443:	8b 42 08             	mov    0x8(%edx),%eax
  801446:	83 e0 03             	and    $0x3,%eax
  801449:	83 f8 01             	cmp    $0x1,%eax
  80144c:	75 21                	jne    80146f <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80144e:	a1 08 40 80 00       	mov    0x804008,%eax
  801453:	8b 40 48             	mov    0x48(%eax),%eax
  801456:	83 ec 04             	sub    $0x4,%esp
  801459:	53                   	push   %ebx
  80145a:	50                   	push   %eax
  80145b:	68 59 26 80 00       	push   $0x802659
  801460:	e8 8c ed ff ff       	call   8001f1 <cprintf>
		return -E_INVAL;
  801465:	83 c4 10             	add    $0x10,%esp
  801468:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80146d:	eb 26                	jmp    801495 <read+0x8a>
	}
	if (!dev->dev_read)
  80146f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801472:	8b 40 08             	mov    0x8(%eax),%eax
  801475:	85 c0                	test   %eax,%eax
  801477:	74 17                	je     801490 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801479:	83 ec 04             	sub    $0x4,%esp
  80147c:	ff 75 10             	pushl  0x10(%ebp)
  80147f:	ff 75 0c             	pushl  0xc(%ebp)
  801482:	52                   	push   %edx
  801483:	ff d0                	call   *%eax
  801485:	89 c2                	mov    %eax,%edx
  801487:	83 c4 10             	add    $0x10,%esp
  80148a:	eb 09                	jmp    801495 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80148c:	89 c2                	mov    %eax,%edx
  80148e:	eb 05                	jmp    801495 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801490:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801495:	89 d0                	mov    %edx,%eax
  801497:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80149a:	c9                   	leave  
  80149b:	c3                   	ret    

0080149c <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80149c:	55                   	push   %ebp
  80149d:	89 e5                	mov    %esp,%ebp
  80149f:	57                   	push   %edi
  8014a0:	56                   	push   %esi
  8014a1:	53                   	push   %ebx
  8014a2:	83 ec 0c             	sub    $0xc,%esp
  8014a5:	8b 7d 08             	mov    0x8(%ebp),%edi
  8014a8:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8014ab:	bb 00 00 00 00       	mov    $0x0,%ebx
  8014b0:	eb 21                	jmp    8014d3 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8014b2:	83 ec 04             	sub    $0x4,%esp
  8014b5:	89 f0                	mov    %esi,%eax
  8014b7:	29 d8                	sub    %ebx,%eax
  8014b9:	50                   	push   %eax
  8014ba:	89 d8                	mov    %ebx,%eax
  8014bc:	03 45 0c             	add    0xc(%ebp),%eax
  8014bf:	50                   	push   %eax
  8014c0:	57                   	push   %edi
  8014c1:	e8 45 ff ff ff       	call   80140b <read>
		if (m < 0)
  8014c6:	83 c4 10             	add    $0x10,%esp
  8014c9:	85 c0                	test   %eax,%eax
  8014cb:	78 10                	js     8014dd <readn+0x41>
			return m;
		if (m == 0)
  8014cd:	85 c0                	test   %eax,%eax
  8014cf:	74 0a                	je     8014db <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8014d1:	01 c3                	add    %eax,%ebx
  8014d3:	39 f3                	cmp    %esi,%ebx
  8014d5:	72 db                	jb     8014b2 <readn+0x16>
  8014d7:	89 d8                	mov    %ebx,%eax
  8014d9:	eb 02                	jmp    8014dd <readn+0x41>
  8014db:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8014dd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014e0:	5b                   	pop    %ebx
  8014e1:	5e                   	pop    %esi
  8014e2:	5f                   	pop    %edi
  8014e3:	5d                   	pop    %ebp
  8014e4:	c3                   	ret    

008014e5 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8014e5:	55                   	push   %ebp
  8014e6:	89 e5                	mov    %esp,%ebp
  8014e8:	53                   	push   %ebx
  8014e9:	83 ec 14             	sub    $0x14,%esp
  8014ec:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014ef:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014f2:	50                   	push   %eax
  8014f3:	53                   	push   %ebx
  8014f4:	e8 ac fc ff ff       	call   8011a5 <fd_lookup>
  8014f9:	83 c4 08             	add    $0x8,%esp
  8014fc:	89 c2                	mov    %eax,%edx
  8014fe:	85 c0                	test   %eax,%eax
  801500:	78 68                	js     80156a <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801502:	83 ec 08             	sub    $0x8,%esp
  801505:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801508:	50                   	push   %eax
  801509:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80150c:	ff 30                	pushl  (%eax)
  80150e:	e8 e8 fc ff ff       	call   8011fb <dev_lookup>
  801513:	83 c4 10             	add    $0x10,%esp
  801516:	85 c0                	test   %eax,%eax
  801518:	78 47                	js     801561 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80151a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80151d:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801521:	75 21                	jne    801544 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801523:	a1 08 40 80 00       	mov    0x804008,%eax
  801528:	8b 40 48             	mov    0x48(%eax),%eax
  80152b:	83 ec 04             	sub    $0x4,%esp
  80152e:	53                   	push   %ebx
  80152f:	50                   	push   %eax
  801530:	68 75 26 80 00       	push   $0x802675
  801535:	e8 b7 ec ff ff       	call   8001f1 <cprintf>
		return -E_INVAL;
  80153a:	83 c4 10             	add    $0x10,%esp
  80153d:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801542:	eb 26                	jmp    80156a <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801544:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801547:	8b 52 0c             	mov    0xc(%edx),%edx
  80154a:	85 d2                	test   %edx,%edx
  80154c:	74 17                	je     801565 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80154e:	83 ec 04             	sub    $0x4,%esp
  801551:	ff 75 10             	pushl  0x10(%ebp)
  801554:	ff 75 0c             	pushl  0xc(%ebp)
  801557:	50                   	push   %eax
  801558:	ff d2                	call   *%edx
  80155a:	89 c2                	mov    %eax,%edx
  80155c:	83 c4 10             	add    $0x10,%esp
  80155f:	eb 09                	jmp    80156a <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801561:	89 c2                	mov    %eax,%edx
  801563:	eb 05                	jmp    80156a <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801565:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80156a:	89 d0                	mov    %edx,%eax
  80156c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80156f:	c9                   	leave  
  801570:	c3                   	ret    

00801571 <seek>:

int
seek(int fdnum, off_t offset)
{
  801571:	55                   	push   %ebp
  801572:	89 e5                	mov    %esp,%ebp
  801574:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801577:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80157a:	50                   	push   %eax
  80157b:	ff 75 08             	pushl  0x8(%ebp)
  80157e:	e8 22 fc ff ff       	call   8011a5 <fd_lookup>
  801583:	83 c4 08             	add    $0x8,%esp
  801586:	85 c0                	test   %eax,%eax
  801588:	78 0e                	js     801598 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80158a:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80158d:	8b 55 0c             	mov    0xc(%ebp),%edx
  801590:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801593:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801598:	c9                   	leave  
  801599:	c3                   	ret    

0080159a <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80159a:	55                   	push   %ebp
  80159b:	89 e5                	mov    %esp,%ebp
  80159d:	53                   	push   %ebx
  80159e:	83 ec 14             	sub    $0x14,%esp
  8015a1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015a4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015a7:	50                   	push   %eax
  8015a8:	53                   	push   %ebx
  8015a9:	e8 f7 fb ff ff       	call   8011a5 <fd_lookup>
  8015ae:	83 c4 08             	add    $0x8,%esp
  8015b1:	89 c2                	mov    %eax,%edx
  8015b3:	85 c0                	test   %eax,%eax
  8015b5:	78 65                	js     80161c <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015b7:	83 ec 08             	sub    $0x8,%esp
  8015ba:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015bd:	50                   	push   %eax
  8015be:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015c1:	ff 30                	pushl  (%eax)
  8015c3:	e8 33 fc ff ff       	call   8011fb <dev_lookup>
  8015c8:	83 c4 10             	add    $0x10,%esp
  8015cb:	85 c0                	test   %eax,%eax
  8015cd:	78 44                	js     801613 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8015cf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015d2:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8015d6:	75 21                	jne    8015f9 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8015d8:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8015dd:	8b 40 48             	mov    0x48(%eax),%eax
  8015e0:	83 ec 04             	sub    $0x4,%esp
  8015e3:	53                   	push   %ebx
  8015e4:	50                   	push   %eax
  8015e5:	68 38 26 80 00       	push   $0x802638
  8015ea:	e8 02 ec ff ff       	call   8001f1 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8015ef:	83 c4 10             	add    $0x10,%esp
  8015f2:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8015f7:	eb 23                	jmp    80161c <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8015f9:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015fc:	8b 52 18             	mov    0x18(%edx),%edx
  8015ff:	85 d2                	test   %edx,%edx
  801601:	74 14                	je     801617 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801603:	83 ec 08             	sub    $0x8,%esp
  801606:	ff 75 0c             	pushl  0xc(%ebp)
  801609:	50                   	push   %eax
  80160a:	ff d2                	call   *%edx
  80160c:	89 c2                	mov    %eax,%edx
  80160e:	83 c4 10             	add    $0x10,%esp
  801611:	eb 09                	jmp    80161c <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801613:	89 c2                	mov    %eax,%edx
  801615:	eb 05                	jmp    80161c <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801617:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  80161c:	89 d0                	mov    %edx,%eax
  80161e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801621:	c9                   	leave  
  801622:	c3                   	ret    

00801623 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801623:	55                   	push   %ebp
  801624:	89 e5                	mov    %esp,%ebp
  801626:	53                   	push   %ebx
  801627:	83 ec 14             	sub    $0x14,%esp
  80162a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80162d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801630:	50                   	push   %eax
  801631:	ff 75 08             	pushl  0x8(%ebp)
  801634:	e8 6c fb ff ff       	call   8011a5 <fd_lookup>
  801639:	83 c4 08             	add    $0x8,%esp
  80163c:	89 c2                	mov    %eax,%edx
  80163e:	85 c0                	test   %eax,%eax
  801640:	78 58                	js     80169a <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801642:	83 ec 08             	sub    $0x8,%esp
  801645:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801648:	50                   	push   %eax
  801649:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80164c:	ff 30                	pushl  (%eax)
  80164e:	e8 a8 fb ff ff       	call   8011fb <dev_lookup>
  801653:	83 c4 10             	add    $0x10,%esp
  801656:	85 c0                	test   %eax,%eax
  801658:	78 37                	js     801691 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80165a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80165d:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801661:	74 32                	je     801695 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801663:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801666:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80166d:	00 00 00 
	stat->st_isdir = 0;
  801670:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801677:	00 00 00 
	stat->st_dev = dev;
  80167a:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801680:	83 ec 08             	sub    $0x8,%esp
  801683:	53                   	push   %ebx
  801684:	ff 75 f0             	pushl  -0x10(%ebp)
  801687:	ff 50 14             	call   *0x14(%eax)
  80168a:	89 c2                	mov    %eax,%edx
  80168c:	83 c4 10             	add    $0x10,%esp
  80168f:	eb 09                	jmp    80169a <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801691:	89 c2                	mov    %eax,%edx
  801693:	eb 05                	jmp    80169a <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801695:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80169a:	89 d0                	mov    %edx,%eax
  80169c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80169f:	c9                   	leave  
  8016a0:	c3                   	ret    

008016a1 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8016a1:	55                   	push   %ebp
  8016a2:	89 e5                	mov    %esp,%ebp
  8016a4:	56                   	push   %esi
  8016a5:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8016a6:	83 ec 08             	sub    $0x8,%esp
  8016a9:	6a 00                	push   $0x0
  8016ab:	ff 75 08             	pushl  0x8(%ebp)
  8016ae:	e8 d6 01 00 00       	call   801889 <open>
  8016b3:	89 c3                	mov    %eax,%ebx
  8016b5:	83 c4 10             	add    $0x10,%esp
  8016b8:	85 c0                	test   %eax,%eax
  8016ba:	78 1b                	js     8016d7 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8016bc:	83 ec 08             	sub    $0x8,%esp
  8016bf:	ff 75 0c             	pushl  0xc(%ebp)
  8016c2:	50                   	push   %eax
  8016c3:	e8 5b ff ff ff       	call   801623 <fstat>
  8016c8:	89 c6                	mov    %eax,%esi
	close(fd);
  8016ca:	89 1c 24             	mov    %ebx,(%esp)
  8016cd:	e8 fd fb ff ff       	call   8012cf <close>
	return r;
  8016d2:	83 c4 10             	add    $0x10,%esp
  8016d5:	89 f0                	mov    %esi,%eax
}
  8016d7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016da:	5b                   	pop    %ebx
  8016db:	5e                   	pop    %esi
  8016dc:	5d                   	pop    %ebp
  8016dd:	c3                   	ret    

008016de <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8016de:	55                   	push   %ebp
  8016df:	89 e5                	mov    %esp,%ebp
  8016e1:	56                   	push   %esi
  8016e2:	53                   	push   %ebx
  8016e3:	89 c6                	mov    %eax,%esi
  8016e5:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8016e7:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8016ee:	75 12                	jne    801702 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8016f0:	83 ec 0c             	sub    $0xc,%esp
  8016f3:	6a 01                	push   $0x1
  8016f5:	e8 fc f9 ff ff       	call   8010f6 <ipc_find_env>
  8016fa:	a3 00 40 80 00       	mov    %eax,0x804000
  8016ff:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801702:	6a 07                	push   $0x7
  801704:	68 00 50 80 00       	push   $0x805000
  801709:	56                   	push   %esi
  80170a:	ff 35 00 40 80 00    	pushl  0x804000
  801710:	e8 8d f9 ff ff       	call   8010a2 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801715:	83 c4 0c             	add    $0xc,%esp
  801718:	6a 00                	push   $0x0
  80171a:	53                   	push   %ebx
  80171b:	6a 00                	push   $0x0
  80171d:	e8 19 f9 ff ff       	call   80103b <ipc_recv>
}
  801722:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801725:	5b                   	pop    %ebx
  801726:	5e                   	pop    %esi
  801727:	5d                   	pop    %ebp
  801728:	c3                   	ret    

00801729 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801729:	55                   	push   %ebp
  80172a:	89 e5                	mov    %esp,%ebp
  80172c:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80172f:	8b 45 08             	mov    0x8(%ebp),%eax
  801732:	8b 40 0c             	mov    0xc(%eax),%eax
  801735:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80173a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80173d:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801742:	ba 00 00 00 00       	mov    $0x0,%edx
  801747:	b8 02 00 00 00       	mov    $0x2,%eax
  80174c:	e8 8d ff ff ff       	call   8016de <fsipc>
}
  801751:	c9                   	leave  
  801752:	c3                   	ret    

00801753 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801753:	55                   	push   %ebp
  801754:	89 e5                	mov    %esp,%ebp
  801756:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801759:	8b 45 08             	mov    0x8(%ebp),%eax
  80175c:	8b 40 0c             	mov    0xc(%eax),%eax
  80175f:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801764:	ba 00 00 00 00       	mov    $0x0,%edx
  801769:	b8 06 00 00 00       	mov    $0x6,%eax
  80176e:	e8 6b ff ff ff       	call   8016de <fsipc>
}
  801773:	c9                   	leave  
  801774:	c3                   	ret    

00801775 <devfile_stat>:

}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801775:	55                   	push   %ebp
  801776:	89 e5                	mov    %esp,%ebp
  801778:	53                   	push   %ebx
  801779:	83 ec 04             	sub    $0x4,%esp
  80177c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80177f:	8b 45 08             	mov    0x8(%ebp),%eax
  801782:	8b 40 0c             	mov    0xc(%eax),%eax
  801785:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80178a:	ba 00 00 00 00       	mov    $0x0,%edx
  80178f:	b8 05 00 00 00       	mov    $0x5,%eax
  801794:	e8 45 ff ff ff       	call   8016de <fsipc>
  801799:	85 c0                	test   %eax,%eax
  80179b:	78 2c                	js     8017c9 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80179d:	83 ec 08             	sub    $0x8,%esp
  8017a0:	68 00 50 80 00       	push   $0x805000
  8017a5:	53                   	push   %ebx
  8017a6:	e8 cb ef ff ff       	call   800776 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8017ab:	a1 80 50 80 00       	mov    0x805080,%eax
  8017b0:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8017b6:	a1 84 50 80 00       	mov    0x805084,%eax
  8017bb:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8017c1:	83 c4 10             	add    $0x10,%esp
  8017c4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017c9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017cc:	c9                   	leave  
  8017cd:	c3                   	ret    

008017ce <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8017ce:	55                   	push   %ebp
  8017cf:	89 e5                	mov    %esp,%ebp
  8017d1:	83 ec 0c             	sub    $0xc,%esp
  8017d4:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	// panic("devfile_write not implemented");

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8017d7:	8b 55 08             	mov    0x8(%ebp),%edx
  8017da:	8b 52 0c             	mov    0xc(%edx),%edx
  8017dd:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  8017e3:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  8017e8:	50                   	push   %eax
  8017e9:	ff 75 0c             	pushl  0xc(%ebp)
  8017ec:	68 08 50 80 00       	push   $0x805008
  8017f1:	e8 12 f1 ff ff       	call   800908 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  8017f6:	ba 00 00 00 00       	mov    $0x0,%edx
  8017fb:	b8 04 00 00 00       	mov    $0x4,%eax
  801800:	e8 d9 fe ff ff       	call   8016de <fsipc>

}
  801805:	c9                   	leave  
  801806:	c3                   	ret    

00801807 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801807:	55                   	push   %ebp
  801808:	89 e5                	mov    %esp,%ebp
  80180a:	56                   	push   %esi
  80180b:	53                   	push   %ebx
  80180c:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80180f:	8b 45 08             	mov    0x8(%ebp),%eax
  801812:	8b 40 0c             	mov    0xc(%eax),%eax
  801815:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80181a:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801820:	ba 00 00 00 00       	mov    $0x0,%edx
  801825:	b8 03 00 00 00       	mov    $0x3,%eax
  80182a:	e8 af fe ff ff       	call   8016de <fsipc>
  80182f:	89 c3                	mov    %eax,%ebx
  801831:	85 c0                	test   %eax,%eax
  801833:	78 4b                	js     801880 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801835:	39 c6                	cmp    %eax,%esi
  801837:	73 16                	jae    80184f <devfile_read+0x48>
  801839:	68 a4 26 80 00       	push   $0x8026a4
  80183e:	68 ab 26 80 00       	push   $0x8026ab
  801843:	6a 7c                	push   $0x7c
  801845:	68 c0 26 80 00       	push   $0x8026c0
  80184a:	e8 bd 05 00 00       	call   801e0c <_panic>
	assert(r <= PGSIZE);
  80184f:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801854:	7e 16                	jle    80186c <devfile_read+0x65>
  801856:	68 cb 26 80 00       	push   $0x8026cb
  80185b:	68 ab 26 80 00       	push   $0x8026ab
  801860:	6a 7d                	push   $0x7d
  801862:	68 c0 26 80 00       	push   $0x8026c0
  801867:	e8 a0 05 00 00       	call   801e0c <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80186c:	83 ec 04             	sub    $0x4,%esp
  80186f:	50                   	push   %eax
  801870:	68 00 50 80 00       	push   $0x805000
  801875:	ff 75 0c             	pushl  0xc(%ebp)
  801878:	e8 8b f0 ff ff       	call   800908 <memmove>
	return r;
  80187d:	83 c4 10             	add    $0x10,%esp
}
  801880:	89 d8                	mov    %ebx,%eax
  801882:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801885:	5b                   	pop    %ebx
  801886:	5e                   	pop    %esi
  801887:	5d                   	pop    %ebp
  801888:	c3                   	ret    

00801889 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801889:	55                   	push   %ebp
  80188a:	89 e5                	mov    %esp,%ebp
  80188c:	53                   	push   %ebx
  80188d:	83 ec 20             	sub    $0x20,%esp
  801890:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801893:	53                   	push   %ebx
  801894:	e8 a4 ee ff ff       	call   80073d <strlen>
  801899:	83 c4 10             	add    $0x10,%esp
  80189c:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8018a1:	7f 67                	jg     80190a <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8018a3:	83 ec 0c             	sub    $0xc,%esp
  8018a6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018a9:	50                   	push   %eax
  8018aa:	e8 a7 f8 ff ff       	call   801156 <fd_alloc>
  8018af:	83 c4 10             	add    $0x10,%esp
		return r;
  8018b2:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8018b4:	85 c0                	test   %eax,%eax
  8018b6:	78 57                	js     80190f <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8018b8:	83 ec 08             	sub    $0x8,%esp
  8018bb:	53                   	push   %ebx
  8018bc:	68 00 50 80 00       	push   $0x805000
  8018c1:	e8 b0 ee ff ff       	call   800776 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8018c6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018c9:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8018ce:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8018d1:	b8 01 00 00 00       	mov    $0x1,%eax
  8018d6:	e8 03 fe ff ff       	call   8016de <fsipc>
  8018db:	89 c3                	mov    %eax,%ebx
  8018dd:	83 c4 10             	add    $0x10,%esp
  8018e0:	85 c0                	test   %eax,%eax
  8018e2:	79 14                	jns    8018f8 <open+0x6f>
		fd_close(fd, 0);
  8018e4:	83 ec 08             	sub    $0x8,%esp
  8018e7:	6a 00                	push   $0x0
  8018e9:	ff 75 f4             	pushl  -0xc(%ebp)
  8018ec:	e8 5d f9 ff ff       	call   80124e <fd_close>
		return r;
  8018f1:	83 c4 10             	add    $0x10,%esp
  8018f4:	89 da                	mov    %ebx,%edx
  8018f6:	eb 17                	jmp    80190f <open+0x86>
	}

	return fd2num(fd);
  8018f8:	83 ec 0c             	sub    $0xc,%esp
  8018fb:	ff 75 f4             	pushl  -0xc(%ebp)
  8018fe:	e8 2c f8 ff ff       	call   80112f <fd2num>
  801903:	89 c2                	mov    %eax,%edx
  801905:	83 c4 10             	add    $0x10,%esp
  801908:	eb 05                	jmp    80190f <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  80190a:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  80190f:	89 d0                	mov    %edx,%eax
  801911:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801914:	c9                   	leave  
  801915:	c3                   	ret    

00801916 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801916:	55                   	push   %ebp
  801917:	89 e5                	mov    %esp,%ebp
  801919:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80191c:	ba 00 00 00 00       	mov    $0x0,%edx
  801921:	b8 08 00 00 00       	mov    $0x8,%eax
  801926:	e8 b3 fd ff ff       	call   8016de <fsipc>
}
  80192b:	c9                   	leave  
  80192c:	c3                   	ret    

0080192d <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  80192d:	55                   	push   %ebp
  80192e:	89 e5                	mov    %esp,%ebp
  801930:	56                   	push   %esi
  801931:	53                   	push   %ebx
  801932:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801935:	83 ec 0c             	sub    $0xc,%esp
  801938:	ff 75 08             	pushl  0x8(%ebp)
  80193b:	e8 ff f7 ff ff       	call   80113f <fd2data>
  801940:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801942:	83 c4 08             	add    $0x8,%esp
  801945:	68 d7 26 80 00       	push   $0x8026d7
  80194a:	53                   	push   %ebx
  80194b:	e8 26 ee ff ff       	call   800776 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801950:	8b 46 04             	mov    0x4(%esi),%eax
  801953:	2b 06                	sub    (%esi),%eax
  801955:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80195b:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801962:	00 00 00 
	stat->st_dev = &devpipe;
  801965:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  80196c:	30 80 00 
	return 0;
}
  80196f:	b8 00 00 00 00       	mov    $0x0,%eax
  801974:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801977:	5b                   	pop    %ebx
  801978:	5e                   	pop    %esi
  801979:	5d                   	pop    %ebp
  80197a:	c3                   	ret    

0080197b <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80197b:	55                   	push   %ebp
  80197c:	89 e5                	mov    %esp,%ebp
  80197e:	53                   	push   %ebx
  80197f:	83 ec 0c             	sub    $0xc,%esp
  801982:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801985:	53                   	push   %ebx
  801986:	6a 00                	push   $0x0
  801988:	e8 71 f2 ff ff       	call   800bfe <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  80198d:	89 1c 24             	mov    %ebx,(%esp)
  801990:	e8 aa f7 ff ff       	call   80113f <fd2data>
  801995:	83 c4 08             	add    $0x8,%esp
  801998:	50                   	push   %eax
  801999:	6a 00                	push   $0x0
  80199b:	e8 5e f2 ff ff       	call   800bfe <sys_page_unmap>
}
  8019a0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019a3:	c9                   	leave  
  8019a4:	c3                   	ret    

008019a5 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8019a5:	55                   	push   %ebp
  8019a6:	89 e5                	mov    %esp,%ebp
  8019a8:	57                   	push   %edi
  8019a9:	56                   	push   %esi
  8019aa:	53                   	push   %ebx
  8019ab:	83 ec 1c             	sub    $0x1c,%esp
  8019ae:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8019b1:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8019b3:	a1 08 40 80 00       	mov    0x804008,%eax
  8019b8:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  8019bb:	83 ec 0c             	sub    $0xc,%esp
  8019be:	ff 75 e0             	pushl  -0x20(%ebp)
  8019c1:	e8 f7 04 00 00       	call   801ebd <pageref>
  8019c6:	89 c3                	mov    %eax,%ebx
  8019c8:	89 3c 24             	mov    %edi,(%esp)
  8019cb:	e8 ed 04 00 00       	call   801ebd <pageref>
  8019d0:	83 c4 10             	add    $0x10,%esp
  8019d3:	39 c3                	cmp    %eax,%ebx
  8019d5:	0f 94 c1             	sete   %cl
  8019d8:	0f b6 c9             	movzbl %cl,%ecx
  8019db:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  8019de:	8b 15 08 40 80 00    	mov    0x804008,%edx
  8019e4:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8019e7:	39 ce                	cmp    %ecx,%esi
  8019e9:	74 1b                	je     801a06 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  8019eb:	39 c3                	cmp    %eax,%ebx
  8019ed:	75 c4                	jne    8019b3 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8019ef:	8b 42 58             	mov    0x58(%edx),%eax
  8019f2:	ff 75 e4             	pushl  -0x1c(%ebp)
  8019f5:	50                   	push   %eax
  8019f6:	56                   	push   %esi
  8019f7:	68 de 26 80 00       	push   $0x8026de
  8019fc:	e8 f0 e7 ff ff       	call   8001f1 <cprintf>
  801a01:	83 c4 10             	add    $0x10,%esp
  801a04:	eb ad                	jmp    8019b3 <_pipeisclosed+0xe>
	}
}
  801a06:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801a09:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a0c:	5b                   	pop    %ebx
  801a0d:	5e                   	pop    %esi
  801a0e:	5f                   	pop    %edi
  801a0f:	5d                   	pop    %ebp
  801a10:	c3                   	ret    

00801a11 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801a11:	55                   	push   %ebp
  801a12:	89 e5                	mov    %esp,%ebp
  801a14:	57                   	push   %edi
  801a15:	56                   	push   %esi
  801a16:	53                   	push   %ebx
  801a17:	83 ec 28             	sub    $0x28,%esp
  801a1a:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801a1d:	56                   	push   %esi
  801a1e:	e8 1c f7 ff ff       	call   80113f <fd2data>
  801a23:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a25:	83 c4 10             	add    $0x10,%esp
  801a28:	bf 00 00 00 00       	mov    $0x0,%edi
  801a2d:	eb 4b                	jmp    801a7a <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801a2f:	89 da                	mov    %ebx,%edx
  801a31:	89 f0                	mov    %esi,%eax
  801a33:	e8 6d ff ff ff       	call   8019a5 <_pipeisclosed>
  801a38:	85 c0                	test   %eax,%eax
  801a3a:	75 48                	jne    801a84 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801a3c:	e8 19 f1 ff ff       	call   800b5a <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801a41:	8b 43 04             	mov    0x4(%ebx),%eax
  801a44:	8b 0b                	mov    (%ebx),%ecx
  801a46:	8d 51 20             	lea    0x20(%ecx),%edx
  801a49:	39 d0                	cmp    %edx,%eax
  801a4b:	73 e2                	jae    801a2f <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801a4d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a50:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801a54:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801a57:	89 c2                	mov    %eax,%edx
  801a59:	c1 fa 1f             	sar    $0x1f,%edx
  801a5c:	89 d1                	mov    %edx,%ecx
  801a5e:	c1 e9 1b             	shr    $0x1b,%ecx
  801a61:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801a64:	83 e2 1f             	and    $0x1f,%edx
  801a67:	29 ca                	sub    %ecx,%edx
  801a69:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801a6d:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801a71:	83 c0 01             	add    $0x1,%eax
  801a74:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a77:	83 c7 01             	add    $0x1,%edi
  801a7a:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801a7d:	75 c2                	jne    801a41 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801a7f:	8b 45 10             	mov    0x10(%ebp),%eax
  801a82:	eb 05                	jmp    801a89 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801a84:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801a89:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a8c:	5b                   	pop    %ebx
  801a8d:	5e                   	pop    %esi
  801a8e:	5f                   	pop    %edi
  801a8f:	5d                   	pop    %ebp
  801a90:	c3                   	ret    

00801a91 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801a91:	55                   	push   %ebp
  801a92:	89 e5                	mov    %esp,%ebp
  801a94:	57                   	push   %edi
  801a95:	56                   	push   %esi
  801a96:	53                   	push   %ebx
  801a97:	83 ec 18             	sub    $0x18,%esp
  801a9a:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801a9d:	57                   	push   %edi
  801a9e:	e8 9c f6 ff ff       	call   80113f <fd2data>
  801aa3:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801aa5:	83 c4 10             	add    $0x10,%esp
  801aa8:	bb 00 00 00 00       	mov    $0x0,%ebx
  801aad:	eb 3d                	jmp    801aec <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801aaf:	85 db                	test   %ebx,%ebx
  801ab1:	74 04                	je     801ab7 <devpipe_read+0x26>
				return i;
  801ab3:	89 d8                	mov    %ebx,%eax
  801ab5:	eb 44                	jmp    801afb <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801ab7:	89 f2                	mov    %esi,%edx
  801ab9:	89 f8                	mov    %edi,%eax
  801abb:	e8 e5 fe ff ff       	call   8019a5 <_pipeisclosed>
  801ac0:	85 c0                	test   %eax,%eax
  801ac2:	75 32                	jne    801af6 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801ac4:	e8 91 f0 ff ff       	call   800b5a <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801ac9:	8b 06                	mov    (%esi),%eax
  801acb:	3b 46 04             	cmp    0x4(%esi),%eax
  801ace:	74 df                	je     801aaf <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801ad0:	99                   	cltd   
  801ad1:	c1 ea 1b             	shr    $0x1b,%edx
  801ad4:	01 d0                	add    %edx,%eax
  801ad6:	83 e0 1f             	and    $0x1f,%eax
  801ad9:	29 d0                	sub    %edx,%eax
  801adb:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801ae0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801ae3:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801ae6:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ae9:	83 c3 01             	add    $0x1,%ebx
  801aec:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801aef:	75 d8                	jne    801ac9 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801af1:	8b 45 10             	mov    0x10(%ebp),%eax
  801af4:	eb 05                	jmp    801afb <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801af6:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801afb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801afe:	5b                   	pop    %ebx
  801aff:	5e                   	pop    %esi
  801b00:	5f                   	pop    %edi
  801b01:	5d                   	pop    %ebp
  801b02:	c3                   	ret    

00801b03 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801b03:	55                   	push   %ebp
  801b04:	89 e5                	mov    %esp,%ebp
  801b06:	56                   	push   %esi
  801b07:	53                   	push   %ebx
  801b08:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801b0b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b0e:	50                   	push   %eax
  801b0f:	e8 42 f6 ff ff       	call   801156 <fd_alloc>
  801b14:	83 c4 10             	add    $0x10,%esp
  801b17:	89 c2                	mov    %eax,%edx
  801b19:	85 c0                	test   %eax,%eax
  801b1b:	0f 88 2c 01 00 00    	js     801c4d <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b21:	83 ec 04             	sub    $0x4,%esp
  801b24:	68 07 04 00 00       	push   $0x407
  801b29:	ff 75 f4             	pushl  -0xc(%ebp)
  801b2c:	6a 00                	push   $0x0
  801b2e:	e8 46 f0 ff ff       	call   800b79 <sys_page_alloc>
  801b33:	83 c4 10             	add    $0x10,%esp
  801b36:	89 c2                	mov    %eax,%edx
  801b38:	85 c0                	test   %eax,%eax
  801b3a:	0f 88 0d 01 00 00    	js     801c4d <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801b40:	83 ec 0c             	sub    $0xc,%esp
  801b43:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801b46:	50                   	push   %eax
  801b47:	e8 0a f6 ff ff       	call   801156 <fd_alloc>
  801b4c:	89 c3                	mov    %eax,%ebx
  801b4e:	83 c4 10             	add    $0x10,%esp
  801b51:	85 c0                	test   %eax,%eax
  801b53:	0f 88 e2 00 00 00    	js     801c3b <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b59:	83 ec 04             	sub    $0x4,%esp
  801b5c:	68 07 04 00 00       	push   $0x407
  801b61:	ff 75 f0             	pushl  -0x10(%ebp)
  801b64:	6a 00                	push   $0x0
  801b66:	e8 0e f0 ff ff       	call   800b79 <sys_page_alloc>
  801b6b:	89 c3                	mov    %eax,%ebx
  801b6d:	83 c4 10             	add    $0x10,%esp
  801b70:	85 c0                	test   %eax,%eax
  801b72:	0f 88 c3 00 00 00    	js     801c3b <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801b78:	83 ec 0c             	sub    $0xc,%esp
  801b7b:	ff 75 f4             	pushl  -0xc(%ebp)
  801b7e:	e8 bc f5 ff ff       	call   80113f <fd2data>
  801b83:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b85:	83 c4 0c             	add    $0xc,%esp
  801b88:	68 07 04 00 00       	push   $0x407
  801b8d:	50                   	push   %eax
  801b8e:	6a 00                	push   $0x0
  801b90:	e8 e4 ef ff ff       	call   800b79 <sys_page_alloc>
  801b95:	89 c3                	mov    %eax,%ebx
  801b97:	83 c4 10             	add    $0x10,%esp
  801b9a:	85 c0                	test   %eax,%eax
  801b9c:	0f 88 89 00 00 00    	js     801c2b <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ba2:	83 ec 0c             	sub    $0xc,%esp
  801ba5:	ff 75 f0             	pushl  -0x10(%ebp)
  801ba8:	e8 92 f5 ff ff       	call   80113f <fd2data>
  801bad:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801bb4:	50                   	push   %eax
  801bb5:	6a 00                	push   $0x0
  801bb7:	56                   	push   %esi
  801bb8:	6a 00                	push   $0x0
  801bba:	e8 fd ef ff ff       	call   800bbc <sys_page_map>
  801bbf:	89 c3                	mov    %eax,%ebx
  801bc1:	83 c4 20             	add    $0x20,%esp
  801bc4:	85 c0                	test   %eax,%eax
  801bc6:	78 55                	js     801c1d <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801bc8:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801bce:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bd1:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801bd3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bd6:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801bdd:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801be3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801be6:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801be8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801beb:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801bf2:	83 ec 0c             	sub    $0xc,%esp
  801bf5:	ff 75 f4             	pushl  -0xc(%ebp)
  801bf8:	e8 32 f5 ff ff       	call   80112f <fd2num>
  801bfd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c00:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801c02:	83 c4 04             	add    $0x4,%esp
  801c05:	ff 75 f0             	pushl  -0x10(%ebp)
  801c08:	e8 22 f5 ff ff       	call   80112f <fd2num>
  801c0d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c10:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801c13:	83 c4 10             	add    $0x10,%esp
  801c16:	ba 00 00 00 00       	mov    $0x0,%edx
  801c1b:	eb 30                	jmp    801c4d <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801c1d:	83 ec 08             	sub    $0x8,%esp
  801c20:	56                   	push   %esi
  801c21:	6a 00                	push   $0x0
  801c23:	e8 d6 ef ff ff       	call   800bfe <sys_page_unmap>
  801c28:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801c2b:	83 ec 08             	sub    $0x8,%esp
  801c2e:	ff 75 f0             	pushl  -0x10(%ebp)
  801c31:	6a 00                	push   $0x0
  801c33:	e8 c6 ef ff ff       	call   800bfe <sys_page_unmap>
  801c38:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801c3b:	83 ec 08             	sub    $0x8,%esp
  801c3e:	ff 75 f4             	pushl  -0xc(%ebp)
  801c41:	6a 00                	push   $0x0
  801c43:	e8 b6 ef ff ff       	call   800bfe <sys_page_unmap>
  801c48:	83 c4 10             	add    $0x10,%esp
  801c4b:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801c4d:	89 d0                	mov    %edx,%eax
  801c4f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c52:	5b                   	pop    %ebx
  801c53:	5e                   	pop    %esi
  801c54:	5d                   	pop    %ebp
  801c55:	c3                   	ret    

00801c56 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801c56:	55                   	push   %ebp
  801c57:	89 e5                	mov    %esp,%ebp
  801c59:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801c5c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c5f:	50                   	push   %eax
  801c60:	ff 75 08             	pushl  0x8(%ebp)
  801c63:	e8 3d f5 ff ff       	call   8011a5 <fd_lookup>
  801c68:	83 c4 10             	add    $0x10,%esp
  801c6b:	85 c0                	test   %eax,%eax
  801c6d:	78 18                	js     801c87 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801c6f:	83 ec 0c             	sub    $0xc,%esp
  801c72:	ff 75 f4             	pushl  -0xc(%ebp)
  801c75:	e8 c5 f4 ff ff       	call   80113f <fd2data>
	return _pipeisclosed(fd, p);
  801c7a:	89 c2                	mov    %eax,%edx
  801c7c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c7f:	e8 21 fd ff ff       	call   8019a5 <_pipeisclosed>
  801c84:	83 c4 10             	add    $0x10,%esp
}
  801c87:	c9                   	leave  
  801c88:	c3                   	ret    

00801c89 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801c89:	55                   	push   %ebp
  801c8a:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801c8c:	b8 00 00 00 00       	mov    $0x0,%eax
  801c91:	5d                   	pop    %ebp
  801c92:	c3                   	ret    

00801c93 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801c93:	55                   	push   %ebp
  801c94:	89 e5                	mov    %esp,%ebp
  801c96:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801c99:	68 f6 26 80 00       	push   $0x8026f6
  801c9e:	ff 75 0c             	pushl  0xc(%ebp)
  801ca1:	e8 d0 ea ff ff       	call   800776 <strcpy>
	return 0;
}
  801ca6:	b8 00 00 00 00       	mov    $0x0,%eax
  801cab:	c9                   	leave  
  801cac:	c3                   	ret    

00801cad <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801cad:	55                   	push   %ebp
  801cae:	89 e5                	mov    %esp,%ebp
  801cb0:	57                   	push   %edi
  801cb1:	56                   	push   %esi
  801cb2:	53                   	push   %ebx
  801cb3:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801cb9:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801cbe:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801cc4:	eb 2d                	jmp    801cf3 <devcons_write+0x46>
		m = n - tot;
  801cc6:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801cc9:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801ccb:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801cce:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801cd3:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801cd6:	83 ec 04             	sub    $0x4,%esp
  801cd9:	53                   	push   %ebx
  801cda:	03 45 0c             	add    0xc(%ebp),%eax
  801cdd:	50                   	push   %eax
  801cde:	57                   	push   %edi
  801cdf:	e8 24 ec ff ff       	call   800908 <memmove>
		sys_cputs(buf, m);
  801ce4:	83 c4 08             	add    $0x8,%esp
  801ce7:	53                   	push   %ebx
  801ce8:	57                   	push   %edi
  801ce9:	e8 cf ed ff ff       	call   800abd <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801cee:	01 de                	add    %ebx,%esi
  801cf0:	83 c4 10             	add    $0x10,%esp
  801cf3:	89 f0                	mov    %esi,%eax
  801cf5:	3b 75 10             	cmp    0x10(%ebp),%esi
  801cf8:	72 cc                	jb     801cc6 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801cfa:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801cfd:	5b                   	pop    %ebx
  801cfe:	5e                   	pop    %esi
  801cff:	5f                   	pop    %edi
  801d00:	5d                   	pop    %ebp
  801d01:	c3                   	ret    

00801d02 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801d02:	55                   	push   %ebp
  801d03:	89 e5                	mov    %esp,%ebp
  801d05:	83 ec 08             	sub    $0x8,%esp
  801d08:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801d0d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801d11:	74 2a                	je     801d3d <devcons_read+0x3b>
  801d13:	eb 05                	jmp    801d1a <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801d15:	e8 40 ee ff ff       	call   800b5a <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801d1a:	e8 bc ed ff ff       	call   800adb <sys_cgetc>
  801d1f:	85 c0                	test   %eax,%eax
  801d21:	74 f2                	je     801d15 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801d23:	85 c0                	test   %eax,%eax
  801d25:	78 16                	js     801d3d <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801d27:	83 f8 04             	cmp    $0x4,%eax
  801d2a:	74 0c                	je     801d38 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801d2c:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d2f:	88 02                	mov    %al,(%edx)
	return 1;
  801d31:	b8 01 00 00 00       	mov    $0x1,%eax
  801d36:	eb 05                	jmp    801d3d <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801d38:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801d3d:	c9                   	leave  
  801d3e:	c3                   	ret    

00801d3f <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801d3f:	55                   	push   %ebp
  801d40:	89 e5                	mov    %esp,%ebp
  801d42:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801d45:	8b 45 08             	mov    0x8(%ebp),%eax
  801d48:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801d4b:	6a 01                	push   $0x1
  801d4d:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801d50:	50                   	push   %eax
  801d51:	e8 67 ed ff ff       	call   800abd <sys_cputs>
}
  801d56:	83 c4 10             	add    $0x10,%esp
  801d59:	c9                   	leave  
  801d5a:	c3                   	ret    

00801d5b <getchar>:

int
getchar(void)
{
  801d5b:	55                   	push   %ebp
  801d5c:	89 e5                	mov    %esp,%ebp
  801d5e:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801d61:	6a 01                	push   $0x1
  801d63:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801d66:	50                   	push   %eax
  801d67:	6a 00                	push   $0x0
  801d69:	e8 9d f6 ff ff       	call   80140b <read>
	if (r < 0)
  801d6e:	83 c4 10             	add    $0x10,%esp
  801d71:	85 c0                	test   %eax,%eax
  801d73:	78 0f                	js     801d84 <getchar+0x29>
		return r;
	if (r < 1)
  801d75:	85 c0                	test   %eax,%eax
  801d77:	7e 06                	jle    801d7f <getchar+0x24>
		return -E_EOF;
	return c;
  801d79:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801d7d:	eb 05                	jmp    801d84 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801d7f:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801d84:	c9                   	leave  
  801d85:	c3                   	ret    

00801d86 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801d86:	55                   	push   %ebp
  801d87:	89 e5                	mov    %esp,%ebp
  801d89:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801d8c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d8f:	50                   	push   %eax
  801d90:	ff 75 08             	pushl  0x8(%ebp)
  801d93:	e8 0d f4 ff ff       	call   8011a5 <fd_lookup>
  801d98:	83 c4 10             	add    $0x10,%esp
  801d9b:	85 c0                	test   %eax,%eax
  801d9d:	78 11                	js     801db0 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801d9f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801da2:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801da8:	39 10                	cmp    %edx,(%eax)
  801daa:	0f 94 c0             	sete   %al
  801dad:	0f b6 c0             	movzbl %al,%eax
}
  801db0:	c9                   	leave  
  801db1:	c3                   	ret    

00801db2 <opencons>:

int
opencons(void)
{
  801db2:	55                   	push   %ebp
  801db3:	89 e5                	mov    %esp,%ebp
  801db5:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801db8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801dbb:	50                   	push   %eax
  801dbc:	e8 95 f3 ff ff       	call   801156 <fd_alloc>
  801dc1:	83 c4 10             	add    $0x10,%esp
		return r;
  801dc4:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801dc6:	85 c0                	test   %eax,%eax
  801dc8:	78 3e                	js     801e08 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801dca:	83 ec 04             	sub    $0x4,%esp
  801dcd:	68 07 04 00 00       	push   $0x407
  801dd2:	ff 75 f4             	pushl  -0xc(%ebp)
  801dd5:	6a 00                	push   $0x0
  801dd7:	e8 9d ed ff ff       	call   800b79 <sys_page_alloc>
  801ddc:	83 c4 10             	add    $0x10,%esp
		return r;
  801ddf:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801de1:	85 c0                	test   %eax,%eax
  801de3:	78 23                	js     801e08 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801de5:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801deb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801dee:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801df0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801df3:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801dfa:	83 ec 0c             	sub    $0xc,%esp
  801dfd:	50                   	push   %eax
  801dfe:	e8 2c f3 ff ff       	call   80112f <fd2num>
  801e03:	89 c2                	mov    %eax,%edx
  801e05:	83 c4 10             	add    $0x10,%esp
}
  801e08:	89 d0                	mov    %edx,%eax
  801e0a:	c9                   	leave  
  801e0b:	c3                   	ret    

00801e0c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801e0c:	55                   	push   %ebp
  801e0d:	89 e5                	mov    %esp,%ebp
  801e0f:	56                   	push   %esi
  801e10:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801e11:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801e14:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801e1a:	e8 1c ed ff ff       	call   800b3b <sys_getenvid>
  801e1f:	83 ec 0c             	sub    $0xc,%esp
  801e22:	ff 75 0c             	pushl  0xc(%ebp)
  801e25:	ff 75 08             	pushl  0x8(%ebp)
  801e28:	56                   	push   %esi
  801e29:	50                   	push   %eax
  801e2a:	68 04 27 80 00       	push   $0x802704
  801e2f:	e8 bd e3 ff ff       	call   8001f1 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801e34:	83 c4 18             	add    $0x18,%esp
  801e37:	53                   	push   %ebx
  801e38:	ff 75 10             	pushl  0x10(%ebp)
  801e3b:	e8 60 e3 ff ff       	call   8001a0 <vcprintf>
	cprintf("\n");
  801e40:	c7 04 24 e9 25 80 00 	movl   $0x8025e9,(%esp)
  801e47:	e8 a5 e3 ff ff       	call   8001f1 <cprintf>
  801e4c:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801e4f:	cc                   	int3   
  801e50:	eb fd                	jmp    801e4f <_panic+0x43>

00801e52 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801e52:	55                   	push   %ebp
  801e53:	89 e5                	mov    %esp,%ebp
  801e55:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801e58:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801e5f:	75 2e                	jne    801e8f <set_pgfault_handler+0x3d>
		// First time through!
		// LAB 4: Your code here.
		// panic("set_pgfault_handler not implemented");

		sys_page_alloc(sys_getenvid(), (void *) (UXSTACKTOP - PGSIZE), PTE_SYSCALL);
  801e61:	e8 d5 ec ff ff       	call   800b3b <sys_getenvid>
  801e66:	83 ec 04             	sub    $0x4,%esp
  801e69:	68 07 0e 00 00       	push   $0xe07
  801e6e:	68 00 f0 bf ee       	push   $0xeebff000
  801e73:	50                   	push   %eax
  801e74:	e8 00 ed ff ff       	call   800b79 <sys_page_alloc>
		sys_env_set_pgfault_upcall(sys_getenvid(), _pgfault_upcall);
  801e79:	e8 bd ec ff ff       	call   800b3b <sys_getenvid>
  801e7e:	83 c4 08             	add    $0x8,%esp
  801e81:	68 99 1e 80 00       	push   $0x801e99
  801e86:	50                   	push   %eax
  801e87:	e8 38 ee ff ff       	call   800cc4 <sys_env_set_pgfault_upcall>
  801e8c:	83 c4 10             	add    $0x10,%esp
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801e8f:	8b 45 08             	mov    0x8(%ebp),%eax
  801e92:	a3 00 60 80 00       	mov    %eax,0x806000
}
  801e97:	c9                   	leave  
  801e98:	c3                   	ret    

00801e99 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801e99:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801e9a:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801e9f:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801ea1:	83 c4 04             	add    $0x4,%esp
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.

	movl 48(%esp), %eax		// trap-time esp
  801ea4:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl 40(%esp), %ebx		// trap-time eip
  801ea8:	8b 5c 24 28          	mov    0x28(%esp),%ebx

	// load eip into esp-4
	// in order to return to trap-time eip later, in the meantime not changing trap-time esp
	movl %ebx, -4(%eax)	
  801eac:	89 58 fc             	mov    %ebx,-0x4(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.

	addl $8, %esp 			// esp now points to trap-time registers
  801eaf:	83 c4 08             	add    $0x8,%esp
	popal					// pop to all registers
  801eb2:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

	addl $4, %esp			// esp now points to trap-time eflags
  801eb3:	83 c4 04             	add    $0x4,%esp
	popfl					// pop to eflags
  801eb6:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.

	popl %esp				// pop to esp
  801eb7:	5c                   	pop    %esp
	// subl $4, %esp		// arithmetic operation will change eflags!!!
	lea -4(%esp), %esp		// subl $4, %esp
  801eb8:	8d 64 24 fc          	lea    -0x4(%esp),%esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.

	ret
  801ebc:	c3                   	ret    

00801ebd <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801ebd:	55                   	push   %ebp
  801ebe:	89 e5                	mov    %esp,%ebp
  801ec0:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801ec3:	89 d0                	mov    %edx,%eax
  801ec5:	c1 e8 16             	shr    $0x16,%eax
  801ec8:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801ecf:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801ed4:	f6 c1 01             	test   $0x1,%cl
  801ed7:	74 1d                	je     801ef6 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801ed9:	c1 ea 0c             	shr    $0xc,%edx
  801edc:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801ee3:	f6 c2 01             	test   $0x1,%dl
  801ee6:	74 0e                	je     801ef6 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801ee8:	c1 ea 0c             	shr    $0xc,%edx
  801eeb:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801ef2:	ef 
  801ef3:	0f b7 c0             	movzwl %ax,%eax
}
  801ef6:	5d                   	pop    %ebp
  801ef7:	c3                   	ret    
  801ef8:	66 90                	xchg   %ax,%ax
  801efa:	66 90                	xchg   %ax,%ax
  801efc:	66 90                	xchg   %ax,%ax
  801efe:	66 90                	xchg   %ax,%ax

00801f00 <__udivdi3>:
  801f00:	55                   	push   %ebp
  801f01:	57                   	push   %edi
  801f02:	56                   	push   %esi
  801f03:	53                   	push   %ebx
  801f04:	83 ec 1c             	sub    $0x1c,%esp
  801f07:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801f0b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801f0f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801f13:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801f17:	85 f6                	test   %esi,%esi
  801f19:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801f1d:	89 ca                	mov    %ecx,%edx
  801f1f:	89 f8                	mov    %edi,%eax
  801f21:	75 3d                	jne    801f60 <__udivdi3+0x60>
  801f23:	39 cf                	cmp    %ecx,%edi
  801f25:	0f 87 c5 00 00 00    	ja     801ff0 <__udivdi3+0xf0>
  801f2b:	85 ff                	test   %edi,%edi
  801f2d:	89 fd                	mov    %edi,%ebp
  801f2f:	75 0b                	jne    801f3c <__udivdi3+0x3c>
  801f31:	b8 01 00 00 00       	mov    $0x1,%eax
  801f36:	31 d2                	xor    %edx,%edx
  801f38:	f7 f7                	div    %edi
  801f3a:	89 c5                	mov    %eax,%ebp
  801f3c:	89 c8                	mov    %ecx,%eax
  801f3e:	31 d2                	xor    %edx,%edx
  801f40:	f7 f5                	div    %ebp
  801f42:	89 c1                	mov    %eax,%ecx
  801f44:	89 d8                	mov    %ebx,%eax
  801f46:	89 cf                	mov    %ecx,%edi
  801f48:	f7 f5                	div    %ebp
  801f4a:	89 c3                	mov    %eax,%ebx
  801f4c:	89 d8                	mov    %ebx,%eax
  801f4e:	89 fa                	mov    %edi,%edx
  801f50:	83 c4 1c             	add    $0x1c,%esp
  801f53:	5b                   	pop    %ebx
  801f54:	5e                   	pop    %esi
  801f55:	5f                   	pop    %edi
  801f56:	5d                   	pop    %ebp
  801f57:	c3                   	ret    
  801f58:	90                   	nop
  801f59:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801f60:	39 ce                	cmp    %ecx,%esi
  801f62:	77 74                	ja     801fd8 <__udivdi3+0xd8>
  801f64:	0f bd fe             	bsr    %esi,%edi
  801f67:	83 f7 1f             	xor    $0x1f,%edi
  801f6a:	0f 84 98 00 00 00    	je     802008 <__udivdi3+0x108>
  801f70:	bb 20 00 00 00       	mov    $0x20,%ebx
  801f75:	89 f9                	mov    %edi,%ecx
  801f77:	89 c5                	mov    %eax,%ebp
  801f79:	29 fb                	sub    %edi,%ebx
  801f7b:	d3 e6                	shl    %cl,%esi
  801f7d:	89 d9                	mov    %ebx,%ecx
  801f7f:	d3 ed                	shr    %cl,%ebp
  801f81:	89 f9                	mov    %edi,%ecx
  801f83:	d3 e0                	shl    %cl,%eax
  801f85:	09 ee                	or     %ebp,%esi
  801f87:	89 d9                	mov    %ebx,%ecx
  801f89:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801f8d:	89 d5                	mov    %edx,%ebp
  801f8f:	8b 44 24 08          	mov    0x8(%esp),%eax
  801f93:	d3 ed                	shr    %cl,%ebp
  801f95:	89 f9                	mov    %edi,%ecx
  801f97:	d3 e2                	shl    %cl,%edx
  801f99:	89 d9                	mov    %ebx,%ecx
  801f9b:	d3 e8                	shr    %cl,%eax
  801f9d:	09 c2                	or     %eax,%edx
  801f9f:	89 d0                	mov    %edx,%eax
  801fa1:	89 ea                	mov    %ebp,%edx
  801fa3:	f7 f6                	div    %esi
  801fa5:	89 d5                	mov    %edx,%ebp
  801fa7:	89 c3                	mov    %eax,%ebx
  801fa9:	f7 64 24 0c          	mull   0xc(%esp)
  801fad:	39 d5                	cmp    %edx,%ebp
  801faf:	72 10                	jb     801fc1 <__udivdi3+0xc1>
  801fb1:	8b 74 24 08          	mov    0x8(%esp),%esi
  801fb5:	89 f9                	mov    %edi,%ecx
  801fb7:	d3 e6                	shl    %cl,%esi
  801fb9:	39 c6                	cmp    %eax,%esi
  801fbb:	73 07                	jae    801fc4 <__udivdi3+0xc4>
  801fbd:	39 d5                	cmp    %edx,%ebp
  801fbf:	75 03                	jne    801fc4 <__udivdi3+0xc4>
  801fc1:	83 eb 01             	sub    $0x1,%ebx
  801fc4:	31 ff                	xor    %edi,%edi
  801fc6:	89 d8                	mov    %ebx,%eax
  801fc8:	89 fa                	mov    %edi,%edx
  801fca:	83 c4 1c             	add    $0x1c,%esp
  801fcd:	5b                   	pop    %ebx
  801fce:	5e                   	pop    %esi
  801fcf:	5f                   	pop    %edi
  801fd0:	5d                   	pop    %ebp
  801fd1:	c3                   	ret    
  801fd2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801fd8:	31 ff                	xor    %edi,%edi
  801fda:	31 db                	xor    %ebx,%ebx
  801fdc:	89 d8                	mov    %ebx,%eax
  801fde:	89 fa                	mov    %edi,%edx
  801fe0:	83 c4 1c             	add    $0x1c,%esp
  801fe3:	5b                   	pop    %ebx
  801fe4:	5e                   	pop    %esi
  801fe5:	5f                   	pop    %edi
  801fe6:	5d                   	pop    %ebp
  801fe7:	c3                   	ret    
  801fe8:	90                   	nop
  801fe9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801ff0:	89 d8                	mov    %ebx,%eax
  801ff2:	f7 f7                	div    %edi
  801ff4:	31 ff                	xor    %edi,%edi
  801ff6:	89 c3                	mov    %eax,%ebx
  801ff8:	89 d8                	mov    %ebx,%eax
  801ffa:	89 fa                	mov    %edi,%edx
  801ffc:	83 c4 1c             	add    $0x1c,%esp
  801fff:	5b                   	pop    %ebx
  802000:	5e                   	pop    %esi
  802001:	5f                   	pop    %edi
  802002:	5d                   	pop    %ebp
  802003:	c3                   	ret    
  802004:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802008:	39 ce                	cmp    %ecx,%esi
  80200a:	72 0c                	jb     802018 <__udivdi3+0x118>
  80200c:	31 db                	xor    %ebx,%ebx
  80200e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802012:	0f 87 34 ff ff ff    	ja     801f4c <__udivdi3+0x4c>
  802018:	bb 01 00 00 00       	mov    $0x1,%ebx
  80201d:	e9 2a ff ff ff       	jmp    801f4c <__udivdi3+0x4c>
  802022:	66 90                	xchg   %ax,%ax
  802024:	66 90                	xchg   %ax,%ax
  802026:	66 90                	xchg   %ax,%ax
  802028:	66 90                	xchg   %ax,%ax
  80202a:	66 90                	xchg   %ax,%ax
  80202c:	66 90                	xchg   %ax,%ax
  80202e:	66 90                	xchg   %ax,%ax

00802030 <__umoddi3>:
  802030:	55                   	push   %ebp
  802031:	57                   	push   %edi
  802032:	56                   	push   %esi
  802033:	53                   	push   %ebx
  802034:	83 ec 1c             	sub    $0x1c,%esp
  802037:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80203b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80203f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802043:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802047:	85 d2                	test   %edx,%edx
  802049:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80204d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802051:	89 f3                	mov    %esi,%ebx
  802053:	89 3c 24             	mov    %edi,(%esp)
  802056:	89 74 24 04          	mov    %esi,0x4(%esp)
  80205a:	75 1c                	jne    802078 <__umoddi3+0x48>
  80205c:	39 f7                	cmp    %esi,%edi
  80205e:	76 50                	jbe    8020b0 <__umoddi3+0x80>
  802060:	89 c8                	mov    %ecx,%eax
  802062:	89 f2                	mov    %esi,%edx
  802064:	f7 f7                	div    %edi
  802066:	89 d0                	mov    %edx,%eax
  802068:	31 d2                	xor    %edx,%edx
  80206a:	83 c4 1c             	add    $0x1c,%esp
  80206d:	5b                   	pop    %ebx
  80206e:	5e                   	pop    %esi
  80206f:	5f                   	pop    %edi
  802070:	5d                   	pop    %ebp
  802071:	c3                   	ret    
  802072:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802078:	39 f2                	cmp    %esi,%edx
  80207a:	89 d0                	mov    %edx,%eax
  80207c:	77 52                	ja     8020d0 <__umoddi3+0xa0>
  80207e:	0f bd ea             	bsr    %edx,%ebp
  802081:	83 f5 1f             	xor    $0x1f,%ebp
  802084:	75 5a                	jne    8020e0 <__umoddi3+0xb0>
  802086:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80208a:	0f 82 e0 00 00 00    	jb     802170 <__umoddi3+0x140>
  802090:	39 0c 24             	cmp    %ecx,(%esp)
  802093:	0f 86 d7 00 00 00    	jbe    802170 <__umoddi3+0x140>
  802099:	8b 44 24 08          	mov    0x8(%esp),%eax
  80209d:	8b 54 24 04          	mov    0x4(%esp),%edx
  8020a1:	83 c4 1c             	add    $0x1c,%esp
  8020a4:	5b                   	pop    %ebx
  8020a5:	5e                   	pop    %esi
  8020a6:	5f                   	pop    %edi
  8020a7:	5d                   	pop    %ebp
  8020a8:	c3                   	ret    
  8020a9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8020b0:	85 ff                	test   %edi,%edi
  8020b2:	89 fd                	mov    %edi,%ebp
  8020b4:	75 0b                	jne    8020c1 <__umoddi3+0x91>
  8020b6:	b8 01 00 00 00       	mov    $0x1,%eax
  8020bb:	31 d2                	xor    %edx,%edx
  8020bd:	f7 f7                	div    %edi
  8020bf:	89 c5                	mov    %eax,%ebp
  8020c1:	89 f0                	mov    %esi,%eax
  8020c3:	31 d2                	xor    %edx,%edx
  8020c5:	f7 f5                	div    %ebp
  8020c7:	89 c8                	mov    %ecx,%eax
  8020c9:	f7 f5                	div    %ebp
  8020cb:	89 d0                	mov    %edx,%eax
  8020cd:	eb 99                	jmp    802068 <__umoddi3+0x38>
  8020cf:	90                   	nop
  8020d0:	89 c8                	mov    %ecx,%eax
  8020d2:	89 f2                	mov    %esi,%edx
  8020d4:	83 c4 1c             	add    $0x1c,%esp
  8020d7:	5b                   	pop    %ebx
  8020d8:	5e                   	pop    %esi
  8020d9:	5f                   	pop    %edi
  8020da:	5d                   	pop    %ebp
  8020db:	c3                   	ret    
  8020dc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8020e0:	8b 34 24             	mov    (%esp),%esi
  8020e3:	bf 20 00 00 00       	mov    $0x20,%edi
  8020e8:	89 e9                	mov    %ebp,%ecx
  8020ea:	29 ef                	sub    %ebp,%edi
  8020ec:	d3 e0                	shl    %cl,%eax
  8020ee:	89 f9                	mov    %edi,%ecx
  8020f0:	89 f2                	mov    %esi,%edx
  8020f2:	d3 ea                	shr    %cl,%edx
  8020f4:	89 e9                	mov    %ebp,%ecx
  8020f6:	09 c2                	or     %eax,%edx
  8020f8:	89 d8                	mov    %ebx,%eax
  8020fa:	89 14 24             	mov    %edx,(%esp)
  8020fd:	89 f2                	mov    %esi,%edx
  8020ff:	d3 e2                	shl    %cl,%edx
  802101:	89 f9                	mov    %edi,%ecx
  802103:	89 54 24 04          	mov    %edx,0x4(%esp)
  802107:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80210b:	d3 e8                	shr    %cl,%eax
  80210d:	89 e9                	mov    %ebp,%ecx
  80210f:	89 c6                	mov    %eax,%esi
  802111:	d3 e3                	shl    %cl,%ebx
  802113:	89 f9                	mov    %edi,%ecx
  802115:	89 d0                	mov    %edx,%eax
  802117:	d3 e8                	shr    %cl,%eax
  802119:	89 e9                	mov    %ebp,%ecx
  80211b:	09 d8                	or     %ebx,%eax
  80211d:	89 d3                	mov    %edx,%ebx
  80211f:	89 f2                	mov    %esi,%edx
  802121:	f7 34 24             	divl   (%esp)
  802124:	89 d6                	mov    %edx,%esi
  802126:	d3 e3                	shl    %cl,%ebx
  802128:	f7 64 24 04          	mull   0x4(%esp)
  80212c:	39 d6                	cmp    %edx,%esi
  80212e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802132:	89 d1                	mov    %edx,%ecx
  802134:	89 c3                	mov    %eax,%ebx
  802136:	72 08                	jb     802140 <__umoddi3+0x110>
  802138:	75 11                	jne    80214b <__umoddi3+0x11b>
  80213a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80213e:	73 0b                	jae    80214b <__umoddi3+0x11b>
  802140:	2b 44 24 04          	sub    0x4(%esp),%eax
  802144:	1b 14 24             	sbb    (%esp),%edx
  802147:	89 d1                	mov    %edx,%ecx
  802149:	89 c3                	mov    %eax,%ebx
  80214b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80214f:	29 da                	sub    %ebx,%edx
  802151:	19 ce                	sbb    %ecx,%esi
  802153:	89 f9                	mov    %edi,%ecx
  802155:	89 f0                	mov    %esi,%eax
  802157:	d3 e0                	shl    %cl,%eax
  802159:	89 e9                	mov    %ebp,%ecx
  80215b:	d3 ea                	shr    %cl,%edx
  80215d:	89 e9                	mov    %ebp,%ecx
  80215f:	d3 ee                	shr    %cl,%esi
  802161:	09 d0                	or     %edx,%eax
  802163:	89 f2                	mov    %esi,%edx
  802165:	83 c4 1c             	add    $0x1c,%esp
  802168:	5b                   	pop    %ebx
  802169:	5e                   	pop    %esi
  80216a:	5f                   	pop    %edi
  80216b:	5d                   	pop    %ebp
  80216c:	c3                   	ret    
  80216d:	8d 76 00             	lea    0x0(%esi),%esi
  802170:	29 f9                	sub    %edi,%ecx
  802172:	19 d6                	sbb    %edx,%esi
  802174:	89 74 24 04          	mov    %esi,0x4(%esp)
  802178:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80217c:	e9 18 ff ff ff       	jmp    802099 <__umoddi3+0x69>
