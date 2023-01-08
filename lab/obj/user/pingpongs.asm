
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
  80003c:	e8 be 0f 00 00       	call   800fff <sfork>
  800041:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800044:	85 c0                	test   %eax,%eax
  800046:	74 42                	je     80008a <umain+0x57>
		cprintf("i am %08x; thisenv is %p\n", sys_getenvid(), thisenv);
  800048:	8b 1d 0c 40 80 00    	mov    0x80400c,%ebx
  80004e:	e8 e8 0a 00 00       	call   800b3b <sys_getenvid>
  800053:	83 ec 04             	sub    $0x4,%esp
  800056:	53                   	push   %ebx
  800057:	50                   	push   %eax
  800058:	68 e0 25 80 00       	push   $0x8025e0
  80005d:	e8 8f 01 00 00       	call   8001f1 <cprintf>
		// get the ball rolling
		cprintf("send 0 from %x to %x\n", sys_getenvid(), who);
  800062:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800065:	e8 d1 0a 00 00       	call   800b3b <sys_getenvid>
  80006a:	83 c4 0c             	add    $0xc,%esp
  80006d:	53                   	push   %ebx
  80006e:	50                   	push   %eax
  80006f:	68 fa 25 80 00       	push   $0x8025fa
  800074:	e8 78 01 00 00       	call   8001f1 <cprintf>
		ipc_send(who, 0, 0, 0);
  800079:	6a 00                	push   $0x0
  80007b:	6a 00                	push   $0x0
  80007d:	6a 00                	push   $0x0
  80007f:	ff 75 e4             	pushl  -0x1c(%ebp)
  800082:	e8 f9 0f 00 00       	call   801080 <ipc_send>
  800087:	83 c4 20             	add    $0x20,%esp
	}

	while (1) {
		ipc_recv(&who, 0, 0);
  80008a:	83 ec 04             	sub    $0x4,%esp
  80008d:	6a 00                	push   $0x0
  80008f:	6a 00                	push   $0x0
  800091:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800094:	50                   	push   %eax
  800095:	e8 7f 0f 00 00       	call   801019 <ipc_recv>
		cprintf("%x got %d from %x (thisenv is %p %x)\n", sys_getenvid(), val, who, thisenv, thisenv->env_id);
  80009a:	8b 1d 0c 40 80 00    	mov    0x80400c,%ebx
  8000a0:	8b 7b 48             	mov    0x48(%ebx),%edi
  8000a3:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8000a6:	a1 08 40 80 00       	mov    0x804008,%eax
  8000ab:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8000ae:	e8 88 0a 00 00       	call   800b3b <sys_getenvid>
  8000b3:	83 c4 08             	add    $0x8,%esp
  8000b6:	57                   	push   %edi
  8000b7:	53                   	push   %ebx
  8000b8:	56                   	push   %esi
  8000b9:	ff 75 d4             	pushl  -0x2c(%ebp)
  8000bc:	50                   	push   %eax
  8000bd:	68 10 26 80 00       	push   $0x802610
  8000c2:	e8 2a 01 00 00       	call   8001f1 <cprintf>
		if (val == 10)
  8000c7:	a1 08 40 80 00       	mov    0x804008,%eax
  8000cc:	83 c4 20             	add    $0x20,%esp
  8000cf:	83 f8 0a             	cmp    $0xa,%eax
  8000d2:	74 22                	je     8000f6 <umain+0xc3>
			return;
		++val;
  8000d4:	83 c0 01             	add    $0x1,%eax
  8000d7:	a3 08 40 80 00       	mov    %eax,0x804008
		ipc_send(who, 0, 0, 0);
  8000dc:	6a 00                	push   $0x0
  8000de:	6a 00                	push   $0x0
  8000e0:	6a 00                	push   $0x0
  8000e2:	ff 75 e4             	pushl  -0x1c(%ebp)
  8000e5:	e8 96 0f 00 00       	call   801080 <ipc_send>
		if (val == 10)
  8000ea:	83 c4 10             	add    $0x10,%esp
  8000ed:	83 3d 08 40 80 00 0a 	cmpl   $0xa,0x804008
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
  80011b:	a3 0c 40 80 00       	mov    %eax,0x80400c

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
  80014a:	e8 89 11 00 00       	call   8012d8 <close_all>
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
  800254:	e8 e7 20 00 00       	call   802340 <__udivdi3>
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
  800297:	e8 d4 21 00 00       	call   802470 <__umoddi3>
  80029c:	83 c4 14             	add    $0x14,%esp
  80029f:	0f be 80 40 26 80 00 	movsbl 0x802640(%eax),%eax
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
  80039b:	ff 24 85 80 27 80 00 	jmp    *0x802780(,%eax,4)
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
  80045f:	8b 14 85 e0 28 80 00 	mov    0x8028e0(,%eax,4),%edx
  800466:	85 d2                	test   %edx,%edx
  800468:	75 18                	jne    800482 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80046a:	50                   	push   %eax
  80046b:	68 58 26 80 00       	push   $0x802658
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
  800483:	68 e1 2a 80 00       	push   $0x802ae1
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
  8004a7:	b8 51 26 80 00       	mov    $0x802651,%eax
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
  800b22:	68 3f 29 80 00       	push   $0x80293f
  800b27:	6a 23                	push   $0x23
  800b29:	68 5c 29 80 00       	push   $0x80295c
  800b2e:	e8 1e 17 00 00       	call   802251 <_panic>

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
  800ba3:	68 3f 29 80 00       	push   $0x80293f
  800ba8:	6a 23                	push   $0x23
  800baa:	68 5c 29 80 00       	push   $0x80295c
  800baf:	e8 9d 16 00 00       	call   802251 <_panic>

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
  800be5:	68 3f 29 80 00       	push   $0x80293f
  800bea:	6a 23                	push   $0x23
  800bec:	68 5c 29 80 00       	push   $0x80295c
  800bf1:	e8 5b 16 00 00       	call   802251 <_panic>

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
  800c27:	68 3f 29 80 00       	push   $0x80293f
  800c2c:	6a 23                	push   $0x23
  800c2e:	68 5c 29 80 00       	push   $0x80295c
  800c33:	e8 19 16 00 00       	call   802251 <_panic>

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
  800c69:	68 3f 29 80 00       	push   $0x80293f
  800c6e:	6a 23                	push   $0x23
  800c70:	68 5c 29 80 00       	push   $0x80295c
  800c75:	e8 d7 15 00 00       	call   802251 <_panic>

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
  800cab:	68 3f 29 80 00       	push   $0x80293f
  800cb0:	6a 23                	push   $0x23
  800cb2:	68 5c 29 80 00       	push   $0x80295c
  800cb7:	e8 95 15 00 00       	call   802251 <_panic>

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
  800ced:	68 3f 29 80 00       	push   $0x80293f
  800cf2:	6a 23                	push   $0x23
  800cf4:	68 5c 29 80 00       	push   $0x80295c
  800cf9:	e8 53 15 00 00       	call   802251 <_panic>

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
  800d51:	68 3f 29 80 00       	push   $0x80293f
  800d56:	6a 23                	push   $0x23
  800d58:	68 5c 29 80 00       	push   $0x80295c
  800d5d:	e8 ef 14 00 00       	call   802251 <_panic>

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

00800d6a <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800d6a:	55                   	push   %ebp
  800d6b:	89 e5                	mov    %esp,%ebp
  800d6d:	57                   	push   %edi
  800d6e:	56                   	push   %esi
  800d6f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d70:	ba 00 00 00 00       	mov    $0x0,%edx
  800d75:	b8 0e 00 00 00       	mov    $0xe,%eax
  800d7a:	89 d1                	mov    %edx,%ecx
  800d7c:	89 d3                	mov    %edx,%ebx
  800d7e:	89 d7                	mov    %edx,%edi
  800d80:	89 d6                	mov    %edx,%esi
  800d82:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800d84:	5b                   	pop    %ebx
  800d85:	5e                   	pop    %esi
  800d86:	5f                   	pop    %edi
  800d87:	5d                   	pop    %ebp
  800d88:	c3                   	ret    

00800d89 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800d89:	55                   	push   %ebp
  800d8a:	89 e5                	mov    %esp,%ebp
  800d8c:	56                   	push   %esi
  800d8d:	53                   	push   %ebx
  800d8e:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800d91:	8b 18                	mov    (%eax),%ebx
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.

	if ((err & FEC_WR) != FEC_WR && ((uvpt[PGNUM(addr)] & PTE_COW) != PTE_COW)) {
  800d93:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800d97:	75 25                	jne    800dbe <pgfault+0x35>
  800d99:	89 d8                	mov    %ebx,%eax
  800d9b:	c1 e8 0c             	shr    $0xc,%eax
  800d9e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800da5:	f6 c4 08             	test   $0x8,%ah
  800da8:	75 14                	jne    800dbe <pgfault+0x35>
		panic("pgfault: not due to a write or a COW page");
  800daa:	83 ec 04             	sub    $0x4,%esp
  800dad:	68 6c 29 80 00       	push   $0x80296c
  800db2:	6a 1e                	push   $0x1e
  800db4:	68 00 2a 80 00       	push   $0x802a00
  800db9:	e8 93 14 00 00       	call   802251 <_panic>

	// LAB 4: Your code here.

	// panic("pgfault not implemented");

	addr = ROUNDDOWN(addr, PGSIZE);
  800dbe:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	envid_t envid = sys_getenvid();
  800dc4:	e8 72 fd ff ff       	call   800b3b <sys_getenvid>
  800dc9:	89 c6                	mov    %eax,%esi

	// envid = 0;

	// Allocate a new page, map it at a temporary location (PFTEMP)
	r = sys_page_alloc(envid, (void *)PFTEMP, PTE_U | PTE_P | PTE_W);
  800dcb:	83 ec 04             	sub    $0x4,%esp
  800dce:	6a 07                	push   $0x7
  800dd0:	68 00 f0 7f 00       	push   $0x7ff000
  800dd5:	50                   	push   %eax
  800dd6:	e8 9e fd ff ff       	call   800b79 <sys_page_alloc>
	if (r < 0)
  800ddb:	83 c4 10             	add    $0x10,%esp
  800dde:	85 c0                	test   %eax,%eax
  800de0:	79 12                	jns    800df4 <pgfault+0x6b>
		panic("pgfault: sys_page_alloc failed: %e\n", r);
  800de2:	50                   	push   %eax
  800de3:	68 98 29 80 00       	push   $0x802998
  800de8:	6a 33                	push   $0x33
  800dea:	68 00 2a 80 00       	push   $0x802a00
  800def:	e8 5d 14 00 00       	call   802251 <_panic>
	
	// copy the data from the old page to the new page
	memcpy((void *) PFTEMP, (const void *) addr, PGSIZE);
  800df4:	83 ec 04             	sub    $0x4,%esp
  800df7:	68 00 10 00 00       	push   $0x1000
  800dfc:	53                   	push   %ebx
  800dfd:	68 00 f0 7f 00       	push   $0x7ff000
  800e02:	e8 69 fb ff ff       	call   800970 <memcpy>

	// move the new page to the old page's address
	r = sys_page_map(envid, (void *) PFTEMP, envid, addr, PTE_U | PTE_P | PTE_W);
  800e07:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800e0e:	53                   	push   %ebx
  800e0f:	56                   	push   %esi
  800e10:	68 00 f0 7f 00       	push   $0x7ff000
  800e15:	56                   	push   %esi
  800e16:	e8 a1 fd ff ff       	call   800bbc <sys_page_map>
	if (r < 0)
  800e1b:	83 c4 20             	add    $0x20,%esp
  800e1e:	85 c0                	test   %eax,%eax
  800e20:	79 12                	jns    800e34 <pgfault+0xab>
		panic("pgfault: sys_page_map failed: %e\n", r);
  800e22:	50                   	push   %eax
  800e23:	68 bc 29 80 00       	push   $0x8029bc
  800e28:	6a 3b                	push   $0x3b
  800e2a:	68 00 2a 80 00       	push   $0x802a00
  800e2f:	e8 1d 14 00 00       	call   802251 <_panic>

	// unmap temporary region
	r = sys_page_unmap(envid, (void *) PFTEMP);
  800e34:	83 ec 08             	sub    $0x8,%esp
  800e37:	68 00 f0 7f 00       	push   $0x7ff000
  800e3c:	56                   	push   %esi
  800e3d:	e8 bc fd ff ff       	call   800bfe <sys_page_unmap>
	if (r < 0)
  800e42:	83 c4 10             	add    $0x10,%esp
  800e45:	85 c0                	test   %eax,%eax
  800e47:	79 12                	jns    800e5b <pgfault+0xd2>
        panic("pgfault: page unmap failed: %e\n", r);
  800e49:	50                   	push   %eax
  800e4a:	68 e0 29 80 00       	push   $0x8029e0
  800e4f:	6a 40                	push   $0x40
  800e51:	68 00 2a 80 00       	push   $0x802a00
  800e56:	e8 f6 13 00 00       	call   802251 <_panic>
}
  800e5b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e5e:	5b                   	pop    %ebx
  800e5f:	5e                   	pop    %esi
  800e60:	5d                   	pop    %ebp
  800e61:	c3                   	ret    

00800e62 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800e62:	55                   	push   %ebp
  800e63:	89 e5                	mov    %esp,%ebp
  800e65:	57                   	push   %edi
  800e66:	56                   	push   %esi
  800e67:	53                   	push   %ebx
  800e68:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	// cprintf("[fork]\n");
	int r;

	set_pgfault_handler(pgfault);
  800e6b:	68 89 0d 80 00       	push   $0x800d89
  800e70:	e8 22 14 00 00       	call   802297 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800e75:	b8 07 00 00 00       	mov    $0x7,%eax
  800e7a:	cd 30                	int    $0x30

	envid_t envid = sys_exofork();
	if (envid < 0)
  800e7c:	83 c4 10             	add    $0x10,%esp
  800e7f:	85 c0                	test   %eax,%eax
  800e81:	0f 88 64 01 00 00    	js     800feb <fork+0x189>
  800e87:	bb 00 00 80 00       	mov    $0x800000,%ebx
  800e8c:	be 00 08 00 00       	mov    $0x800,%esi
		return envid;

	// fix "thisenv" in the child process
	if (envid == 0) {
  800e91:	85 c0                	test   %eax,%eax
  800e93:	75 21                	jne    800eb6 <fork+0x54>
		thisenv = &envs[ENVX(sys_getenvid())];
  800e95:	e8 a1 fc ff ff       	call   800b3b <sys_getenvid>
  800e9a:	25 ff 03 00 00       	and    $0x3ff,%eax
  800e9f:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800ea2:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800ea7:	a3 0c 40 80 00       	mov    %eax,0x80400c
        return 0;
  800eac:	ba 00 00 00 00       	mov    $0x0,%edx
  800eb1:	e9 3f 01 00 00       	jmp    800ff5 <fork+0x193>
  800eb6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800eb9:	89 c7                	mov    %eax,%edi
	for (uint32_t pn = PGNUM(UTEXT); pn < PGNUM(USTACKTOP); pn++) {

		addr = pn * PGSIZE;

		// if level-2 page exists
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P) {
  800ebb:	89 d8                	mov    %ebx,%eax
  800ebd:	c1 e8 16             	shr    $0x16,%eax
  800ec0:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800ec7:	a8 01                	test   $0x1,%al
  800ec9:	0f 84 bd 00 00 00    	je     800f8c <fork+0x12a>
			
			// if real PTE exists
			if ((uvpt[PGNUM(addr)] & PTE_P) == PTE_P) {
  800ecf:	89 d8                	mov    %ebx,%eax
  800ed1:	c1 e8 0c             	shr    $0xc,%eax
  800ed4:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800edb:	f6 c2 01             	test   $0x1,%dl
  800ede:	0f 84 a8 00 00 00    	je     800f8c <fork+0x12a>

				// For each writable or copy-on-write page
				// if ((uvpt[PGNUM(addr)] & (PTE_W | PTE_COW)) != 0) {
				if ((uvpt[PGNUM(addr)] & PTE_U) != 0) {
  800ee4:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800eeb:	a8 04                	test   $0x4,%al
  800eed:	0f 84 99 00 00 00    	je     800f8c <fork+0x12a>
	// r = envid2env(envid, &env, 1);
	// if (r < 0)
	// 	return r;	// E_BAD_ENV
	// envid_t parent_envid = env->env_parent_id;

	if (uvpt[pn] & PTE_SHARE) {
  800ef3:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800efa:	f6 c4 04             	test   $0x4,%ah
  800efd:	74 17                	je     800f16 <fork+0xb4>
		sys_page_map(0, (void *)va, envid, (void *)va, PTE_SYSCALL);
  800eff:	83 ec 0c             	sub    $0xc,%esp
  800f02:	68 07 0e 00 00       	push   $0xe07
  800f07:	53                   	push   %ebx
  800f08:	57                   	push   %edi
  800f09:	53                   	push   %ebx
  800f0a:	6a 00                	push   $0x0
  800f0c:	e8 ab fc ff ff       	call   800bbc <sys_page_map>
  800f11:	83 c4 20             	add    $0x20,%esp
  800f14:	eb 76                	jmp    800f8c <fork+0x12a>
	}
	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {
  800f16:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800f1d:	a8 02                	test   $0x2,%al
  800f1f:	75 0c                	jne    800f2d <fork+0xcb>
  800f21:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800f28:	f6 c4 08             	test   $0x8,%ah
  800f2b:	74 3f                	je     800f6c <fork+0x10a>

		// map the page copy-on-write into the address space of the child
        r = sys_page_map(0, (void *)va, envid, (void *)va, PTE_P|PTE_U|PTE_COW);
  800f2d:	83 ec 0c             	sub    $0xc,%esp
  800f30:	68 05 08 00 00       	push   $0x805
  800f35:	53                   	push   %ebx
  800f36:	57                   	push   %edi
  800f37:	53                   	push   %ebx
  800f38:	6a 00                	push   $0x0
  800f3a:	e8 7d fc ff ff       	call   800bbc <sys_page_map>
		if (r < 0)
  800f3f:	83 c4 20             	add    $0x20,%esp
  800f42:	85 c0                	test   %eax,%eax
  800f44:	0f 88 a5 00 00 00    	js     800fef <fork+0x18d>
            return r;

		// remap the page copy-on-write in its own(parent) address space
        r = sys_page_map(0, (void *)va, 0, (void *)va, PTE_P|PTE_U|PTE_COW);
  800f4a:	83 ec 0c             	sub    $0xc,%esp
  800f4d:	68 05 08 00 00       	push   $0x805
  800f52:	53                   	push   %ebx
  800f53:	6a 00                	push   $0x0
  800f55:	53                   	push   %ebx
  800f56:	6a 00                	push   $0x0
  800f58:	e8 5f fc ff ff       	call   800bbc <sys_page_map>
  800f5d:	83 c4 20             	add    $0x20,%esp
  800f60:	85 c0                	test   %eax,%eax
  800f62:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f67:	0f 4f c1             	cmovg  %ecx,%eax
  800f6a:	eb 1c                	jmp    800f88 <fork+0x126>
		if (r < 0)
            return r;
    }
    else {
        r = sys_page_map(0, (void *)va, envid, (void *)va, PTE_P|PTE_U);
  800f6c:	83 ec 0c             	sub    $0xc,%esp
  800f6f:	6a 05                	push   $0x5
  800f71:	53                   	push   %ebx
  800f72:	57                   	push   %edi
  800f73:	53                   	push   %ebx
  800f74:	6a 00                	push   $0x0
  800f76:	e8 41 fc ff ff       	call   800bbc <sys_page_map>
  800f7b:	83 c4 20             	add    $0x20,%esp
  800f7e:	85 c0                	test   %eax,%eax
  800f80:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f85:	0f 4f c1             	cmovg  %ecx,%eax

				// For each writable or copy-on-write page
				// if ((uvpt[PGNUM(addr)] & (PTE_W | PTE_COW)) != 0) {
				if ((uvpt[PGNUM(addr)] & PTE_U) != 0) {
					r = duppage(envid, pn);
					if (r < 0)
  800f88:	85 c0                	test   %eax,%eax
  800f8a:	78 67                	js     800ff3 <fork+0x191>
        return 0;
	}

	// For each writable or copy-on-write page in its address space below UTOP, the parent calls duppage
	uint32_t addr;
	for (uint32_t pn = PGNUM(UTEXT); pn < PGNUM(USTACKTOP); pn++) {
  800f8c:	83 c6 01             	add    $0x1,%esi
  800f8f:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  800f95:	81 fe fe eb 0e 00    	cmp    $0xeebfe,%esi
  800f9b:	0f 85 1a ff ff ff    	jne    800ebb <fork+0x59>
  800fa1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
		}
	}

	// allocate a fresh page in the child for the exception stack
	r = sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U | PTE_P | PTE_W);
  800fa4:	83 ec 04             	sub    $0x4,%esp
  800fa7:	6a 07                	push   $0x7
  800fa9:	68 00 f0 bf ee       	push   $0xeebff000
  800fae:	57                   	push   %edi
  800faf:	e8 c5 fb ff ff       	call   800b79 <sys_page_alloc>
	if (r < 0)
  800fb4:	83 c4 10             	add    $0x10,%esp
		return r;
  800fb7:	89 c2                	mov    %eax,%edx
		}
	}

	// allocate a fresh page in the child for the exception stack
	r = sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U | PTE_P | PTE_W);
	if (r < 0)
  800fb9:	85 c0                	test   %eax,%eax
  800fbb:	78 38                	js     800ff5 <fork+0x193>
		return r;

	// The parent sets the user page fault entrypoint for the child to look like its own
	extern void _pgfault_upcall(void);
	r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  800fbd:	83 ec 08             	sub    $0x8,%esp
  800fc0:	68 de 22 80 00       	push   $0x8022de
  800fc5:	57                   	push   %edi
  800fc6:	e8 f9 fc ff ff       	call   800cc4 <sys_env_set_pgfault_upcall>
	if (r < 0)
  800fcb:	83 c4 10             	add    $0x10,%esp
		return r;
  800fce:	89 c2                	mov    %eax,%edx
		return r;

	// The parent sets the user page fault entrypoint for the child to look like its own
	extern void _pgfault_upcall(void);
	r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
	if (r < 0)
  800fd0:	85 c0                	test   %eax,%eax
  800fd2:	78 21                	js     800ff5 <fork+0x193>
		return r;

	// The child is now ready to run, so the parent marks it runnable
	r = sys_env_set_status(envid, ENV_RUNNABLE);
  800fd4:	83 ec 08             	sub    $0x8,%esp
  800fd7:	6a 02                	push   $0x2
  800fd9:	57                   	push   %edi
  800fda:	e8 61 fc ff ff       	call   800c40 <sys_env_set_status>
	if (r < 0)
  800fdf:	83 c4 10             	add    $0x10,%esp
		return r;

	return envid;
  800fe2:	85 c0                	test   %eax,%eax
  800fe4:	0f 48 f8             	cmovs  %eax,%edi
  800fe7:	89 fa                	mov    %edi,%edx
  800fe9:	eb 0a                	jmp    800ff5 <fork+0x193>

	set_pgfault_handler(pgfault);

	envid_t envid = sys_exofork();
	if (envid < 0)
		return envid;
  800feb:	89 c2                	mov    %eax,%edx
  800fed:	eb 06                	jmp    800ff5 <fork+0x193>
		sys_page_map(0, (void *)va, envid, (void *)va, PTE_SYSCALL);
	}
	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {

		// map the page copy-on-write into the address space of the child
        r = sys_page_map(0, (void *)va, envid, (void *)va, PTE_P|PTE_U|PTE_COW);
  800fef:	89 c2                	mov    %eax,%edx
  800ff1:	eb 02                	jmp    800ff5 <fork+0x193>
  800ff3:	89 c2                	mov    %eax,%edx
	if (r < 0)
		return r;

	return envid;
	// panic("fork not implemented");
}
  800ff5:	89 d0                	mov    %edx,%eax
  800ff7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ffa:	5b                   	pop    %ebx
  800ffb:	5e                   	pop    %esi
  800ffc:	5f                   	pop    %edi
  800ffd:	5d                   	pop    %ebp
  800ffe:	c3                   	ret    

