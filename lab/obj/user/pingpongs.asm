
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
  80003c:	e8 00 10 00 00       	call   801041 <sfork>
  800041:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800044:	85 c0                	test   %eax,%eax
  800046:	74 42                	je     80008a <umain+0x57>
		cprintf("i am %08x; thisenv is %p\n", sys_getenvid(), thisenv);
  800048:	8b 1d 0c 40 80 00    	mov    0x80400c,%ebx
  80004e:	e8 e8 0a 00 00       	call   800b3b <sys_getenvid>
  800053:	83 ec 04             	sub    $0x4,%esp
  800056:	53                   	push   %ebx
  800057:	50                   	push   %eax
  800058:	68 20 26 80 00       	push   $0x802620
  80005d:	e8 8f 01 00 00       	call   8001f1 <cprintf>
		// get the ball rolling
		cprintf("send 0 from %x to %x\n", sys_getenvid(), who);
  800062:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800065:	e8 d1 0a 00 00       	call   800b3b <sys_getenvid>
  80006a:	83 c4 0c             	add    $0xc,%esp
  80006d:	53                   	push   %ebx
  80006e:	50                   	push   %eax
  80006f:	68 3a 26 80 00       	push   $0x80263a
  800074:	e8 78 01 00 00       	call   8001f1 <cprintf>
		ipc_send(who, 0, 0, 0);
  800079:	6a 00                	push   $0x0
  80007b:	6a 00                	push   $0x0
  80007d:	6a 00                	push   $0x0
  80007f:	ff 75 e4             	pushl  -0x1c(%ebp)
  800082:	e8 3b 10 00 00       	call   8010c2 <ipc_send>
  800087:	83 c4 20             	add    $0x20,%esp
	}

	while (1) {
		ipc_recv(&who, 0, 0);
  80008a:	83 ec 04             	sub    $0x4,%esp
  80008d:	6a 00                	push   $0x0
  80008f:	6a 00                	push   $0x0
  800091:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800094:	50                   	push   %eax
  800095:	e8 c1 0f 00 00       	call   80105b <ipc_recv>
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
  8000bd:	68 50 26 80 00       	push   $0x802650
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
  8000e5:	e8 d8 0f 00 00       	call   8010c2 <ipc_send>
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
  80014a:	e8 cb 11 00 00       	call   80131a <close_all>
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
  800254:	e8 27 21 00 00       	call   802380 <__udivdi3>
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
  800297:	e8 14 22 00 00       	call   8024b0 <__umoddi3>
  80029c:	83 c4 14             	add    $0x14,%esp
  80029f:	0f be 80 80 26 80 00 	movsbl 0x802680(%eax),%eax
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
  80039b:	ff 24 85 c0 27 80 00 	jmp    *0x8027c0(,%eax,4)
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
  80045f:	8b 14 85 20 29 80 00 	mov    0x802920(,%eax,4),%edx
  800466:	85 d2                	test   %edx,%edx
  800468:	75 18                	jne    800482 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80046a:	50                   	push   %eax
  80046b:	68 98 26 80 00       	push   $0x802698
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
  800483:	68 21 2b 80 00       	push   $0x802b21
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
  8004a7:	b8 91 26 80 00       	mov    $0x802691,%eax
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
  800b22:	68 7f 29 80 00       	push   $0x80297f
  800b27:	6a 23                	push   $0x23
  800b29:	68 9c 29 80 00       	push   $0x80299c
  800b2e:	e8 60 17 00 00       	call   802293 <_panic>

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
  800ba3:	68 7f 29 80 00       	push   $0x80297f
  800ba8:	6a 23                	push   $0x23
  800baa:	68 9c 29 80 00       	push   $0x80299c
  800baf:	e8 df 16 00 00       	call   802293 <_panic>

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
  800be5:	68 7f 29 80 00       	push   $0x80297f
  800bea:	6a 23                	push   $0x23
  800bec:	68 9c 29 80 00       	push   $0x80299c
  800bf1:	e8 9d 16 00 00       	call   802293 <_panic>

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
  800c27:	68 7f 29 80 00       	push   $0x80297f
  800c2c:	6a 23                	push   $0x23
  800c2e:	68 9c 29 80 00       	push   $0x80299c
  800c33:	e8 5b 16 00 00       	call   802293 <_panic>

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
  800c69:	68 7f 29 80 00       	push   $0x80297f
  800c6e:	6a 23                	push   $0x23
  800c70:	68 9c 29 80 00       	push   $0x80299c
  800c75:	e8 19 16 00 00       	call   802293 <_panic>

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
  800cab:	68 7f 29 80 00       	push   $0x80297f
  800cb0:	6a 23                	push   $0x23
  800cb2:	68 9c 29 80 00       	push   $0x80299c
  800cb7:	e8 d7 15 00 00       	call   802293 <_panic>

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
  800ced:	68 7f 29 80 00       	push   $0x80297f
  800cf2:	6a 23                	push   $0x23
  800cf4:	68 9c 29 80 00       	push   $0x80299c
  800cf9:	e8 95 15 00 00       	call   802293 <_panic>

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
  800d51:	68 7f 29 80 00       	push   $0x80297f
  800d56:	6a 23                	push   $0x23
  800d58:	68 9c 29 80 00       	push   $0x80299c
  800d5d:	e8 31 15 00 00       	call   802293 <_panic>

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

00800d89 <sys_e1000_try_send>:

int
sys_e1000_try_send(void *data, uint32_t len)
{
  800d89:	55                   	push   %ebp
  800d8a:	89 e5                	mov    %esp,%ebp
  800d8c:	57                   	push   %edi
  800d8d:	56                   	push   %esi
  800d8e:	53                   	push   %ebx
  800d8f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d92:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d97:	b8 0f 00 00 00       	mov    $0xf,%eax
  800d9c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d9f:	8b 55 08             	mov    0x8(%ebp),%edx
  800da2:	89 df                	mov    %ebx,%edi
  800da4:	89 de                	mov    %ebx,%esi
  800da6:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800da8:	85 c0                	test   %eax,%eax
  800daa:	7e 17                	jle    800dc3 <sys_e1000_try_send+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dac:	83 ec 0c             	sub    $0xc,%esp
  800daf:	50                   	push   %eax
  800db0:	6a 0f                	push   $0xf
  800db2:	68 7f 29 80 00       	push   $0x80297f
  800db7:	6a 23                	push   $0x23
  800db9:	68 9c 29 80 00       	push   $0x80299c
  800dbe:	e8 d0 14 00 00       	call   802293 <_panic>

int
sys_e1000_try_send(void *data, uint32_t len)
{
	return syscall(SYS_e1000_try_send, 1, (uint32_t)data, len, 0, 0, 0);
}
  800dc3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dc6:	5b                   	pop    %ebx
  800dc7:	5e                   	pop    %esi
  800dc8:	5f                   	pop    %edi
  800dc9:	5d                   	pop    %ebp
  800dca:	c3                   	ret    

00800dcb <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800dcb:	55                   	push   %ebp
  800dcc:	89 e5                	mov    %esp,%ebp
  800dce:	56                   	push   %esi
  800dcf:	53                   	push   %ebx
  800dd0:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800dd3:	8b 18                	mov    (%eax),%ebx
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.

	if ((err & FEC_WR) != FEC_WR && ((uvpt[PGNUM(addr)] & PTE_COW) != PTE_COW)) {
  800dd5:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800dd9:	75 25                	jne    800e00 <pgfault+0x35>
  800ddb:	89 d8                	mov    %ebx,%eax
  800ddd:	c1 e8 0c             	shr    $0xc,%eax
  800de0:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800de7:	f6 c4 08             	test   $0x8,%ah
  800dea:	75 14                	jne    800e00 <pgfault+0x35>
		panic("pgfault: not due to a write or a COW page");
  800dec:	83 ec 04             	sub    $0x4,%esp
  800def:	68 ac 29 80 00       	push   $0x8029ac
  800df4:	6a 1e                	push   $0x1e
  800df6:	68 40 2a 80 00       	push   $0x802a40
  800dfb:	e8 93 14 00 00       	call   802293 <_panic>

	// LAB 4: Your code here.

	// panic("pgfault not implemented");

	addr = ROUNDDOWN(addr, PGSIZE);
  800e00:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	envid_t envid = sys_getenvid();
  800e06:	e8 30 fd ff ff       	call   800b3b <sys_getenvid>
  800e0b:	89 c6                	mov    %eax,%esi

	// envid = 0;

	// Allocate a new page, map it at a temporary location (PFTEMP)
	r = sys_page_alloc(envid, (void *)PFTEMP, PTE_U | PTE_P | PTE_W);
  800e0d:	83 ec 04             	sub    $0x4,%esp
  800e10:	6a 07                	push   $0x7
  800e12:	68 00 f0 7f 00       	push   $0x7ff000
  800e17:	50                   	push   %eax
  800e18:	e8 5c fd ff ff       	call   800b79 <sys_page_alloc>
	if (r < 0)
  800e1d:	83 c4 10             	add    $0x10,%esp
  800e20:	85 c0                	test   %eax,%eax
  800e22:	79 12                	jns    800e36 <pgfault+0x6b>
		panic("pgfault: sys_page_alloc failed: %e\n", r);
  800e24:	50                   	push   %eax
  800e25:	68 d8 29 80 00       	push   $0x8029d8
  800e2a:	6a 33                	push   $0x33
  800e2c:	68 40 2a 80 00       	push   $0x802a40
  800e31:	e8 5d 14 00 00       	call   802293 <_panic>
	
	// copy the data from the old page to the new page
	memcpy((void *) PFTEMP, (const void *) addr, PGSIZE);
  800e36:	83 ec 04             	sub    $0x4,%esp
  800e39:	68 00 10 00 00       	push   $0x1000
  800e3e:	53                   	push   %ebx
  800e3f:	68 00 f0 7f 00       	push   $0x7ff000
  800e44:	e8 27 fb ff ff       	call   800970 <memcpy>

	// move the new page to the old page's address
	r = sys_page_map(envid, (void *) PFTEMP, envid, addr, PTE_U | PTE_P | PTE_W);
  800e49:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800e50:	53                   	push   %ebx
  800e51:	56                   	push   %esi
  800e52:	68 00 f0 7f 00       	push   $0x7ff000
  800e57:	56                   	push   %esi
  800e58:	e8 5f fd ff ff       	call   800bbc <sys_page_map>
	if (r < 0)
  800e5d:	83 c4 20             	add    $0x20,%esp
  800e60:	85 c0                	test   %eax,%eax
  800e62:	79 12                	jns    800e76 <pgfault+0xab>
		panic("pgfault: sys_page_map failed: %e\n", r);
  800e64:	50                   	push   %eax
  800e65:	68 fc 29 80 00       	push   $0x8029fc
  800e6a:	6a 3b                	push   $0x3b
  800e6c:	68 40 2a 80 00       	push   $0x802a40
  800e71:	e8 1d 14 00 00       	call   802293 <_panic>

	// unmap temporary region
	r = sys_page_unmap(envid, (void *) PFTEMP);
  800e76:	83 ec 08             	sub    $0x8,%esp
  800e79:	68 00 f0 7f 00       	push   $0x7ff000
  800e7e:	56                   	push   %esi
  800e7f:	e8 7a fd ff ff       	call   800bfe <sys_page_unmap>
	if (r < 0)
  800e84:	83 c4 10             	add    $0x10,%esp
  800e87:	85 c0                	test   %eax,%eax
  800e89:	79 12                	jns    800e9d <pgfault+0xd2>
        panic("pgfault: page unmap failed: %e\n", r);
  800e8b:	50                   	push   %eax
  800e8c:	68 20 2a 80 00       	push   $0x802a20
  800e91:	6a 40                	push   $0x40
  800e93:	68 40 2a 80 00       	push   $0x802a40
  800e98:	e8 f6 13 00 00       	call   802293 <_panic>
}
  800e9d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ea0:	5b                   	pop    %ebx
  800ea1:	5e                   	pop    %esi
  800ea2:	5d                   	pop    %ebp
  800ea3:	c3                   	ret    

00800ea4 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800ea4:	55                   	push   %ebp
  800ea5:	89 e5                	mov    %esp,%ebp
  800ea7:	57                   	push   %edi
  800ea8:	56                   	push   %esi
  800ea9:	53                   	push   %ebx
  800eaa:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	// cprintf("[fork]\n");
	int r;

	set_pgfault_handler(pgfault);
  800ead:	68 cb 0d 80 00       	push   $0x800dcb
  800eb2:	e8 22 14 00 00       	call   8022d9 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800eb7:	b8 07 00 00 00       	mov    $0x7,%eax
  800ebc:	cd 30                	int    $0x30

	envid_t envid = sys_exofork();
	if (envid < 0)
  800ebe:	83 c4 10             	add    $0x10,%esp
  800ec1:	85 c0                	test   %eax,%eax
  800ec3:	0f 88 64 01 00 00    	js     80102d <fork+0x189>
  800ec9:	bb 00 00 80 00       	mov    $0x800000,%ebx
  800ece:	be 00 08 00 00       	mov    $0x800,%esi
		return envid;

	// fix "thisenv" in the child process
	if (envid == 0) {
  800ed3:	85 c0                	test   %eax,%eax
  800ed5:	75 21                	jne    800ef8 <fork+0x54>
		thisenv = &envs[ENVX(sys_getenvid())];
  800ed7:	e8 5f fc ff ff       	call   800b3b <sys_getenvid>
  800edc:	25 ff 03 00 00       	and    $0x3ff,%eax
  800ee1:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800ee4:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800ee9:	a3 0c 40 80 00       	mov    %eax,0x80400c
        return 0;
  800eee:	ba 00 00 00 00       	mov    $0x0,%edx
  800ef3:	e9 3f 01 00 00       	jmp    801037 <fork+0x193>
  800ef8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800efb:	89 c7                	mov    %eax,%edi
	for (uint32_t pn = PGNUM(UTEXT); pn < PGNUM(USTACKTOP); pn++) {

		addr = pn * PGSIZE;

		// if level-2 page exists
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P) {
  800efd:	89 d8                	mov    %ebx,%eax
  800eff:	c1 e8 16             	shr    $0x16,%eax
  800f02:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f09:	a8 01                	test   $0x1,%al
  800f0b:	0f 84 bd 00 00 00    	je     800fce <fork+0x12a>
			
			// if real PTE exists
			if ((uvpt[PGNUM(addr)] & PTE_P) == PTE_P) {
  800f11:	89 d8                	mov    %ebx,%eax
  800f13:	c1 e8 0c             	shr    $0xc,%eax
  800f16:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f1d:	f6 c2 01             	test   $0x1,%dl
  800f20:	0f 84 a8 00 00 00    	je     800fce <fork+0x12a>

				// For each writable or copy-on-write page
				// if ((uvpt[PGNUM(addr)] & (PTE_W | PTE_COW)) != 0) {
				if ((uvpt[PGNUM(addr)] & PTE_U) != 0) {
  800f26:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f2d:	a8 04                	test   $0x4,%al
  800f2f:	0f 84 99 00 00 00    	je     800fce <fork+0x12a>
	// r = envid2env(envid, &env, 1);
	// if (r < 0)
	// 	return r;	// E_BAD_ENV
	// envid_t parent_envid = env->env_parent_id;

	if (uvpt[pn] & PTE_SHARE) {
  800f35:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800f3c:	f6 c4 04             	test   $0x4,%ah
  800f3f:	74 17                	je     800f58 <fork+0xb4>
		sys_page_map(0, (void *)va, envid, (void *)va, PTE_SYSCALL);
  800f41:	83 ec 0c             	sub    $0xc,%esp
  800f44:	68 07 0e 00 00       	push   $0xe07
  800f49:	53                   	push   %ebx
  800f4a:	57                   	push   %edi
  800f4b:	53                   	push   %ebx
  800f4c:	6a 00                	push   $0x0
  800f4e:	e8 69 fc ff ff       	call   800bbc <sys_page_map>
  800f53:	83 c4 20             	add    $0x20,%esp
  800f56:	eb 76                	jmp    800fce <fork+0x12a>
	}
	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {
  800f58:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800f5f:	a8 02                	test   $0x2,%al
  800f61:	75 0c                	jne    800f6f <fork+0xcb>
  800f63:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800f6a:	f6 c4 08             	test   $0x8,%ah
  800f6d:	74 3f                	je     800fae <fork+0x10a>

		// map the page copy-on-write into the address space of the child
        r = sys_page_map(0, (void *)va, envid, (void *)va, PTE_P|PTE_U|PTE_COW);
  800f6f:	83 ec 0c             	sub    $0xc,%esp
  800f72:	68 05 08 00 00       	push   $0x805
  800f77:	53                   	push   %ebx
  800f78:	57                   	push   %edi
  800f79:	53                   	push   %ebx
  800f7a:	6a 00                	push   $0x0
  800f7c:	e8 3b fc ff ff       	call   800bbc <sys_page_map>
		if (r < 0)
  800f81:	83 c4 20             	add    $0x20,%esp
  800f84:	85 c0                	test   %eax,%eax
  800f86:	0f 88 a5 00 00 00    	js     801031 <fork+0x18d>
            return r;

		// remap the page copy-on-write in its own(parent) address space
        r = sys_page_map(0, (void *)va, 0, (void *)va, PTE_P|PTE_U|PTE_COW);
  800f8c:	83 ec 0c             	sub    $0xc,%esp
  800f8f:	68 05 08 00 00       	push   $0x805
  800f94:	53                   	push   %ebx
  800f95:	6a 00                	push   $0x0
  800f97:	53                   	push   %ebx
  800f98:	6a 00                	push   $0x0
  800f9a:	e8 1d fc ff ff       	call   800bbc <sys_page_map>
  800f9f:	83 c4 20             	add    $0x20,%esp
  800fa2:	85 c0                	test   %eax,%eax
  800fa4:	b9 00 00 00 00       	mov    $0x0,%ecx
  800fa9:	0f 4f c1             	cmovg  %ecx,%eax
  800fac:	eb 1c                	jmp    800fca <fork+0x126>
		if (r < 0)
            return r;
    }
    else {
        r = sys_page_map(0, (void *)va, envid, (void *)va, PTE_P|PTE_U);
  800fae:	83 ec 0c             	sub    $0xc,%esp
  800fb1:	6a 05                	push   $0x5
  800fb3:	53                   	push   %ebx
  800fb4:	57                   	push   %edi
  800fb5:	53                   	push   %ebx
  800fb6:	6a 00                	push   $0x0
  800fb8:	e8 ff fb ff ff       	call   800bbc <sys_page_map>
  800fbd:	83 c4 20             	add    $0x20,%esp
  800fc0:	85 c0                	test   %eax,%eax
  800fc2:	b9 00 00 00 00       	mov    $0x0,%ecx
  800fc7:	0f 4f c1             	cmovg  %ecx,%eax

				// For each writable or copy-on-write page
				// if ((uvpt[PGNUM(addr)] & (PTE_W | PTE_COW)) != 0) {
				if ((uvpt[PGNUM(addr)] & PTE_U) != 0) {
					r = duppage(envid, pn);
					if (r < 0)
  800fca:	85 c0                	test   %eax,%eax
  800fcc:	78 67                	js     801035 <fork+0x191>
        return 0;
	}

	// For each writable or copy-on-write page in its address space below UTOP, the parent calls duppage
	uint32_t addr;
	for (uint32_t pn = PGNUM(UTEXT); pn < PGNUM(USTACKTOP); pn++) {
  800fce:	83 c6 01             	add    $0x1,%esi
  800fd1:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  800fd7:	81 fe fe eb 0e 00    	cmp    $0xeebfe,%esi
  800fdd:	0f 85 1a ff ff ff    	jne    800efd <fork+0x59>
  800fe3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
		}
	}

	// allocate a fresh page in the child for the exception stack
	r = sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U | PTE_P | PTE_W);
  800fe6:	83 ec 04             	sub    $0x4,%esp
  800fe9:	6a 07                	push   $0x7
  800feb:	68 00 f0 bf ee       	push   $0xeebff000
  800ff0:	57                   	push   %edi
  800ff1:	e8 83 fb ff ff       	call   800b79 <sys_page_alloc>
	if (r < 0)
  800ff6:	83 c4 10             	add    $0x10,%esp
		return r;
  800ff9:	89 c2                	mov    %eax,%edx
		}
	}

	// allocate a fresh page in the child for the exception stack
	r = sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U | PTE_P | PTE_W);
	if (r < 0)
  800ffb:	85 c0                	test   %eax,%eax
  800ffd:	78 38                	js     801037 <fork+0x193>
		return r;

	// The parent sets the user page fault entrypoint for the child to look like its own
	extern void _pgfault_upcall(void);
	r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  800fff:	83 ec 08             	sub    $0x8,%esp
  801002:	68 20 23 80 00       	push   $0x802320
  801007:	57                   	push   %edi
  801008:	e8 b7 fc ff ff       	call   800cc4 <sys_env_set_pgfault_upcall>
	if (r < 0)
  80100d:	83 c4 10             	add    $0x10,%esp
		return r;
  801010:	89 c2                	mov    %eax,%edx
		return r;

	// The parent sets the user page fault entrypoint for the child to look like its own
	extern void _pgfault_upcall(void);
	r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
	if (r < 0)
  801012:	85 c0                	test   %eax,%eax
  801014:	78 21                	js     801037 <fork+0x193>
		return r;

	// The child is now ready to run, so the parent marks it runnable
	r = sys_env_set_status(envid, ENV_RUNNABLE);
  801016:	83 ec 08             	sub    $0x8,%esp
  801019:	6a 02                	push   $0x2
  80101b:	57                   	push   %edi
  80101c:	e8 1f fc ff ff       	call   800c40 <sys_env_set_status>
	if (r < 0)
  801021:	83 c4 10             	add    $0x10,%esp
		return r;

	return envid;
  801024:	85 c0                	test   %eax,%eax
  801026:	0f 48 f8             	cmovs  %eax,%edi
  801029:	89 fa                	mov    %edi,%edx
  80102b:	eb 0a                	jmp    801037 <fork+0x193>

	set_pgfault_handler(pgfault);

	envid_t envid = sys_exofork();
	if (envid < 0)
		return envid;
  80102d:	89 c2                	mov    %eax,%edx
  80102f:	eb 06                	jmp    801037 <fork+0x193>
		sys_page_map(0, (void *)va, envid, (void *)va, PTE_SYSCALL);
	}
	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {

		// map the page copy-on-write into the address space of the child
        r = sys_page_map(0, (void *)va, envid, (void *)va, PTE_P|PTE_U|PTE_COW);
  801031:	89 c2                	mov    %eax,%edx
  801033:	eb 02                	jmp    801037 <fork+0x193>
  801035:	89 c2                	mov    %eax,%edx
	if (r < 0)
		return r;

	return envid;
	// panic("fork not implemented");
}
  801037:	89 d0                	mov    %edx,%eax
  801039:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80103c:	5b                   	pop    %ebx
  80103d:	5e                   	pop    %esi
  80103e:	5f                   	pop    %edi
  80103f:	5d                   	pop    %ebp
  801040:	c3                   	ret    

00801041 <sfork>:

// Challenge!
int
sfork(void)
{
  801041:	55                   	push   %ebp
  801042:	89 e5                	mov    %esp,%ebp
  801044:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801047:	68 4b 2a 80 00       	push   $0x802a4b
  80104c:	68 c9 00 00 00       	push   $0xc9
  801051:	68 40 2a 80 00       	push   $0x802a40
  801056:	e8 38 12 00 00       	call   802293 <_panic>

0080105b <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80105b:	55                   	push   %ebp
  80105c:	89 e5                	mov    %esp,%ebp
  80105e:	56                   	push   %esi
  80105f:	53                   	push   %ebx
  801060:	8b 75 08             	mov    0x8(%ebp),%esi
  801063:	8b 45 0c             	mov    0xc(%ebp),%eax
  801066:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");

	// don't want to recv page
	if (pg == NULL)
  801069:	85 c0                	test   %eax,%eax
		pg = (void *)UTOP;
  80106b:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801070:	0f 44 c2             	cmove  %edx,%eax

	int err = sys_ipc_recv(pg);
  801073:	83 ec 0c             	sub    $0xc,%esp
  801076:	50                   	push   %eax
  801077:	e8 ad fc ff ff       	call   800d29 <sys_ipc_recv>

	if (from_env_store != NULL)
  80107c:	83 c4 10             	add    $0x10,%esp
  80107f:	85 f6                	test   %esi,%esi
  801081:	74 14                	je     801097 <ipc_recv+0x3c>
		*from_env_store = err < 0? 0 : thisenv->env_ipc_from;
  801083:	ba 00 00 00 00       	mov    $0x0,%edx
  801088:	85 c0                	test   %eax,%eax
  80108a:	78 09                	js     801095 <ipc_recv+0x3a>
  80108c:	8b 15 0c 40 80 00    	mov    0x80400c,%edx
  801092:	8b 52 74             	mov    0x74(%edx),%edx
  801095:	89 16                	mov    %edx,(%esi)
	
	if (perm_store != NULL)
  801097:	85 db                	test   %ebx,%ebx
  801099:	74 14                	je     8010af <ipc_recv+0x54>
		*perm_store = err < 0? 0 : thisenv->env_ipc_perm;
  80109b:	ba 00 00 00 00       	mov    $0x0,%edx
  8010a0:	85 c0                	test   %eax,%eax
  8010a2:	78 09                	js     8010ad <ipc_recv+0x52>
  8010a4:	8b 15 0c 40 80 00    	mov    0x80400c,%edx
  8010aa:	8b 52 78             	mov    0x78(%edx),%edx
  8010ad:	89 13                	mov    %edx,(%ebx)

	if (err < 0)
  8010af:	85 c0                	test   %eax,%eax
  8010b1:	78 08                	js     8010bb <ipc_recv+0x60>
		return err;
	return thisenv->env_ipc_value;
  8010b3:	a1 0c 40 80 00       	mov    0x80400c,%eax
  8010b8:	8b 40 70             	mov    0x70(%eax),%eax
}
  8010bb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8010be:	5b                   	pop    %ebx
  8010bf:	5e                   	pop    %esi
  8010c0:	5d                   	pop    %ebp
  8010c1:	c3                   	ret    

008010c2 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8010c2:	55                   	push   %ebp
  8010c3:	89 e5                	mov    %esp,%ebp
  8010c5:	57                   	push   %edi
  8010c6:	56                   	push   %esi
  8010c7:	53                   	push   %ebx
  8010c8:	83 ec 0c             	sub    $0xc,%esp
  8010cb:	8b 7d 08             	mov    0x8(%ebp),%edi
  8010ce:	8b 75 0c             	mov    0xc(%ebp),%esi
  8010d1:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");

	// don't want to send page
	if (pg == NULL)
  8010d4:	85 db                	test   %ebx,%ebx
		pg = (void *)UTOP;
  8010d6:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  8010db:	0f 44 d8             	cmove  %eax,%ebx
	
	int err = 0;
	
	do {

		err = sys_ipc_try_send(to_env, val, pg, perm);
  8010de:	ff 75 14             	pushl  0x14(%ebp)
  8010e1:	53                   	push   %ebx
  8010e2:	56                   	push   %esi
  8010e3:	57                   	push   %edi
  8010e4:	e8 1d fc ff ff       	call   800d06 <sys_ipc_try_send>

		if (err < 0) {
  8010e9:	83 c4 10             	add    $0x10,%esp
  8010ec:	85 c0                	test   %eax,%eax
  8010ee:	79 1e                	jns    80110e <ipc_send+0x4c>
			if (err == -E_IPC_NOT_RECV)
  8010f0:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8010f3:	75 07                	jne    8010fc <ipc_send+0x3a>
				sys_yield();
  8010f5:	e8 60 fa ff ff       	call   800b5a <sys_yield>
  8010fa:	eb e2                	jmp    8010de <ipc_send+0x1c>
			else 
				panic("ipc_send: %e", err);
  8010fc:	50                   	push   %eax
  8010fd:	68 61 2a 80 00       	push   $0x802a61
  801102:	6a 49                	push   $0x49
  801104:	68 6e 2a 80 00       	push   $0x802a6e
  801109:	e8 85 11 00 00       	call   802293 <_panic>
		}

	} while (err < 0);

}
  80110e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801111:	5b                   	pop    %ebx
  801112:	5e                   	pop    %esi
  801113:	5f                   	pop    %edi
  801114:	5d                   	pop    %ebp
  801115:	c3                   	ret    