00800fff <sfork>:

// Challenge!
int
sfork(void)
{
  800fff:	55                   	push   %ebp
  801000:	89 e5                	mov    %esp,%ebp
  801002:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801005:	68 0b 2a 80 00       	push   $0x802a0b
  80100a:	68 c9 00 00 00       	push   $0xc9
  80100f:	68 00 2a 80 00       	push   $0x802a00
  801014:	e8 38 12 00 00       	call   802251 <_panic>

00801019 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801019:	55                   	push   %ebp
  80101a:	89 e5                	mov    %esp,%ebp
  80101c:	56                   	push   %esi
  80101d:	53                   	push   %ebx
  80101e:	8b 75 08             	mov    0x8(%ebp),%esi
  801021:	8b 45 0c             	mov    0xc(%ebp),%eax
  801024:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");

	// don't want to recv page
	if (pg == NULL)
  801027:	85 c0                	test   %eax,%eax
		pg = (void *)UTOP;
  801029:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  80102e:	0f 44 c2             	cmove  %edx,%eax

	int err = sys_ipc_recv(pg);
  801031:	83 ec 0c             	sub    $0xc,%esp
  801034:	50                   	push   %eax
  801035:	e8 ef fc ff ff       	call   800d29 <sys_ipc_recv>

	if (from_env_store != NULL)
  80103a:	83 c4 10             	add    $0x10,%esp
  80103d:	85 f6                	test   %esi,%esi
  80103f:	74 14                	je     801055 <ipc_recv+0x3c>
		*from_env_store = err < 0? 0 : thisenv->env_ipc_from;
  801041:	ba 00 00 00 00       	mov    $0x0,%edx
  801046:	85 c0                	test   %eax,%eax
  801048:	78 09                	js     801053 <ipc_recv+0x3a>
  80104a:	8b 15 0c 40 80 00    	mov    0x80400c,%edx
  801050:	8b 52 74             	mov    0x74(%edx),%edx
  801053:	89 16                	mov    %edx,(%esi)
	
	if (perm_store != NULL)
  801055:	85 db                	test   %ebx,%ebx
  801057:	74 14                	je     80106d <ipc_recv+0x54>
		*perm_store = err < 0? 0 : thisenv->env_ipc_perm;
  801059:	ba 00 00 00 00       	mov    $0x0,%edx
  80105e:	85 c0                	test   %eax,%eax
  801060:	78 09                	js     80106b <ipc_recv+0x52>
  801062:	8b 15 0c 40 80 00    	mov    0x80400c,%edx
  801068:	8b 52 78             	mov    0x78(%edx),%edx
  80106b:	89 13                	mov    %edx,(%ebx)

	if (err < 0)
  80106d:	85 c0                	test   %eax,%eax
  80106f:	78 08                	js     801079 <ipc_recv+0x60>
		return err;
	return thisenv->env_ipc_value;
  801071:	a1 0c 40 80 00       	mov    0x80400c,%eax
  801076:	8b 40 70             	mov    0x70(%eax),%eax
}
  801079:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80107c:	5b                   	pop    %ebx
  80107d:	5e                   	pop    %esi
  80107e:	5d                   	pop    %ebp
  80107f:	c3                   	ret    

00801080 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801080:	55                   	push   %ebp
  801081:	89 e5                	mov    %esp,%ebp
  801083:	57                   	push   %edi
  801084:	56                   	push   %esi
  801085:	53                   	push   %ebx
  801086:	83 ec 0c             	sub    $0xc,%esp
  801089:	8b 7d 08             	mov    0x8(%ebp),%edi
  80108c:	8b 75 0c             	mov    0xc(%ebp),%esi
  80108f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");

	// don't want to send page
	if (pg == NULL)
  801092:	85 db                	test   %ebx,%ebx
		pg = (void *)UTOP;
  801094:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801099:	0f 44 d8             	cmove  %eax,%ebx
	
	int err = 0;
	
	do {

		err = sys_ipc_try_send(to_env, val, pg, perm);
  80109c:	ff 75 14             	pushl  0x14(%ebp)
  80109f:	53                   	push   %ebx
  8010a0:	56                   	push   %esi
  8010a1:	57                   	push   %edi
  8010a2:	e8 5f fc ff ff       	call   800d06 <sys_ipc_try_send>

		if (err < 0) {
  8010a7:	83 c4 10             	add    $0x10,%esp
  8010aa:	85 c0                	test   %eax,%eax
  8010ac:	79 1e                	jns    8010cc <ipc_send+0x4c>
			if (err == -E_IPC_NOT_RECV)
  8010ae:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8010b1:	75 07                	jne    8010ba <ipc_send+0x3a>
				sys_yield();
  8010b3:	e8 a2 fa ff ff       	call   800b5a <sys_yield>
  8010b8:	eb e2                	jmp    80109c <ipc_send+0x1c>
			else 
				panic("ipc_send: %e", err);
  8010ba:	50                   	push   %eax
  8010bb:	68 21 2a 80 00       	push   $0x802a21
  8010c0:	6a 49                	push   $0x49
  8010c2:	68 2e 2a 80 00       	push   $0x802a2e
  8010c7:	e8 85 11 00 00       	call   802251 <_panic>
		}

	} while (err < 0);

}
  8010cc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010cf:	5b                   	pop    %ebx
  8010d0:	5e                   	pop    %esi
  8010d1:	5f                   	pop    %edi
  8010d2:	5d                   	pop    %ebp
  8010d3:	c3                   	ret    

008010d4 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8010d4:	55                   	push   %ebp
  8010d5:	89 e5                	mov    %esp,%ebp
  8010d7:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8010da:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8010df:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8010e2:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8010e8:	8b 52 50             	mov    0x50(%edx),%edx
  8010eb:	39 ca                	cmp    %ecx,%edx
  8010ed:	75 0d                	jne    8010fc <ipc_find_env+0x28>
			return envs[i].env_id;
  8010ef:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8010f2:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8010f7:	8b 40 48             	mov    0x48(%eax),%eax
  8010fa:	eb 0f                	jmp    80110b <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8010fc:	83 c0 01             	add    $0x1,%eax
  8010ff:	3d 00 04 00 00       	cmp    $0x400,%eax
  801104:	75 d9                	jne    8010df <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801106:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80110b:	5d                   	pop    %ebp
  80110c:	c3                   	ret    

0080110d <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80110d:	55                   	push   %ebp
  80110e:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801110:	8b 45 08             	mov    0x8(%ebp),%eax
  801113:	05 00 00 00 30       	add    $0x30000000,%eax
  801118:	c1 e8 0c             	shr    $0xc,%eax
}
  80111b:	5d                   	pop    %ebp
  80111c:	c3                   	ret    

0080111d <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80111d:	55                   	push   %ebp
  80111e:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801120:	8b 45 08             	mov    0x8(%ebp),%eax
  801123:	05 00 00 00 30       	add    $0x30000000,%eax
  801128:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80112d:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801132:	5d                   	pop    %ebp
  801133:	c3                   	ret    

00801134 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801134:	55                   	push   %ebp
  801135:	89 e5                	mov    %esp,%ebp
  801137:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80113a:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80113f:	89 c2                	mov    %eax,%edx
  801141:	c1 ea 16             	shr    $0x16,%edx
  801144:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80114b:	f6 c2 01             	test   $0x1,%dl
  80114e:	74 11                	je     801161 <fd_alloc+0x2d>
  801150:	89 c2                	mov    %eax,%edx
  801152:	c1 ea 0c             	shr    $0xc,%edx
  801155:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80115c:	f6 c2 01             	test   $0x1,%dl
  80115f:	75 09                	jne    80116a <fd_alloc+0x36>
			*fd_store = fd;
  801161:	89 01                	mov    %eax,(%ecx)
			return 0;
  801163:	b8 00 00 00 00       	mov    $0x0,%eax
  801168:	eb 17                	jmp    801181 <fd_alloc+0x4d>
  80116a:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80116f:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801174:	75 c9                	jne    80113f <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801176:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  80117c:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801181:	5d                   	pop    %ebp
  801182:	c3                   	ret    

00801183 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801183:	55                   	push   %ebp
  801184:	89 e5                	mov    %esp,%ebp
  801186:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801189:	83 f8 1f             	cmp    $0x1f,%eax
  80118c:	77 36                	ja     8011c4 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80118e:	c1 e0 0c             	shl    $0xc,%eax
  801191:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801196:	89 c2                	mov    %eax,%edx
  801198:	c1 ea 16             	shr    $0x16,%edx
  80119b:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8011a2:	f6 c2 01             	test   $0x1,%dl
  8011a5:	74 24                	je     8011cb <fd_lookup+0x48>
  8011a7:	89 c2                	mov    %eax,%edx
  8011a9:	c1 ea 0c             	shr    $0xc,%edx
  8011ac:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8011b3:	f6 c2 01             	test   $0x1,%dl
  8011b6:	74 1a                	je     8011d2 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8011b8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011bb:	89 02                	mov    %eax,(%edx)
	return 0;
  8011bd:	b8 00 00 00 00       	mov    $0x0,%eax
  8011c2:	eb 13                	jmp    8011d7 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8011c4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011c9:	eb 0c                	jmp    8011d7 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8011cb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011d0:	eb 05                	jmp    8011d7 <fd_lookup+0x54>
  8011d2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8011d7:	5d                   	pop    %ebp
  8011d8:	c3                   	ret    

008011d9 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8011d9:	55                   	push   %ebp
  8011da:	89 e5                	mov    %esp,%ebp
  8011dc:	83 ec 08             	sub    $0x8,%esp
  8011df:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011e2:	ba b4 2a 80 00       	mov    $0x802ab4,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8011e7:	eb 13                	jmp    8011fc <dev_lookup+0x23>
  8011e9:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8011ec:	39 08                	cmp    %ecx,(%eax)
  8011ee:	75 0c                	jne    8011fc <dev_lookup+0x23>
			*dev = devtab[i];
  8011f0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011f3:	89 01                	mov    %eax,(%ecx)
			return 0;
  8011f5:	b8 00 00 00 00       	mov    $0x0,%eax
  8011fa:	eb 2e                	jmp    80122a <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8011fc:	8b 02                	mov    (%edx),%eax
  8011fe:	85 c0                	test   %eax,%eax
  801200:	75 e7                	jne    8011e9 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801202:	a1 0c 40 80 00       	mov    0x80400c,%eax
  801207:	8b 40 48             	mov    0x48(%eax),%eax
  80120a:	83 ec 04             	sub    $0x4,%esp
  80120d:	51                   	push   %ecx
  80120e:	50                   	push   %eax
  80120f:	68 38 2a 80 00       	push   $0x802a38
  801214:	e8 d8 ef ff ff       	call   8001f1 <cprintf>
	*dev = 0;
  801219:	8b 45 0c             	mov    0xc(%ebp),%eax
  80121c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801222:	83 c4 10             	add    $0x10,%esp
  801225:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80122a:	c9                   	leave  
  80122b:	c3                   	ret    

0080122c <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80122c:	55                   	push   %ebp
  80122d:	89 e5                	mov    %esp,%ebp
  80122f:	56                   	push   %esi
  801230:	53                   	push   %ebx
  801231:	83 ec 10             	sub    $0x10,%esp
  801234:	8b 75 08             	mov    0x8(%ebp),%esi
  801237:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80123a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80123d:	50                   	push   %eax
  80123e:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801244:	c1 e8 0c             	shr    $0xc,%eax
  801247:	50                   	push   %eax
  801248:	e8 36 ff ff ff       	call   801183 <fd_lookup>
  80124d:	83 c4 08             	add    $0x8,%esp
  801250:	85 c0                	test   %eax,%eax
  801252:	78 05                	js     801259 <fd_close+0x2d>
	    || fd != fd2)
  801254:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801257:	74 0c                	je     801265 <fd_close+0x39>
		return (must_exist ? r : 0);
  801259:	84 db                	test   %bl,%bl
  80125b:	ba 00 00 00 00       	mov    $0x0,%edx
  801260:	0f 44 c2             	cmove  %edx,%eax
  801263:	eb 41                	jmp    8012a6 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801265:	83 ec 08             	sub    $0x8,%esp
  801268:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80126b:	50                   	push   %eax
  80126c:	ff 36                	pushl  (%esi)
  80126e:	e8 66 ff ff ff       	call   8011d9 <dev_lookup>
  801273:	89 c3                	mov    %eax,%ebx
  801275:	83 c4 10             	add    $0x10,%esp
  801278:	85 c0                	test   %eax,%eax
  80127a:	78 1a                	js     801296 <fd_close+0x6a>
		if (dev->dev_close)
  80127c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80127f:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801282:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801287:	85 c0                	test   %eax,%eax
  801289:	74 0b                	je     801296 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80128b:	83 ec 0c             	sub    $0xc,%esp
  80128e:	56                   	push   %esi
  80128f:	ff d0                	call   *%eax
  801291:	89 c3                	mov    %eax,%ebx
  801293:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801296:	83 ec 08             	sub    $0x8,%esp
  801299:	56                   	push   %esi
  80129a:	6a 00                	push   $0x0
  80129c:	e8 5d f9 ff ff       	call   800bfe <sys_page_unmap>
	return r;
  8012a1:	83 c4 10             	add    $0x10,%esp
  8012a4:	89 d8                	mov    %ebx,%eax
}
  8012a6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012a9:	5b                   	pop    %ebx
  8012aa:	5e                   	pop    %esi
  8012ab:	5d                   	pop    %ebp
  8012ac:	c3                   	ret    

008012ad <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8012ad:	55                   	push   %ebp
  8012ae:	89 e5                	mov    %esp,%ebp
  8012b0:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8012b3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012b6:	50                   	push   %eax
  8012b7:	ff 75 08             	pushl  0x8(%ebp)
  8012ba:	e8 c4 fe ff ff       	call   801183 <fd_lookup>
  8012bf:	83 c4 08             	add    $0x8,%esp
  8012c2:	85 c0                	test   %eax,%eax
  8012c4:	78 10                	js     8012d6 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8012c6:	83 ec 08             	sub    $0x8,%esp
  8012c9:	6a 01                	push   $0x1
  8012cb:	ff 75 f4             	pushl  -0xc(%ebp)
  8012ce:	e8 59 ff ff ff       	call   80122c <fd_close>
  8012d3:	83 c4 10             	add    $0x10,%esp
}
  8012d6:	c9                   	leave  
  8012d7:	c3                   	ret    

008012d8 <close_all>:

void
close_all(void)
{
  8012d8:	55                   	push   %ebp
  8012d9:	89 e5                	mov    %esp,%ebp
  8012db:	53                   	push   %ebx
  8012dc:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8012df:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8012e4:	83 ec 0c             	sub    $0xc,%esp
  8012e7:	53                   	push   %ebx
  8012e8:	e8 c0 ff ff ff       	call   8012ad <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8012ed:	83 c3 01             	add    $0x1,%ebx
  8012f0:	83 c4 10             	add    $0x10,%esp
  8012f3:	83 fb 20             	cmp    $0x20,%ebx
  8012f6:	75 ec                	jne    8012e4 <close_all+0xc>
		close(i);
}
  8012f8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012fb:	c9                   	leave  
  8012fc:	c3                   	ret    

008012fd <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8012fd:	55                   	push   %ebp
  8012fe:	89 e5                	mov    %esp,%ebp
  801300:	57                   	push   %edi
  801301:	56                   	push   %esi
  801302:	53                   	push   %ebx
  801303:	83 ec 2c             	sub    $0x2c,%esp
  801306:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801309:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80130c:	50                   	push   %eax
  80130d:	ff 75 08             	pushl  0x8(%ebp)
  801310:	e8 6e fe ff ff       	call   801183 <fd_lookup>
  801315:	83 c4 08             	add    $0x8,%esp
  801318:	85 c0                	test   %eax,%eax
  80131a:	0f 88 c1 00 00 00    	js     8013e1 <dup+0xe4>
		return r;
	close(newfdnum);
  801320:	83 ec 0c             	sub    $0xc,%esp
  801323:	56                   	push   %esi
  801324:	e8 84 ff ff ff       	call   8012ad <close>

	newfd = INDEX2FD(newfdnum);
  801329:	89 f3                	mov    %esi,%ebx
  80132b:	c1 e3 0c             	shl    $0xc,%ebx
  80132e:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801334:	83 c4 04             	add    $0x4,%esp
  801337:	ff 75 e4             	pushl  -0x1c(%ebp)
  80133a:	e8 de fd ff ff       	call   80111d <fd2data>
  80133f:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801341:	89 1c 24             	mov    %ebx,(%esp)
  801344:	e8 d4 fd ff ff       	call   80111d <fd2data>
  801349:	83 c4 10             	add    $0x10,%esp
  80134c:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80134f:	89 f8                	mov    %edi,%eax
  801351:	c1 e8 16             	shr    $0x16,%eax
  801354:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80135b:	a8 01                	test   $0x1,%al
  80135d:	74 37                	je     801396 <dup+0x99>
  80135f:	89 f8                	mov    %edi,%eax
  801361:	c1 e8 0c             	shr    $0xc,%eax
  801364:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80136b:	f6 c2 01             	test   $0x1,%dl
  80136e:	74 26                	je     801396 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801370:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801377:	83 ec 0c             	sub    $0xc,%esp
  80137a:	25 07 0e 00 00       	and    $0xe07,%eax
  80137f:	50                   	push   %eax
  801380:	ff 75 d4             	pushl  -0x2c(%ebp)
  801383:	6a 00                	push   $0x0
  801385:	57                   	push   %edi
  801386:	6a 00                	push   $0x0
  801388:	e8 2f f8 ff ff       	call   800bbc <sys_page_map>
  80138d:	89 c7                	mov    %eax,%edi
  80138f:	83 c4 20             	add    $0x20,%esp
  801392:	85 c0                	test   %eax,%eax
  801394:	78 2e                	js     8013c4 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801396:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801399:	89 d0                	mov    %edx,%eax
  80139b:	c1 e8 0c             	shr    $0xc,%eax
  80139e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8013a5:	83 ec 0c             	sub    $0xc,%esp
  8013a8:	25 07 0e 00 00       	and    $0xe07,%eax
  8013ad:	50                   	push   %eax
  8013ae:	53                   	push   %ebx
  8013af:	6a 00                	push   $0x0
  8013b1:	52                   	push   %edx
  8013b2:	6a 00                	push   $0x0
  8013b4:	e8 03 f8 ff ff       	call   800bbc <sys_page_map>
  8013b9:	89 c7                	mov    %eax,%edi
  8013bb:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8013be:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8013c0:	85 ff                	test   %edi,%edi
  8013c2:	79 1d                	jns    8013e1 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8013c4:	83 ec 08             	sub    $0x8,%esp
  8013c7:	53                   	push   %ebx
  8013c8:	6a 00                	push   $0x0
  8013ca:	e8 2f f8 ff ff       	call   800bfe <sys_page_unmap>
	sys_page_unmap(0, nva);
  8013cf:	83 c4 08             	add    $0x8,%esp
  8013d2:	ff 75 d4             	pushl  -0x2c(%ebp)
  8013d5:	6a 00                	push   $0x0
  8013d7:	e8 22 f8 ff ff       	call   800bfe <sys_page_unmap>
	return r;
  8013dc:	83 c4 10             	add    $0x10,%esp
  8013df:	89 f8                	mov    %edi,%eax
}
  8013e1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013e4:	5b                   	pop    %ebx
  8013e5:	5e                   	pop    %esi
  8013e6:	5f                   	pop    %edi
  8013e7:	5d                   	pop    %ebp
  8013e8:	c3                   	ret    