00801116 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801116:	55                   	push   %ebp
  801117:	89 e5                	mov    %esp,%ebp
  801119:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80111c:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801121:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801124:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80112a:	8b 52 50             	mov    0x50(%edx),%edx
  80112d:	39 ca                	cmp    %ecx,%edx
  80112f:	75 0d                	jne    80113e <ipc_find_env+0x28>
			return envs[i].env_id;
  801131:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801134:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801139:	8b 40 48             	mov    0x48(%eax),%eax
  80113c:	eb 0f                	jmp    80114d <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80113e:	83 c0 01             	add    $0x1,%eax
  801141:	3d 00 04 00 00       	cmp    $0x400,%eax
  801146:	75 d9                	jne    801121 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801148:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80114d:	5d                   	pop    %ebp
  80114e:	c3                   	ret    

0080114f <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80114f:	55                   	push   %ebp
  801150:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801152:	8b 45 08             	mov    0x8(%ebp),%eax
  801155:	05 00 00 00 30       	add    $0x30000000,%eax
  80115a:	c1 e8 0c             	shr    $0xc,%eax
}
  80115d:	5d                   	pop    %ebp
  80115e:	c3                   	ret    

0080115f <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80115f:	55                   	push   %ebp
  801160:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801162:	8b 45 08             	mov    0x8(%ebp),%eax
  801165:	05 00 00 00 30       	add    $0x30000000,%eax
  80116a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80116f:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801174:	5d                   	pop    %ebp
  801175:	c3                   	ret    