008013e9 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8013e9:	55                   	push   %ebp
  8013ea:	89 e5                	mov    %esp,%ebp
  8013ec:	53                   	push   %ebx
  8013ed:	83 ec 14             	sub    $0x14,%esp
  8013f0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013f3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013f6:	50                   	push   %eax
  8013f7:	53                   	push   %ebx
  8013f8:	e8 86 fd ff ff       	call   801183 <fd_lookup>
  8013fd:	83 c4 08             	add    $0x8,%esp
  801400:	89 c2                	mov    %eax,%edx
  801402:	85 c0                	test   %eax,%eax
  801404:	78 6d                	js     801473 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801406:	83 ec 08             	sub    $0x8,%esp
  801409:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80140c:	50                   	push   %eax
  80140d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801410:	ff 30                	pushl  (%eax)
  801412:	e8 c2 fd ff ff       	call   8011d9 <dev_lookup>
  801417:	83 c4 10             	add    $0x10,%esp
  80141a:	85 c0                	test   %eax,%eax
  80141c:	78 4c                	js     80146a <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80141e:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801421:	8b 42 08             	mov    0x8(%edx),%eax
  801424:	83 e0 03             	and    $0x3,%eax
  801427:	83 f8 01             	cmp    $0x1,%eax
  80142a:	75 21                	jne    80144d <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80142c:	a1 0c 40 80 00       	mov    0x80400c,%eax
  801431:	8b 40 48             	mov    0x48(%eax),%eax
  801434:	83 ec 04             	sub    $0x4,%esp
  801437:	53                   	push   %ebx
  801438:	50                   	push   %eax
  801439:	68 79 2a 80 00       	push   $0x802a79
  80143e:	e8 ae ed ff ff       	call   8001f1 <cprintf>
		return -E_INVAL;
  801443:	83 c4 10             	add    $0x10,%esp
  801446:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80144b:	eb 26                	jmp    801473 <read+0x8a>
	}
	if (!dev->dev_read)
  80144d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801450:	8b 40 08             	mov    0x8(%eax),%eax
  801453:	85 c0                	test   %eax,%eax
  801455:	74 17                	je     80146e <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801457:	83 ec 04             	sub    $0x4,%esp
  80145a:	ff 75 10             	pushl  0x10(%ebp)
  80145d:	ff 75 0c             	pushl  0xc(%ebp)
  801460:	52                   	push   %edx
  801461:	ff d0                	call   *%eax
  801463:	89 c2                	mov    %eax,%edx
  801465:	83 c4 10             	add    $0x10,%esp
  801468:	eb 09                	jmp    801473 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80146a:	89 c2                	mov    %eax,%edx
  80146c:	eb 05                	jmp    801473 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80146e:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801473:	89 d0                	mov    %edx,%eax
  801475:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801478:	c9                   	leave  
  801479:	c3                   	ret    

0080147a <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80147a:	55                   	push   %ebp
  80147b:	89 e5                	mov    %esp,%ebp
  80147d:	57                   	push   %edi
  80147e:	56                   	push   %esi
  80147f:	53                   	push   %ebx
  801480:	83 ec 0c             	sub    $0xc,%esp
  801483:	8b 7d 08             	mov    0x8(%ebp),%edi
  801486:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801489:	bb 00 00 00 00       	mov    $0x0,%ebx
  80148e:	eb 21                	jmp    8014b1 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801490:	83 ec 04             	sub    $0x4,%esp
  801493:	89 f0                	mov    %esi,%eax
  801495:	29 d8                	sub    %ebx,%eax
  801497:	50                   	push   %eax
  801498:	89 d8                	mov    %ebx,%eax
  80149a:	03 45 0c             	add    0xc(%ebp),%eax
  80149d:	50                   	push   %eax
  80149e:	57                   	push   %edi
  80149f:	e8 45 ff ff ff       	call   8013e9 <read>
		if (m < 0)
  8014a4:	83 c4 10             	add    $0x10,%esp
  8014a7:	85 c0                	test   %eax,%eax
  8014a9:	78 10                	js     8014bb <readn+0x41>
			return m;
		if (m == 0)
  8014ab:	85 c0                	test   %eax,%eax
  8014ad:	74 0a                	je     8014b9 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8014af:	01 c3                	add    %eax,%ebx
  8014b1:	39 f3                	cmp    %esi,%ebx
  8014b3:	72 db                	jb     801490 <readn+0x16>
  8014b5:	89 d8                	mov    %ebx,%eax
  8014b7:	eb 02                	jmp    8014bb <readn+0x41>
  8014b9:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8014bb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014be:	5b                   	pop    %ebx
  8014bf:	5e                   	pop    %esi
  8014c0:	5f                   	pop    %edi
  8014c1:	5d                   	pop    %ebp
  8014c2:	c3                   	ret    

008014c3 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8014c3:	55                   	push   %ebp
  8014c4:	89 e5                	mov    %esp,%ebp
  8014c6:	53                   	push   %ebx
  8014c7:	83 ec 14             	sub    $0x14,%esp
  8014ca:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014cd:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014d0:	50                   	push   %eax
  8014d1:	53                   	push   %ebx
  8014d2:	e8 ac fc ff ff       	call   801183 <fd_lookup>
  8014d7:	83 c4 08             	add    $0x8,%esp
  8014da:	89 c2                	mov    %eax,%edx
  8014dc:	85 c0                	test   %eax,%eax
  8014de:	78 68                	js     801548 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014e0:	83 ec 08             	sub    $0x8,%esp
  8014e3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014e6:	50                   	push   %eax
  8014e7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014ea:	ff 30                	pushl  (%eax)
  8014ec:	e8 e8 fc ff ff       	call   8011d9 <dev_lookup>
  8014f1:	83 c4 10             	add    $0x10,%esp
  8014f4:	85 c0                	test   %eax,%eax
  8014f6:	78 47                	js     80153f <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8014f8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014fb:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8014ff:	75 21                	jne    801522 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801501:	a1 0c 40 80 00       	mov    0x80400c,%eax
  801506:	8b 40 48             	mov    0x48(%eax),%eax
  801509:	83 ec 04             	sub    $0x4,%esp
  80150c:	53                   	push   %ebx
  80150d:	50                   	push   %eax
  80150e:	68 95 2a 80 00       	push   $0x802a95
  801513:	e8 d9 ec ff ff       	call   8001f1 <cprintf>
		return -E_INVAL;
  801518:	83 c4 10             	add    $0x10,%esp
  80151b:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801520:	eb 26                	jmp    801548 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801522:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801525:	8b 52 0c             	mov    0xc(%edx),%edx
  801528:	85 d2                	test   %edx,%edx
  80152a:	74 17                	je     801543 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80152c:	83 ec 04             	sub    $0x4,%esp
  80152f:	ff 75 10             	pushl  0x10(%ebp)
  801532:	ff 75 0c             	pushl  0xc(%ebp)
  801535:	50                   	push   %eax
  801536:	ff d2                	call   *%edx
  801538:	89 c2                	mov    %eax,%edx
  80153a:	83 c4 10             	add    $0x10,%esp
  80153d:	eb 09                	jmp    801548 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80153f:	89 c2                	mov    %eax,%edx
  801541:	eb 05                	jmp    801548 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801543:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801548:	89 d0                	mov    %edx,%eax
  80154a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80154d:	c9                   	leave  
  80154e:	c3                   	ret    

0080154f <seek>:

int
seek(int fdnum, off_t offset)
{
  80154f:	55                   	push   %ebp
  801550:	89 e5                	mov    %esp,%ebp
  801552:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801555:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801558:	50                   	push   %eax
  801559:	ff 75 08             	pushl  0x8(%ebp)
  80155c:	e8 22 fc ff ff       	call   801183 <fd_lookup>
  801561:	83 c4 08             	add    $0x8,%esp
  801564:	85 c0                	test   %eax,%eax
  801566:	78 0e                	js     801576 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801568:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80156b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80156e:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801571:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801576:	c9                   	leave  
  801577:	c3                   	ret    

00801578 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801578:	55                   	push   %ebp
  801579:	89 e5                	mov    %esp,%ebp
  80157b:	53                   	push   %ebx
  80157c:	83 ec 14             	sub    $0x14,%esp
  80157f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801582:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801585:	50                   	push   %eax
  801586:	53                   	push   %ebx
  801587:	e8 f7 fb ff ff       	call   801183 <fd_lookup>
  80158c:	83 c4 08             	add    $0x8,%esp
  80158f:	89 c2                	mov    %eax,%edx
  801591:	85 c0                	test   %eax,%eax
  801593:	78 65                	js     8015fa <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801595:	83 ec 08             	sub    $0x8,%esp
  801598:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80159b:	50                   	push   %eax
  80159c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80159f:	ff 30                	pushl  (%eax)
  8015a1:	e8 33 fc ff ff       	call   8011d9 <dev_lookup>
  8015a6:	83 c4 10             	add    $0x10,%esp
  8015a9:	85 c0                	test   %eax,%eax
  8015ab:	78 44                	js     8015f1 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8015ad:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015b0:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8015b4:	75 21                	jne    8015d7 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8015b6:	a1 0c 40 80 00       	mov    0x80400c,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8015bb:	8b 40 48             	mov    0x48(%eax),%eax
  8015be:	83 ec 04             	sub    $0x4,%esp
  8015c1:	53                   	push   %ebx
  8015c2:	50                   	push   %eax
  8015c3:	68 58 2a 80 00       	push   $0x802a58
  8015c8:	e8 24 ec ff ff       	call   8001f1 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8015cd:	83 c4 10             	add    $0x10,%esp
  8015d0:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8015d5:	eb 23                	jmp    8015fa <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8015d7:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015da:	8b 52 18             	mov    0x18(%edx),%edx
  8015dd:	85 d2                	test   %edx,%edx
  8015df:	74 14                	je     8015f5 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8015e1:	83 ec 08             	sub    $0x8,%esp
  8015e4:	ff 75 0c             	pushl  0xc(%ebp)
  8015e7:	50                   	push   %eax
  8015e8:	ff d2                	call   *%edx
  8015ea:	89 c2                	mov    %eax,%edx
  8015ec:	83 c4 10             	add    $0x10,%esp
  8015ef:	eb 09                	jmp    8015fa <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015f1:	89 c2                	mov    %eax,%edx
  8015f3:	eb 05                	jmp    8015fa <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8015f5:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8015fa:	89 d0                	mov    %edx,%eax
  8015fc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015ff:	c9                   	leave  
  801600:	c3                   	ret    

00801601 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801601:	55                   	push   %ebp
  801602:	89 e5                	mov    %esp,%ebp
  801604:	53                   	push   %ebx
  801605:	83 ec 14             	sub    $0x14,%esp
  801608:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80160b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80160e:	50                   	push   %eax
  80160f:	ff 75 08             	pushl  0x8(%ebp)
  801612:	e8 6c fb ff ff       	call   801183 <fd_lookup>
  801617:	83 c4 08             	add    $0x8,%esp
  80161a:	89 c2                	mov    %eax,%edx
  80161c:	85 c0                	test   %eax,%eax
  80161e:	78 58                	js     801678 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801620:	83 ec 08             	sub    $0x8,%esp
  801623:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801626:	50                   	push   %eax
  801627:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80162a:	ff 30                	pushl  (%eax)
  80162c:	e8 a8 fb ff ff       	call   8011d9 <dev_lookup>
  801631:	83 c4 10             	add    $0x10,%esp
  801634:	85 c0                	test   %eax,%eax
  801636:	78 37                	js     80166f <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801638:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80163b:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80163f:	74 32                	je     801673 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801641:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801644:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80164b:	00 00 00 
	stat->st_isdir = 0;
  80164e:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801655:	00 00 00 
	stat->st_dev = dev;
  801658:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80165e:	83 ec 08             	sub    $0x8,%esp
  801661:	53                   	push   %ebx
  801662:	ff 75 f0             	pushl  -0x10(%ebp)
  801665:	ff 50 14             	call   *0x14(%eax)
  801668:	89 c2                	mov    %eax,%edx
  80166a:	83 c4 10             	add    $0x10,%esp
  80166d:	eb 09                	jmp    801678 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80166f:	89 c2                	mov    %eax,%edx
  801671:	eb 05                	jmp    801678 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801673:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801678:	89 d0                	mov    %edx,%eax
  80167a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80167d:	c9                   	leave  
  80167e:	c3                   	ret    

0080167f <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80167f:	55                   	push   %ebp
  801680:	89 e5                	mov    %esp,%ebp
  801682:	56                   	push   %esi
  801683:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801684:	83 ec 08             	sub    $0x8,%esp
  801687:	6a 00                	push   $0x0
  801689:	ff 75 08             	pushl  0x8(%ebp)
  80168c:	e8 d6 01 00 00       	call   801867 <open>
  801691:	89 c3                	mov    %eax,%ebx
  801693:	83 c4 10             	add    $0x10,%esp
  801696:	85 c0                	test   %eax,%eax
  801698:	78 1b                	js     8016b5 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80169a:	83 ec 08             	sub    $0x8,%esp
  80169d:	ff 75 0c             	pushl  0xc(%ebp)
  8016a0:	50                   	push   %eax
  8016a1:	e8 5b ff ff ff       	call   801601 <fstat>
  8016a6:	89 c6                	mov    %eax,%esi
	close(fd);
  8016a8:	89 1c 24             	mov    %ebx,(%esp)
  8016ab:	e8 fd fb ff ff       	call   8012ad <close>
	return r;
  8016b0:	83 c4 10             	add    $0x10,%esp
  8016b3:	89 f0                	mov    %esi,%eax
}
  8016b5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016b8:	5b                   	pop    %ebx
  8016b9:	5e                   	pop    %esi
  8016ba:	5d                   	pop    %ebp
  8016bb:	c3                   	ret    

008016bc <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8016bc:	55                   	push   %ebp
  8016bd:	89 e5                	mov    %esp,%ebp
  8016bf:	56                   	push   %esi
  8016c0:	53                   	push   %ebx
  8016c1:	89 c6                	mov    %eax,%esi
  8016c3:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8016c5:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8016cc:	75 12                	jne    8016e0 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8016ce:	83 ec 0c             	sub    $0xc,%esp
  8016d1:	6a 01                	push   $0x1
  8016d3:	e8 fc f9 ff ff       	call   8010d4 <ipc_find_env>
  8016d8:	a3 00 40 80 00       	mov    %eax,0x804000
  8016dd:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8016e0:	6a 07                	push   $0x7
  8016e2:	68 00 50 80 00       	push   $0x805000
  8016e7:	56                   	push   %esi
  8016e8:	ff 35 00 40 80 00    	pushl  0x804000
  8016ee:	e8 8d f9 ff ff       	call   801080 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8016f3:	83 c4 0c             	add    $0xc,%esp
  8016f6:	6a 00                	push   $0x0
  8016f8:	53                   	push   %ebx
  8016f9:	6a 00                	push   $0x0
  8016fb:	e8 19 f9 ff ff       	call   801019 <ipc_recv>
}
  801700:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801703:	5b                   	pop    %ebx
  801704:	5e                   	pop    %esi
  801705:	5d                   	pop    %ebp
  801706:	c3                   	ret    

00801707 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801707:	55                   	push   %ebp
  801708:	89 e5                	mov    %esp,%ebp
  80170a:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80170d:	8b 45 08             	mov    0x8(%ebp),%eax
  801710:	8b 40 0c             	mov    0xc(%eax),%eax
  801713:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801718:	8b 45 0c             	mov    0xc(%ebp),%eax
  80171b:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801720:	ba 00 00 00 00       	mov    $0x0,%edx
  801725:	b8 02 00 00 00       	mov    $0x2,%eax
  80172a:	e8 8d ff ff ff       	call   8016bc <fsipc>
}
  80172f:	c9                   	leave  
  801730:	c3                   	ret    

00801731 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801731:	55                   	push   %ebp
  801732:	89 e5                	mov    %esp,%ebp
  801734:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801737:	8b 45 08             	mov    0x8(%ebp),%eax
  80173a:	8b 40 0c             	mov    0xc(%eax),%eax
  80173d:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801742:	ba 00 00 00 00       	mov    $0x0,%edx
  801747:	b8 06 00 00 00       	mov    $0x6,%eax
  80174c:	e8 6b ff ff ff       	call   8016bc <fsipc>
}
  801751:	c9                   	leave  
  801752:	c3                   	ret    

00801753 <devfile_stat>:

}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801753:	55                   	push   %ebp
  801754:	89 e5                	mov    %esp,%ebp
  801756:	53                   	push   %ebx
  801757:	83 ec 04             	sub    $0x4,%esp
  80175a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80175d:	8b 45 08             	mov    0x8(%ebp),%eax
  801760:	8b 40 0c             	mov    0xc(%eax),%eax
  801763:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801768:	ba 00 00 00 00       	mov    $0x0,%edx
  80176d:	b8 05 00 00 00       	mov    $0x5,%eax
  801772:	e8 45 ff ff ff       	call   8016bc <fsipc>
  801777:	85 c0                	test   %eax,%eax
  801779:	78 2c                	js     8017a7 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80177b:	83 ec 08             	sub    $0x8,%esp
  80177e:	68 00 50 80 00       	push   $0x805000
  801783:	53                   	push   %ebx
  801784:	e8 ed ef ff ff       	call   800776 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801789:	a1 80 50 80 00       	mov    0x805080,%eax
  80178e:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801794:	a1 84 50 80 00       	mov    0x805084,%eax
  801799:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80179f:	83 c4 10             	add    $0x10,%esp
  8017a2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017a7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017aa:	c9                   	leave  
  8017ab:	c3                   	ret    

008017ac <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8017ac:	55                   	push   %ebp
  8017ad:	89 e5                	mov    %esp,%ebp
  8017af:	83 ec 0c             	sub    $0xc,%esp
  8017b2:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	// panic("devfile_write not implemented");

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8017b5:	8b 55 08             	mov    0x8(%ebp),%edx
  8017b8:	8b 52 0c             	mov    0xc(%edx),%edx
  8017bb:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  8017c1:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  8017c6:	50                   	push   %eax
  8017c7:	ff 75 0c             	pushl  0xc(%ebp)
  8017ca:	68 08 50 80 00       	push   $0x805008
  8017cf:	e8 34 f1 ff ff       	call   800908 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  8017d4:	ba 00 00 00 00       	mov    $0x0,%edx
  8017d9:	b8 04 00 00 00       	mov    $0x4,%eax
  8017de:	e8 d9 fe ff ff       	call   8016bc <fsipc>

}
  8017e3:	c9                   	leave  
  8017e4:	c3                   	ret    

008017e5 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8017e5:	55                   	push   %ebp
  8017e6:	89 e5                	mov    %esp,%ebp
  8017e8:	56                   	push   %esi
  8017e9:	53                   	push   %ebx
  8017ea:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8017ed:	8b 45 08             	mov    0x8(%ebp),%eax
  8017f0:	8b 40 0c             	mov    0xc(%eax),%eax
  8017f3:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8017f8:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8017fe:	ba 00 00 00 00       	mov    $0x0,%edx
  801803:	b8 03 00 00 00       	mov    $0x3,%eax
  801808:	e8 af fe ff ff       	call   8016bc <fsipc>
  80180d:	89 c3                	mov    %eax,%ebx
  80180f:	85 c0                	test   %eax,%eax
  801811:	78 4b                	js     80185e <devfile_read+0x79>
		return r;
	assert(r <= n);
  801813:	39 c6                	cmp    %eax,%esi
  801815:	73 16                	jae    80182d <devfile_read+0x48>
  801817:	68 c8 2a 80 00       	push   $0x802ac8
  80181c:	68 cf 2a 80 00       	push   $0x802acf
  801821:	6a 7c                	push   $0x7c
  801823:	68 e4 2a 80 00       	push   $0x802ae4
  801828:	e8 24 0a 00 00       	call   802251 <_panic>
	assert(r <= PGSIZE);
  80182d:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801832:	7e 16                	jle    80184a <devfile_read+0x65>
  801834:	68 ef 2a 80 00       	push   $0x802aef
  801839:	68 cf 2a 80 00       	push   $0x802acf
  80183e:	6a 7d                	push   $0x7d
  801840:	68 e4 2a 80 00       	push   $0x802ae4
  801845:	e8 07 0a 00 00       	call   802251 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80184a:	83 ec 04             	sub    $0x4,%esp
  80184d:	50                   	push   %eax
  80184e:	68 00 50 80 00       	push   $0x805000
  801853:	ff 75 0c             	pushl  0xc(%ebp)
  801856:	e8 ad f0 ff ff       	call   800908 <memmove>
	return r;
  80185b:	83 c4 10             	add    $0x10,%esp
}
  80185e:	89 d8                	mov    %ebx,%eax
  801860:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801863:	5b                   	pop    %ebx
  801864:	5e                   	pop    %esi
  801865:	5d                   	pop    %ebp
  801866:	c3                   	ret    

00801867 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801867:	55                   	push   %ebp
  801868:	89 e5                	mov    %esp,%ebp
  80186a:	53                   	push   %ebx
  80186b:	83 ec 20             	sub    $0x20,%esp
  80186e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801871:	53                   	push   %ebx
  801872:	e8 c6 ee ff ff       	call   80073d <strlen>
  801877:	83 c4 10             	add    $0x10,%esp
  80187a:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80187f:	7f 67                	jg     8018e8 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801881:	83 ec 0c             	sub    $0xc,%esp
  801884:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801887:	50                   	push   %eax
  801888:	e8 a7 f8 ff ff       	call   801134 <fd_alloc>
  80188d:	83 c4 10             	add    $0x10,%esp
		return r;
  801890:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801892:	85 c0                	test   %eax,%eax
  801894:	78 57                	js     8018ed <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801896:	83 ec 08             	sub    $0x8,%esp
  801899:	53                   	push   %ebx
  80189a:	68 00 50 80 00       	push   $0x805000
  80189f:	e8 d2 ee ff ff       	call   800776 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8018a4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018a7:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8018ac:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8018af:	b8 01 00 00 00       	mov    $0x1,%eax
  8018b4:	e8 03 fe ff ff       	call   8016bc <fsipc>
  8018b9:	89 c3                	mov    %eax,%ebx
  8018bb:	83 c4 10             	add    $0x10,%esp
  8018be:	85 c0                	test   %eax,%eax
  8018c0:	79 14                	jns    8018d6 <open+0x6f>
		fd_close(fd, 0);
  8018c2:	83 ec 08             	sub    $0x8,%esp
  8018c5:	6a 00                	push   $0x0
  8018c7:	ff 75 f4             	pushl  -0xc(%ebp)
  8018ca:	e8 5d f9 ff ff       	call   80122c <fd_close>
		return r;
  8018cf:	83 c4 10             	add    $0x10,%esp
  8018d2:	89 da                	mov    %ebx,%edx
  8018d4:	eb 17                	jmp    8018ed <open+0x86>
	}

	return fd2num(fd);
  8018d6:	83 ec 0c             	sub    $0xc,%esp
  8018d9:	ff 75 f4             	pushl  -0xc(%ebp)
  8018dc:	e8 2c f8 ff ff       	call   80110d <fd2num>
  8018e1:	89 c2                	mov    %eax,%edx
  8018e3:	83 c4 10             	add    $0x10,%esp
  8018e6:	eb 05                	jmp    8018ed <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8018e8:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8018ed:	89 d0                	mov    %edx,%eax
  8018ef:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018f2:	c9                   	leave  
  8018f3:	c3                   	ret    

008018f4 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8018f4:	55                   	push   %ebp
  8018f5:	89 e5                	mov    %esp,%ebp
  8018f7:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8018fa:	ba 00 00 00 00       	mov    $0x0,%edx
  8018ff:	b8 08 00 00 00       	mov    $0x8,%eax
  801904:	e8 b3 fd ff ff       	call   8016bc <fsipc>
}
  801909:	c9                   	leave  
  80190a:	c3                   	ret    

0080190b <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  80190b:	55                   	push   %ebp
  80190c:	89 e5                	mov    %esp,%ebp
  80190e:	56                   	push   %esi
  80190f:	53                   	push   %ebx
  801910:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801913:	83 ec 0c             	sub    $0xc,%esp
  801916:	ff 75 08             	pushl  0x8(%ebp)
  801919:	e8 ff f7 ff ff       	call   80111d <fd2data>
  80191e:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801920:	83 c4 08             	add    $0x8,%esp
  801923:	68 fb 2a 80 00       	push   $0x802afb
  801928:	53                   	push   %ebx
  801929:	e8 48 ee ff ff       	call   800776 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  80192e:	8b 46 04             	mov    0x4(%esi),%eax
  801931:	2b 06                	sub    (%esi),%eax
  801933:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801939:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801940:	00 00 00 
	stat->st_dev = &devpipe;
  801943:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  80194a:	30 80 00 
	return 0;
}
  80194d:	b8 00 00 00 00       	mov    $0x0,%eax
  801952:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801955:	5b                   	pop    %ebx
  801956:	5e                   	pop    %esi
  801957:	5d                   	pop    %ebp
  801958:	c3                   	ret    

00801959 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801959:	55                   	push   %ebp
  80195a:	89 e5                	mov    %esp,%ebp
  80195c:	53                   	push   %ebx
  80195d:	83 ec 0c             	sub    $0xc,%esp
  801960:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801963:	53                   	push   %ebx
  801964:	6a 00                	push   $0x0
  801966:	e8 93 f2 ff ff       	call   800bfe <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  80196b:	89 1c 24             	mov    %ebx,(%esp)
  80196e:	e8 aa f7 ff ff       	call   80111d <fd2data>
  801973:	83 c4 08             	add    $0x8,%esp
  801976:	50                   	push   %eax
  801977:	6a 00                	push   $0x0
  801979:	e8 80 f2 ff ff       	call   800bfe <sys_page_unmap>
}
  80197e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801981:	c9                   	leave  
  801982:	c3                   	ret    

00801983 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801983:	55                   	push   %ebp
  801984:	89 e5                	mov    %esp,%ebp
  801986:	57                   	push   %edi
  801987:	56                   	push   %esi
  801988:	53                   	push   %ebx
  801989:	83 ec 1c             	sub    $0x1c,%esp
  80198c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80198f:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801991:	a1 0c 40 80 00       	mov    0x80400c,%eax
  801996:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801999:	83 ec 0c             	sub    $0xc,%esp
  80199c:	ff 75 e0             	pushl  -0x20(%ebp)
  80199f:	e8 5e 09 00 00       	call   802302 <pageref>
  8019a4:	89 c3                	mov    %eax,%ebx
  8019a6:	89 3c 24             	mov    %edi,(%esp)
  8019a9:	e8 54 09 00 00       	call   802302 <pageref>
  8019ae:	83 c4 10             	add    $0x10,%esp
  8019b1:	39 c3                	cmp    %eax,%ebx
  8019b3:	0f 94 c1             	sete   %cl
  8019b6:	0f b6 c9             	movzbl %cl,%ecx
  8019b9:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  8019bc:	8b 15 0c 40 80 00    	mov    0x80400c,%edx
  8019c2:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8019c5:	39 ce                	cmp    %ecx,%esi
  8019c7:	74 1b                	je     8019e4 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  8019c9:	39 c3                	cmp    %eax,%ebx
  8019cb:	75 c4                	jne    801991 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8019cd:	8b 42 58             	mov    0x58(%edx),%eax
  8019d0:	ff 75 e4             	pushl  -0x1c(%ebp)
  8019d3:	50                   	push   %eax
  8019d4:	56                   	push   %esi
  8019d5:	68 02 2b 80 00       	push   $0x802b02
  8019da:	e8 12 e8 ff ff       	call   8001f1 <cprintf>
  8019df:	83 c4 10             	add    $0x10,%esp
  8019e2:	eb ad                	jmp    801991 <_pipeisclosed+0xe>
	}
}
  8019e4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8019e7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8019ea:	5b                   	pop    %ebx
  8019eb:	5e                   	pop    %esi
  8019ec:	5f                   	pop    %edi
  8019ed:	5d                   	pop    %ebp
  8019ee:	c3                   	ret    