00801176 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801176:	55                   	push   %ebp
  801177:	89 e5                	mov    %esp,%ebp
  801179:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80117c:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801181:	89 c2                	mov    %eax,%edx
  801183:	c1 ea 16             	shr    $0x16,%edx
  801186:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80118d:	f6 c2 01             	test   $0x1,%dl
  801190:	74 11                	je     8011a3 <fd_alloc+0x2d>
  801192:	89 c2                	mov    %eax,%edx
  801194:	c1 ea 0c             	shr    $0xc,%edx
  801197:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80119e:	f6 c2 01             	test   $0x1,%dl
  8011a1:	75 09                	jne    8011ac <fd_alloc+0x36>
			*fd_store = fd;
  8011a3:	89 01                	mov    %eax,(%ecx)
			return 0;
  8011a5:	b8 00 00 00 00       	mov    $0x0,%eax
  8011aa:	eb 17                	jmp    8011c3 <fd_alloc+0x4d>
  8011ac:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8011b1:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8011b6:	75 c9                	jne    801181 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8011b8:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8011be:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8011c3:	5d                   	pop    %ebp
  8011c4:	c3                   	ret    

008011c5 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8011c5:	55                   	push   %ebp
  8011c6:	89 e5                	mov    %esp,%ebp
  8011c8:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8011cb:	83 f8 1f             	cmp    $0x1f,%eax
  8011ce:	77 36                	ja     801206 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8011d0:	c1 e0 0c             	shl    $0xc,%eax
  8011d3:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8011d8:	89 c2                	mov    %eax,%edx
  8011da:	c1 ea 16             	shr    $0x16,%edx
  8011dd:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8011e4:	f6 c2 01             	test   $0x1,%dl
  8011e7:	74 24                	je     80120d <fd_lookup+0x48>
  8011e9:	89 c2                	mov    %eax,%edx
  8011eb:	c1 ea 0c             	shr    $0xc,%edx
  8011ee:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8011f5:	f6 c2 01             	test   $0x1,%dl
  8011f8:	74 1a                	je     801214 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8011fa:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011fd:	89 02                	mov    %eax,(%edx)
	return 0;
  8011ff:	b8 00 00 00 00       	mov    $0x0,%eax
  801204:	eb 13                	jmp    801219 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801206:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80120b:	eb 0c                	jmp    801219 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80120d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801212:	eb 05                	jmp    801219 <fd_lookup+0x54>
  801214:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801219:	5d                   	pop    %ebp
  80121a:	c3                   	ret    

0080121b <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80121b:	55                   	push   %ebp
  80121c:	89 e5                	mov    %esp,%ebp
  80121e:	83 ec 08             	sub    $0x8,%esp
  801221:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801224:	ba f4 2a 80 00       	mov    $0x802af4,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801229:	eb 13                	jmp    80123e <dev_lookup+0x23>
  80122b:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80122e:	39 08                	cmp    %ecx,(%eax)
  801230:	75 0c                	jne    80123e <dev_lookup+0x23>
			*dev = devtab[i];
  801232:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801235:	89 01                	mov    %eax,(%ecx)
			return 0;
  801237:	b8 00 00 00 00       	mov    $0x0,%eax
  80123c:	eb 2e                	jmp    80126c <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80123e:	8b 02                	mov    (%edx),%eax
  801240:	85 c0                	test   %eax,%eax
  801242:	75 e7                	jne    80122b <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801244:	a1 0c 40 80 00       	mov    0x80400c,%eax
  801249:	8b 40 48             	mov    0x48(%eax),%eax
  80124c:	83 ec 04             	sub    $0x4,%esp
  80124f:	51                   	push   %ecx
  801250:	50                   	push   %eax
  801251:	68 78 2a 80 00       	push   $0x802a78
  801256:	e8 96 ef ff ff       	call   8001f1 <cprintf>
	*dev = 0;
  80125b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80125e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801264:	83 c4 10             	add    $0x10,%esp
  801267:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80126c:	c9                   	leave  
  80126d:	c3                   	ret    

0080126e <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80126e:	55                   	push   %ebp
  80126f:	89 e5                	mov    %esp,%ebp
  801271:	56                   	push   %esi
  801272:	53                   	push   %ebx
  801273:	83 ec 10             	sub    $0x10,%esp
  801276:	8b 75 08             	mov    0x8(%ebp),%esi
  801279:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80127c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80127f:	50                   	push   %eax
  801280:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801286:	c1 e8 0c             	shr    $0xc,%eax
  801289:	50                   	push   %eax
  80128a:	e8 36 ff ff ff       	call   8011c5 <fd_lookup>
  80128f:	83 c4 08             	add    $0x8,%esp
  801292:	85 c0                	test   %eax,%eax
  801294:	78 05                	js     80129b <fd_close+0x2d>
	    || fd != fd2)
  801296:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801299:	74 0c                	je     8012a7 <fd_close+0x39>
		return (must_exist ? r : 0);
  80129b:	84 db                	test   %bl,%bl
  80129d:	ba 00 00 00 00       	mov    $0x0,%edx
  8012a2:	0f 44 c2             	cmove  %edx,%eax
  8012a5:	eb 41                	jmp    8012e8 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8012a7:	83 ec 08             	sub    $0x8,%esp
  8012aa:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012ad:	50                   	push   %eax
  8012ae:	ff 36                	pushl  (%esi)
  8012b0:	e8 66 ff ff ff       	call   80121b <dev_lookup>
  8012b5:	89 c3                	mov    %eax,%ebx
  8012b7:	83 c4 10             	add    $0x10,%esp
  8012ba:	85 c0                	test   %eax,%eax
  8012bc:	78 1a                	js     8012d8 <fd_close+0x6a>
		if (dev->dev_close)
  8012be:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012c1:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8012c4:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8012c9:	85 c0                	test   %eax,%eax
  8012cb:	74 0b                	je     8012d8 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8012cd:	83 ec 0c             	sub    $0xc,%esp
  8012d0:	56                   	push   %esi
  8012d1:	ff d0                	call   *%eax
  8012d3:	89 c3                	mov    %eax,%ebx
  8012d5:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8012d8:	83 ec 08             	sub    $0x8,%esp
  8012db:	56                   	push   %esi
  8012dc:	6a 00                	push   $0x0
  8012de:	e8 1b f9 ff ff       	call   800bfe <sys_page_unmap>
	return r;
  8012e3:	83 c4 10             	add    $0x10,%esp
  8012e6:	89 d8                	mov    %ebx,%eax
}
  8012e8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012eb:	5b                   	pop    %ebx
  8012ec:	5e                   	pop    %esi
  8012ed:	5d                   	pop    %ebp
  8012ee:	c3                   	ret    

008012ef <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8012ef:	55                   	push   %ebp
  8012f0:	89 e5                	mov    %esp,%ebp
  8012f2:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8012f5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012f8:	50                   	push   %eax
  8012f9:	ff 75 08             	pushl  0x8(%ebp)
  8012fc:	e8 c4 fe ff ff       	call   8011c5 <fd_lookup>
  801301:	83 c4 08             	add    $0x8,%esp
  801304:	85 c0                	test   %eax,%eax
  801306:	78 10                	js     801318 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801308:	83 ec 08             	sub    $0x8,%esp
  80130b:	6a 01                	push   $0x1
  80130d:	ff 75 f4             	pushl  -0xc(%ebp)
  801310:	e8 59 ff ff ff       	call   80126e <fd_close>
  801315:	83 c4 10             	add    $0x10,%esp
}
  801318:	c9                   	leave  
  801319:	c3                   	ret    

0080131a <close_all>:

void
close_all(void)
{
  80131a:	55                   	push   %ebp
  80131b:	89 e5                	mov    %esp,%ebp
  80131d:	53                   	push   %ebx
  80131e:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801321:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801326:	83 ec 0c             	sub    $0xc,%esp
  801329:	53                   	push   %ebx
  80132a:	e8 c0 ff ff ff       	call   8012ef <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80132f:	83 c3 01             	add    $0x1,%ebx
  801332:	83 c4 10             	add    $0x10,%esp
  801335:	83 fb 20             	cmp    $0x20,%ebx
  801338:	75 ec                	jne    801326 <close_all+0xc>
		close(i);
}
  80133a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80133d:	c9                   	leave  
  80133e:	c3                   	ret    

0080133f <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80133f:	55                   	push   %ebp
  801340:	89 e5                	mov    %esp,%ebp
  801342:	57                   	push   %edi
  801343:	56                   	push   %esi
  801344:	53                   	push   %ebx
  801345:	83 ec 2c             	sub    $0x2c,%esp
  801348:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80134b:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80134e:	50                   	push   %eax
  80134f:	ff 75 08             	pushl  0x8(%ebp)
  801352:	e8 6e fe ff ff       	call   8011c5 <fd_lookup>
  801357:	83 c4 08             	add    $0x8,%esp
  80135a:	85 c0                	test   %eax,%eax
  80135c:	0f 88 c1 00 00 00    	js     801423 <dup+0xe4>
		return r;
	close(newfdnum);
  801362:	83 ec 0c             	sub    $0xc,%esp
  801365:	56                   	push   %esi
  801366:	e8 84 ff ff ff       	call   8012ef <close>

	newfd = INDEX2FD(newfdnum);
  80136b:	89 f3                	mov    %esi,%ebx
  80136d:	c1 e3 0c             	shl    $0xc,%ebx
  801370:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801376:	83 c4 04             	add    $0x4,%esp
  801379:	ff 75 e4             	pushl  -0x1c(%ebp)
  80137c:	e8 de fd ff ff       	call   80115f <fd2data>
  801381:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801383:	89 1c 24             	mov    %ebx,(%esp)
  801386:	e8 d4 fd ff ff       	call   80115f <fd2data>
  80138b:	83 c4 10             	add    $0x10,%esp
  80138e:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801391:	89 f8                	mov    %edi,%eax
  801393:	c1 e8 16             	shr    $0x16,%eax
  801396:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80139d:	a8 01                	test   $0x1,%al
  80139f:	74 37                	je     8013d8 <dup+0x99>
  8013a1:	89 f8                	mov    %edi,%eax
  8013a3:	c1 e8 0c             	shr    $0xc,%eax
  8013a6:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8013ad:	f6 c2 01             	test   $0x1,%dl
  8013b0:	74 26                	je     8013d8 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8013b2:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8013b9:	83 ec 0c             	sub    $0xc,%esp
  8013bc:	25 07 0e 00 00       	and    $0xe07,%eax
  8013c1:	50                   	push   %eax
  8013c2:	ff 75 d4             	pushl  -0x2c(%ebp)
  8013c5:	6a 00                	push   $0x0
  8013c7:	57                   	push   %edi
  8013c8:	6a 00                	push   $0x0
  8013ca:	e8 ed f7 ff ff       	call   800bbc <sys_page_map>
  8013cf:	89 c7                	mov    %eax,%edi
  8013d1:	83 c4 20             	add    $0x20,%esp
  8013d4:	85 c0                	test   %eax,%eax
  8013d6:	78 2e                	js     801406 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8013d8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8013db:	89 d0                	mov    %edx,%eax
  8013dd:	c1 e8 0c             	shr    $0xc,%eax
  8013e0:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8013e7:	83 ec 0c             	sub    $0xc,%esp
  8013ea:	25 07 0e 00 00       	and    $0xe07,%eax
  8013ef:	50                   	push   %eax
  8013f0:	53                   	push   %ebx
  8013f1:	6a 00                	push   $0x0
  8013f3:	52                   	push   %edx
  8013f4:	6a 00                	push   $0x0
  8013f6:	e8 c1 f7 ff ff       	call   800bbc <sys_page_map>
  8013fb:	89 c7                	mov    %eax,%edi
  8013fd:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801400:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801402:	85 ff                	test   %edi,%edi
  801404:	79 1d                	jns    801423 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801406:	83 ec 08             	sub    $0x8,%esp
  801409:	53                   	push   %ebx
  80140a:	6a 00                	push   $0x0
  80140c:	e8 ed f7 ff ff       	call   800bfe <sys_page_unmap>
	sys_page_unmap(0, nva);
  801411:	83 c4 08             	add    $0x8,%esp
  801414:	ff 75 d4             	pushl  -0x2c(%ebp)
  801417:	6a 00                	push   $0x0
  801419:	e8 e0 f7 ff ff       	call   800bfe <sys_page_unmap>
	return r;
  80141e:	83 c4 10             	add    $0x10,%esp
  801421:	89 f8                	mov    %edi,%eax
}
  801423:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801426:	5b                   	pop    %ebx
  801427:	5e                   	pop    %esi
  801428:	5f                   	pop    %edi
  801429:	5d                   	pop    %ebp
  80142a:	c3                   	ret    

0080142b <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80142b:	55                   	push   %ebp
  80142c:	89 e5                	mov    %esp,%ebp
  80142e:	53                   	push   %ebx
  80142f:	83 ec 14             	sub    $0x14,%esp
  801432:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801435:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801438:	50                   	push   %eax
  801439:	53                   	push   %ebx
  80143a:	e8 86 fd ff ff       	call   8011c5 <fd_lookup>
  80143f:	83 c4 08             	add    $0x8,%esp
  801442:	89 c2                	mov    %eax,%edx
  801444:	85 c0                	test   %eax,%eax
  801446:	78 6d                	js     8014b5 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801448:	83 ec 08             	sub    $0x8,%esp
  80144b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80144e:	50                   	push   %eax
  80144f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801452:	ff 30                	pushl  (%eax)
  801454:	e8 c2 fd ff ff       	call   80121b <dev_lookup>
  801459:	83 c4 10             	add    $0x10,%esp
  80145c:	85 c0                	test   %eax,%eax
  80145e:	78 4c                	js     8014ac <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801460:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801463:	8b 42 08             	mov    0x8(%edx),%eax
  801466:	83 e0 03             	and    $0x3,%eax
  801469:	83 f8 01             	cmp    $0x1,%eax
  80146c:	75 21                	jne    80148f <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80146e:	a1 0c 40 80 00       	mov    0x80400c,%eax
  801473:	8b 40 48             	mov    0x48(%eax),%eax
  801476:	83 ec 04             	sub    $0x4,%esp
  801479:	53                   	push   %ebx
  80147a:	50                   	push   %eax
  80147b:	68 b9 2a 80 00       	push   $0x802ab9
  801480:	e8 6c ed ff ff       	call   8001f1 <cprintf>
		return -E_INVAL;
  801485:	83 c4 10             	add    $0x10,%esp
  801488:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80148d:	eb 26                	jmp    8014b5 <read+0x8a>
	}
	if (!dev->dev_read)
  80148f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801492:	8b 40 08             	mov    0x8(%eax),%eax
  801495:	85 c0                	test   %eax,%eax
  801497:	74 17                	je     8014b0 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801499:	83 ec 04             	sub    $0x4,%esp
  80149c:	ff 75 10             	pushl  0x10(%ebp)
  80149f:	ff 75 0c             	pushl  0xc(%ebp)
  8014a2:	52                   	push   %edx
  8014a3:	ff d0                	call   *%eax
  8014a5:	89 c2                	mov    %eax,%edx
  8014a7:	83 c4 10             	add    $0x10,%esp
  8014aa:	eb 09                	jmp    8014b5 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014ac:	89 c2                	mov    %eax,%edx
  8014ae:	eb 05                	jmp    8014b5 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8014b0:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8014b5:	89 d0                	mov    %edx,%eax
  8014b7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014ba:	c9                   	leave  
  8014bb:	c3                   	ret    

008014bc <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8014bc:	55                   	push   %ebp
  8014bd:	89 e5                	mov    %esp,%ebp
  8014bf:	57                   	push   %edi
  8014c0:	56                   	push   %esi
  8014c1:	53                   	push   %ebx
  8014c2:	83 ec 0c             	sub    $0xc,%esp
  8014c5:	8b 7d 08             	mov    0x8(%ebp),%edi
  8014c8:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8014cb:	bb 00 00 00 00       	mov    $0x0,%ebx
  8014d0:	eb 21                	jmp    8014f3 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8014d2:	83 ec 04             	sub    $0x4,%esp
  8014d5:	89 f0                	mov    %esi,%eax
  8014d7:	29 d8                	sub    %ebx,%eax
  8014d9:	50                   	push   %eax
  8014da:	89 d8                	mov    %ebx,%eax
  8014dc:	03 45 0c             	add    0xc(%ebp),%eax
  8014df:	50                   	push   %eax
  8014e0:	57                   	push   %edi
  8014e1:	e8 45 ff ff ff       	call   80142b <read>
		if (m < 0)
  8014e6:	83 c4 10             	add    $0x10,%esp
  8014e9:	85 c0                	test   %eax,%eax
  8014eb:	78 10                	js     8014fd <readn+0x41>
			return m;
		if (m == 0)
  8014ed:	85 c0                	test   %eax,%eax
  8014ef:	74 0a                	je     8014fb <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8014f1:	01 c3                	add    %eax,%ebx
  8014f3:	39 f3                	cmp    %esi,%ebx
  8014f5:	72 db                	jb     8014d2 <readn+0x16>
  8014f7:	89 d8                	mov    %ebx,%eax
  8014f9:	eb 02                	jmp    8014fd <readn+0x41>
  8014fb:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8014fd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801500:	5b                   	pop    %ebx
  801501:	5e                   	pop    %esi
  801502:	5f                   	pop    %edi
  801503:	5d                   	pop    %ebp
  801504:	c3                   	ret    

00801505 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801505:	55                   	push   %ebp
  801506:	89 e5                	mov    %esp,%ebp
  801508:	53                   	push   %ebx
  801509:	83 ec 14             	sub    $0x14,%esp
  80150c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80150f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801512:	50                   	push   %eax
  801513:	53                   	push   %ebx
  801514:	e8 ac fc ff ff       	call   8011c5 <fd_lookup>
  801519:	83 c4 08             	add    $0x8,%esp
  80151c:	89 c2                	mov    %eax,%edx
  80151e:	85 c0                	test   %eax,%eax
  801520:	78 68                	js     80158a <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801522:	83 ec 08             	sub    $0x8,%esp
  801525:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801528:	50                   	push   %eax
  801529:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80152c:	ff 30                	pushl  (%eax)
  80152e:	e8 e8 fc ff ff       	call   80121b <dev_lookup>
  801533:	83 c4 10             	add    $0x10,%esp
  801536:	85 c0                	test   %eax,%eax
  801538:	78 47                	js     801581 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80153a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80153d:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801541:	75 21                	jne    801564 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801543:	a1 0c 40 80 00       	mov    0x80400c,%eax
  801548:	8b 40 48             	mov    0x48(%eax),%eax
  80154b:	83 ec 04             	sub    $0x4,%esp
  80154e:	53                   	push   %ebx
  80154f:	50                   	push   %eax
  801550:	68 d5 2a 80 00       	push   $0x802ad5
  801555:	e8 97 ec ff ff       	call   8001f1 <cprintf>
		return -E_INVAL;
  80155a:	83 c4 10             	add    $0x10,%esp
  80155d:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801562:	eb 26                	jmp    80158a <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801564:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801567:	8b 52 0c             	mov    0xc(%edx),%edx
  80156a:	85 d2                	test   %edx,%edx
  80156c:	74 17                	je     801585 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80156e:	83 ec 04             	sub    $0x4,%esp
  801571:	ff 75 10             	pushl  0x10(%ebp)
  801574:	ff 75 0c             	pushl  0xc(%ebp)
  801577:	50                   	push   %eax
  801578:	ff d2                	call   *%edx
  80157a:	89 c2                	mov    %eax,%edx
  80157c:	83 c4 10             	add    $0x10,%esp
  80157f:	eb 09                	jmp    80158a <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801581:	89 c2                	mov    %eax,%edx
  801583:	eb 05                	jmp    80158a <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801585:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80158a:	89 d0                	mov    %edx,%eax
  80158c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80158f:	c9                   	leave  
  801590:	c3                   	ret    

00801591 <seek>:

int
seek(int fdnum, off_t offset)
{
  801591:	55                   	push   %ebp
  801592:	89 e5                	mov    %esp,%ebp
  801594:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801597:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80159a:	50                   	push   %eax
  80159b:	ff 75 08             	pushl  0x8(%ebp)
  80159e:	e8 22 fc ff ff       	call   8011c5 <fd_lookup>
  8015a3:	83 c4 08             	add    $0x8,%esp
  8015a6:	85 c0                	test   %eax,%eax
  8015a8:	78 0e                	js     8015b8 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8015aa:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8015ad:	8b 55 0c             	mov    0xc(%ebp),%edx
  8015b0:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8015b3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8015b8:	c9                   	leave  
  8015b9:	c3                   	ret    

008015ba <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8015ba:	55                   	push   %ebp
  8015bb:	89 e5                	mov    %esp,%ebp
  8015bd:	53                   	push   %ebx
  8015be:	83 ec 14             	sub    $0x14,%esp
  8015c1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015c4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015c7:	50                   	push   %eax
  8015c8:	53                   	push   %ebx
  8015c9:	e8 f7 fb ff ff       	call   8011c5 <fd_lookup>
  8015ce:	83 c4 08             	add    $0x8,%esp
  8015d1:	89 c2                	mov    %eax,%edx
  8015d3:	85 c0                	test   %eax,%eax
  8015d5:	78 65                	js     80163c <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015d7:	83 ec 08             	sub    $0x8,%esp
  8015da:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015dd:	50                   	push   %eax
  8015de:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015e1:	ff 30                	pushl  (%eax)
  8015e3:	e8 33 fc ff ff       	call   80121b <dev_lookup>
  8015e8:	83 c4 10             	add    $0x10,%esp
  8015eb:	85 c0                	test   %eax,%eax
  8015ed:	78 44                	js     801633 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8015ef:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015f2:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8015f6:	75 21                	jne    801619 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8015f8:	a1 0c 40 80 00       	mov    0x80400c,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8015fd:	8b 40 48             	mov    0x48(%eax),%eax
  801600:	83 ec 04             	sub    $0x4,%esp
  801603:	53                   	push   %ebx
  801604:	50                   	push   %eax
  801605:	68 98 2a 80 00       	push   $0x802a98
  80160a:	e8 e2 eb ff ff       	call   8001f1 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80160f:	83 c4 10             	add    $0x10,%esp
  801612:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801617:	eb 23                	jmp    80163c <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801619:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80161c:	8b 52 18             	mov    0x18(%edx),%edx
  80161f:	85 d2                	test   %edx,%edx
  801621:	74 14                	je     801637 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801623:	83 ec 08             	sub    $0x8,%esp
  801626:	ff 75 0c             	pushl  0xc(%ebp)
  801629:	50                   	push   %eax
  80162a:	ff d2                	call   *%edx
  80162c:	89 c2                	mov    %eax,%edx
  80162e:	83 c4 10             	add    $0x10,%esp
  801631:	eb 09                	jmp    80163c <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801633:	89 c2                	mov    %eax,%edx
  801635:	eb 05                	jmp    80163c <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801637:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  80163c:	89 d0                	mov    %edx,%eax
  80163e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801641:	c9                   	leave  
  801642:	c3                   	ret    

00801643 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801643:	55                   	push   %ebp
  801644:	89 e5                	mov    %esp,%ebp
  801646:	53                   	push   %ebx
  801647:	83 ec 14             	sub    $0x14,%esp
  80164a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80164d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801650:	50                   	push   %eax
  801651:	ff 75 08             	pushl  0x8(%ebp)
  801654:	e8 6c fb ff ff       	call   8011c5 <fd_lookup>
  801659:	83 c4 08             	add    $0x8,%esp
  80165c:	89 c2                	mov    %eax,%edx
  80165e:	85 c0                	test   %eax,%eax
  801660:	78 58                	js     8016ba <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801662:	83 ec 08             	sub    $0x8,%esp
  801665:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801668:	50                   	push   %eax
  801669:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80166c:	ff 30                	pushl  (%eax)
  80166e:	e8 a8 fb ff ff       	call   80121b <dev_lookup>
  801673:	83 c4 10             	add    $0x10,%esp
  801676:	85 c0                	test   %eax,%eax
  801678:	78 37                	js     8016b1 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80167a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80167d:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801681:	74 32                	je     8016b5 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801683:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801686:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80168d:	00 00 00 
	stat->st_isdir = 0;
  801690:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801697:	00 00 00 
	stat->st_dev = dev;
  80169a:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8016a0:	83 ec 08             	sub    $0x8,%esp
  8016a3:	53                   	push   %ebx
  8016a4:	ff 75 f0             	pushl  -0x10(%ebp)
  8016a7:	ff 50 14             	call   *0x14(%eax)
  8016aa:	89 c2                	mov    %eax,%edx
  8016ac:	83 c4 10             	add    $0x10,%esp
  8016af:	eb 09                	jmp    8016ba <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016b1:	89 c2                	mov    %eax,%edx
  8016b3:	eb 05                	jmp    8016ba <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8016b5:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8016ba:	89 d0                	mov    %edx,%eax
  8016bc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016bf:	c9                   	leave  
  8016c0:	c3                   	ret    

008016c1 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8016c1:	55                   	push   %ebp
  8016c2:	89 e5                	mov    %esp,%ebp
  8016c4:	56                   	push   %esi
  8016c5:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8016c6:	83 ec 08             	sub    $0x8,%esp
  8016c9:	6a 00                	push   $0x0
  8016cb:	ff 75 08             	pushl  0x8(%ebp)
  8016ce:	e8 d6 01 00 00       	call   8018a9 <open>
  8016d3:	89 c3                	mov    %eax,%ebx
  8016d5:	83 c4 10             	add    $0x10,%esp
  8016d8:	85 c0                	test   %eax,%eax
  8016da:	78 1b                	js     8016f7 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8016dc:	83 ec 08             	sub    $0x8,%esp
  8016df:	ff 75 0c             	pushl  0xc(%ebp)
  8016e2:	50                   	push   %eax
  8016e3:	e8 5b ff ff ff       	call   801643 <fstat>
  8016e8:	89 c6                	mov    %eax,%esi
	close(fd);
  8016ea:	89 1c 24             	mov    %ebx,(%esp)
  8016ed:	e8 fd fb ff ff       	call   8012ef <close>
	return r;
  8016f2:	83 c4 10             	add    $0x10,%esp
  8016f5:	89 f0                	mov    %esi,%eax
}
  8016f7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016fa:	5b                   	pop    %ebx
  8016fb:	5e                   	pop    %esi
  8016fc:	5d                   	pop    %ebp
  8016fd:	c3                   	ret    

008016fe <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8016fe:	55                   	push   %ebp
  8016ff:	89 e5                	mov    %esp,%ebp
  801701:	56                   	push   %esi
  801702:	53                   	push   %ebx
  801703:	89 c6                	mov    %eax,%esi
  801705:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801707:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80170e:	75 12                	jne    801722 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801710:	83 ec 0c             	sub    $0xc,%esp
  801713:	6a 01                	push   $0x1
  801715:	e8 fc f9 ff ff       	call   801116 <ipc_find_env>
  80171a:	a3 00 40 80 00       	mov    %eax,0x804000
  80171f:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801722:	6a 07                	push   $0x7
  801724:	68 00 50 80 00       	push   $0x805000
  801729:	56                   	push   %esi
  80172a:	ff 35 00 40 80 00    	pushl  0x804000
  801730:	e8 8d f9 ff ff       	call   8010c2 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801735:	83 c4 0c             	add    $0xc,%esp
  801738:	6a 00                	push   $0x0
  80173a:	53                   	push   %ebx
  80173b:	6a 00                	push   $0x0
  80173d:	e8 19 f9 ff ff       	call   80105b <ipc_recv>
}
  801742:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801745:	5b                   	pop    %ebx
  801746:	5e                   	pop    %esi
  801747:	5d                   	pop    %ebp
  801748:	c3                   	ret    