008019ef <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8019ef:	55                   	push   %ebp
  8019f0:	89 e5                	mov    %esp,%ebp
  8019f2:	57                   	push   %edi
  8019f3:	56                   	push   %esi
  8019f4:	53                   	push   %ebx
  8019f5:	83 ec 28             	sub    $0x28,%esp
  8019f8:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8019fb:	56                   	push   %esi
  8019fc:	e8 1c f7 ff ff       	call   80111d <fd2data>
  801a01:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a03:	83 c4 10             	add    $0x10,%esp
  801a06:	bf 00 00 00 00       	mov    $0x0,%edi
  801a0b:	eb 4b                	jmp    801a58 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801a0d:	89 da                	mov    %ebx,%edx
  801a0f:	89 f0                	mov    %esi,%eax
  801a11:	e8 6d ff ff ff       	call   801983 <_pipeisclosed>
  801a16:	85 c0                	test   %eax,%eax
  801a18:	75 48                	jne    801a62 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801a1a:	e8 3b f1 ff ff       	call   800b5a <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801a1f:	8b 43 04             	mov    0x4(%ebx),%eax
  801a22:	8b 0b                	mov    (%ebx),%ecx
  801a24:	8d 51 20             	lea    0x20(%ecx),%edx
  801a27:	39 d0                	cmp    %edx,%eax
  801a29:	73 e2                	jae    801a0d <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801a2b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a2e:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801a32:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801a35:	89 c2                	mov    %eax,%edx
  801a37:	c1 fa 1f             	sar    $0x1f,%edx
  801a3a:	89 d1                	mov    %edx,%ecx
  801a3c:	c1 e9 1b             	shr    $0x1b,%ecx
  801a3f:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801a42:	83 e2 1f             	and    $0x1f,%edx
  801a45:	29 ca                	sub    %ecx,%edx
  801a47:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801a4b:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801a4f:	83 c0 01             	add    $0x1,%eax
  801a52:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a55:	83 c7 01             	add    $0x1,%edi
  801a58:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801a5b:	75 c2                	jne    801a1f <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801a5d:	8b 45 10             	mov    0x10(%ebp),%eax
  801a60:	eb 05                	jmp    801a67 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801a62:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801a67:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a6a:	5b                   	pop    %ebx
  801a6b:	5e                   	pop    %esi
  801a6c:	5f                   	pop    %edi
  801a6d:	5d                   	pop    %ebp
  801a6e:	c3                   	ret    

00801a6f <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801a6f:	55                   	push   %ebp
  801a70:	89 e5                	mov    %esp,%ebp
  801a72:	57                   	push   %edi
  801a73:	56                   	push   %esi
  801a74:	53                   	push   %ebx
  801a75:	83 ec 18             	sub    $0x18,%esp
  801a78:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801a7b:	57                   	push   %edi
  801a7c:	e8 9c f6 ff ff       	call   80111d <fd2data>
  801a81:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a83:	83 c4 10             	add    $0x10,%esp
  801a86:	bb 00 00 00 00       	mov    $0x0,%ebx
  801a8b:	eb 3d                	jmp    801aca <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801a8d:	85 db                	test   %ebx,%ebx
  801a8f:	74 04                	je     801a95 <devpipe_read+0x26>
				return i;
  801a91:	89 d8                	mov    %ebx,%eax
  801a93:	eb 44                	jmp    801ad9 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801a95:	89 f2                	mov    %esi,%edx
  801a97:	89 f8                	mov    %edi,%eax
  801a99:	e8 e5 fe ff ff       	call   801983 <_pipeisclosed>
  801a9e:	85 c0                	test   %eax,%eax
  801aa0:	75 32                	jne    801ad4 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801aa2:	e8 b3 f0 ff ff       	call   800b5a <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801aa7:	8b 06                	mov    (%esi),%eax
  801aa9:	3b 46 04             	cmp    0x4(%esi),%eax
  801aac:	74 df                	je     801a8d <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801aae:	99                   	cltd   
  801aaf:	c1 ea 1b             	shr    $0x1b,%edx
  801ab2:	01 d0                	add    %edx,%eax
  801ab4:	83 e0 1f             	and    $0x1f,%eax
  801ab7:	29 d0                	sub    %edx,%eax
  801ab9:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801abe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801ac1:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801ac4:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ac7:	83 c3 01             	add    $0x1,%ebx
  801aca:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801acd:	75 d8                	jne    801aa7 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801acf:	8b 45 10             	mov    0x10(%ebp),%eax
  801ad2:	eb 05                	jmp    801ad9 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801ad4:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801ad9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801adc:	5b                   	pop    %ebx
  801add:	5e                   	pop    %esi
  801ade:	5f                   	pop    %edi
  801adf:	5d                   	pop    %ebp
  801ae0:	c3                   	ret    

00801ae1 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801ae1:	55                   	push   %ebp
  801ae2:	89 e5                	mov    %esp,%ebp
  801ae4:	56                   	push   %esi
  801ae5:	53                   	push   %ebx
  801ae6:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801ae9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801aec:	50                   	push   %eax
  801aed:	e8 42 f6 ff ff       	call   801134 <fd_alloc>
  801af2:	83 c4 10             	add    $0x10,%esp
  801af5:	89 c2                	mov    %eax,%edx
  801af7:	85 c0                	test   %eax,%eax
  801af9:	0f 88 2c 01 00 00    	js     801c2b <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801aff:	83 ec 04             	sub    $0x4,%esp
  801b02:	68 07 04 00 00       	push   $0x407
  801b07:	ff 75 f4             	pushl  -0xc(%ebp)
  801b0a:	6a 00                	push   $0x0
  801b0c:	e8 68 f0 ff ff       	call   800b79 <sys_page_alloc>
  801b11:	83 c4 10             	add    $0x10,%esp
  801b14:	89 c2                	mov    %eax,%edx
  801b16:	85 c0                	test   %eax,%eax
  801b18:	0f 88 0d 01 00 00    	js     801c2b <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801b1e:	83 ec 0c             	sub    $0xc,%esp
  801b21:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801b24:	50                   	push   %eax
  801b25:	e8 0a f6 ff ff       	call   801134 <fd_alloc>
  801b2a:	89 c3                	mov    %eax,%ebx
  801b2c:	83 c4 10             	add    $0x10,%esp
  801b2f:	85 c0                	test   %eax,%eax
  801b31:	0f 88 e2 00 00 00    	js     801c19 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b37:	83 ec 04             	sub    $0x4,%esp
  801b3a:	68 07 04 00 00       	push   $0x407
  801b3f:	ff 75 f0             	pushl  -0x10(%ebp)
  801b42:	6a 00                	push   $0x0
  801b44:	e8 30 f0 ff ff       	call   800b79 <sys_page_alloc>
  801b49:	89 c3                	mov    %eax,%ebx
  801b4b:	83 c4 10             	add    $0x10,%esp
  801b4e:	85 c0                	test   %eax,%eax
  801b50:	0f 88 c3 00 00 00    	js     801c19 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801b56:	83 ec 0c             	sub    $0xc,%esp
  801b59:	ff 75 f4             	pushl  -0xc(%ebp)
  801b5c:	e8 bc f5 ff ff       	call   80111d <fd2data>
  801b61:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b63:	83 c4 0c             	add    $0xc,%esp
  801b66:	68 07 04 00 00       	push   $0x407
  801b6b:	50                   	push   %eax
  801b6c:	6a 00                	push   $0x0
  801b6e:	e8 06 f0 ff ff       	call   800b79 <sys_page_alloc>
  801b73:	89 c3                	mov    %eax,%ebx
  801b75:	83 c4 10             	add    $0x10,%esp
  801b78:	85 c0                	test   %eax,%eax
  801b7a:	0f 88 89 00 00 00    	js     801c09 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b80:	83 ec 0c             	sub    $0xc,%esp
  801b83:	ff 75 f0             	pushl  -0x10(%ebp)
  801b86:	e8 92 f5 ff ff       	call   80111d <fd2data>
  801b8b:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801b92:	50                   	push   %eax
  801b93:	6a 00                	push   $0x0
  801b95:	56                   	push   %esi
  801b96:	6a 00                	push   $0x0
  801b98:	e8 1f f0 ff ff       	call   800bbc <sys_page_map>
  801b9d:	89 c3                	mov    %eax,%ebx
  801b9f:	83 c4 20             	add    $0x20,%esp
  801ba2:	85 c0                	test   %eax,%eax
  801ba4:	78 55                	js     801bfb <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801ba6:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801bac:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801baf:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801bb1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bb4:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801bbb:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801bc1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801bc4:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801bc6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801bc9:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801bd0:	83 ec 0c             	sub    $0xc,%esp
  801bd3:	ff 75 f4             	pushl  -0xc(%ebp)
  801bd6:	e8 32 f5 ff ff       	call   80110d <fd2num>
  801bdb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801bde:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801be0:	83 c4 04             	add    $0x4,%esp
  801be3:	ff 75 f0             	pushl  -0x10(%ebp)
  801be6:	e8 22 f5 ff ff       	call   80110d <fd2num>
  801beb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801bee:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801bf1:	83 c4 10             	add    $0x10,%esp
  801bf4:	ba 00 00 00 00       	mov    $0x0,%edx
  801bf9:	eb 30                	jmp    801c2b <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801bfb:	83 ec 08             	sub    $0x8,%esp
  801bfe:	56                   	push   %esi
  801bff:	6a 00                	push   $0x0
  801c01:	e8 f8 ef ff ff       	call   800bfe <sys_page_unmap>
  801c06:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801c09:	83 ec 08             	sub    $0x8,%esp
  801c0c:	ff 75 f0             	pushl  -0x10(%ebp)
  801c0f:	6a 00                	push   $0x0
  801c11:	e8 e8 ef ff ff       	call   800bfe <sys_page_unmap>
  801c16:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801c19:	83 ec 08             	sub    $0x8,%esp
  801c1c:	ff 75 f4             	pushl  -0xc(%ebp)
  801c1f:	6a 00                	push   $0x0
  801c21:	e8 d8 ef ff ff       	call   800bfe <sys_page_unmap>
  801c26:	83 c4 10             	add    $0x10,%esp
  801c29:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801c2b:	89 d0                	mov    %edx,%eax
  801c2d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c30:	5b                   	pop    %ebx
  801c31:	5e                   	pop    %esi
  801c32:	5d                   	pop    %ebp
  801c33:	c3                   	ret    

00801c34 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801c34:	55                   	push   %ebp
  801c35:	89 e5                	mov    %esp,%ebp
  801c37:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801c3a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c3d:	50                   	push   %eax
  801c3e:	ff 75 08             	pushl  0x8(%ebp)
  801c41:	e8 3d f5 ff ff       	call   801183 <fd_lookup>
  801c46:	83 c4 10             	add    $0x10,%esp
  801c49:	85 c0                	test   %eax,%eax
  801c4b:	78 18                	js     801c65 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801c4d:	83 ec 0c             	sub    $0xc,%esp
  801c50:	ff 75 f4             	pushl  -0xc(%ebp)
  801c53:	e8 c5 f4 ff ff       	call   80111d <fd2data>
	return _pipeisclosed(fd, p);
  801c58:	89 c2                	mov    %eax,%edx
  801c5a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c5d:	e8 21 fd ff ff       	call   801983 <_pipeisclosed>
  801c62:	83 c4 10             	add    $0x10,%esp
}
  801c65:	c9                   	leave  
  801c66:	c3                   	ret    

00801c67 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801c67:	55                   	push   %ebp
  801c68:	89 e5                	mov    %esp,%ebp
  801c6a:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  801c6d:	68 1a 2b 80 00       	push   $0x802b1a
  801c72:	ff 75 0c             	pushl  0xc(%ebp)
  801c75:	e8 fc ea ff ff       	call   800776 <strcpy>
	return 0;
}
  801c7a:	b8 00 00 00 00       	mov    $0x0,%eax
  801c7f:	c9                   	leave  
  801c80:	c3                   	ret    

00801c81 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801c81:	55                   	push   %ebp
  801c82:	89 e5                	mov    %esp,%ebp
  801c84:	53                   	push   %ebx
  801c85:	83 ec 10             	sub    $0x10,%esp
  801c88:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801c8b:	53                   	push   %ebx
  801c8c:	e8 71 06 00 00       	call   802302 <pageref>
  801c91:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  801c94:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  801c99:	83 f8 01             	cmp    $0x1,%eax
  801c9c:	75 10                	jne    801cae <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  801c9e:	83 ec 0c             	sub    $0xc,%esp
  801ca1:	ff 73 0c             	pushl  0xc(%ebx)
  801ca4:	e8 c0 02 00 00       	call   801f69 <nsipc_close>
  801ca9:	89 c2                	mov    %eax,%edx
  801cab:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  801cae:	89 d0                	mov    %edx,%eax
  801cb0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801cb3:	c9                   	leave  
  801cb4:	c3                   	ret    

00801cb5 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801cb5:	55                   	push   %ebp
  801cb6:	89 e5                	mov    %esp,%ebp
  801cb8:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801cbb:	6a 00                	push   $0x0
  801cbd:	ff 75 10             	pushl  0x10(%ebp)
  801cc0:	ff 75 0c             	pushl  0xc(%ebp)
  801cc3:	8b 45 08             	mov    0x8(%ebp),%eax
  801cc6:	ff 70 0c             	pushl  0xc(%eax)
  801cc9:	e8 78 03 00 00       	call   802046 <nsipc_send>
}
  801cce:	c9                   	leave  
  801ccf:	c3                   	ret    

00801cd0 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801cd0:	55                   	push   %ebp
  801cd1:	89 e5                	mov    %esp,%ebp
  801cd3:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801cd6:	6a 00                	push   $0x0
  801cd8:	ff 75 10             	pushl  0x10(%ebp)
  801cdb:	ff 75 0c             	pushl  0xc(%ebp)
  801cde:	8b 45 08             	mov    0x8(%ebp),%eax
  801ce1:	ff 70 0c             	pushl  0xc(%eax)
  801ce4:	e8 f1 02 00 00       	call   801fda <nsipc_recv>
}
  801ce9:	c9                   	leave  
  801cea:	c3                   	ret    

00801ceb <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801ceb:	55                   	push   %ebp
  801cec:	89 e5                	mov    %esp,%ebp
  801cee:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801cf1:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801cf4:	52                   	push   %edx
  801cf5:	50                   	push   %eax
  801cf6:	e8 88 f4 ff ff       	call   801183 <fd_lookup>
  801cfb:	83 c4 10             	add    $0x10,%esp
  801cfe:	85 c0                	test   %eax,%eax
  801d00:	78 17                	js     801d19 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801d02:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d05:	8b 0d 3c 30 80 00    	mov    0x80303c,%ecx
  801d0b:	39 08                	cmp    %ecx,(%eax)
  801d0d:	75 05                	jne    801d14 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801d0f:	8b 40 0c             	mov    0xc(%eax),%eax
  801d12:	eb 05                	jmp    801d19 <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801d14:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801d19:	c9                   	leave  
  801d1a:	c3                   	ret    