00801749 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801749:	55                   	push   %ebp
  80174a:	89 e5                	mov    %esp,%ebp
  80174c:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80174f:	8b 45 08             	mov    0x8(%ebp),%eax
  801752:	8b 40 0c             	mov    0xc(%eax),%eax
  801755:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80175a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80175d:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801762:	ba 00 00 00 00       	mov    $0x0,%edx
  801767:	b8 02 00 00 00       	mov    $0x2,%eax
  80176c:	e8 8d ff ff ff       	call   8016fe <fsipc>
}
  801771:	c9                   	leave  
  801772:	c3                   	ret    

00801773 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801773:	55                   	push   %ebp
  801774:	89 e5                	mov    %esp,%ebp
  801776:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801779:	8b 45 08             	mov    0x8(%ebp),%eax
  80177c:	8b 40 0c             	mov    0xc(%eax),%eax
  80177f:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801784:	ba 00 00 00 00       	mov    $0x0,%edx
  801789:	b8 06 00 00 00       	mov    $0x6,%eax
  80178e:	e8 6b ff ff ff       	call   8016fe <fsipc>
}
  801793:	c9                   	leave  
  801794:	c3                   	ret    

00801795 <devfile_stat>:

}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801795:	55                   	push   %ebp
  801796:	89 e5                	mov    %esp,%ebp
  801798:	53                   	push   %ebx
  801799:	83 ec 04             	sub    $0x4,%esp
  80179c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80179f:	8b 45 08             	mov    0x8(%ebp),%eax
  8017a2:	8b 40 0c             	mov    0xc(%eax),%eax
  8017a5:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8017aa:	ba 00 00 00 00       	mov    $0x0,%edx
  8017af:	b8 05 00 00 00       	mov    $0x5,%eax
  8017b4:	e8 45 ff ff ff       	call   8016fe <fsipc>
  8017b9:	85 c0                	test   %eax,%eax
  8017bb:	78 2c                	js     8017e9 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8017bd:	83 ec 08             	sub    $0x8,%esp
  8017c0:	68 00 50 80 00       	push   $0x805000
  8017c5:	53                   	push   %ebx
  8017c6:	e8 ab ef ff ff       	call   800776 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8017cb:	a1 80 50 80 00       	mov    0x805080,%eax
  8017d0:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8017d6:	a1 84 50 80 00       	mov    0x805084,%eax
  8017db:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8017e1:	83 c4 10             	add    $0x10,%esp
  8017e4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017e9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017ec:	c9                   	leave  
  8017ed:	c3                   	ret    

008017ee <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8017ee:	55                   	push   %ebp
  8017ef:	89 e5                	mov    %esp,%ebp
  8017f1:	83 ec 0c             	sub    $0xc,%esp
  8017f4:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	// panic("devfile_write not implemented");

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8017f7:	8b 55 08             	mov    0x8(%ebp),%edx
  8017fa:	8b 52 0c             	mov    0xc(%edx),%edx
  8017fd:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  801803:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  801808:	50                   	push   %eax
  801809:	ff 75 0c             	pushl  0xc(%ebp)
  80180c:	68 08 50 80 00       	push   $0x805008
  801811:	e8 f2 f0 ff ff       	call   800908 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  801816:	ba 00 00 00 00       	mov    $0x0,%edx
  80181b:	b8 04 00 00 00       	mov    $0x4,%eax
  801820:	e8 d9 fe ff ff       	call   8016fe <fsipc>

}
  801825:	c9                   	leave  
  801826:	c3                   	ret    

00801827 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801827:	55                   	push   %ebp
  801828:	89 e5                	mov    %esp,%ebp
  80182a:	56                   	push   %esi
  80182b:	53                   	push   %ebx
  80182c:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80182f:	8b 45 08             	mov    0x8(%ebp),%eax
  801832:	8b 40 0c             	mov    0xc(%eax),%eax
  801835:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80183a:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801840:	ba 00 00 00 00       	mov    $0x0,%edx
  801845:	b8 03 00 00 00       	mov    $0x3,%eax
  80184a:	e8 af fe ff ff       	call   8016fe <fsipc>
  80184f:	89 c3                	mov    %eax,%ebx
  801851:	85 c0                	test   %eax,%eax
  801853:	78 4b                	js     8018a0 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801855:	39 c6                	cmp    %eax,%esi
  801857:	73 16                	jae    80186f <devfile_read+0x48>
  801859:	68 08 2b 80 00       	push   $0x802b08
  80185e:	68 0f 2b 80 00       	push   $0x802b0f
  801863:	6a 7c                	push   $0x7c
  801865:	68 24 2b 80 00       	push   $0x802b24
  80186a:	e8 24 0a 00 00       	call   802293 <_panic>
	assert(r <= PGSIZE);
  80186f:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801874:	7e 16                	jle    80188c <devfile_read+0x65>
  801876:	68 2f 2b 80 00       	push   $0x802b2f
  80187b:	68 0f 2b 80 00       	push   $0x802b0f
  801880:	6a 7d                	push   $0x7d
  801882:	68 24 2b 80 00       	push   $0x802b24
  801887:	e8 07 0a 00 00       	call   802293 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80188c:	83 ec 04             	sub    $0x4,%esp
  80188f:	50                   	push   %eax
  801890:	68 00 50 80 00       	push   $0x805000
  801895:	ff 75 0c             	pushl  0xc(%ebp)
  801898:	e8 6b f0 ff ff       	call   800908 <memmove>
	return r;
  80189d:	83 c4 10             	add    $0x10,%esp
}
  8018a0:	89 d8                	mov    %ebx,%eax
  8018a2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018a5:	5b                   	pop    %ebx
  8018a6:	5e                   	pop    %esi
  8018a7:	5d                   	pop    %ebp
  8018a8:	c3                   	ret    

008018a9 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8018a9:	55                   	push   %ebp
  8018aa:	89 e5                	mov    %esp,%ebp
  8018ac:	53                   	push   %ebx
  8018ad:	83 ec 20             	sub    $0x20,%esp
  8018b0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8018b3:	53                   	push   %ebx
  8018b4:	e8 84 ee ff ff       	call   80073d <strlen>
  8018b9:	83 c4 10             	add    $0x10,%esp
  8018bc:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8018c1:	7f 67                	jg     80192a <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8018c3:	83 ec 0c             	sub    $0xc,%esp
  8018c6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018c9:	50                   	push   %eax
  8018ca:	e8 a7 f8 ff ff       	call   801176 <fd_alloc>
  8018cf:	83 c4 10             	add    $0x10,%esp
		return r;
  8018d2:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8018d4:	85 c0                	test   %eax,%eax
  8018d6:	78 57                	js     80192f <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8018d8:	83 ec 08             	sub    $0x8,%esp
  8018db:	53                   	push   %ebx
  8018dc:	68 00 50 80 00       	push   $0x805000
  8018e1:	e8 90 ee ff ff       	call   800776 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8018e6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018e9:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8018ee:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8018f1:	b8 01 00 00 00       	mov    $0x1,%eax
  8018f6:	e8 03 fe ff ff       	call   8016fe <fsipc>
  8018fb:	89 c3                	mov    %eax,%ebx
  8018fd:	83 c4 10             	add    $0x10,%esp
  801900:	85 c0                	test   %eax,%eax
  801902:	79 14                	jns    801918 <open+0x6f>
		fd_close(fd, 0);
  801904:	83 ec 08             	sub    $0x8,%esp
  801907:	6a 00                	push   $0x0
  801909:	ff 75 f4             	pushl  -0xc(%ebp)
  80190c:	e8 5d f9 ff ff       	call   80126e <fd_close>
		return r;
  801911:	83 c4 10             	add    $0x10,%esp
  801914:	89 da                	mov    %ebx,%edx
  801916:	eb 17                	jmp    80192f <open+0x86>
	}

	return fd2num(fd);
  801918:	83 ec 0c             	sub    $0xc,%esp
  80191b:	ff 75 f4             	pushl  -0xc(%ebp)
  80191e:	e8 2c f8 ff ff       	call   80114f <fd2num>
  801923:	89 c2                	mov    %eax,%edx
  801925:	83 c4 10             	add    $0x10,%esp
  801928:	eb 05                	jmp    80192f <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  80192a:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  80192f:	89 d0                	mov    %edx,%eax
  801931:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801934:	c9                   	leave  
  801935:	c3                   	ret    

00801936 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801936:	55                   	push   %ebp
  801937:	89 e5                	mov    %esp,%ebp
  801939:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80193c:	ba 00 00 00 00       	mov    $0x0,%edx
  801941:	b8 08 00 00 00       	mov    $0x8,%eax
  801946:	e8 b3 fd ff ff       	call   8016fe <fsipc>
}
  80194b:	c9                   	leave  
  80194c:	c3                   	ret    

0080194d <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  80194d:	55                   	push   %ebp
  80194e:	89 e5                	mov    %esp,%ebp
  801950:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  801953:	68 3b 2b 80 00       	push   $0x802b3b
  801958:	ff 75 0c             	pushl  0xc(%ebp)
  80195b:	e8 16 ee ff ff       	call   800776 <strcpy>
	return 0;
}
  801960:	b8 00 00 00 00       	mov    $0x0,%eax
  801965:	c9                   	leave  
  801966:	c3                   	ret    

00801967 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801967:	55                   	push   %ebp
  801968:	89 e5                	mov    %esp,%ebp
  80196a:	53                   	push   %ebx
  80196b:	83 ec 10             	sub    $0x10,%esp
  80196e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801971:	53                   	push   %ebx
  801972:	e8 cd 09 00 00       	call   802344 <pageref>
  801977:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  80197a:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  80197f:	83 f8 01             	cmp    $0x1,%eax
  801982:	75 10                	jne    801994 <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  801984:	83 ec 0c             	sub    $0xc,%esp
  801987:	ff 73 0c             	pushl  0xc(%ebx)
  80198a:	e8 c0 02 00 00       	call   801c4f <nsipc_close>
  80198f:	89 c2                	mov    %eax,%edx
  801991:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  801994:	89 d0                	mov    %edx,%eax
  801996:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801999:	c9                   	leave  
  80199a:	c3                   	ret    

0080199b <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  80199b:	55                   	push   %ebp
  80199c:	89 e5                	mov    %esp,%ebp
  80199e:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  8019a1:	6a 00                	push   $0x0
  8019a3:	ff 75 10             	pushl  0x10(%ebp)
  8019a6:	ff 75 0c             	pushl  0xc(%ebp)
  8019a9:	8b 45 08             	mov    0x8(%ebp),%eax
  8019ac:	ff 70 0c             	pushl  0xc(%eax)
  8019af:	e8 78 03 00 00       	call   801d2c <nsipc_send>
}
  8019b4:	c9                   	leave  
  8019b5:	c3                   	ret    

008019b6 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  8019b6:	55                   	push   %ebp
  8019b7:	89 e5                	mov    %esp,%ebp
  8019b9:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  8019bc:	6a 00                	push   $0x0
  8019be:	ff 75 10             	pushl  0x10(%ebp)
  8019c1:	ff 75 0c             	pushl  0xc(%ebp)
  8019c4:	8b 45 08             	mov    0x8(%ebp),%eax
  8019c7:	ff 70 0c             	pushl  0xc(%eax)
  8019ca:	e8 f1 02 00 00       	call   801cc0 <nsipc_recv>
}
  8019cf:	c9                   	leave  
  8019d0:	c3                   	ret    

008019d1 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  8019d1:	55                   	push   %ebp
  8019d2:	89 e5                	mov    %esp,%ebp
  8019d4:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  8019d7:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8019da:	52                   	push   %edx
  8019db:	50                   	push   %eax
  8019dc:	e8 e4 f7 ff ff       	call   8011c5 <fd_lookup>
  8019e1:	83 c4 10             	add    $0x10,%esp
  8019e4:	85 c0                	test   %eax,%eax
  8019e6:	78 17                	js     8019ff <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  8019e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019eb:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  8019f1:	39 08                	cmp    %ecx,(%eax)
  8019f3:	75 05                	jne    8019fa <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  8019f5:	8b 40 0c             	mov    0xc(%eax),%eax
  8019f8:	eb 05                	jmp    8019ff <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  8019fa:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  8019ff:	c9                   	leave  
  801a00:	c3                   	ret    

00801a01 <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  801a01:	55                   	push   %ebp
  801a02:	89 e5                	mov    %esp,%ebp
  801a04:	56                   	push   %esi
  801a05:	53                   	push   %ebx
  801a06:	83 ec 1c             	sub    $0x1c,%esp
  801a09:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801a0b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a0e:	50                   	push   %eax
  801a0f:	e8 62 f7 ff ff       	call   801176 <fd_alloc>
  801a14:	89 c3                	mov    %eax,%ebx
  801a16:	83 c4 10             	add    $0x10,%esp
  801a19:	85 c0                	test   %eax,%eax
  801a1b:	78 1b                	js     801a38 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801a1d:	83 ec 04             	sub    $0x4,%esp
  801a20:	68 07 04 00 00       	push   $0x407
  801a25:	ff 75 f4             	pushl  -0xc(%ebp)
  801a28:	6a 00                	push   $0x0
  801a2a:	e8 4a f1 ff ff       	call   800b79 <sys_page_alloc>
  801a2f:	89 c3                	mov    %eax,%ebx
  801a31:	83 c4 10             	add    $0x10,%esp
  801a34:	85 c0                	test   %eax,%eax
  801a36:	79 10                	jns    801a48 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  801a38:	83 ec 0c             	sub    $0xc,%esp
  801a3b:	56                   	push   %esi
  801a3c:	e8 0e 02 00 00       	call   801c4f <nsipc_close>
		return r;
  801a41:	83 c4 10             	add    $0x10,%esp
  801a44:	89 d8                	mov    %ebx,%eax
  801a46:	eb 24                	jmp    801a6c <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801a48:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801a4e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a51:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801a53:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a56:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801a5d:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801a60:	83 ec 0c             	sub    $0xc,%esp
  801a63:	50                   	push   %eax
  801a64:	e8 e6 f6 ff ff       	call   80114f <fd2num>
  801a69:	83 c4 10             	add    $0x10,%esp
}
  801a6c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a6f:	5b                   	pop    %ebx
  801a70:	5e                   	pop    %esi
  801a71:	5d                   	pop    %ebp
  801a72:	c3                   	ret    

00801a73 <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801a73:	55                   	push   %ebp
  801a74:	89 e5                	mov    %esp,%ebp
  801a76:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801a79:	8b 45 08             	mov    0x8(%ebp),%eax
  801a7c:	e8 50 ff ff ff       	call   8019d1 <fd2sockid>
		return r;
  801a81:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  801a83:	85 c0                	test   %eax,%eax
  801a85:	78 1f                	js     801aa6 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801a87:	83 ec 04             	sub    $0x4,%esp
  801a8a:	ff 75 10             	pushl  0x10(%ebp)
  801a8d:	ff 75 0c             	pushl  0xc(%ebp)
  801a90:	50                   	push   %eax
  801a91:	e8 12 01 00 00       	call   801ba8 <nsipc_accept>
  801a96:	83 c4 10             	add    $0x10,%esp
		return r;
  801a99:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801a9b:	85 c0                	test   %eax,%eax
  801a9d:	78 07                	js     801aa6 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  801a9f:	e8 5d ff ff ff       	call   801a01 <alloc_sockfd>
  801aa4:	89 c1                	mov    %eax,%ecx
}
  801aa6:	89 c8                	mov    %ecx,%eax
  801aa8:	c9                   	leave  
  801aa9:	c3                   	ret    

00801aaa <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801aaa:	55                   	push   %ebp
  801aab:	89 e5                	mov    %esp,%ebp
  801aad:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801ab0:	8b 45 08             	mov    0x8(%ebp),%eax
  801ab3:	e8 19 ff ff ff       	call   8019d1 <fd2sockid>
  801ab8:	85 c0                	test   %eax,%eax
  801aba:	78 12                	js     801ace <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  801abc:	83 ec 04             	sub    $0x4,%esp
  801abf:	ff 75 10             	pushl  0x10(%ebp)
  801ac2:	ff 75 0c             	pushl  0xc(%ebp)
  801ac5:	50                   	push   %eax
  801ac6:	e8 2d 01 00 00       	call   801bf8 <nsipc_bind>
  801acb:	83 c4 10             	add    $0x10,%esp
}
  801ace:	c9                   	leave  
  801acf:	c3                   	ret    

00801ad0 <shutdown>:

int
shutdown(int s, int how)
{
  801ad0:	55                   	push   %ebp
  801ad1:	89 e5                	mov    %esp,%ebp
  801ad3:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801ad6:	8b 45 08             	mov    0x8(%ebp),%eax
  801ad9:	e8 f3 fe ff ff       	call   8019d1 <fd2sockid>
  801ade:	85 c0                	test   %eax,%eax
  801ae0:	78 0f                	js     801af1 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801ae2:	83 ec 08             	sub    $0x8,%esp
  801ae5:	ff 75 0c             	pushl  0xc(%ebp)
  801ae8:	50                   	push   %eax
  801ae9:	e8 3f 01 00 00       	call   801c2d <nsipc_shutdown>
  801aee:	83 c4 10             	add    $0x10,%esp
}
  801af1:	c9                   	leave  
  801af2:	c3                   	ret    

00801af3 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801af3:	55                   	push   %ebp
  801af4:	89 e5                	mov    %esp,%ebp
  801af6:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801af9:	8b 45 08             	mov    0x8(%ebp),%eax
  801afc:	e8 d0 fe ff ff       	call   8019d1 <fd2sockid>
  801b01:	85 c0                	test   %eax,%eax
  801b03:	78 12                	js     801b17 <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  801b05:	83 ec 04             	sub    $0x4,%esp
  801b08:	ff 75 10             	pushl  0x10(%ebp)
  801b0b:	ff 75 0c             	pushl  0xc(%ebp)
  801b0e:	50                   	push   %eax
  801b0f:	e8 55 01 00 00       	call   801c69 <nsipc_connect>
  801b14:	83 c4 10             	add    $0x10,%esp
}
  801b17:	c9                   	leave  
  801b18:	c3                   	ret    

00801b19 <listen>:

int
listen(int s, int backlog)
{
  801b19:	55                   	push   %ebp
  801b1a:	89 e5                	mov    %esp,%ebp
  801b1c:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801b1f:	8b 45 08             	mov    0x8(%ebp),%eax
  801b22:	e8 aa fe ff ff       	call   8019d1 <fd2sockid>
  801b27:	85 c0                	test   %eax,%eax
  801b29:	78 0f                	js     801b3a <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801b2b:	83 ec 08             	sub    $0x8,%esp
  801b2e:	ff 75 0c             	pushl  0xc(%ebp)
  801b31:	50                   	push   %eax
  801b32:	e8 67 01 00 00       	call   801c9e <nsipc_listen>
  801b37:	83 c4 10             	add    $0x10,%esp
}
  801b3a:	c9                   	leave  
  801b3b:	c3                   	ret    

00801b3c <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801b3c:	55                   	push   %ebp
  801b3d:	89 e5                	mov    %esp,%ebp
  801b3f:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801b42:	ff 75 10             	pushl  0x10(%ebp)
  801b45:	ff 75 0c             	pushl  0xc(%ebp)
  801b48:	ff 75 08             	pushl  0x8(%ebp)
  801b4b:	e8 3a 02 00 00       	call   801d8a <nsipc_socket>
  801b50:	83 c4 10             	add    $0x10,%esp
  801b53:	85 c0                	test   %eax,%eax
  801b55:	78 05                	js     801b5c <socket+0x20>
		return r;
	return alloc_sockfd(r);
  801b57:	e8 a5 fe ff ff       	call   801a01 <alloc_sockfd>
}
  801b5c:	c9                   	leave  
  801b5d:	c3                   	ret    

00801b5e <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801b5e:	55                   	push   %ebp
  801b5f:	89 e5                	mov    %esp,%ebp
  801b61:	53                   	push   %ebx
  801b62:	83 ec 04             	sub    $0x4,%esp
  801b65:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801b67:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801b6e:	75 12                	jne    801b82 <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801b70:	83 ec 0c             	sub    $0xc,%esp
  801b73:	6a 02                	push   $0x2
  801b75:	e8 9c f5 ff ff       	call   801116 <ipc_find_env>
  801b7a:	a3 04 40 80 00       	mov    %eax,0x804004
  801b7f:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801b82:	6a 07                	push   $0x7
  801b84:	68 00 60 80 00       	push   $0x806000
  801b89:	53                   	push   %ebx
  801b8a:	ff 35 04 40 80 00    	pushl  0x804004
  801b90:	e8 2d f5 ff ff       	call   8010c2 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801b95:	83 c4 0c             	add    $0xc,%esp
  801b98:	6a 00                	push   $0x0
  801b9a:	6a 00                	push   $0x0
  801b9c:	6a 00                	push   $0x0
  801b9e:	e8 b8 f4 ff ff       	call   80105b <ipc_recv>
}
  801ba3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ba6:	c9                   	leave  
  801ba7:	c3                   	ret    

00801ba8 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801ba8:	55                   	push   %ebp
  801ba9:	89 e5                	mov    %esp,%ebp
  801bab:	56                   	push   %esi
  801bac:	53                   	push   %ebx
  801bad:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801bb0:	8b 45 08             	mov    0x8(%ebp),%eax
  801bb3:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801bb8:	8b 06                	mov    (%esi),%eax
  801bba:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801bbf:	b8 01 00 00 00       	mov    $0x1,%eax
  801bc4:	e8 95 ff ff ff       	call   801b5e <nsipc>
  801bc9:	89 c3                	mov    %eax,%ebx
  801bcb:	85 c0                	test   %eax,%eax
  801bcd:	78 20                	js     801bef <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801bcf:	83 ec 04             	sub    $0x4,%esp
  801bd2:	ff 35 10 60 80 00    	pushl  0x806010
  801bd8:	68 00 60 80 00       	push   $0x806000
  801bdd:	ff 75 0c             	pushl  0xc(%ebp)
  801be0:	e8 23 ed ff ff       	call   800908 <memmove>
		*addrlen = ret->ret_addrlen;
  801be5:	a1 10 60 80 00       	mov    0x806010,%eax
  801bea:	89 06                	mov    %eax,(%esi)
  801bec:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  801bef:	89 d8                	mov    %ebx,%eax
  801bf1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801bf4:	5b                   	pop    %ebx
  801bf5:	5e                   	pop    %esi
  801bf6:	5d                   	pop    %ebp
  801bf7:	c3                   	ret    

00801bf8 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801bf8:	55                   	push   %ebp
  801bf9:	89 e5                	mov    %esp,%ebp
  801bfb:	53                   	push   %ebx
  801bfc:	83 ec 08             	sub    $0x8,%esp
  801bff:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801c02:	8b 45 08             	mov    0x8(%ebp),%eax
  801c05:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801c0a:	53                   	push   %ebx
  801c0b:	ff 75 0c             	pushl  0xc(%ebp)
  801c0e:	68 04 60 80 00       	push   $0x806004
  801c13:	e8 f0 ec ff ff       	call   800908 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801c18:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801c1e:	b8 02 00 00 00       	mov    $0x2,%eax
  801c23:	e8 36 ff ff ff       	call   801b5e <nsipc>
}
  801c28:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c2b:	c9                   	leave  
  801c2c:	c3                   	ret    

00801c2d <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801c2d:	55                   	push   %ebp
  801c2e:	89 e5                	mov    %esp,%ebp
  801c30:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801c33:	8b 45 08             	mov    0x8(%ebp),%eax
  801c36:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801c3b:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c3e:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801c43:	b8 03 00 00 00       	mov    $0x3,%eax
  801c48:	e8 11 ff ff ff       	call   801b5e <nsipc>
}
  801c4d:	c9                   	leave  
  801c4e:	c3                   	ret    

00801c4f <nsipc_close>:

int
nsipc_close(int s)
{
  801c4f:	55                   	push   %ebp
  801c50:	89 e5                	mov    %esp,%ebp
  801c52:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801c55:	8b 45 08             	mov    0x8(%ebp),%eax
  801c58:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801c5d:	b8 04 00 00 00       	mov    $0x4,%eax
  801c62:	e8 f7 fe ff ff       	call   801b5e <nsipc>
}
  801c67:	c9                   	leave  
  801c68:	c3                   	ret    

00801c69 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801c69:	55                   	push   %ebp
  801c6a:	89 e5                	mov    %esp,%ebp
  801c6c:	53                   	push   %ebx
  801c6d:	83 ec 08             	sub    $0x8,%esp
  801c70:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801c73:	8b 45 08             	mov    0x8(%ebp),%eax
  801c76:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801c7b:	53                   	push   %ebx
  801c7c:	ff 75 0c             	pushl  0xc(%ebp)
  801c7f:	68 04 60 80 00       	push   $0x806004
  801c84:	e8 7f ec ff ff       	call   800908 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801c89:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801c8f:	b8 05 00 00 00       	mov    $0x5,%eax
  801c94:	e8 c5 fe ff ff       	call   801b5e <nsipc>
}
  801c99:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c9c:	c9                   	leave  
  801c9d:	c3                   	ret    

00801c9e <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801c9e:	55                   	push   %ebp
  801c9f:	89 e5                	mov    %esp,%ebp
  801ca1:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801ca4:	8b 45 08             	mov    0x8(%ebp),%eax
  801ca7:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801cac:	8b 45 0c             	mov    0xc(%ebp),%eax
  801caf:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801cb4:	b8 06 00 00 00       	mov    $0x6,%eax
  801cb9:	e8 a0 fe ff ff       	call   801b5e <nsipc>
}
  801cbe:	c9                   	leave  
  801cbf:	c3                   	ret    

00801cc0 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801cc0:	55                   	push   %ebp
  801cc1:	89 e5                	mov    %esp,%ebp
  801cc3:	56                   	push   %esi
  801cc4:	53                   	push   %ebx
  801cc5:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801cc8:	8b 45 08             	mov    0x8(%ebp),%eax
  801ccb:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801cd0:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801cd6:	8b 45 14             	mov    0x14(%ebp),%eax
  801cd9:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801cde:	b8 07 00 00 00       	mov    $0x7,%eax
  801ce3:	e8 76 fe ff ff       	call   801b5e <nsipc>
  801ce8:	89 c3                	mov    %eax,%ebx
  801cea:	85 c0                	test   %eax,%eax
  801cec:	78 35                	js     801d23 <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  801cee:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801cf3:	7f 04                	jg     801cf9 <nsipc_recv+0x39>
  801cf5:	39 c6                	cmp    %eax,%esi
  801cf7:	7d 16                	jge    801d0f <nsipc_recv+0x4f>
  801cf9:	68 47 2b 80 00       	push   $0x802b47
  801cfe:	68 0f 2b 80 00       	push   $0x802b0f
  801d03:	6a 62                	push   $0x62
  801d05:	68 5c 2b 80 00       	push   $0x802b5c
  801d0a:	e8 84 05 00 00       	call   802293 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801d0f:	83 ec 04             	sub    $0x4,%esp
  801d12:	50                   	push   %eax
  801d13:	68 00 60 80 00       	push   $0x806000
  801d18:	ff 75 0c             	pushl  0xc(%ebp)
  801d1b:	e8 e8 eb ff ff       	call   800908 <memmove>
  801d20:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801d23:	89 d8                	mov    %ebx,%eax
  801d25:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d28:	5b                   	pop    %ebx
  801d29:	5e                   	pop    %esi
  801d2a:	5d                   	pop    %ebp
  801d2b:	c3                   	ret    

00801d2c <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801d2c:	55                   	push   %ebp
  801d2d:	89 e5                	mov    %esp,%ebp
  801d2f:	53                   	push   %ebx
  801d30:	83 ec 04             	sub    $0x4,%esp
  801d33:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801d36:	8b 45 08             	mov    0x8(%ebp),%eax
  801d39:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801d3e:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801d44:	7e 16                	jle    801d5c <nsipc_send+0x30>
  801d46:	68 68 2b 80 00       	push   $0x802b68
  801d4b:	68 0f 2b 80 00       	push   $0x802b0f
  801d50:	6a 6d                	push   $0x6d
  801d52:	68 5c 2b 80 00       	push   $0x802b5c
  801d57:	e8 37 05 00 00       	call   802293 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801d5c:	83 ec 04             	sub    $0x4,%esp
  801d5f:	53                   	push   %ebx
  801d60:	ff 75 0c             	pushl  0xc(%ebp)
  801d63:	68 0c 60 80 00       	push   $0x80600c
  801d68:	e8 9b eb ff ff       	call   800908 <memmove>
	nsipcbuf.send.req_size = size;
  801d6d:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801d73:	8b 45 14             	mov    0x14(%ebp),%eax
  801d76:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801d7b:	b8 08 00 00 00       	mov    $0x8,%eax
  801d80:	e8 d9 fd ff ff       	call   801b5e <nsipc>
}
  801d85:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801d88:	c9                   	leave  
  801d89:	c3                   	ret    