00801d1b <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  801d1b:	55                   	push   %ebp
  801d1c:	89 e5                	mov    %esp,%ebp
  801d1e:	56                   	push   %esi
  801d1f:	53                   	push   %ebx
  801d20:	83 ec 1c             	sub    $0x1c,%esp
  801d23:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801d25:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d28:	50                   	push   %eax
  801d29:	e8 06 f4 ff ff       	call   801134 <fd_alloc>
  801d2e:	89 c3                	mov    %eax,%ebx
  801d30:	83 c4 10             	add    $0x10,%esp
  801d33:	85 c0                	test   %eax,%eax
  801d35:	78 1b                	js     801d52 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801d37:	83 ec 04             	sub    $0x4,%esp
  801d3a:	68 07 04 00 00       	push   $0x407
  801d3f:	ff 75 f4             	pushl  -0xc(%ebp)
  801d42:	6a 00                	push   $0x0
  801d44:	e8 30 ee ff ff       	call   800b79 <sys_page_alloc>
  801d49:	89 c3                	mov    %eax,%ebx
  801d4b:	83 c4 10             	add    $0x10,%esp
  801d4e:	85 c0                	test   %eax,%eax
  801d50:	79 10                	jns    801d62 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  801d52:	83 ec 0c             	sub    $0xc,%esp
  801d55:	56                   	push   %esi
  801d56:	e8 0e 02 00 00       	call   801f69 <nsipc_close>
		return r;
  801d5b:	83 c4 10             	add    $0x10,%esp
  801d5e:	89 d8                	mov    %ebx,%eax
  801d60:	eb 24                	jmp    801d86 <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801d62:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801d68:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d6b:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801d6d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d70:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801d77:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801d7a:	83 ec 0c             	sub    $0xc,%esp
  801d7d:	50                   	push   %eax
  801d7e:	e8 8a f3 ff ff       	call   80110d <fd2num>
  801d83:	83 c4 10             	add    $0x10,%esp
}
  801d86:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d89:	5b                   	pop    %ebx
  801d8a:	5e                   	pop    %esi
  801d8b:	5d                   	pop    %ebp
  801d8c:	c3                   	ret    

00801d8d <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801d8d:	55                   	push   %ebp
  801d8e:	89 e5                	mov    %esp,%ebp
  801d90:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801d93:	8b 45 08             	mov    0x8(%ebp),%eax
  801d96:	e8 50 ff ff ff       	call   801ceb <fd2sockid>
		return r;
  801d9b:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  801d9d:	85 c0                	test   %eax,%eax
  801d9f:	78 1f                	js     801dc0 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801da1:	83 ec 04             	sub    $0x4,%esp
  801da4:	ff 75 10             	pushl  0x10(%ebp)
  801da7:	ff 75 0c             	pushl  0xc(%ebp)
  801daa:	50                   	push   %eax
  801dab:	e8 12 01 00 00       	call   801ec2 <nsipc_accept>
  801db0:	83 c4 10             	add    $0x10,%esp
		return r;
  801db3:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801db5:	85 c0                	test   %eax,%eax
  801db7:	78 07                	js     801dc0 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  801db9:	e8 5d ff ff ff       	call   801d1b <alloc_sockfd>
  801dbe:	89 c1                	mov    %eax,%ecx
}
  801dc0:	89 c8                	mov    %ecx,%eax
  801dc2:	c9                   	leave  
  801dc3:	c3                   	ret    

00801dc4 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801dc4:	55                   	push   %ebp
  801dc5:	89 e5                	mov    %esp,%ebp
  801dc7:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801dca:	8b 45 08             	mov    0x8(%ebp),%eax
  801dcd:	e8 19 ff ff ff       	call   801ceb <fd2sockid>
  801dd2:	85 c0                	test   %eax,%eax
  801dd4:	78 12                	js     801de8 <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  801dd6:	83 ec 04             	sub    $0x4,%esp
  801dd9:	ff 75 10             	pushl  0x10(%ebp)
  801ddc:	ff 75 0c             	pushl  0xc(%ebp)
  801ddf:	50                   	push   %eax
  801de0:	e8 2d 01 00 00       	call   801f12 <nsipc_bind>
  801de5:	83 c4 10             	add    $0x10,%esp
}
  801de8:	c9                   	leave  
  801de9:	c3                   	ret    

00801dea <shutdown>:

int
shutdown(int s, int how)
{
  801dea:	55                   	push   %ebp
  801deb:	89 e5                	mov    %esp,%ebp
  801ded:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801df0:	8b 45 08             	mov    0x8(%ebp),%eax
  801df3:	e8 f3 fe ff ff       	call   801ceb <fd2sockid>
  801df8:	85 c0                	test   %eax,%eax
  801dfa:	78 0f                	js     801e0b <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801dfc:	83 ec 08             	sub    $0x8,%esp
  801dff:	ff 75 0c             	pushl  0xc(%ebp)
  801e02:	50                   	push   %eax
  801e03:	e8 3f 01 00 00       	call   801f47 <nsipc_shutdown>
  801e08:	83 c4 10             	add    $0x10,%esp
}
  801e0b:	c9                   	leave  
  801e0c:	c3                   	ret    

00801e0d <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801e0d:	55                   	push   %ebp
  801e0e:	89 e5                	mov    %esp,%ebp
  801e10:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801e13:	8b 45 08             	mov    0x8(%ebp),%eax
  801e16:	e8 d0 fe ff ff       	call   801ceb <fd2sockid>
  801e1b:	85 c0                	test   %eax,%eax
  801e1d:	78 12                	js     801e31 <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  801e1f:	83 ec 04             	sub    $0x4,%esp
  801e22:	ff 75 10             	pushl  0x10(%ebp)
  801e25:	ff 75 0c             	pushl  0xc(%ebp)
  801e28:	50                   	push   %eax
  801e29:	e8 55 01 00 00       	call   801f83 <nsipc_connect>
  801e2e:	83 c4 10             	add    $0x10,%esp
}
  801e31:	c9                   	leave  
  801e32:	c3                   	ret    

00801e33 <listen>:

int
listen(int s, int backlog)
{
  801e33:	55                   	push   %ebp
  801e34:	89 e5                	mov    %esp,%ebp
  801e36:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801e39:	8b 45 08             	mov    0x8(%ebp),%eax
  801e3c:	e8 aa fe ff ff       	call   801ceb <fd2sockid>
  801e41:	85 c0                	test   %eax,%eax
  801e43:	78 0f                	js     801e54 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801e45:	83 ec 08             	sub    $0x8,%esp
  801e48:	ff 75 0c             	pushl  0xc(%ebp)
  801e4b:	50                   	push   %eax
  801e4c:	e8 67 01 00 00       	call   801fb8 <nsipc_listen>
  801e51:	83 c4 10             	add    $0x10,%esp
}
  801e54:	c9                   	leave  
  801e55:	c3                   	ret    

00801e56 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801e56:	55                   	push   %ebp
  801e57:	89 e5                	mov    %esp,%ebp
  801e59:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801e5c:	ff 75 10             	pushl  0x10(%ebp)
  801e5f:	ff 75 0c             	pushl  0xc(%ebp)
  801e62:	ff 75 08             	pushl  0x8(%ebp)
  801e65:	e8 3a 02 00 00       	call   8020a4 <nsipc_socket>
  801e6a:	83 c4 10             	add    $0x10,%esp
  801e6d:	85 c0                	test   %eax,%eax
  801e6f:	78 05                	js     801e76 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  801e71:	e8 a5 fe ff ff       	call   801d1b <alloc_sockfd>
}
  801e76:	c9                   	leave  
  801e77:	c3                   	ret    

00801e78 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801e78:	55                   	push   %ebp
  801e79:	89 e5                	mov    %esp,%ebp
  801e7b:	53                   	push   %ebx
  801e7c:	83 ec 04             	sub    $0x4,%esp
  801e7f:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801e81:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801e88:	75 12                	jne    801e9c <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801e8a:	83 ec 0c             	sub    $0xc,%esp
  801e8d:	6a 02                	push   $0x2
  801e8f:	e8 40 f2 ff ff       	call   8010d4 <ipc_find_env>
  801e94:	a3 04 40 80 00       	mov    %eax,0x804004
  801e99:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801e9c:	6a 07                	push   $0x7
  801e9e:	68 00 60 80 00       	push   $0x806000
  801ea3:	53                   	push   %ebx
  801ea4:	ff 35 04 40 80 00    	pushl  0x804004
  801eaa:	e8 d1 f1 ff ff       	call   801080 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801eaf:	83 c4 0c             	add    $0xc,%esp
  801eb2:	6a 00                	push   $0x0
  801eb4:	6a 00                	push   $0x0
  801eb6:	6a 00                	push   $0x0
  801eb8:	e8 5c f1 ff ff       	call   801019 <ipc_recv>
}
  801ebd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ec0:	c9                   	leave  
  801ec1:	c3                   	ret    

00801ec2 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801ec2:	55                   	push   %ebp
  801ec3:	89 e5                	mov    %esp,%ebp
  801ec5:	56                   	push   %esi
  801ec6:	53                   	push   %ebx
  801ec7:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801eca:	8b 45 08             	mov    0x8(%ebp),%eax
  801ecd:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801ed2:	8b 06                	mov    (%esi),%eax
  801ed4:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801ed9:	b8 01 00 00 00       	mov    $0x1,%eax
  801ede:	e8 95 ff ff ff       	call   801e78 <nsipc>
  801ee3:	89 c3                	mov    %eax,%ebx
  801ee5:	85 c0                	test   %eax,%eax
  801ee7:	78 20                	js     801f09 <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801ee9:	83 ec 04             	sub    $0x4,%esp
  801eec:	ff 35 10 60 80 00    	pushl  0x806010
  801ef2:	68 00 60 80 00       	push   $0x806000
  801ef7:	ff 75 0c             	pushl  0xc(%ebp)
  801efa:	e8 09 ea ff ff       	call   800908 <memmove>
		*addrlen = ret->ret_addrlen;
  801eff:	a1 10 60 80 00       	mov    0x806010,%eax
  801f04:	89 06                	mov    %eax,(%esi)
  801f06:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  801f09:	89 d8                	mov    %ebx,%eax
  801f0b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f0e:	5b                   	pop    %ebx
  801f0f:	5e                   	pop    %esi
  801f10:	5d                   	pop    %ebp
  801f11:	c3                   	ret    

00801f12 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801f12:	55                   	push   %ebp
  801f13:	89 e5                	mov    %esp,%ebp
  801f15:	53                   	push   %ebx
  801f16:	83 ec 08             	sub    $0x8,%esp
  801f19:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801f1c:	8b 45 08             	mov    0x8(%ebp),%eax
  801f1f:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801f24:	53                   	push   %ebx
  801f25:	ff 75 0c             	pushl  0xc(%ebp)
  801f28:	68 04 60 80 00       	push   $0x806004
  801f2d:	e8 d6 e9 ff ff       	call   800908 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801f32:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801f38:	b8 02 00 00 00       	mov    $0x2,%eax
  801f3d:	e8 36 ff ff ff       	call   801e78 <nsipc>
}
  801f42:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801f45:	c9                   	leave  
  801f46:	c3                   	ret    

00801f47 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801f47:	55                   	push   %ebp
  801f48:	89 e5                	mov    %esp,%ebp
  801f4a:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801f4d:	8b 45 08             	mov    0x8(%ebp),%eax
  801f50:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801f55:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f58:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801f5d:	b8 03 00 00 00       	mov    $0x3,%eax
  801f62:	e8 11 ff ff ff       	call   801e78 <nsipc>
}
  801f67:	c9                   	leave  
  801f68:	c3                   	ret    

00801f69 <nsipc_close>:

int
nsipc_close(int s)
{
  801f69:	55                   	push   %ebp
  801f6a:	89 e5                	mov    %esp,%ebp
  801f6c:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801f6f:	8b 45 08             	mov    0x8(%ebp),%eax
  801f72:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801f77:	b8 04 00 00 00       	mov    $0x4,%eax
  801f7c:	e8 f7 fe ff ff       	call   801e78 <nsipc>
}
  801f81:	c9                   	leave  
  801f82:	c3                   	ret    

00801f83 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801f83:	55                   	push   %ebp
  801f84:	89 e5                	mov    %esp,%ebp
  801f86:	53                   	push   %ebx
  801f87:	83 ec 08             	sub    $0x8,%esp
  801f8a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801f8d:	8b 45 08             	mov    0x8(%ebp),%eax
  801f90:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801f95:	53                   	push   %ebx
  801f96:	ff 75 0c             	pushl  0xc(%ebp)
  801f99:	68 04 60 80 00       	push   $0x806004
  801f9e:	e8 65 e9 ff ff       	call   800908 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801fa3:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801fa9:	b8 05 00 00 00       	mov    $0x5,%eax
  801fae:	e8 c5 fe ff ff       	call   801e78 <nsipc>
}
  801fb3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801fb6:	c9                   	leave  
  801fb7:	c3                   	ret    

00801fb8 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801fb8:	55                   	push   %ebp
  801fb9:	89 e5                	mov    %esp,%ebp
  801fbb:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801fbe:	8b 45 08             	mov    0x8(%ebp),%eax
  801fc1:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801fc6:	8b 45 0c             	mov    0xc(%ebp),%eax
  801fc9:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801fce:	b8 06 00 00 00       	mov    $0x6,%eax
  801fd3:	e8 a0 fe ff ff       	call   801e78 <nsipc>
}
  801fd8:	c9                   	leave  
  801fd9:	c3                   	ret    

00801fda <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801fda:	55                   	push   %ebp
  801fdb:	89 e5                	mov    %esp,%ebp
  801fdd:	56                   	push   %esi
  801fde:	53                   	push   %ebx
  801fdf:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801fe2:	8b 45 08             	mov    0x8(%ebp),%eax
  801fe5:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801fea:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801ff0:	8b 45 14             	mov    0x14(%ebp),%eax
  801ff3:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801ff8:	b8 07 00 00 00       	mov    $0x7,%eax
  801ffd:	e8 76 fe ff ff       	call   801e78 <nsipc>
  802002:	89 c3                	mov    %eax,%ebx
  802004:	85 c0                	test   %eax,%eax
  802006:	78 35                	js     80203d <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  802008:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  80200d:	7f 04                	jg     802013 <nsipc_recv+0x39>
  80200f:	39 c6                	cmp    %eax,%esi
  802011:	7d 16                	jge    802029 <nsipc_recv+0x4f>
  802013:	68 26 2b 80 00       	push   $0x802b26
  802018:	68 cf 2a 80 00       	push   $0x802acf
  80201d:	6a 62                	push   $0x62
  80201f:	68 3b 2b 80 00       	push   $0x802b3b
  802024:	e8 28 02 00 00       	call   802251 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  802029:	83 ec 04             	sub    $0x4,%esp
  80202c:	50                   	push   %eax
  80202d:	68 00 60 80 00       	push   $0x806000
  802032:	ff 75 0c             	pushl  0xc(%ebp)
  802035:	e8 ce e8 ff ff       	call   800908 <memmove>
  80203a:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  80203d:	89 d8                	mov    %ebx,%eax
  80203f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802042:	5b                   	pop    %ebx
  802043:	5e                   	pop    %esi
  802044:	5d                   	pop    %ebp
  802045:	c3                   	ret    