00801d8a <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801d8a:	55                   	push   %ebp
  801d8b:	89 e5                	mov    %esp,%ebp
  801d8d:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801d90:	8b 45 08             	mov    0x8(%ebp),%eax
  801d93:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801d98:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d9b:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801da0:	8b 45 10             	mov    0x10(%ebp),%eax
  801da3:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801da8:	b8 09 00 00 00       	mov    $0x9,%eax
  801dad:	e8 ac fd ff ff       	call   801b5e <nsipc>
}
  801db2:	c9                   	leave  
  801db3:	c3                   	ret    

00801db4 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801db4:	55                   	push   %ebp
  801db5:	89 e5                	mov    %esp,%ebp
  801db7:	56                   	push   %esi
  801db8:	53                   	push   %ebx
  801db9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801dbc:	83 ec 0c             	sub    $0xc,%esp
  801dbf:	ff 75 08             	pushl  0x8(%ebp)
  801dc2:	e8 98 f3 ff ff       	call   80115f <fd2data>
  801dc7:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801dc9:	83 c4 08             	add    $0x8,%esp
  801dcc:	68 74 2b 80 00       	push   $0x802b74
  801dd1:	53                   	push   %ebx
  801dd2:	e8 9f e9 ff ff       	call   800776 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801dd7:	8b 46 04             	mov    0x4(%esi),%eax
  801dda:	2b 06                	sub    (%esi),%eax
  801ddc:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801de2:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801de9:	00 00 00 
	stat->st_dev = &devpipe;
  801dec:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801df3:	30 80 00 
	return 0;
}
  801df6:	b8 00 00 00 00       	mov    $0x0,%eax
  801dfb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801dfe:	5b                   	pop    %ebx
  801dff:	5e                   	pop    %esi
  801e00:	5d                   	pop    %ebp
  801e01:	c3                   	ret    

00801e02 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801e02:	55                   	push   %ebp
  801e03:	89 e5                	mov    %esp,%ebp
  801e05:	53                   	push   %ebx
  801e06:	83 ec 0c             	sub    $0xc,%esp
  801e09:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801e0c:	53                   	push   %ebx
  801e0d:	6a 00                	push   $0x0
  801e0f:	e8 ea ed ff ff       	call   800bfe <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801e14:	89 1c 24             	mov    %ebx,(%esp)
  801e17:	e8 43 f3 ff ff       	call   80115f <fd2data>
  801e1c:	83 c4 08             	add    $0x8,%esp
  801e1f:	50                   	push   %eax
  801e20:	6a 00                	push   $0x0
  801e22:	e8 d7 ed ff ff       	call   800bfe <sys_page_unmap>
}
  801e27:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801e2a:	c9                   	leave  
  801e2b:	c3                   	ret    

00801e2c <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801e2c:	55                   	push   %ebp
  801e2d:	89 e5                	mov    %esp,%ebp
  801e2f:	57                   	push   %edi
  801e30:	56                   	push   %esi
  801e31:	53                   	push   %ebx
  801e32:	83 ec 1c             	sub    $0x1c,%esp
  801e35:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801e38:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801e3a:	a1 0c 40 80 00       	mov    0x80400c,%eax
  801e3f:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801e42:	83 ec 0c             	sub    $0xc,%esp
  801e45:	ff 75 e0             	pushl  -0x20(%ebp)
  801e48:	e8 f7 04 00 00       	call   802344 <pageref>
  801e4d:	89 c3                	mov    %eax,%ebx
  801e4f:	89 3c 24             	mov    %edi,(%esp)
  801e52:	e8 ed 04 00 00       	call   802344 <pageref>
  801e57:	83 c4 10             	add    $0x10,%esp
  801e5a:	39 c3                	cmp    %eax,%ebx
  801e5c:	0f 94 c1             	sete   %cl
  801e5f:	0f b6 c9             	movzbl %cl,%ecx
  801e62:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801e65:	8b 15 0c 40 80 00    	mov    0x80400c,%edx
  801e6b:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801e6e:	39 ce                	cmp    %ecx,%esi
  801e70:	74 1b                	je     801e8d <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801e72:	39 c3                	cmp    %eax,%ebx
  801e74:	75 c4                	jne    801e3a <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801e76:	8b 42 58             	mov    0x58(%edx),%eax
  801e79:	ff 75 e4             	pushl  -0x1c(%ebp)
  801e7c:	50                   	push   %eax
  801e7d:	56                   	push   %esi
  801e7e:	68 7b 2b 80 00       	push   $0x802b7b
  801e83:	e8 69 e3 ff ff       	call   8001f1 <cprintf>
  801e88:	83 c4 10             	add    $0x10,%esp
  801e8b:	eb ad                	jmp    801e3a <_pipeisclosed+0xe>
	}
}
  801e8d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801e90:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e93:	5b                   	pop    %ebx
  801e94:	5e                   	pop    %esi
  801e95:	5f                   	pop    %edi
  801e96:	5d                   	pop    %ebp
  801e97:	c3                   	ret    

00801e98 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801e98:	55                   	push   %ebp
  801e99:	89 e5                	mov    %esp,%ebp
  801e9b:	57                   	push   %edi
  801e9c:	56                   	push   %esi
  801e9d:	53                   	push   %ebx
  801e9e:	83 ec 28             	sub    $0x28,%esp
  801ea1:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801ea4:	56                   	push   %esi
  801ea5:	e8 b5 f2 ff ff       	call   80115f <fd2data>
  801eaa:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801eac:	83 c4 10             	add    $0x10,%esp
  801eaf:	bf 00 00 00 00       	mov    $0x0,%edi
  801eb4:	eb 4b                	jmp    801f01 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801eb6:	89 da                	mov    %ebx,%edx
  801eb8:	89 f0                	mov    %esi,%eax
  801eba:	e8 6d ff ff ff       	call   801e2c <_pipeisclosed>
  801ebf:	85 c0                	test   %eax,%eax
  801ec1:	75 48                	jne    801f0b <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801ec3:	e8 92 ec ff ff       	call   800b5a <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801ec8:	8b 43 04             	mov    0x4(%ebx),%eax
  801ecb:	8b 0b                	mov    (%ebx),%ecx
  801ecd:	8d 51 20             	lea    0x20(%ecx),%edx
  801ed0:	39 d0                	cmp    %edx,%eax
  801ed2:	73 e2                	jae    801eb6 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801ed4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801ed7:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801edb:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801ede:	89 c2                	mov    %eax,%edx
  801ee0:	c1 fa 1f             	sar    $0x1f,%edx
  801ee3:	89 d1                	mov    %edx,%ecx
  801ee5:	c1 e9 1b             	shr    $0x1b,%ecx
  801ee8:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801eeb:	83 e2 1f             	and    $0x1f,%edx
  801eee:	29 ca                	sub    %ecx,%edx
  801ef0:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801ef4:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801ef8:	83 c0 01             	add    $0x1,%eax
  801efb:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801efe:	83 c7 01             	add    $0x1,%edi
  801f01:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801f04:	75 c2                	jne    801ec8 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801f06:	8b 45 10             	mov    0x10(%ebp),%eax
  801f09:	eb 05                	jmp    801f10 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801f0b:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801f10:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f13:	5b                   	pop    %ebx
  801f14:	5e                   	pop    %esi
  801f15:	5f                   	pop    %edi
  801f16:	5d                   	pop    %ebp
  801f17:	c3                   	ret    

00801f18 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801f18:	55                   	push   %ebp
  801f19:	89 e5                	mov    %esp,%ebp
  801f1b:	57                   	push   %edi
  801f1c:	56                   	push   %esi
  801f1d:	53                   	push   %ebx
  801f1e:	83 ec 18             	sub    $0x18,%esp
  801f21:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801f24:	57                   	push   %edi
  801f25:	e8 35 f2 ff ff       	call   80115f <fd2data>
  801f2a:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801f2c:	83 c4 10             	add    $0x10,%esp
  801f2f:	bb 00 00 00 00       	mov    $0x0,%ebx
  801f34:	eb 3d                	jmp    801f73 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801f36:	85 db                	test   %ebx,%ebx
  801f38:	74 04                	je     801f3e <devpipe_read+0x26>
				return i;
  801f3a:	89 d8                	mov    %ebx,%eax
  801f3c:	eb 44                	jmp    801f82 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801f3e:	89 f2                	mov    %esi,%edx
  801f40:	89 f8                	mov    %edi,%eax
  801f42:	e8 e5 fe ff ff       	call   801e2c <_pipeisclosed>
  801f47:	85 c0                	test   %eax,%eax
  801f49:	75 32                	jne    801f7d <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801f4b:	e8 0a ec ff ff       	call   800b5a <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801f50:	8b 06                	mov    (%esi),%eax
  801f52:	3b 46 04             	cmp    0x4(%esi),%eax
  801f55:	74 df                	je     801f36 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801f57:	99                   	cltd   
  801f58:	c1 ea 1b             	shr    $0x1b,%edx
  801f5b:	01 d0                	add    %edx,%eax
  801f5d:	83 e0 1f             	and    $0x1f,%eax
  801f60:	29 d0                	sub    %edx,%eax
  801f62:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801f67:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801f6a:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801f6d:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801f70:	83 c3 01             	add    $0x1,%ebx
  801f73:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801f76:	75 d8                	jne    801f50 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801f78:	8b 45 10             	mov    0x10(%ebp),%eax
  801f7b:	eb 05                	jmp    801f82 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801f7d:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801f82:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f85:	5b                   	pop    %ebx
  801f86:	5e                   	pop    %esi
  801f87:	5f                   	pop    %edi
  801f88:	5d                   	pop    %ebp
  801f89:	c3                   	ret    

00801f8a <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801f8a:	55                   	push   %ebp
  801f8b:	89 e5                	mov    %esp,%ebp
  801f8d:	56                   	push   %esi
  801f8e:	53                   	push   %ebx
  801f8f:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801f92:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f95:	50                   	push   %eax
  801f96:	e8 db f1 ff ff       	call   801176 <fd_alloc>
  801f9b:	83 c4 10             	add    $0x10,%esp
  801f9e:	89 c2                	mov    %eax,%edx
  801fa0:	85 c0                	test   %eax,%eax
  801fa2:	0f 88 2c 01 00 00    	js     8020d4 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801fa8:	83 ec 04             	sub    $0x4,%esp
  801fab:	68 07 04 00 00       	push   $0x407
  801fb0:	ff 75 f4             	pushl  -0xc(%ebp)
  801fb3:	6a 00                	push   $0x0
  801fb5:	e8 bf eb ff ff       	call   800b79 <sys_page_alloc>
  801fba:	83 c4 10             	add    $0x10,%esp
  801fbd:	89 c2                	mov    %eax,%edx
  801fbf:	85 c0                	test   %eax,%eax
  801fc1:	0f 88 0d 01 00 00    	js     8020d4 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801fc7:	83 ec 0c             	sub    $0xc,%esp
  801fca:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801fcd:	50                   	push   %eax
  801fce:	e8 a3 f1 ff ff       	call   801176 <fd_alloc>
  801fd3:	89 c3                	mov    %eax,%ebx
  801fd5:	83 c4 10             	add    $0x10,%esp
  801fd8:	85 c0                	test   %eax,%eax
  801fda:	0f 88 e2 00 00 00    	js     8020c2 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801fe0:	83 ec 04             	sub    $0x4,%esp
  801fe3:	68 07 04 00 00       	push   $0x407
  801fe8:	ff 75 f0             	pushl  -0x10(%ebp)
  801feb:	6a 00                	push   $0x0
  801fed:	e8 87 eb ff ff       	call   800b79 <sys_page_alloc>
  801ff2:	89 c3                	mov    %eax,%ebx
  801ff4:	83 c4 10             	add    $0x10,%esp
  801ff7:	85 c0                	test   %eax,%eax
  801ff9:	0f 88 c3 00 00 00    	js     8020c2 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801fff:	83 ec 0c             	sub    $0xc,%esp
  802002:	ff 75 f4             	pushl  -0xc(%ebp)
  802005:	e8 55 f1 ff ff       	call   80115f <fd2data>
  80200a:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80200c:	83 c4 0c             	add    $0xc,%esp
  80200f:	68 07 04 00 00       	push   $0x407
  802014:	50                   	push   %eax
  802015:	6a 00                	push   $0x0
  802017:	e8 5d eb ff ff       	call   800b79 <sys_page_alloc>
  80201c:	89 c3                	mov    %eax,%ebx
  80201e:	83 c4 10             	add    $0x10,%esp
  802021:	85 c0                	test   %eax,%eax
  802023:	0f 88 89 00 00 00    	js     8020b2 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802029:	83 ec 0c             	sub    $0xc,%esp
  80202c:	ff 75 f0             	pushl  -0x10(%ebp)
  80202f:	e8 2b f1 ff ff       	call   80115f <fd2data>
  802034:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  80203b:	50                   	push   %eax
  80203c:	6a 00                	push   $0x0
  80203e:	56                   	push   %esi
  80203f:	6a 00                	push   $0x0
  802041:	e8 76 eb ff ff       	call   800bbc <sys_page_map>
  802046:	89 c3                	mov    %eax,%ebx
  802048:	83 c4 20             	add    $0x20,%esp
  80204b:	85 c0                	test   %eax,%eax
  80204d:	78 55                	js     8020a4 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  80204f:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  802055:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802058:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  80205a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80205d:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  802064:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80206a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80206d:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  80206f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802072:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  802079:	83 ec 0c             	sub    $0xc,%esp
  80207c:	ff 75 f4             	pushl  -0xc(%ebp)
  80207f:	e8 cb f0 ff ff       	call   80114f <fd2num>
  802084:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802087:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  802089:	83 c4 04             	add    $0x4,%esp
  80208c:	ff 75 f0             	pushl  -0x10(%ebp)
  80208f:	e8 bb f0 ff ff       	call   80114f <fd2num>
  802094:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802097:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  80209a:	83 c4 10             	add    $0x10,%esp
  80209d:	ba 00 00 00 00       	mov    $0x0,%edx
  8020a2:	eb 30                	jmp    8020d4 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  8020a4:	83 ec 08             	sub    $0x8,%esp
  8020a7:	56                   	push   %esi
  8020a8:	6a 00                	push   $0x0
  8020aa:	e8 4f eb ff ff       	call   800bfe <sys_page_unmap>
  8020af:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  8020b2:	83 ec 08             	sub    $0x8,%esp
  8020b5:	ff 75 f0             	pushl  -0x10(%ebp)
  8020b8:	6a 00                	push   $0x0
  8020ba:	e8 3f eb ff ff       	call   800bfe <sys_page_unmap>
  8020bf:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  8020c2:	83 ec 08             	sub    $0x8,%esp
  8020c5:	ff 75 f4             	pushl  -0xc(%ebp)
  8020c8:	6a 00                	push   $0x0
  8020ca:	e8 2f eb ff ff       	call   800bfe <sys_page_unmap>
  8020cf:	83 c4 10             	add    $0x10,%esp
  8020d2:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  8020d4:	89 d0                	mov    %edx,%eax
  8020d6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8020d9:	5b                   	pop    %ebx
  8020da:	5e                   	pop    %esi
  8020db:	5d                   	pop    %ebp
  8020dc:	c3                   	ret    

008020dd <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8020dd:	55                   	push   %ebp
  8020de:	89 e5                	mov    %esp,%ebp
  8020e0:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8020e3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8020e6:	50                   	push   %eax
  8020e7:	ff 75 08             	pushl  0x8(%ebp)
  8020ea:	e8 d6 f0 ff ff       	call   8011c5 <fd_lookup>
  8020ef:	83 c4 10             	add    $0x10,%esp
  8020f2:	85 c0                	test   %eax,%eax
  8020f4:	78 18                	js     80210e <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8020f6:	83 ec 0c             	sub    $0xc,%esp
  8020f9:	ff 75 f4             	pushl  -0xc(%ebp)
  8020fc:	e8 5e f0 ff ff       	call   80115f <fd2data>
	return _pipeisclosed(fd, p);
  802101:	89 c2                	mov    %eax,%edx
  802103:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802106:	e8 21 fd ff ff       	call   801e2c <_pipeisclosed>
  80210b:	83 c4 10             	add    $0x10,%esp
}
  80210e:	c9                   	leave  
  80210f:	c3                   	ret    

00802110 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  802110:	55                   	push   %ebp
  802111:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  802113:	b8 00 00 00 00       	mov    $0x0,%eax
  802118:	5d                   	pop    %ebp
  802119:	c3                   	ret    

0080211a <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80211a:	55                   	push   %ebp
  80211b:	89 e5                	mov    %esp,%ebp
  80211d:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  802120:	68 93 2b 80 00       	push   $0x802b93
  802125:	ff 75 0c             	pushl  0xc(%ebp)
  802128:	e8 49 e6 ff ff       	call   800776 <strcpy>
	return 0;
}
  80212d:	b8 00 00 00 00       	mov    $0x0,%eax
  802132:	c9                   	leave  
  802133:	c3                   	ret    

00802134 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802134:	55                   	push   %ebp
  802135:	89 e5                	mov    %esp,%ebp
  802137:	57                   	push   %edi
  802138:	56                   	push   %esi
  802139:	53                   	push   %ebx
  80213a:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802140:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802145:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80214b:	eb 2d                	jmp    80217a <devcons_write+0x46>
		m = n - tot;
  80214d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802150:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  802152:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  802155:	ba 7f 00 00 00       	mov    $0x7f,%edx
  80215a:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80215d:	83 ec 04             	sub    $0x4,%esp
  802160:	53                   	push   %ebx
  802161:	03 45 0c             	add    0xc(%ebp),%eax
  802164:	50                   	push   %eax
  802165:	57                   	push   %edi
  802166:	e8 9d e7 ff ff       	call   800908 <memmove>
		sys_cputs(buf, m);
  80216b:	83 c4 08             	add    $0x8,%esp
  80216e:	53                   	push   %ebx
  80216f:	57                   	push   %edi
  802170:	e8 48 e9 ff ff       	call   800abd <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802175:	01 de                	add    %ebx,%esi
  802177:	83 c4 10             	add    $0x10,%esp
  80217a:	89 f0                	mov    %esi,%eax
  80217c:	3b 75 10             	cmp    0x10(%ebp),%esi
  80217f:	72 cc                	jb     80214d <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  802181:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802184:	5b                   	pop    %ebx
  802185:	5e                   	pop    %esi
  802186:	5f                   	pop    %edi
  802187:	5d                   	pop    %ebp
  802188:	c3                   	ret    

00802189 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  802189:	55                   	push   %ebp
  80218a:	89 e5                	mov    %esp,%ebp
  80218c:	83 ec 08             	sub    $0x8,%esp
  80218f:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  802194:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802198:	74 2a                	je     8021c4 <devcons_read+0x3b>
  80219a:	eb 05                	jmp    8021a1 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  80219c:	e8 b9 e9 ff ff       	call   800b5a <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8021a1:	e8 35 e9 ff ff       	call   800adb <sys_cgetc>
  8021a6:	85 c0                	test   %eax,%eax
  8021a8:	74 f2                	je     80219c <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8021aa:	85 c0                	test   %eax,%eax
  8021ac:	78 16                	js     8021c4 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8021ae:	83 f8 04             	cmp    $0x4,%eax
  8021b1:	74 0c                	je     8021bf <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  8021b3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8021b6:	88 02                	mov    %al,(%edx)
	return 1;
  8021b8:	b8 01 00 00 00       	mov    $0x1,%eax
  8021bd:	eb 05                	jmp    8021c4 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8021bf:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8021c4:	c9                   	leave  
  8021c5:	c3                   	ret    

008021c6 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8021c6:	55                   	push   %ebp
  8021c7:	89 e5                	mov    %esp,%ebp
  8021c9:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8021cc:	8b 45 08             	mov    0x8(%ebp),%eax
  8021cf:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8021d2:	6a 01                	push   $0x1
  8021d4:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8021d7:	50                   	push   %eax
  8021d8:	e8 e0 e8 ff ff       	call   800abd <sys_cputs>
}
  8021dd:	83 c4 10             	add    $0x10,%esp
  8021e0:	c9                   	leave  
  8021e1:	c3                   	ret    

008021e2 <getchar>:

int
getchar(void)
{
  8021e2:	55                   	push   %ebp
  8021e3:	89 e5                	mov    %esp,%ebp
  8021e5:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8021e8:	6a 01                	push   $0x1
  8021ea:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8021ed:	50                   	push   %eax
  8021ee:	6a 00                	push   $0x0
  8021f0:	e8 36 f2 ff ff       	call   80142b <read>
	if (r < 0)
  8021f5:	83 c4 10             	add    $0x10,%esp
  8021f8:	85 c0                	test   %eax,%eax
  8021fa:	78 0f                	js     80220b <getchar+0x29>
		return r;
	if (r < 1)
  8021fc:	85 c0                	test   %eax,%eax
  8021fe:	7e 06                	jle    802206 <getchar+0x24>
		return -E_EOF;
	return c;
  802200:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  802204:	eb 05                	jmp    80220b <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  802206:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80220b:	c9                   	leave  
  80220c:	c3                   	ret    

0080220d <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  80220d:	55                   	push   %ebp
  80220e:	89 e5                	mov    %esp,%ebp
  802210:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802213:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802216:	50                   	push   %eax
  802217:	ff 75 08             	pushl  0x8(%ebp)
  80221a:	e8 a6 ef ff ff       	call   8011c5 <fd_lookup>
  80221f:	83 c4 10             	add    $0x10,%esp
  802222:	85 c0                	test   %eax,%eax
  802224:	78 11                	js     802237 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  802226:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802229:	8b 15 58 30 80 00    	mov    0x803058,%edx
  80222f:	39 10                	cmp    %edx,(%eax)
  802231:	0f 94 c0             	sete   %al
  802234:	0f b6 c0             	movzbl %al,%eax
}
  802237:	c9                   	leave  
  802238:	c3                   	ret    

00802239 <opencons>:

int
opencons(void)
{
  802239:	55                   	push   %ebp
  80223a:	89 e5                	mov    %esp,%ebp
  80223c:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80223f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802242:	50                   	push   %eax
  802243:	e8 2e ef ff ff       	call   801176 <fd_alloc>
  802248:	83 c4 10             	add    $0x10,%esp
		return r;
  80224b:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80224d:	85 c0                	test   %eax,%eax
  80224f:	78 3e                	js     80228f <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802251:	83 ec 04             	sub    $0x4,%esp
  802254:	68 07 04 00 00       	push   $0x407
  802259:	ff 75 f4             	pushl  -0xc(%ebp)
  80225c:	6a 00                	push   $0x0
  80225e:	e8 16 e9 ff ff       	call   800b79 <sys_page_alloc>
  802263:	83 c4 10             	add    $0x10,%esp
		return r;
  802266:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802268:	85 c0                	test   %eax,%eax
  80226a:	78 23                	js     80228f <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  80226c:	8b 15 58 30 80 00    	mov    0x803058,%edx
  802272:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802275:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  802277:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80227a:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802281:	83 ec 0c             	sub    $0xc,%esp
  802284:	50                   	push   %eax
  802285:	e8 c5 ee ff ff       	call   80114f <fd2num>
  80228a:	89 c2                	mov    %eax,%edx
  80228c:	83 c4 10             	add    $0x10,%esp
}
  80228f:	89 d0                	mov    %edx,%eax
  802291:	c9                   	leave  
  802292:	c3                   	ret    

00802293 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  802293:	55                   	push   %ebp
  802294:	89 e5                	mov    %esp,%ebp
  802296:	56                   	push   %esi
  802297:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  802298:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80229b:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8022a1:	e8 95 e8 ff ff       	call   800b3b <sys_getenvid>
  8022a6:	83 ec 0c             	sub    $0xc,%esp
  8022a9:	ff 75 0c             	pushl  0xc(%ebp)
  8022ac:	ff 75 08             	pushl  0x8(%ebp)
  8022af:	56                   	push   %esi
  8022b0:	50                   	push   %eax
  8022b1:	68 a0 2b 80 00       	push   $0x802ba0
  8022b6:	e8 36 df ff ff       	call   8001f1 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8022bb:	83 c4 18             	add    $0x18,%esp
  8022be:	53                   	push   %ebx
  8022bf:	ff 75 10             	pushl  0x10(%ebp)
  8022c2:	e8 d9 de ff ff       	call   8001a0 <vcprintf>
	cprintf("\n");
  8022c7:	c7 04 24 8c 2b 80 00 	movl   $0x802b8c,(%esp)
  8022ce:	e8 1e df ff ff       	call   8001f1 <cprintf>
  8022d3:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8022d6:	cc                   	int3   
  8022d7:	eb fd                	jmp    8022d6 <_panic+0x43>

008022d9 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8022d9:	55                   	push   %ebp
  8022da:	89 e5                	mov    %esp,%ebp
  8022dc:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  8022df:	83 3d 00 70 80 00 00 	cmpl   $0x0,0x807000
  8022e6:	75 2e                	jne    802316 <set_pgfault_handler+0x3d>
		// First time through!
		// LAB 4: Your code here.
		// panic("set_pgfault_handler not implemented");

		sys_page_alloc(sys_getenvid(), (void *) (UXSTACKTOP - PGSIZE), PTE_SYSCALL);
  8022e8:	e8 4e e8 ff ff       	call   800b3b <sys_getenvid>
  8022ed:	83 ec 04             	sub    $0x4,%esp
  8022f0:	68 07 0e 00 00       	push   $0xe07
  8022f5:	68 00 f0 bf ee       	push   $0xeebff000
  8022fa:	50                   	push   %eax
  8022fb:	e8 79 e8 ff ff       	call   800b79 <sys_page_alloc>
		sys_env_set_pgfault_upcall(sys_getenvid(), _pgfault_upcall);
  802300:	e8 36 e8 ff ff       	call   800b3b <sys_getenvid>
  802305:	83 c4 08             	add    $0x8,%esp
  802308:	68 20 23 80 00       	push   $0x802320
  80230d:	50                   	push   %eax
  80230e:	e8 b1 e9 ff ff       	call   800cc4 <sys_env_set_pgfault_upcall>
  802313:	83 c4 10             	add    $0x10,%esp
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802316:	8b 45 08             	mov    0x8(%ebp),%eax
  802319:	a3 00 70 80 00       	mov    %eax,0x807000
}
  80231e:	c9                   	leave  
  80231f:	c3                   	ret    

00802320 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802320:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802321:	a1 00 70 80 00       	mov    0x807000,%eax
	call *%eax
  802326:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802328:	83 c4 04             	add    $0x4,%esp
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.

	movl 48(%esp), %eax		// trap-time esp
  80232b:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl 40(%esp), %ebx		// trap-time eip
  80232f:	8b 5c 24 28          	mov    0x28(%esp),%ebx

	// load eip into esp-4
	// in order to return to trap-time eip later, in the meantime not changing trap-time esp
	movl %ebx, -4(%eax)	
  802333:	89 58 fc             	mov    %ebx,-0x4(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.

	addl $8, %esp 			// esp now points to trap-time registers
  802336:	83 c4 08             	add    $0x8,%esp
	popal					// pop to all registers
  802339:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

	addl $4, %esp			// esp now points to trap-time eflags
  80233a:	83 c4 04             	add    $0x4,%esp
	popfl					// pop to eflags
  80233d:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.

	popl %esp				// pop to esp
  80233e:	5c                   	pop    %esp
	// subl $4, %esp		// arithmetic operation will change eflags!!!
	lea -4(%esp), %esp		// subl $4, %esp
  80233f:	8d 64 24 fc          	lea    -0x4(%esp),%esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.

	ret
  802343:	c3                   	ret    

00802344 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802344:	55                   	push   %ebp
  802345:	89 e5                	mov    %esp,%ebp
  802347:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80234a:	89 d0                	mov    %edx,%eax
  80234c:	c1 e8 16             	shr    $0x16,%eax
  80234f:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802356:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80235b:	f6 c1 01             	test   $0x1,%cl
  80235e:	74 1d                	je     80237d <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802360:	c1 ea 0c             	shr    $0xc,%edx
  802363:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  80236a:	f6 c2 01             	test   $0x1,%dl
  80236d:	74 0e                	je     80237d <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80236f:	c1 ea 0c             	shr    $0xc,%edx
  802372:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802379:	ef 
  80237a:	0f b7 c0             	movzwl %ax,%eax
}
  80237d:	5d                   	pop    %ebp
  80237e:	c3                   	ret    
  80237f:	90                   	nop

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