00802046 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  802046:	55                   	push   %ebp
  802047:	89 e5                	mov    %esp,%ebp
  802049:	53                   	push   %ebx
  80204a:	83 ec 04             	sub    $0x4,%esp
  80204d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  802050:	8b 45 08             	mov    0x8(%ebp),%eax
  802053:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  802058:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  80205e:	7e 16                	jle    802076 <nsipc_send+0x30>
  802060:	68 47 2b 80 00       	push   $0x802b47
  802065:	68 cf 2a 80 00       	push   $0x802acf
  80206a:	6a 6d                	push   $0x6d
  80206c:	68 3b 2b 80 00       	push   $0x802b3b
  802071:	e8 db 01 00 00       	call   802251 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  802076:	83 ec 04             	sub    $0x4,%esp
  802079:	53                   	push   %ebx
  80207a:	ff 75 0c             	pushl  0xc(%ebp)
  80207d:	68 0c 60 80 00       	push   $0x80600c
  802082:	e8 81 e8 ff ff       	call   800908 <memmove>
	nsipcbuf.send.req_size = size;
  802087:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  80208d:	8b 45 14             	mov    0x14(%ebp),%eax
  802090:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  802095:	b8 08 00 00 00       	mov    $0x8,%eax
  80209a:	e8 d9 fd ff ff       	call   801e78 <nsipc>
}
  80209f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8020a2:	c9                   	leave  
  8020a3:	c3                   	ret    

008020a4 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  8020a4:	55                   	push   %ebp
  8020a5:	89 e5                	mov    %esp,%ebp
  8020a7:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  8020aa:	8b 45 08             	mov    0x8(%ebp),%eax
  8020ad:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  8020b2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8020b5:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  8020ba:	8b 45 10             	mov    0x10(%ebp),%eax
  8020bd:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  8020c2:	b8 09 00 00 00       	mov    $0x9,%eax
  8020c7:	e8 ac fd ff ff       	call   801e78 <nsipc>
}
  8020cc:	c9                   	leave  
  8020cd:	c3                   	ret    

008020ce <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8020ce:	55                   	push   %ebp
  8020cf:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8020d1:	b8 00 00 00 00       	mov    $0x0,%eax
  8020d6:	5d                   	pop    %ebp
  8020d7:	c3                   	ret    

008020d8 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8020d8:	55                   	push   %ebp
  8020d9:	89 e5                	mov    %esp,%ebp
  8020db:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8020de:	68 53 2b 80 00       	push   $0x802b53
  8020e3:	ff 75 0c             	pushl  0xc(%ebp)
  8020e6:	e8 8b e6 ff ff       	call   800776 <strcpy>
	return 0;
}
  8020eb:	b8 00 00 00 00       	mov    $0x0,%eax
  8020f0:	c9                   	leave  
  8020f1:	c3                   	ret    

008020f2 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8020f2:	55                   	push   %ebp
  8020f3:	89 e5                	mov    %esp,%ebp
  8020f5:	57                   	push   %edi
  8020f6:	56                   	push   %esi
  8020f7:	53                   	push   %ebx
  8020f8:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8020fe:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802103:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802109:	eb 2d                	jmp    802138 <devcons_write+0x46>
		m = n - tot;
  80210b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80210e:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  802110:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  802113:	ba 7f 00 00 00       	mov    $0x7f,%edx
  802118:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80211b:	83 ec 04             	sub    $0x4,%esp
  80211e:	53                   	push   %ebx
  80211f:	03 45 0c             	add    0xc(%ebp),%eax
  802122:	50                   	push   %eax
  802123:	57                   	push   %edi
  802124:	e8 df e7 ff ff       	call   800908 <memmove>
		sys_cputs(buf, m);
  802129:	83 c4 08             	add    $0x8,%esp
  80212c:	53                   	push   %ebx
  80212d:	57                   	push   %edi
  80212e:	e8 8a e9 ff ff       	call   800abd <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802133:	01 de                	add    %ebx,%esi
  802135:	83 c4 10             	add    $0x10,%esp
  802138:	89 f0                	mov    %esi,%eax
  80213a:	3b 75 10             	cmp    0x10(%ebp),%esi
  80213d:	72 cc                	jb     80210b <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  80213f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802142:	5b                   	pop    %ebx
  802143:	5e                   	pop    %esi
  802144:	5f                   	pop    %edi
  802145:	5d                   	pop    %ebp
  802146:	c3                   	ret    

00802147 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  802147:	55                   	push   %ebp
  802148:	89 e5                	mov    %esp,%ebp
  80214a:	83 ec 08             	sub    $0x8,%esp
  80214d:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  802152:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802156:	74 2a                	je     802182 <devcons_read+0x3b>
  802158:	eb 05                	jmp    80215f <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  80215a:	e8 fb e9 ff ff       	call   800b5a <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  80215f:	e8 77 e9 ff ff       	call   800adb <sys_cgetc>
  802164:	85 c0                	test   %eax,%eax
  802166:	74 f2                	je     80215a <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  802168:	85 c0                	test   %eax,%eax
  80216a:	78 16                	js     802182 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  80216c:	83 f8 04             	cmp    $0x4,%eax
  80216f:	74 0c                	je     80217d <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  802171:	8b 55 0c             	mov    0xc(%ebp),%edx
  802174:	88 02                	mov    %al,(%edx)
	return 1;
  802176:	b8 01 00 00 00       	mov    $0x1,%eax
  80217b:	eb 05                	jmp    802182 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  80217d:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  802182:	c9                   	leave  
  802183:	c3                   	ret    

00802184 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  802184:	55                   	push   %ebp
  802185:	89 e5                	mov    %esp,%ebp
  802187:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  80218a:	8b 45 08             	mov    0x8(%ebp),%eax
  80218d:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  802190:	6a 01                	push   $0x1
  802192:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802195:	50                   	push   %eax
  802196:	e8 22 e9 ff ff       	call   800abd <sys_cputs>
}
  80219b:	83 c4 10             	add    $0x10,%esp
  80219e:	c9                   	leave  
  80219f:	c3                   	ret    

008021a0 <getchar>:

int
getchar(void)
{
  8021a0:	55                   	push   %ebp
  8021a1:	89 e5                	mov    %esp,%ebp
  8021a3:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8021a6:	6a 01                	push   $0x1
  8021a8:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8021ab:	50                   	push   %eax
  8021ac:	6a 00                	push   $0x0
  8021ae:	e8 36 f2 ff ff       	call   8013e9 <read>
	if (r < 0)
  8021b3:	83 c4 10             	add    $0x10,%esp
  8021b6:	85 c0                	test   %eax,%eax
  8021b8:	78 0f                	js     8021c9 <getchar+0x29>
		return r;
	if (r < 1)
  8021ba:	85 c0                	test   %eax,%eax
  8021bc:	7e 06                	jle    8021c4 <getchar+0x24>
		return -E_EOF;
	return c;
  8021be:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8021c2:	eb 05                	jmp    8021c9 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8021c4:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8021c9:	c9                   	leave  
  8021ca:	c3                   	ret    

008021cb <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8021cb:	55                   	push   %ebp
  8021cc:	89 e5                	mov    %esp,%ebp
  8021ce:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8021d1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8021d4:	50                   	push   %eax
  8021d5:	ff 75 08             	pushl  0x8(%ebp)
  8021d8:	e8 a6 ef ff ff       	call   801183 <fd_lookup>
  8021dd:	83 c4 10             	add    $0x10,%esp
  8021e0:	85 c0                	test   %eax,%eax
  8021e2:	78 11                	js     8021f5 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8021e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021e7:	8b 15 58 30 80 00    	mov    0x803058,%edx
  8021ed:	39 10                	cmp    %edx,(%eax)
  8021ef:	0f 94 c0             	sete   %al
  8021f2:	0f b6 c0             	movzbl %al,%eax
}
  8021f5:	c9                   	leave  
  8021f6:	c3                   	ret    

008021f7 <opencons>:

int
opencons(void)
{
  8021f7:	55                   	push   %ebp
  8021f8:	89 e5                	mov    %esp,%ebp
  8021fa:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8021fd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802200:	50                   	push   %eax
  802201:	e8 2e ef ff ff       	call   801134 <fd_alloc>
  802206:	83 c4 10             	add    $0x10,%esp
		return r;
  802209:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80220b:	85 c0                	test   %eax,%eax
  80220d:	78 3e                	js     80224d <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80220f:	83 ec 04             	sub    $0x4,%esp
  802212:	68 07 04 00 00       	push   $0x407
  802217:	ff 75 f4             	pushl  -0xc(%ebp)
  80221a:	6a 00                	push   $0x0
  80221c:	e8 58 e9 ff ff       	call   800b79 <sys_page_alloc>
  802221:	83 c4 10             	add    $0x10,%esp
		return r;
  802224:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802226:	85 c0                	test   %eax,%eax
  802228:	78 23                	js     80224d <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  80222a:	8b 15 58 30 80 00    	mov    0x803058,%edx
  802230:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802233:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  802235:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802238:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80223f:	83 ec 0c             	sub    $0xc,%esp
  802242:	50                   	push   %eax
  802243:	e8 c5 ee ff ff       	call   80110d <fd2num>
  802248:	89 c2                	mov    %eax,%edx
  80224a:	83 c4 10             	add    $0x10,%esp
}
  80224d:	89 d0                	mov    %edx,%eax
  80224f:	c9                   	leave  
  802250:	c3                   	ret    

00802251 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  802251:	55                   	push   %ebp
  802252:	89 e5                	mov    %esp,%ebp
  802254:	56                   	push   %esi
  802255:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  802256:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  802259:	8b 35 00 30 80 00    	mov    0x803000,%esi
  80225f:	e8 d7 e8 ff ff       	call   800b3b <sys_getenvid>
  802264:	83 ec 0c             	sub    $0xc,%esp
  802267:	ff 75 0c             	pushl  0xc(%ebp)
  80226a:	ff 75 08             	pushl  0x8(%ebp)
  80226d:	56                   	push   %esi
  80226e:	50                   	push   %eax
  80226f:	68 60 2b 80 00       	push   $0x802b60
  802274:	e8 78 df ff ff       	call   8001f1 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  802279:	83 c4 18             	add    $0x18,%esp
  80227c:	53                   	push   %ebx
  80227d:	ff 75 10             	pushl  0x10(%ebp)
  802280:	e8 1b df ff ff       	call   8001a0 <vcprintf>
	cprintf("\n");
  802285:	c7 04 24 13 2b 80 00 	movl   $0x802b13,(%esp)
  80228c:	e8 60 df ff ff       	call   8001f1 <cprintf>
  802291:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  802294:	cc                   	int3   
  802295:	eb fd                	jmp    802294 <_panic+0x43>

00802297 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802297:	55                   	push   %ebp
  802298:	89 e5                	mov    %esp,%ebp
  80229a:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  80229d:	83 3d 00 70 80 00 00 	cmpl   $0x0,0x807000
  8022a4:	75 2e                	jne    8022d4 <set_pgfault_handler+0x3d>
		// First time through!
		// LAB 4: Your code here.
		// panic("set_pgfault_handler not implemented");

		sys_page_alloc(sys_getenvid(), (void *) (UXSTACKTOP - PGSIZE), PTE_SYSCALL);
  8022a6:	e8 90 e8 ff ff       	call   800b3b <sys_getenvid>
  8022ab:	83 ec 04             	sub    $0x4,%esp
  8022ae:	68 07 0e 00 00       	push   $0xe07
  8022b3:	68 00 f0 bf ee       	push   $0xeebff000
  8022b8:	50                   	push   %eax
  8022b9:	e8 bb e8 ff ff       	call   800b79 <sys_page_alloc>
		sys_env_set_pgfault_upcall(sys_getenvid(), _pgfault_upcall);
  8022be:	e8 78 e8 ff ff       	call   800b3b <sys_getenvid>
  8022c3:	83 c4 08             	add    $0x8,%esp
  8022c6:	68 de 22 80 00       	push   $0x8022de
  8022cb:	50                   	push   %eax
  8022cc:	e8 f3 e9 ff ff       	call   800cc4 <sys_env_set_pgfault_upcall>
  8022d1:	83 c4 10             	add    $0x10,%esp
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8022d4:	8b 45 08             	mov    0x8(%ebp),%eax
  8022d7:	a3 00 70 80 00       	mov    %eax,0x807000
}
  8022dc:	c9                   	leave  
  8022dd:	c3                   	ret    

008022de <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8022de:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8022df:	a1 00 70 80 00       	mov    0x807000,%eax
	call *%eax
  8022e4:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8022e6:	83 c4 04             	add    $0x4,%esp
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.

	movl 48(%esp), %eax		// trap-time esp
  8022e9:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl 40(%esp), %ebx		// trap-time eip
  8022ed:	8b 5c 24 28          	mov    0x28(%esp),%ebx

	// load eip into esp-4
	// in order to return to trap-time eip later, in the meantime not changing trap-time esp
	movl %ebx, -4(%eax)	
  8022f1:	89 58 fc             	mov    %ebx,-0x4(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.

	addl $8, %esp 			// esp now points to trap-time registers
  8022f4:	83 c4 08             	add    $0x8,%esp
	popal					// pop to all registers
  8022f7:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

	addl $4, %esp			// esp now points to trap-time eflags
  8022f8:	83 c4 04             	add    $0x4,%esp
	popfl					// pop to eflags
  8022fb:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.

	popl %esp				// pop to esp
  8022fc:	5c                   	pop    %esp
	// subl $4, %esp		// arithmetic operation will change eflags!!!
	lea -4(%esp), %esp		// subl $4, %esp
  8022fd:	8d 64 24 fc          	lea    -0x4(%esp),%esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.

	ret
  802301:	c3                   	ret    

00802302 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802302:	55                   	push   %ebp
  802303:	89 e5                	mov    %esp,%ebp
  802305:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802308:	89 d0                	mov    %edx,%eax
  80230a:	c1 e8 16             	shr    $0x16,%eax
  80230d:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802314:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802319:	f6 c1 01             	test   $0x1,%cl
  80231c:	74 1d                	je     80233b <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  80231e:	c1 ea 0c             	shr    $0xc,%edx
  802321:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802328:	f6 c2 01             	test   $0x1,%dl
  80232b:	74 0e                	je     80233b <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80232d:	c1 ea 0c             	shr    $0xc,%edx
  802330:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802337:	ef 
  802338:	0f b7 c0             	movzwl %ax,%eax
}
  80233b:	5d                   	pop    %ebp
  80233c:	c3                   	ret    
  80233d:	66 90                	xchg   %ax,%ax
  80233f:	90                   	nop

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
