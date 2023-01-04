
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
  80003c:	e8 a2 0f 00 00       	call   800fe3 <sfork>
  800041:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800044:	85 c0                	test   %eax,%eax
  800046:	74 42                	je     80008a <umain+0x57>
		cprintf("i am %08x; thisenv is %p\n", sys_getenvid(), thisenv);
  800048:	8b 1d 08 40 80 00    	mov    0x804008,%ebx
  80004e:	e8 e8 0a 00 00       	call   800b3b <sys_getenvid>
  800053:	83 ec 04             	sub    $0x4,%esp
  800056:	53                   	push   %ebx
  800057:	50                   	push   %eax
  800058:	68 60 21 80 00       	push   $0x802160
  80005d:	e8 8f 01 00 00       	call   8001f1 <cprintf>
		// get the ball rolling
		cprintf("send 0 from %x to %x\n", sys_getenvid(), who);
  800062:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800065:	e8 d1 0a 00 00       	call   800b3b <sys_getenvid>
  80006a:	83 c4 0c             	add    $0xc,%esp
  80006d:	53                   	push   %ebx
  80006e:	50                   	push   %eax
  80006f:	68 7a 21 80 00       	push   $0x80217a
  800074:	e8 78 01 00 00       	call   8001f1 <cprintf>
		ipc_send(who, 0, 0, 0);
  800079:	6a 00                	push   $0x0
  80007b:	6a 00                	push   $0x0
  80007d:	6a 00                	push   $0x0
  80007f:	ff 75 e4             	pushl  -0x1c(%ebp)
  800082:	e8 dd 0f 00 00       	call   801064 <ipc_send>
  800087:	83 c4 20             	add    $0x20,%esp
	}

	while (1) {
		ipc_recv(&who, 0, 0);
  80008a:	83 ec 04             	sub    $0x4,%esp
  80008d:	6a 00                	push   $0x0
  80008f:	6a 00                	push   $0x0
  800091:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800094:	50                   	push   %eax
  800095:	e8 63 0f 00 00       	call   800ffd <ipc_recv>
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
  8000bd:	68 90 21 80 00       	push   $0x802190
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
  8000e5:	e8 7a 0f 00 00       	call   801064 <ipc_send>
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
  80014a:	e8 6d 11 00 00       	call   8012bc <close_all>
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
  800254:	e8 67 1c 00 00       	call   801ec0 <__udivdi3>
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
  800297:	e8 54 1d 00 00       	call   801ff0 <__umoddi3>
  80029c:	83 c4 14             	add    $0x14,%esp
  80029f:	0f be 80 c0 21 80 00 	movsbl 0x8021c0(%eax),%eax
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
  80039b:	ff 24 85 00 23 80 00 	jmp    *0x802300(,%eax,4)
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
  80045f:	8b 14 85 60 24 80 00 	mov    0x802460(,%eax,4),%edx
  800466:	85 d2                	test   %edx,%edx
  800468:	75 18                	jne    800482 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80046a:	50                   	push   %eax
  80046b:	68 d8 21 80 00       	push   $0x8021d8
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
  800483:	68 5d 26 80 00       	push   $0x80265d
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
  8004a7:	b8 d1 21 80 00       	mov    $0x8021d1,%eax
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
  800b22:	68 bf 24 80 00       	push   $0x8024bf
  800b27:	6a 23                	push   $0x23
  800b29:	68 dc 24 80 00       	push   $0x8024dc
  800b2e:	e8 9b 12 00 00       	call   801dce <_panic>

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
  800ba3:	68 bf 24 80 00       	push   $0x8024bf
  800ba8:	6a 23                	push   $0x23
  800baa:	68 dc 24 80 00       	push   $0x8024dc
  800baf:	e8 1a 12 00 00       	call   801dce <_panic>

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
  800be5:	68 bf 24 80 00       	push   $0x8024bf
  800bea:	6a 23                	push   $0x23
  800bec:	68 dc 24 80 00       	push   $0x8024dc
  800bf1:	e8 d8 11 00 00       	call   801dce <_panic>

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
  800c27:	68 bf 24 80 00       	push   $0x8024bf
  800c2c:	6a 23                	push   $0x23
  800c2e:	68 dc 24 80 00       	push   $0x8024dc
  800c33:	e8 96 11 00 00       	call   801dce <_panic>

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
  800c69:	68 bf 24 80 00       	push   $0x8024bf
  800c6e:	6a 23                	push   $0x23
  800c70:	68 dc 24 80 00       	push   $0x8024dc
  800c75:	e8 54 11 00 00       	call   801dce <_panic>

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
  800cab:	68 bf 24 80 00       	push   $0x8024bf
  800cb0:	6a 23                	push   $0x23
  800cb2:	68 dc 24 80 00       	push   $0x8024dc
  800cb7:	e8 12 11 00 00       	call   801dce <_panic>

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
  800ced:	68 bf 24 80 00       	push   $0x8024bf
  800cf2:	6a 23                	push   $0x23
  800cf4:	68 dc 24 80 00       	push   $0x8024dc
  800cf9:	e8 d0 10 00 00       	call   801dce <_panic>

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
  800d51:	68 bf 24 80 00       	push   $0x8024bf
  800d56:	6a 23                	push   $0x23
  800d58:	68 dc 24 80 00       	push   $0x8024dc
  800d5d:	e8 6c 10 00 00       	call   801dce <_panic>

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
  800d6d:	56                   	push   %esi
  800d6e:	53                   	push   %ebx
  800d6f:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800d72:	8b 18                	mov    (%eax),%ebx
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.

	if ((err & FEC_WR) != FEC_WR && ((uvpt[PGNUM(addr)] & PTE_COW) != PTE_COW)) {
  800d74:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800d78:	75 25                	jne    800d9f <pgfault+0x35>
  800d7a:	89 d8                	mov    %ebx,%eax
  800d7c:	c1 e8 0c             	shr    $0xc,%eax
  800d7f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800d86:	f6 c4 08             	test   $0x8,%ah
  800d89:	75 14                	jne    800d9f <pgfault+0x35>
		panic("pgfault: not due to a write or a COW page");
  800d8b:	83 ec 04             	sub    $0x4,%esp
  800d8e:	68 ec 24 80 00       	push   $0x8024ec
  800d93:	6a 1e                	push   $0x1e
  800d95:	68 80 25 80 00       	push   $0x802580
  800d9a:	e8 2f 10 00 00       	call   801dce <_panic>

	// LAB 4: Your code here.

	// panic("pgfault not implemented");

	addr = ROUNDDOWN(addr, PGSIZE);
  800d9f:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	envid_t envid = sys_getenvid();
  800da5:	e8 91 fd ff ff       	call   800b3b <sys_getenvid>
  800daa:	89 c6                	mov    %eax,%esi

	// Allocate a new page, map it at a temporary location (PFTEMP)
	r = sys_page_alloc(envid, (void *)PFTEMP, PTE_U | PTE_P | PTE_W);
  800dac:	83 ec 04             	sub    $0x4,%esp
  800daf:	6a 07                	push   $0x7
  800db1:	68 00 f0 7f 00       	push   $0x7ff000
  800db6:	50                   	push   %eax
  800db7:	e8 bd fd ff ff       	call   800b79 <sys_page_alloc>
	if (r < 0)
  800dbc:	83 c4 10             	add    $0x10,%esp
  800dbf:	85 c0                	test   %eax,%eax
  800dc1:	79 12                	jns    800dd5 <pgfault+0x6b>
		panic("pgfault: sys_page_alloc failed: %e\n", r);
  800dc3:	50                   	push   %eax
  800dc4:	68 18 25 80 00       	push   $0x802518
  800dc9:	6a 31                	push   $0x31
  800dcb:	68 80 25 80 00       	push   $0x802580
  800dd0:	e8 f9 0f 00 00       	call   801dce <_panic>
	
	// copy the data from the old page to the new page
	memcpy((void *) PFTEMP, (const void *) addr, PGSIZE);
  800dd5:	83 ec 04             	sub    $0x4,%esp
  800dd8:	68 00 10 00 00       	push   $0x1000
  800ddd:	53                   	push   %ebx
  800dde:	68 00 f0 7f 00       	push   $0x7ff000
  800de3:	e8 88 fb ff ff       	call   800970 <memcpy>

	// move the new page to the old page's address
	r = sys_page_map(envid, (void *) PFTEMP, envid, addr, PTE_U | PTE_P | PTE_W);
  800de8:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800def:	53                   	push   %ebx
  800df0:	56                   	push   %esi
  800df1:	68 00 f0 7f 00       	push   $0x7ff000
  800df6:	56                   	push   %esi
  800df7:	e8 c0 fd ff ff       	call   800bbc <sys_page_map>
	if (r < 0)
  800dfc:	83 c4 20             	add    $0x20,%esp
  800dff:	85 c0                	test   %eax,%eax
  800e01:	79 12                	jns    800e15 <pgfault+0xab>
		panic("pgfault: sys_page_map failed: %e\n", r);
  800e03:	50                   	push   %eax
  800e04:	68 3c 25 80 00       	push   $0x80253c
  800e09:	6a 39                	push   $0x39
  800e0b:	68 80 25 80 00       	push   $0x802580
  800e10:	e8 b9 0f 00 00       	call   801dce <_panic>

	// unmap temporary region
	r = sys_page_unmap(envid, (void *) PFTEMP);
  800e15:	83 ec 08             	sub    $0x8,%esp
  800e18:	68 00 f0 7f 00       	push   $0x7ff000
  800e1d:	56                   	push   %esi
  800e1e:	e8 db fd ff ff       	call   800bfe <sys_page_unmap>
	if (r < 0)
  800e23:	83 c4 10             	add    $0x10,%esp
  800e26:	85 c0                	test   %eax,%eax
  800e28:	79 12                	jns    800e3c <pgfault+0xd2>
        panic("pgfault: page unmap failed: %e\n", r);
  800e2a:	50                   	push   %eax
  800e2b:	68 60 25 80 00       	push   $0x802560
  800e30:	6a 3e                	push   $0x3e
  800e32:	68 80 25 80 00       	push   $0x802580
  800e37:	e8 92 0f 00 00       	call   801dce <_panic>
}
  800e3c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e3f:	5b                   	pop    %ebx
  800e40:	5e                   	pop    %esi
  800e41:	5d                   	pop    %ebp
  800e42:	c3                   	ret    

00800e43 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800e43:	55                   	push   %ebp
  800e44:	89 e5                	mov    %esp,%ebp
  800e46:	57                   	push   %edi
  800e47:	56                   	push   %esi
  800e48:	53                   	push   %ebx
  800e49:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	// cprintf("[fork]\n");
	int r;

	set_pgfault_handler(pgfault);
  800e4c:	68 6a 0d 80 00       	push   $0x800d6a
  800e51:	e8 be 0f 00 00       	call   801e14 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800e56:	b8 07 00 00 00       	mov    $0x7,%eax
  800e5b:	cd 30                	int    $0x30

	envid_t envid = sys_exofork();
	if (envid < 0)
  800e5d:	83 c4 10             	add    $0x10,%esp
  800e60:	85 c0                	test   %eax,%eax
  800e62:	0f 88 67 01 00 00    	js     800fcf <fork+0x18c>
  800e68:	bb 00 00 80 00       	mov    $0x800000,%ebx
  800e6d:	be 00 08 00 00       	mov    $0x800,%esi
		return envid;

	// fix "thisenv" in the child process
	if (envid == 0) {
  800e72:	85 c0                	test   %eax,%eax
  800e74:	75 21                	jne    800e97 <fork+0x54>
		thisenv = &envs[ENVX(sys_getenvid())];
  800e76:	e8 c0 fc ff ff       	call   800b3b <sys_getenvid>
  800e7b:	25 ff 03 00 00       	and    $0x3ff,%eax
  800e80:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800e83:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800e88:	a3 08 40 80 00       	mov    %eax,0x804008
        return 0;
  800e8d:	ba 00 00 00 00       	mov    $0x0,%edx
  800e92:	e9 42 01 00 00       	jmp    800fd9 <fork+0x196>
  800e97:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800e9a:	89 c7                	mov    %eax,%edi
	for (uint32_t pn = PGNUM(UTEXT); pn < PGNUM(USTACKTOP); pn++) {

		addr = pn * PGSIZE;

		// if level-2 page exists
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P) {
  800e9c:	89 d8                	mov    %ebx,%eax
  800e9e:	c1 e8 16             	shr    $0x16,%eax
  800ea1:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800ea8:	a8 01                	test   $0x1,%al
  800eaa:	0f 84 c0 00 00 00    	je     800f70 <fork+0x12d>
			
			// if real PTE exists
			if ((uvpt[PGNUM(addr)] & PTE_P) == PTE_P) {
  800eb0:	89 d8                	mov    %ebx,%eax
  800eb2:	c1 e8 0c             	shr    $0xc,%eax
  800eb5:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800ebc:	f6 c2 01             	test   $0x1,%dl
  800ebf:	0f 84 ab 00 00 00    	je     800f70 <fork+0x12d>

				// For each writable or copy-on-write page
				if ((uvpt[PGNUM(addr)] & (PTE_W | PTE_COW)) != 0) {
  800ec5:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800ecc:	a9 02 08 00 00       	test   $0x802,%eax
  800ed1:	0f 84 99 00 00 00    	je     800f70 <fork+0x12d>
	// r = envid2env(envid, &env, 1);
	// if (r < 0)
	// 	return r;	// E_BAD_ENV
	// envid_t parent_envid = env->env_parent_id;

	if (uvpt[pn] & PTE_SHARE) {
  800ed7:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800ede:	f6 c4 04             	test   $0x4,%ah
  800ee1:	74 17                	je     800efa <fork+0xb7>
		sys_page_map(0, (void *)va, envid, (void *)va, PTE_SYSCALL);
  800ee3:	83 ec 0c             	sub    $0xc,%esp
  800ee6:	68 07 0e 00 00       	push   $0xe07
  800eeb:	53                   	push   %ebx
  800eec:	57                   	push   %edi
  800eed:	53                   	push   %ebx
  800eee:	6a 00                	push   $0x0
  800ef0:	e8 c7 fc ff ff       	call   800bbc <sys_page_map>
  800ef5:	83 c4 20             	add    $0x20,%esp
  800ef8:	eb 76                	jmp    800f70 <fork+0x12d>
	}
	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {
  800efa:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800f01:	a8 02                	test   $0x2,%al
  800f03:	75 0c                	jne    800f11 <fork+0xce>
  800f05:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800f0c:	f6 c4 08             	test   $0x8,%ah
  800f0f:	74 3f                	je     800f50 <fork+0x10d>

		// map the page copy-on-write into the address space of the child
        r = sys_page_map(0, (void *)va, envid, (void *)va, PTE_P|PTE_U|PTE_COW);
  800f11:	83 ec 0c             	sub    $0xc,%esp
  800f14:	68 05 08 00 00       	push   $0x805
  800f19:	53                   	push   %ebx
  800f1a:	57                   	push   %edi
  800f1b:	53                   	push   %ebx
  800f1c:	6a 00                	push   $0x0
  800f1e:	e8 99 fc ff ff       	call   800bbc <sys_page_map>
		if (r < 0)
  800f23:	83 c4 20             	add    $0x20,%esp
  800f26:	85 c0                	test   %eax,%eax
  800f28:	0f 88 a5 00 00 00    	js     800fd3 <fork+0x190>
            return r;

		// remap the page copy-on-write in its own(parent) address space
        r = sys_page_map(0, (void *)va, 0, (void *)va, PTE_P|PTE_U|PTE_COW);
  800f2e:	83 ec 0c             	sub    $0xc,%esp
  800f31:	68 05 08 00 00       	push   $0x805
  800f36:	53                   	push   %ebx
  800f37:	6a 00                	push   $0x0
  800f39:	53                   	push   %ebx
  800f3a:	6a 00                	push   $0x0
  800f3c:	e8 7b fc ff ff       	call   800bbc <sys_page_map>
  800f41:	83 c4 20             	add    $0x20,%esp
  800f44:	85 c0                	test   %eax,%eax
  800f46:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f4b:	0f 4f c1             	cmovg  %ecx,%eax
  800f4e:	eb 1c                	jmp    800f6c <fork+0x129>
		if (r < 0)
            return r;
    }
    else {
        r = sys_page_map(0, (void *)va, envid, (void *)va, PTE_P|PTE_U);
  800f50:	83 ec 0c             	sub    $0xc,%esp
  800f53:	6a 05                	push   $0x5
  800f55:	53                   	push   %ebx
  800f56:	57                   	push   %edi
  800f57:	53                   	push   %ebx
  800f58:	6a 00                	push   $0x0
  800f5a:	e8 5d fc ff ff       	call   800bbc <sys_page_map>
  800f5f:	83 c4 20             	add    $0x20,%esp
  800f62:	85 c0                	test   %eax,%eax
  800f64:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f69:	0f 4f c1             	cmovg  %ecx,%eax
			if ((uvpt[PGNUM(addr)] & PTE_P) == PTE_P) {

				// For each writable or copy-on-write page
				if ((uvpt[PGNUM(addr)] & (PTE_W | PTE_COW)) != 0) {
					r = duppage(envid, pn);
					if (r < 0)
  800f6c:	85 c0                	test   %eax,%eax
  800f6e:	78 67                	js     800fd7 <fork+0x194>
        return 0;
	}

	// For each writable or copy-on-write page in its address space below UTOP, the parent calls duppage
	uint32_t addr;
	for (uint32_t pn = PGNUM(UTEXT); pn < PGNUM(USTACKTOP); pn++) {
  800f70:	83 c6 01             	add    $0x1,%esi
  800f73:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  800f79:	81 fe fe eb 0e 00    	cmp    $0xeebfe,%esi
  800f7f:	0f 85 17 ff ff ff    	jne    800e9c <fork+0x59>
  800f85:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
		}
	}

	// allocate a fresh page in the child for the exception stack
	r = sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U | PTE_P | PTE_W);
  800f88:	83 ec 04             	sub    $0x4,%esp
  800f8b:	6a 07                	push   $0x7
  800f8d:	68 00 f0 bf ee       	push   $0xeebff000
  800f92:	57                   	push   %edi
  800f93:	e8 e1 fb ff ff       	call   800b79 <sys_page_alloc>
	if (r < 0)
  800f98:	83 c4 10             	add    $0x10,%esp
		return r;
  800f9b:	89 c2                	mov    %eax,%edx
		}
	}

	// allocate a fresh page in the child for the exception stack
	r = sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U | PTE_P | PTE_W);
	if (r < 0)
  800f9d:	85 c0                	test   %eax,%eax
  800f9f:	78 38                	js     800fd9 <fork+0x196>
		return r;

	// The parent sets the user page fault entrypoint for the child to look like its own
	extern void _pgfault_upcall(void);
	r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  800fa1:	83 ec 08             	sub    $0x8,%esp
  800fa4:	68 5b 1e 80 00       	push   $0x801e5b
  800fa9:	57                   	push   %edi
  800faa:	e8 15 fd ff ff       	call   800cc4 <sys_env_set_pgfault_upcall>
	if (r < 0)
  800faf:	83 c4 10             	add    $0x10,%esp
		return r;
  800fb2:	89 c2                	mov    %eax,%edx
		return r;

	// The parent sets the user page fault entrypoint for the child to look like its own
	extern void _pgfault_upcall(void);
	r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
	if (r < 0)
  800fb4:	85 c0                	test   %eax,%eax
  800fb6:	78 21                	js     800fd9 <fork+0x196>
		return r;

	// The child is now ready to run, so the parent marks it runnable
	r = sys_env_set_status(envid, ENV_RUNNABLE);
  800fb8:	83 ec 08             	sub    $0x8,%esp
  800fbb:	6a 02                	push   $0x2
  800fbd:	57                   	push   %edi
  800fbe:	e8 7d fc ff ff       	call   800c40 <sys_env_set_status>
	if (r < 0)
  800fc3:	83 c4 10             	add    $0x10,%esp
		return r;

	return envid;
  800fc6:	85 c0                	test   %eax,%eax
  800fc8:	0f 48 f8             	cmovs  %eax,%edi
  800fcb:	89 fa                	mov    %edi,%edx
  800fcd:	eb 0a                	jmp    800fd9 <fork+0x196>

	set_pgfault_handler(pgfault);

	envid_t envid = sys_exofork();
	if (envid < 0)
		return envid;
  800fcf:	89 c2                	mov    %eax,%edx
  800fd1:	eb 06                	jmp    800fd9 <fork+0x196>
		sys_page_map(0, (void *)va, envid, (void *)va, PTE_SYSCALL);
	}
	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {

		// map the page copy-on-write into the address space of the child
        r = sys_page_map(0, (void *)va, envid, (void *)va, PTE_P|PTE_U|PTE_COW);
  800fd3:	89 c2                	mov    %eax,%edx
  800fd5:	eb 02                	jmp    800fd9 <fork+0x196>
  800fd7:	89 c2                	mov    %eax,%edx
	if (r < 0)
		return r;

	return envid;
	// panic("fork not implemented");
}
  800fd9:	89 d0                	mov    %edx,%eax
  800fdb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fde:	5b                   	pop    %ebx
  800fdf:	5e                   	pop    %esi
  800fe0:	5f                   	pop    %edi
  800fe1:	5d                   	pop    %ebp
  800fe2:	c3                   	ret    

00800fe3 <sfork>:

// Challenge!
int
sfork(void)
{
  800fe3:	55                   	push   %ebp
  800fe4:	89 e5                	mov    %esp,%ebp
  800fe6:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  800fe9:	68 8b 25 80 00       	push   $0x80258b
  800fee:	68 c6 00 00 00       	push   $0xc6
  800ff3:	68 80 25 80 00       	push   $0x802580
  800ff8:	e8 d1 0d 00 00       	call   801dce <_panic>

00800ffd <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  800ffd:	55                   	push   %ebp
  800ffe:	89 e5                	mov    %esp,%ebp
  801000:	56                   	push   %esi
  801001:	53                   	push   %ebx
  801002:	8b 75 08             	mov    0x8(%ebp),%esi
  801005:	8b 45 0c             	mov    0xc(%ebp),%eax
  801008:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");

	// don't want to recv page
	if (pg == NULL)
  80100b:	85 c0                	test   %eax,%eax
		pg = (void *)UTOP;
  80100d:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801012:	0f 44 c2             	cmove  %edx,%eax

	int err = sys_ipc_recv(pg);
  801015:	83 ec 0c             	sub    $0xc,%esp
  801018:	50                   	push   %eax
  801019:	e8 0b fd ff ff       	call   800d29 <sys_ipc_recv>

	if (from_env_store != NULL)
  80101e:	83 c4 10             	add    $0x10,%esp
  801021:	85 f6                	test   %esi,%esi
  801023:	74 14                	je     801039 <ipc_recv+0x3c>
		*from_env_store = err < 0? 0 : thisenv->env_ipc_from;
  801025:	ba 00 00 00 00       	mov    $0x0,%edx
  80102a:	85 c0                	test   %eax,%eax
  80102c:	78 09                	js     801037 <ipc_recv+0x3a>
  80102e:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801034:	8b 52 74             	mov    0x74(%edx),%edx
  801037:	89 16                	mov    %edx,(%esi)
	
	if (perm_store != NULL)
  801039:	85 db                	test   %ebx,%ebx
  80103b:	74 14                	je     801051 <ipc_recv+0x54>
		*perm_store = err < 0? 0 : thisenv->env_ipc_perm;
  80103d:	ba 00 00 00 00       	mov    $0x0,%edx
  801042:	85 c0                	test   %eax,%eax
  801044:	78 09                	js     80104f <ipc_recv+0x52>
  801046:	8b 15 08 40 80 00    	mov    0x804008,%edx
  80104c:	8b 52 78             	mov    0x78(%edx),%edx
  80104f:	89 13                	mov    %edx,(%ebx)

	if (err < 0)
  801051:	85 c0                	test   %eax,%eax
  801053:	78 08                	js     80105d <ipc_recv+0x60>
		return err;
	return thisenv->env_ipc_value;
  801055:	a1 08 40 80 00       	mov    0x804008,%eax
  80105a:	8b 40 70             	mov    0x70(%eax),%eax
}
  80105d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801060:	5b                   	pop    %ebx
  801061:	5e                   	pop    %esi
  801062:	5d                   	pop    %ebp
  801063:	c3                   	ret    

00801064 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801064:	55                   	push   %ebp
  801065:	89 e5                	mov    %esp,%ebp
  801067:	57                   	push   %edi
  801068:	56                   	push   %esi
  801069:	53                   	push   %ebx
  80106a:	83 ec 0c             	sub    $0xc,%esp
  80106d:	8b 7d 08             	mov    0x8(%ebp),%edi
  801070:	8b 75 0c             	mov    0xc(%ebp),%esi
  801073:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");

	// don't want to send page
	if (pg == NULL)
  801076:	85 db                	test   %ebx,%ebx
		pg = (void *)UTOP;
  801078:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  80107d:	0f 44 d8             	cmove  %eax,%ebx
	
	int err = 0;
	
	do {

		err = sys_ipc_try_send(to_env, val, pg, perm);
  801080:	ff 75 14             	pushl  0x14(%ebp)
  801083:	53                   	push   %ebx
  801084:	56                   	push   %esi
  801085:	57                   	push   %edi
  801086:	e8 7b fc ff ff       	call   800d06 <sys_ipc_try_send>

		if (err < 0) {
  80108b:	83 c4 10             	add    $0x10,%esp
  80108e:	85 c0                	test   %eax,%eax
  801090:	79 1e                	jns    8010b0 <ipc_send+0x4c>
			if (err == -E_IPC_NOT_RECV)
  801092:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801095:	75 07                	jne    80109e <ipc_send+0x3a>
				sys_yield();
  801097:	e8 be fa ff ff       	call   800b5a <sys_yield>
  80109c:	eb e2                	jmp    801080 <ipc_send+0x1c>
			else 
				panic("ipc_send: %e", err);
  80109e:	50                   	push   %eax
  80109f:	68 a1 25 80 00       	push   $0x8025a1
  8010a4:	6a 49                	push   $0x49
  8010a6:	68 ae 25 80 00       	push   $0x8025ae
  8010ab:	e8 1e 0d 00 00       	call   801dce <_panic>
		}

	} while (err < 0);

}
  8010b0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010b3:	5b                   	pop    %ebx
  8010b4:	5e                   	pop    %esi
  8010b5:	5f                   	pop    %edi
  8010b6:	5d                   	pop    %ebp
  8010b7:	c3                   	ret    

008010b8 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8010b8:	55                   	push   %ebp
  8010b9:	89 e5                	mov    %esp,%ebp
  8010bb:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8010be:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8010c3:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8010c6:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8010cc:	8b 52 50             	mov    0x50(%edx),%edx
  8010cf:	39 ca                	cmp    %ecx,%edx
  8010d1:	75 0d                	jne    8010e0 <ipc_find_env+0x28>
			return envs[i].env_id;
  8010d3:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8010d6:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8010db:	8b 40 48             	mov    0x48(%eax),%eax
  8010de:	eb 0f                	jmp    8010ef <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8010e0:	83 c0 01             	add    $0x1,%eax
  8010e3:	3d 00 04 00 00       	cmp    $0x400,%eax
  8010e8:	75 d9                	jne    8010c3 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8010ea:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8010ef:	5d                   	pop    %ebp
  8010f0:	c3                   	ret    

008010f1 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8010f1:	55                   	push   %ebp
  8010f2:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8010f4:	8b 45 08             	mov    0x8(%ebp),%eax
  8010f7:	05 00 00 00 30       	add    $0x30000000,%eax
  8010fc:	c1 e8 0c             	shr    $0xc,%eax
}
  8010ff:	5d                   	pop    %ebp
  801100:	c3                   	ret    

00801101 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801101:	55                   	push   %ebp
  801102:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801104:	8b 45 08             	mov    0x8(%ebp),%eax
  801107:	05 00 00 00 30       	add    $0x30000000,%eax
  80110c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801111:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801116:	5d                   	pop    %ebp
  801117:	c3                   	ret    

00801118 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801118:	55                   	push   %ebp
  801119:	89 e5                	mov    %esp,%ebp
  80111b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80111e:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801123:	89 c2                	mov    %eax,%edx
  801125:	c1 ea 16             	shr    $0x16,%edx
  801128:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80112f:	f6 c2 01             	test   $0x1,%dl
  801132:	74 11                	je     801145 <fd_alloc+0x2d>
  801134:	89 c2                	mov    %eax,%edx
  801136:	c1 ea 0c             	shr    $0xc,%edx
  801139:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801140:	f6 c2 01             	test   $0x1,%dl
  801143:	75 09                	jne    80114e <fd_alloc+0x36>
			*fd_store = fd;
  801145:	89 01                	mov    %eax,(%ecx)
			return 0;
  801147:	b8 00 00 00 00       	mov    $0x0,%eax
  80114c:	eb 17                	jmp    801165 <fd_alloc+0x4d>
  80114e:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801153:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801158:	75 c9                	jne    801123 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80115a:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801160:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801165:	5d                   	pop    %ebp
  801166:	c3                   	ret    

00801167 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801167:	55                   	push   %ebp
  801168:	89 e5                	mov    %esp,%ebp
  80116a:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80116d:	83 f8 1f             	cmp    $0x1f,%eax
  801170:	77 36                	ja     8011a8 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801172:	c1 e0 0c             	shl    $0xc,%eax
  801175:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80117a:	89 c2                	mov    %eax,%edx
  80117c:	c1 ea 16             	shr    $0x16,%edx
  80117f:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801186:	f6 c2 01             	test   $0x1,%dl
  801189:	74 24                	je     8011af <fd_lookup+0x48>
  80118b:	89 c2                	mov    %eax,%edx
  80118d:	c1 ea 0c             	shr    $0xc,%edx
  801190:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801197:	f6 c2 01             	test   $0x1,%dl
  80119a:	74 1a                	je     8011b6 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80119c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80119f:	89 02                	mov    %eax,(%edx)
	return 0;
  8011a1:	b8 00 00 00 00       	mov    $0x0,%eax
  8011a6:	eb 13                	jmp    8011bb <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8011a8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011ad:	eb 0c                	jmp    8011bb <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8011af:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011b4:	eb 05                	jmp    8011bb <fd_lookup+0x54>
  8011b6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8011bb:	5d                   	pop    %ebp
  8011bc:	c3                   	ret    

008011bd <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8011bd:	55                   	push   %ebp
  8011be:	89 e5                	mov    %esp,%ebp
  8011c0:	83 ec 08             	sub    $0x8,%esp
  8011c3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011c6:	ba 34 26 80 00       	mov    $0x802634,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8011cb:	eb 13                	jmp    8011e0 <dev_lookup+0x23>
  8011cd:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8011d0:	39 08                	cmp    %ecx,(%eax)
  8011d2:	75 0c                	jne    8011e0 <dev_lookup+0x23>
			*dev = devtab[i];
  8011d4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011d7:	89 01                	mov    %eax,(%ecx)
			return 0;
  8011d9:	b8 00 00 00 00       	mov    $0x0,%eax
  8011de:	eb 2e                	jmp    80120e <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8011e0:	8b 02                	mov    (%edx),%eax
  8011e2:	85 c0                	test   %eax,%eax
  8011e4:	75 e7                	jne    8011cd <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8011e6:	a1 08 40 80 00       	mov    0x804008,%eax
  8011eb:	8b 40 48             	mov    0x48(%eax),%eax
  8011ee:	83 ec 04             	sub    $0x4,%esp
  8011f1:	51                   	push   %ecx
  8011f2:	50                   	push   %eax
  8011f3:	68 b8 25 80 00       	push   $0x8025b8
  8011f8:	e8 f4 ef ff ff       	call   8001f1 <cprintf>
	*dev = 0;
  8011fd:	8b 45 0c             	mov    0xc(%ebp),%eax
  801200:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801206:	83 c4 10             	add    $0x10,%esp
  801209:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80120e:	c9                   	leave  
  80120f:	c3                   	ret    

00801210 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801210:	55                   	push   %ebp
  801211:	89 e5                	mov    %esp,%ebp
  801213:	56                   	push   %esi
  801214:	53                   	push   %ebx
  801215:	83 ec 10             	sub    $0x10,%esp
  801218:	8b 75 08             	mov    0x8(%ebp),%esi
  80121b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80121e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801221:	50                   	push   %eax
  801222:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801228:	c1 e8 0c             	shr    $0xc,%eax
  80122b:	50                   	push   %eax
  80122c:	e8 36 ff ff ff       	call   801167 <fd_lookup>
  801231:	83 c4 08             	add    $0x8,%esp
  801234:	85 c0                	test   %eax,%eax
  801236:	78 05                	js     80123d <fd_close+0x2d>
	    || fd != fd2)
  801238:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80123b:	74 0c                	je     801249 <fd_close+0x39>
		return (must_exist ? r : 0);
  80123d:	84 db                	test   %bl,%bl
  80123f:	ba 00 00 00 00       	mov    $0x0,%edx
  801244:	0f 44 c2             	cmove  %edx,%eax
  801247:	eb 41                	jmp    80128a <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801249:	83 ec 08             	sub    $0x8,%esp
  80124c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80124f:	50                   	push   %eax
  801250:	ff 36                	pushl  (%esi)
  801252:	e8 66 ff ff ff       	call   8011bd <dev_lookup>
  801257:	89 c3                	mov    %eax,%ebx
  801259:	83 c4 10             	add    $0x10,%esp
  80125c:	85 c0                	test   %eax,%eax
  80125e:	78 1a                	js     80127a <fd_close+0x6a>
		if (dev->dev_close)
  801260:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801263:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801266:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  80126b:	85 c0                	test   %eax,%eax
  80126d:	74 0b                	je     80127a <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80126f:	83 ec 0c             	sub    $0xc,%esp
  801272:	56                   	push   %esi
  801273:	ff d0                	call   *%eax
  801275:	89 c3                	mov    %eax,%ebx
  801277:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80127a:	83 ec 08             	sub    $0x8,%esp
  80127d:	56                   	push   %esi
  80127e:	6a 00                	push   $0x0
  801280:	e8 79 f9 ff ff       	call   800bfe <sys_page_unmap>
	return r;
  801285:	83 c4 10             	add    $0x10,%esp
  801288:	89 d8                	mov    %ebx,%eax
}
  80128a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80128d:	5b                   	pop    %ebx
  80128e:	5e                   	pop    %esi
  80128f:	5d                   	pop    %ebp
  801290:	c3                   	ret    

00801291 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801291:	55                   	push   %ebp
  801292:	89 e5                	mov    %esp,%ebp
  801294:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801297:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80129a:	50                   	push   %eax
  80129b:	ff 75 08             	pushl  0x8(%ebp)
  80129e:	e8 c4 fe ff ff       	call   801167 <fd_lookup>
  8012a3:	83 c4 08             	add    $0x8,%esp
  8012a6:	85 c0                	test   %eax,%eax
  8012a8:	78 10                	js     8012ba <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8012aa:	83 ec 08             	sub    $0x8,%esp
  8012ad:	6a 01                	push   $0x1
  8012af:	ff 75 f4             	pushl  -0xc(%ebp)
  8012b2:	e8 59 ff ff ff       	call   801210 <fd_close>
  8012b7:	83 c4 10             	add    $0x10,%esp
}
  8012ba:	c9                   	leave  
  8012bb:	c3                   	ret    

008012bc <close_all>:

void
close_all(void)
{
  8012bc:	55                   	push   %ebp
  8012bd:	89 e5                	mov    %esp,%ebp
  8012bf:	53                   	push   %ebx
  8012c0:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8012c3:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8012c8:	83 ec 0c             	sub    $0xc,%esp
  8012cb:	53                   	push   %ebx
  8012cc:	e8 c0 ff ff ff       	call   801291 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8012d1:	83 c3 01             	add    $0x1,%ebx
  8012d4:	83 c4 10             	add    $0x10,%esp
  8012d7:	83 fb 20             	cmp    $0x20,%ebx
  8012da:	75 ec                	jne    8012c8 <close_all+0xc>
		close(i);
}
  8012dc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012df:	c9                   	leave  
  8012e0:	c3                   	ret    

008012e1 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8012e1:	55                   	push   %ebp
  8012e2:	89 e5                	mov    %esp,%ebp
  8012e4:	57                   	push   %edi
  8012e5:	56                   	push   %esi
  8012e6:	53                   	push   %ebx
  8012e7:	83 ec 2c             	sub    $0x2c,%esp
  8012ea:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8012ed:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8012f0:	50                   	push   %eax
  8012f1:	ff 75 08             	pushl  0x8(%ebp)
  8012f4:	e8 6e fe ff ff       	call   801167 <fd_lookup>
  8012f9:	83 c4 08             	add    $0x8,%esp
  8012fc:	85 c0                	test   %eax,%eax
  8012fe:	0f 88 c1 00 00 00    	js     8013c5 <dup+0xe4>
		return r;
	close(newfdnum);
  801304:	83 ec 0c             	sub    $0xc,%esp
  801307:	56                   	push   %esi
  801308:	e8 84 ff ff ff       	call   801291 <close>

	newfd = INDEX2FD(newfdnum);
  80130d:	89 f3                	mov    %esi,%ebx
  80130f:	c1 e3 0c             	shl    $0xc,%ebx
  801312:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801318:	83 c4 04             	add    $0x4,%esp
  80131b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80131e:	e8 de fd ff ff       	call   801101 <fd2data>
  801323:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801325:	89 1c 24             	mov    %ebx,(%esp)
  801328:	e8 d4 fd ff ff       	call   801101 <fd2data>
  80132d:	83 c4 10             	add    $0x10,%esp
  801330:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801333:	89 f8                	mov    %edi,%eax
  801335:	c1 e8 16             	shr    $0x16,%eax
  801338:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80133f:	a8 01                	test   $0x1,%al
  801341:	74 37                	je     80137a <dup+0x99>
  801343:	89 f8                	mov    %edi,%eax
  801345:	c1 e8 0c             	shr    $0xc,%eax
  801348:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80134f:	f6 c2 01             	test   $0x1,%dl
  801352:	74 26                	je     80137a <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801354:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80135b:	83 ec 0c             	sub    $0xc,%esp
  80135e:	25 07 0e 00 00       	and    $0xe07,%eax
  801363:	50                   	push   %eax
  801364:	ff 75 d4             	pushl  -0x2c(%ebp)
  801367:	6a 00                	push   $0x0
  801369:	57                   	push   %edi
  80136a:	6a 00                	push   $0x0
  80136c:	e8 4b f8 ff ff       	call   800bbc <sys_page_map>
  801371:	89 c7                	mov    %eax,%edi
  801373:	83 c4 20             	add    $0x20,%esp
  801376:	85 c0                	test   %eax,%eax
  801378:	78 2e                	js     8013a8 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80137a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80137d:	89 d0                	mov    %edx,%eax
  80137f:	c1 e8 0c             	shr    $0xc,%eax
  801382:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801389:	83 ec 0c             	sub    $0xc,%esp
  80138c:	25 07 0e 00 00       	and    $0xe07,%eax
  801391:	50                   	push   %eax
  801392:	53                   	push   %ebx
  801393:	6a 00                	push   $0x0
  801395:	52                   	push   %edx
  801396:	6a 00                	push   $0x0
  801398:	e8 1f f8 ff ff       	call   800bbc <sys_page_map>
  80139d:	89 c7                	mov    %eax,%edi
  80139f:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8013a2:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8013a4:	85 ff                	test   %edi,%edi
  8013a6:	79 1d                	jns    8013c5 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8013a8:	83 ec 08             	sub    $0x8,%esp
  8013ab:	53                   	push   %ebx
  8013ac:	6a 00                	push   $0x0
  8013ae:	e8 4b f8 ff ff       	call   800bfe <sys_page_unmap>
	sys_page_unmap(0, nva);
  8013b3:	83 c4 08             	add    $0x8,%esp
  8013b6:	ff 75 d4             	pushl  -0x2c(%ebp)
  8013b9:	6a 00                	push   $0x0
  8013bb:	e8 3e f8 ff ff       	call   800bfe <sys_page_unmap>
	return r;
  8013c0:	83 c4 10             	add    $0x10,%esp
  8013c3:	89 f8                	mov    %edi,%eax
}
  8013c5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013c8:	5b                   	pop    %ebx
  8013c9:	5e                   	pop    %esi
  8013ca:	5f                   	pop    %edi
  8013cb:	5d                   	pop    %ebp
  8013cc:	c3                   	ret    

008013cd <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8013cd:	55                   	push   %ebp
  8013ce:	89 e5                	mov    %esp,%ebp
  8013d0:	53                   	push   %ebx
  8013d1:	83 ec 14             	sub    $0x14,%esp
  8013d4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013d7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013da:	50                   	push   %eax
  8013db:	53                   	push   %ebx
  8013dc:	e8 86 fd ff ff       	call   801167 <fd_lookup>
  8013e1:	83 c4 08             	add    $0x8,%esp
  8013e4:	89 c2                	mov    %eax,%edx
  8013e6:	85 c0                	test   %eax,%eax
  8013e8:	78 6d                	js     801457 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013ea:	83 ec 08             	sub    $0x8,%esp
  8013ed:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013f0:	50                   	push   %eax
  8013f1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013f4:	ff 30                	pushl  (%eax)
  8013f6:	e8 c2 fd ff ff       	call   8011bd <dev_lookup>
  8013fb:	83 c4 10             	add    $0x10,%esp
  8013fe:	85 c0                	test   %eax,%eax
  801400:	78 4c                	js     80144e <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801402:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801405:	8b 42 08             	mov    0x8(%edx),%eax
  801408:	83 e0 03             	and    $0x3,%eax
  80140b:	83 f8 01             	cmp    $0x1,%eax
  80140e:	75 21                	jne    801431 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801410:	a1 08 40 80 00       	mov    0x804008,%eax
  801415:	8b 40 48             	mov    0x48(%eax),%eax
  801418:	83 ec 04             	sub    $0x4,%esp
  80141b:	53                   	push   %ebx
  80141c:	50                   	push   %eax
  80141d:	68 f9 25 80 00       	push   $0x8025f9
  801422:	e8 ca ed ff ff       	call   8001f1 <cprintf>
		return -E_INVAL;
  801427:	83 c4 10             	add    $0x10,%esp
  80142a:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80142f:	eb 26                	jmp    801457 <read+0x8a>
	}
	if (!dev->dev_read)
  801431:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801434:	8b 40 08             	mov    0x8(%eax),%eax
  801437:	85 c0                	test   %eax,%eax
  801439:	74 17                	je     801452 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80143b:	83 ec 04             	sub    $0x4,%esp
  80143e:	ff 75 10             	pushl  0x10(%ebp)
  801441:	ff 75 0c             	pushl  0xc(%ebp)
  801444:	52                   	push   %edx
  801445:	ff d0                	call   *%eax
  801447:	89 c2                	mov    %eax,%edx
  801449:	83 c4 10             	add    $0x10,%esp
  80144c:	eb 09                	jmp    801457 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80144e:	89 c2                	mov    %eax,%edx
  801450:	eb 05                	jmp    801457 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801452:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801457:	89 d0                	mov    %edx,%eax
  801459:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80145c:	c9                   	leave  
  80145d:	c3                   	ret    

0080145e <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80145e:	55                   	push   %ebp
  80145f:	89 e5                	mov    %esp,%ebp
  801461:	57                   	push   %edi
  801462:	56                   	push   %esi
  801463:	53                   	push   %ebx
  801464:	83 ec 0c             	sub    $0xc,%esp
  801467:	8b 7d 08             	mov    0x8(%ebp),%edi
  80146a:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80146d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801472:	eb 21                	jmp    801495 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801474:	83 ec 04             	sub    $0x4,%esp
  801477:	89 f0                	mov    %esi,%eax
  801479:	29 d8                	sub    %ebx,%eax
  80147b:	50                   	push   %eax
  80147c:	89 d8                	mov    %ebx,%eax
  80147e:	03 45 0c             	add    0xc(%ebp),%eax
  801481:	50                   	push   %eax
  801482:	57                   	push   %edi
  801483:	e8 45 ff ff ff       	call   8013cd <read>
		if (m < 0)
  801488:	83 c4 10             	add    $0x10,%esp
  80148b:	85 c0                	test   %eax,%eax
  80148d:	78 10                	js     80149f <readn+0x41>
			return m;
		if (m == 0)
  80148f:	85 c0                	test   %eax,%eax
  801491:	74 0a                	je     80149d <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801493:	01 c3                	add    %eax,%ebx
  801495:	39 f3                	cmp    %esi,%ebx
  801497:	72 db                	jb     801474 <readn+0x16>
  801499:	89 d8                	mov    %ebx,%eax
  80149b:	eb 02                	jmp    80149f <readn+0x41>
  80149d:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80149f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014a2:	5b                   	pop    %ebx
  8014a3:	5e                   	pop    %esi
  8014a4:	5f                   	pop    %edi
  8014a5:	5d                   	pop    %ebp
  8014a6:	c3                   	ret    

008014a7 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8014a7:	55                   	push   %ebp
  8014a8:	89 e5                	mov    %esp,%ebp
  8014aa:	53                   	push   %ebx
  8014ab:	83 ec 14             	sub    $0x14,%esp
  8014ae:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014b1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014b4:	50                   	push   %eax
  8014b5:	53                   	push   %ebx
  8014b6:	e8 ac fc ff ff       	call   801167 <fd_lookup>
  8014bb:	83 c4 08             	add    $0x8,%esp
  8014be:	89 c2                	mov    %eax,%edx
  8014c0:	85 c0                	test   %eax,%eax
  8014c2:	78 68                	js     80152c <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014c4:	83 ec 08             	sub    $0x8,%esp
  8014c7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014ca:	50                   	push   %eax
  8014cb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014ce:	ff 30                	pushl  (%eax)
  8014d0:	e8 e8 fc ff ff       	call   8011bd <dev_lookup>
  8014d5:	83 c4 10             	add    $0x10,%esp
  8014d8:	85 c0                	test   %eax,%eax
  8014da:	78 47                	js     801523 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8014dc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014df:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8014e3:	75 21                	jne    801506 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8014e5:	a1 08 40 80 00       	mov    0x804008,%eax
  8014ea:	8b 40 48             	mov    0x48(%eax),%eax
  8014ed:	83 ec 04             	sub    $0x4,%esp
  8014f0:	53                   	push   %ebx
  8014f1:	50                   	push   %eax
  8014f2:	68 15 26 80 00       	push   $0x802615
  8014f7:	e8 f5 ec ff ff       	call   8001f1 <cprintf>
		return -E_INVAL;
  8014fc:	83 c4 10             	add    $0x10,%esp
  8014ff:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801504:	eb 26                	jmp    80152c <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801506:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801509:	8b 52 0c             	mov    0xc(%edx),%edx
  80150c:	85 d2                	test   %edx,%edx
  80150e:	74 17                	je     801527 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801510:	83 ec 04             	sub    $0x4,%esp
  801513:	ff 75 10             	pushl  0x10(%ebp)
  801516:	ff 75 0c             	pushl  0xc(%ebp)
  801519:	50                   	push   %eax
  80151a:	ff d2                	call   *%edx
  80151c:	89 c2                	mov    %eax,%edx
  80151e:	83 c4 10             	add    $0x10,%esp
  801521:	eb 09                	jmp    80152c <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801523:	89 c2                	mov    %eax,%edx
  801525:	eb 05                	jmp    80152c <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801527:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80152c:	89 d0                	mov    %edx,%eax
  80152e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801531:	c9                   	leave  
  801532:	c3                   	ret    

00801533 <seek>:

int
seek(int fdnum, off_t offset)
{
  801533:	55                   	push   %ebp
  801534:	89 e5                	mov    %esp,%ebp
  801536:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801539:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80153c:	50                   	push   %eax
  80153d:	ff 75 08             	pushl  0x8(%ebp)
  801540:	e8 22 fc ff ff       	call   801167 <fd_lookup>
  801545:	83 c4 08             	add    $0x8,%esp
  801548:	85 c0                	test   %eax,%eax
  80154a:	78 0e                	js     80155a <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80154c:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80154f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801552:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801555:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80155a:	c9                   	leave  
  80155b:	c3                   	ret    

0080155c <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80155c:	55                   	push   %ebp
  80155d:	89 e5                	mov    %esp,%ebp
  80155f:	53                   	push   %ebx
  801560:	83 ec 14             	sub    $0x14,%esp
  801563:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801566:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801569:	50                   	push   %eax
  80156a:	53                   	push   %ebx
  80156b:	e8 f7 fb ff ff       	call   801167 <fd_lookup>
  801570:	83 c4 08             	add    $0x8,%esp
  801573:	89 c2                	mov    %eax,%edx
  801575:	85 c0                	test   %eax,%eax
  801577:	78 65                	js     8015de <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801579:	83 ec 08             	sub    $0x8,%esp
  80157c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80157f:	50                   	push   %eax
  801580:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801583:	ff 30                	pushl  (%eax)
  801585:	e8 33 fc ff ff       	call   8011bd <dev_lookup>
  80158a:	83 c4 10             	add    $0x10,%esp
  80158d:	85 c0                	test   %eax,%eax
  80158f:	78 44                	js     8015d5 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801591:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801594:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801598:	75 21                	jne    8015bb <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80159a:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80159f:	8b 40 48             	mov    0x48(%eax),%eax
  8015a2:	83 ec 04             	sub    $0x4,%esp
  8015a5:	53                   	push   %ebx
  8015a6:	50                   	push   %eax
  8015a7:	68 d8 25 80 00       	push   $0x8025d8
  8015ac:	e8 40 ec ff ff       	call   8001f1 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8015b1:	83 c4 10             	add    $0x10,%esp
  8015b4:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8015b9:	eb 23                	jmp    8015de <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8015bb:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015be:	8b 52 18             	mov    0x18(%edx),%edx
  8015c1:	85 d2                	test   %edx,%edx
  8015c3:	74 14                	je     8015d9 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8015c5:	83 ec 08             	sub    $0x8,%esp
  8015c8:	ff 75 0c             	pushl  0xc(%ebp)
  8015cb:	50                   	push   %eax
  8015cc:	ff d2                	call   *%edx
  8015ce:	89 c2                	mov    %eax,%edx
  8015d0:	83 c4 10             	add    $0x10,%esp
  8015d3:	eb 09                	jmp    8015de <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015d5:	89 c2                	mov    %eax,%edx
  8015d7:	eb 05                	jmp    8015de <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8015d9:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8015de:	89 d0                	mov    %edx,%eax
  8015e0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015e3:	c9                   	leave  
  8015e4:	c3                   	ret    

008015e5 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8015e5:	55                   	push   %ebp
  8015e6:	89 e5                	mov    %esp,%ebp
  8015e8:	53                   	push   %ebx
  8015e9:	83 ec 14             	sub    $0x14,%esp
  8015ec:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015ef:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015f2:	50                   	push   %eax
  8015f3:	ff 75 08             	pushl  0x8(%ebp)
  8015f6:	e8 6c fb ff ff       	call   801167 <fd_lookup>
  8015fb:	83 c4 08             	add    $0x8,%esp
  8015fe:	89 c2                	mov    %eax,%edx
  801600:	85 c0                	test   %eax,%eax
  801602:	78 58                	js     80165c <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801604:	83 ec 08             	sub    $0x8,%esp
  801607:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80160a:	50                   	push   %eax
  80160b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80160e:	ff 30                	pushl  (%eax)
  801610:	e8 a8 fb ff ff       	call   8011bd <dev_lookup>
  801615:	83 c4 10             	add    $0x10,%esp
  801618:	85 c0                	test   %eax,%eax
  80161a:	78 37                	js     801653 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80161c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80161f:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801623:	74 32                	je     801657 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801625:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801628:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80162f:	00 00 00 
	stat->st_isdir = 0;
  801632:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801639:	00 00 00 
	stat->st_dev = dev;
  80163c:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801642:	83 ec 08             	sub    $0x8,%esp
  801645:	53                   	push   %ebx
  801646:	ff 75 f0             	pushl  -0x10(%ebp)
  801649:	ff 50 14             	call   *0x14(%eax)
  80164c:	89 c2                	mov    %eax,%edx
  80164e:	83 c4 10             	add    $0x10,%esp
  801651:	eb 09                	jmp    80165c <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801653:	89 c2                	mov    %eax,%edx
  801655:	eb 05                	jmp    80165c <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801657:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80165c:	89 d0                	mov    %edx,%eax
  80165e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801661:	c9                   	leave  
  801662:	c3                   	ret    

00801663 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801663:	55                   	push   %ebp
  801664:	89 e5                	mov    %esp,%ebp
  801666:	56                   	push   %esi
  801667:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801668:	83 ec 08             	sub    $0x8,%esp
  80166b:	6a 00                	push   $0x0
  80166d:	ff 75 08             	pushl  0x8(%ebp)
  801670:	e8 d6 01 00 00       	call   80184b <open>
  801675:	89 c3                	mov    %eax,%ebx
  801677:	83 c4 10             	add    $0x10,%esp
  80167a:	85 c0                	test   %eax,%eax
  80167c:	78 1b                	js     801699 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80167e:	83 ec 08             	sub    $0x8,%esp
  801681:	ff 75 0c             	pushl  0xc(%ebp)
  801684:	50                   	push   %eax
  801685:	e8 5b ff ff ff       	call   8015e5 <fstat>
  80168a:	89 c6                	mov    %eax,%esi
	close(fd);
  80168c:	89 1c 24             	mov    %ebx,(%esp)
  80168f:	e8 fd fb ff ff       	call   801291 <close>
	return r;
  801694:	83 c4 10             	add    $0x10,%esp
  801697:	89 f0                	mov    %esi,%eax
}
  801699:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80169c:	5b                   	pop    %ebx
  80169d:	5e                   	pop    %esi
  80169e:	5d                   	pop    %ebp
  80169f:	c3                   	ret    

008016a0 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8016a0:	55                   	push   %ebp
  8016a1:	89 e5                	mov    %esp,%ebp
  8016a3:	56                   	push   %esi
  8016a4:	53                   	push   %ebx
  8016a5:	89 c6                	mov    %eax,%esi
  8016a7:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8016a9:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8016b0:	75 12                	jne    8016c4 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8016b2:	83 ec 0c             	sub    $0xc,%esp
  8016b5:	6a 01                	push   $0x1
  8016b7:	e8 fc f9 ff ff       	call   8010b8 <ipc_find_env>
  8016bc:	a3 00 40 80 00       	mov    %eax,0x804000
  8016c1:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8016c4:	6a 07                	push   $0x7
  8016c6:	68 00 50 80 00       	push   $0x805000
  8016cb:	56                   	push   %esi
  8016cc:	ff 35 00 40 80 00    	pushl  0x804000
  8016d2:	e8 8d f9 ff ff       	call   801064 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8016d7:	83 c4 0c             	add    $0xc,%esp
  8016da:	6a 00                	push   $0x0
  8016dc:	53                   	push   %ebx
  8016dd:	6a 00                	push   $0x0
  8016df:	e8 19 f9 ff ff       	call   800ffd <ipc_recv>
}
  8016e4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016e7:	5b                   	pop    %ebx
  8016e8:	5e                   	pop    %esi
  8016e9:	5d                   	pop    %ebp
  8016ea:	c3                   	ret    

008016eb <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8016eb:	55                   	push   %ebp
  8016ec:	89 e5                	mov    %esp,%ebp
  8016ee:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8016f1:	8b 45 08             	mov    0x8(%ebp),%eax
  8016f4:	8b 40 0c             	mov    0xc(%eax),%eax
  8016f7:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8016fc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8016ff:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801704:	ba 00 00 00 00       	mov    $0x0,%edx
  801709:	b8 02 00 00 00       	mov    $0x2,%eax
  80170e:	e8 8d ff ff ff       	call   8016a0 <fsipc>
}
  801713:	c9                   	leave  
  801714:	c3                   	ret    

00801715 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801715:	55                   	push   %ebp
  801716:	89 e5                	mov    %esp,%ebp
  801718:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80171b:	8b 45 08             	mov    0x8(%ebp),%eax
  80171e:	8b 40 0c             	mov    0xc(%eax),%eax
  801721:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801726:	ba 00 00 00 00       	mov    $0x0,%edx
  80172b:	b8 06 00 00 00       	mov    $0x6,%eax
  801730:	e8 6b ff ff ff       	call   8016a0 <fsipc>
}
  801735:	c9                   	leave  
  801736:	c3                   	ret    

00801737 <devfile_stat>:

}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801737:	55                   	push   %ebp
  801738:	89 e5                	mov    %esp,%ebp
  80173a:	53                   	push   %ebx
  80173b:	83 ec 04             	sub    $0x4,%esp
  80173e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801741:	8b 45 08             	mov    0x8(%ebp),%eax
  801744:	8b 40 0c             	mov    0xc(%eax),%eax
  801747:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80174c:	ba 00 00 00 00       	mov    $0x0,%edx
  801751:	b8 05 00 00 00       	mov    $0x5,%eax
  801756:	e8 45 ff ff ff       	call   8016a0 <fsipc>
  80175b:	85 c0                	test   %eax,%eax
  80175d:	78 2c                	js     80178b <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80175f:	83 ec 08             	sub    $0x8,%esp
  801762:	68 00 50 80 00       	push   $0x805000
  801767:	53                   	push   %ebx
  801768:	e8 09 f0 ff ff       	call   800776 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80176d:	a1 80 50 80 00       	mov    0x805080,%eax
  801772:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801778:	a1 84 50 80 00       	mov    0x805084,%eax
  80177d:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801783:	83 c4 10             	add    $0x10,%esp
  801786:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80178b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80178e:	c9                   	leave  
  80178f:	c3                   	ret    

00801790 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801790:	55                   	push   %ebp
  801791:	89 e5                	mov    %esp,%ebp
  801793:	83 ec 0c             	sub    $0xc,%esp
  801796:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	// panic("devfile_write not implemented");

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801799:	8b 55 08             	mov    0x8(%ebp),%edx
  80179c:	8b 52 0c             	mov    0xc(%edx),%edx
  80179f:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  8017a5:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  8017aa:	50                   	push   %eax
  8017ab:	ff 75 0c             	pushl  0xc(%ebp)
  8017ae:	68 08 50 80 00       	push   $0x805008
  8017b3:	e8 50 f1 ff ff       	call   800908 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  8017b8:	ba 00 00 00 00       	mov    $0x0,%edx
  8017bd:	b8 04 00 00 00       	mov    $0x4,%eax
  8017c2:	e8 d9 fe ff ff       	call   8016a0 <fsipc>

}
  8017c7:	c9                   	leave  
  8017c8:	c3                   	ret    

008017c9 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8017c9:	55                   	push   %ebp
  8017ca:	89 e5                	mov    %esp,%ebp
  8017cc:	56                   	push   %esi
  8017cd:	53                   	push   %ebx
  8017ce:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8017d1:	8b 45 08             	mov    0x8(%ebp),%eax
  8017d4:	8b 40 0c             	mov    0xc(%eax),%eax
  8017d7:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8017dc:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8017e2:	ba 00 00 00 00       	mov    $0x0,%edx
  8017e7:	b8 03 00 00 00       	mov    $0x3,%eax
  8017ec:	e8 af fe ff ff       	call   8016a0 <fsipc>
  8017f1:	89 c3                	mov    %eax,%ebx
  8017f3:	85 c0                	test   %eax,%eax
  8017f5:	78 4b                	js     801842 <devfile_read+0x79>
		return r;
	assert(r <= n);
  8017f7:	39 c6                	cmp    %eax,%esi
  8017f9:	73 16                	jae    801811 <devfile_read+0x48>
  8017fb:	68 44 26 80 00       	push   $0x802644
  801800:	68 4b 26 80 00       	push   $0x80264b
  801805:	6a 7c                	push   $0x7c
  801807:	68 60 26 80 00       	push   $0x802660
  80180c:	e8 bd 05 00 00       	call   801dce <_panic>
	assert(r <= PGSIZE);
  801811:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801816:	7e 16                	jle    80182e <devfile_read+0x65>
  801818:	68 6b 26 80 00       	push   $0x80266b
  80181d:	68 4b 26 80 00       	push   $0x80264b
  801822:	6a 7d                	push   $0x7d
  801824:	68 60 26 80 00       	push   $0x802660
  801829:	e8 a0 05 00 00       	call   801dce <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80182e:	83 ec 04             	sub    $0x4,%esp
  801831:	50                   	push   %eax
  801832:	68 00 50 80 00       	push   $0x805000
  801837:	ff 75 0c             	pushl  0xc(%ebp)
  80183a:	e8 c9 f0 ff ff       	call   800908 <memmove>
	return r;
  80183f:	83 c4 10             	add    $0x10,%esp
}
  801842:	89 d8                	mov    %ebx,%eax
  801844:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801847:	5b                   	pop    %ebx
  801848:	5e                   	pop    %esi
  801849:	5d                   	pop    %ebp
  80184a:	c3                   	ret    

0080184b <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  80184b:	55                   	push   %ebp
  80184c:	89 e5                	mov    %esp,%ebp
  80184e:	53                   	push   %ebx
  80184f:	83 ec 20             	sub    $0x20,%esp
  801852:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801855:	53                   	push   %ebx
  801856:	e8 e2 ee ff ff       	call   80073d <strlen>
  80185b:	83 c4 10             	add    $0x10,%esp
  80185e:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801863:	7f 67                	jg     8018cc <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801865:	83 ec 0c             	sub    $0xc,%esp
  801868:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80186b:	50                   	push   %eax
  80186c:	e8 a7 f8 ff ff       	call   801118 <fd_alloc>
  801871:	83 c4 10             	add    $0x10,%esp
		return r;
  801874:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801876:	85 c0                	test   %eax,%eax
  801878:	78 57                	js     8018d1 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  80187a:	83 ec 08             	sub    $0x8,%esp
  80187d:	53                   	push   %ebx
  80187e:	68 00 50 80 00       	push   $0x805000
  801883:	e8 ee ee ff ff       	call   800776 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801888:	8b 45 0c             	mov    0xc(%ebp),%eax
  80188b:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801890:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801893:	b8 01 00 00 00       	mov    $0x1,%eax
  801898:	e8 03 fe ff ff       	call   8016a0 <fsipc>
  80189d:	89 c3                	mov    %eax,%ebx
  80189f:	83 c4 10             	add    $0x10,%esp
  8018a2:	85 c0                	test   %eax,%eax
  8018a4:	79 14                	jns    8018ba <open+0x6f>
		fd_close(fd, 0);
  8018a6:	83 ec 08             	sub    $0x8,%esp
  8018a9:	6a 00                	push   $0x0
  8018ab:	ff 75 f4             	pushl  -0xc(%ebp)
  8018ae:	e8 5d f9 ff ff       	call   801210 <fd_close>
		return r;
  8018b3:	83 c4 10             	add    $0x10,%esp
  8018b6:	89 da                	mov    %ebx,%edx
  8018b8:	eb 17                	jmp    8018d1 <open+0x86>
	}

	return fd2num(fd);
  8018ba:	83 ec 0c             	sub    $0xc,%esp
  8018bd:	ff 75 f4             	pushl  -0xc(%ebp)
  8018c0:	e8 2c f8 ff ff       	call   8010f1 <fd2num>
  8018c5:	89 c2                	mov    %eax,%edx
  8018c7:	83 c4 10             	add    $0x10,%esp
  8018ca:	eb 05                	jmp    8018d1 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8018cc:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8018d1:	89 d0                	mov    %edx,%eax
  8018d3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018d6:	c9                   	leave  
  8018d7:	c3                   	ret    

008018d8 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8018d8:	55                   	push   %ebp
  8018d9:	89 e5                	mov    %esp,%ebp
  8018db:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8018de:	ba 00 00 00 00       	mov    $0x0,%edx
  8018e3:	b8 08 00 00 00       	mov    $0x8,%eax
  8018e8:	e8 b3 fd ff ff       	call   8016a0 <fsipc>
}
  8018ed:	c9                   	leave  
  8018ee:	c3                   	ret    

008018ef <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8018ef:	55                   	push   %ebp
  8018f0:	89 e5                	mov    %esp,%ebp
  8018f2:	56                   	push   %esi
  8018f3:	53                   	push   %ebx
  8018f4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8018f7:	83 ec 0c             	sub    $0xc,%esp
  8018fa:	ff 75 08             	pushl  0x8(%ebp)
  8018fd:	e8 ff f7 ff ff       	call   801101 <fd2data>
  801902:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801904:	83 c4 08             	add    $0x8,%esp
  801907:	68 77 26 80 00       	push   $0x802677
  80190c:	53                   	push   %ebx
  80190d:	e8 64 ee ff ff       	call   800776 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801912:	8b 46 04             	mov    0x4(%esi),%eax
  801915:	2b 06                	sub    (%esi),%eax
  801917:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80191d:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801924:	00 00 00 
	stat->st_dev = &devpipe;
  801927:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  80192e:	30 80 00 
	return 0;
}
  801931:	b8 00 00 00 00       	mov    $0x0,%eax
  801936:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801939:	5b                   	pop    %ebx
  80193a:	5e                   	pop    %esi
  80193b:	5d                   	pop    %ebp
  80193c:	c3                   	ret    

0080193d <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80193d:	55                   	push   %ebp
  80193e:	89 e5                	mov    %esp,%ebp
  801940:	53                   	push   %ebx
  801941:	83 ec 0c             	sub    $0xc,%esp
  801944:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801947:	53                   	push   %ebx
  801948:	6a 00                	push   $0x0
  80194a:	e8 af f2 ff ff       	call   800bfe <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  80194f:	89 1c 24             	mov    %ebx,(%esp)
  801952:	e8 aa f7 ff ff       	call   801101 <fd2data>
  801957:	83 c4 08             	add    $0x8,%esp
  80195a:	50                   	push   %eax
  80195b:	6a 00                	push   $0x0
  80195d:	e8 9c f2 ff ff       	call   800bfe <sys_page_unmap>
}
  801962:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801965:	c9                   	leave  
  801966:	c3                   	ret    

00801967 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801967:	55                   	push   %ebp
  801968:	89 e5                	mov    %esp,%ebp
  80196a:	57                   	push   %edi
  80196b:	56                   	push   %esi
  80196c:	53                   	push   %ebx
  80196d:	83 ec 1c             	sub    $0x1c,%esp
  801970:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801973:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801975:	a1 08 40 80 00       	mov    0x804008,%eax
  80197a:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  80197d:	83 ec 0c             	sub    $0xc,%esp
  801980:	ff 75 e0             	pushl  -0x20(%ebp)
  801983:	e8 f7 04 00 00       	call   801e7f <pageref>
  801988:	89 c3                	mov    %eax,%ebx
  80198a:	89 3c 24             	mov    %edi,(%esp)
  80198d:	e8 ed 04 00 00       	call   801e7f <pageref>
  801992:	83 c4 10             	add    $0x10,%esp
  801995:	39 c3                	cmp    %eax,%ebx
  801997:	0f 94 c1             	sete   %cl
  80199a:	0f b6 c9             	movzbl %cl,%ecx
  80199d:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  8019a0:	8b 15 08 40 80 00    	mov    0x804008,%edx
  8019a6:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8019a9:	39 ce                	cmp    %ecx,%esi
  8019ab:	74 1b                	je     8019c8 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  8019ad:	39 c3                	cmp    %eax,%ebx
  8019af:	75 c4                	jne    801975 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8019b1:	8b 42 58             	mov    0x58(%edx),%eax
  8019b4:	ff 75 e4             	pushl  -0x1c(%ebp)
  8019b7:	50                   	push   %eax
  8019b8:	56                   	push   %esi
  8019b9:	68 7e 26 80 00       	push   $0x80267e
  8019be:	e8 2e e8 ff ff       	call   8001f1 <cprintf>
  8019c3:	83 c4 10             	add    $0x10,%esp
  8019c6:	eb ad                	jmp    801975 <_pipeisclosed+0xe>
	}
}
  8019c8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8019cb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8019ce:	5b                   	pop    %ebx
  8019cf:	5e                   	pop    %esi
  8019d0:	5f                   	pop    %edi
  8019d1:	5d                   	pop    %ebp
  8019d2:	c3                   	ret    

008019d3 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8019d3:	55                   	push   %ebp
  8019d4:	89 e5                	mov    %esp,%ebp
  8019d6:	57                   	push   %edi
  8019d7:	56                   	push   %esi
  8019d8:	53                   	push   %ebx
  8019d9:	83 ec 28             	sub    $0x28,%esp
  8019dc:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8019df:	56                   	push   %esi
  8019e0:	e8 1c f7 ff ff       	call   801101 <fd2data>
  8019e5:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8019e7:	83 c4 10             	add    $0x10,%esp
  8019ea:	bf 00 00 00 00       	mov    $0x0,%edi
  8019ef:	eb 4b                	jmp    801a3c <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8019f1:	89 da                	mov    %ebx,%edx
  8019f3:	89 f0                	mov    %esi,%eax
  8019f5:	e8 6d ff ff ff       	call   801967 <_pipeisclosed>
  8019fa:	85 c0                	test   %eax,%eax
  8019fc:	75 48                	jne    801a46 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8019fe:	e8 57 f1 ff ff       	call   800b5a <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801a03:	8b 43 04             	mov    0x4(%ebx),%eax
  801a06:	8b 0b                	mov    (%ebx),%ecx
  801a08:	8d 51 20             	lea    0x20(%ecx),%edx
  801a0b:	39 d0                	cmp    %edx,%eax
  801a0d:	73 e2                	jae    8019f1 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801a0f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a12:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801a16:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801a19:	89 c2                	mov    %eax,%edx
  801a1b:	c1 fa 1f             	sar    $0x1f,%edx
  801a1e:	89 d1                	mov    %edx,%ecx
  801a20:	c1 e9 1b             	shr    $0x1b,%ecx
  801a23:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801a26:	83 e2 1f             	and    $0x1f,%edx
  801a29:	29 ca                	sub    %ecx,%edx
  801a2b:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801a2f:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801a33:	83 c0 01             	add    $0x1,%eax
  801a36:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a39:	83 c7 01             	add    $0x1,%edi
  801a3c:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801a3f:	75 c2                	jne    801a03 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801a41:	8b 45 10             	mov    0x10(%ebp),%eax
  801a44:	eb 05                	jmp    801a4b <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801a46:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801a4b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a4e:	5b                   	pop    %ebx
  801a4f:	5e                   	pop    %esi
  801a50:	5f                   	pop    %edi
  801a51:	5d                   	pop    %ebp
  801a52:	c3                   	ret    

00801a53 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801a53:	55                   	push   %ebp
  801a54:	89 e5                	mov    %esp,%ebp
  801a56:	57                   	push   %edi
  801a57:	56                   	push   %esi
  801a58:	53                   	push   %ebx
  801a59:	83 ec 18             	sub    $0x18,%esp
  801a5c:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801a5f:	57                   	push   %edi
  801a60:	e8 9c f6 ff ff       	call   801101 <fd2data>
  801a65:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a67:	83 c4 10             	add    $0x10,%esp
  801a6a:	bb 00 00 00 00       	mov    $0x0,%ebx
  801a6f:	eb 3d                	jmp    801aae <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801a71:	85 db                	test   %ebx,%ebx
  801a73:	74 04                	je     801a79 <devpipe_read+0x26>
				return i;
  801a75:	89 d8                	mov    %ebx,%eax
  801a77:	eb 44                	jmp    801abd <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801a79:	89 f2                	mov    %esi,%edx
  801a7b:	89 f8                	mov    %edi,%eax
  801a7d:	e8 e5 fe ff ff       	call   801967 <_pipeisclosed>
  801a82:	85 c0                	test   %eax,%eax
  801a84:	75 32                	jne    801ab8 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801a86:	e8 cf f0 ff ff       	call   800b5a <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801a8b:	8b 06                	mov    (%esi),%eax
  801a8d:	3b 46 04             	cmp    0x4(%esi),%eax
  801a90:	74 df                	je     801a71 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801a92:	99                   	cltd   
  801a93:	c1 ea 1b             	shr    $0x1b,%edx
  801a96:	01 d0                	add    %edx,%eax
  801a98:	83 e0 1f             	and    $0x1f,%eax
  801a9b:	29 d0                	sub    %edx,%eax
  801a9d:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801aa2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801aa5:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801aa8:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801aab:	83 c3 01             	add    $0x1,%ebx
  801aae:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801ab1:	75 d8                	jne    801a8b <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801ab3:	8b 45 10             	mov    0x10(%ebp),%eax
  801ab6:	eb 05                	jmp    801abd <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801ab8:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801abd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ac0:	5b                   	pop    %ebx
  801ac1:	5e                   	pop    %esi
  801ac2:	5f                   	pop    %edi
  801ac3:	5d                   	pop    %ebp
  801ac4:	c3                   	ret    

00801ac5 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801ac5:	55                   	push   %ebp
  801ac6:	89 e5                	mov    %esp,%ebp
  801ac8:	56                   	push   %esi
  801ac9:	53                   	push   %ebx
  801aca:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801acd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ad0:	50                   	push   %eax
  801ad1:	e8 42 f6 ff ff       	call   801118 <fd_alloc>
  801ad6:	83 c4 10             	add    $0x10,%esp
  801ad9:	89 c2                	mov    %eax,%edx
  801adb:	85 c0                	test   %eax,%eax
  801add:	0f 88 2c 01 00 00    	js     801c0f <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ae3:	83 ec 04             	sub    $0x4,%esp
  801ae6:	68 07 04 00 00       	push   $0x407
  801aeb:	ff 75 f4             	pushl  -0xc(%ebp)
  801aee:	6a 00                	push   $0x0
  801af0:	e8 84 f0 ff ff       	call   800b79 <sys_page_alloc>
  801af5:	83 c4 10             	add    $0x10,%esp
  801af8:	89 c2                	mov    %eax,%edx
  801afa:	85 c0                	test   %eax,%eax
  801afc:	0f 88 0d 01 00 00    	js     801c0f <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801b02:	83 ec 0c             	sub    $0xc,%esp
  801b05:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801b08:	50                   	push   %eax
  801b09:	e8 0a f6 ff ff       	call   801118 <fd_alloc>
  801b0e:	89 c3                	mov    %eax,%ebx
  801b10:	83 c4 10             	add    $0x10,%esp
  801b13:	85 c0                	test   %eax,%eax
  801b15:	0f 88 e2 00 00 00    	js     801bfd <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b1b:	83 ec 04             	sub    $0x4,%esp
  801b1e:	68 07 04 00 00       	push   $0x407
  801b23:	ff 75 f0             	pushl  -0x10(%ebp)
  801b26:	6a 00                	push   $0x0
  801b28:	e8 4c f0 ff ff       	call   800b79 <sys_page_alloc>
  801b2d:	89 c3                	mov    %eax,%ebx
  801b2f:	83 c4 10             	add    $0x10,%esp
  801b32:	85 c0                	test   %eax,%eax
  801b34:	0f 88 c3 00 00 00    	js     801bfd <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801b3a:	83 ec 0c             	sub    $0xc,%esp
  801b3d:	ff 75 f4             	pushl  -0xc(%ebp)
  801b40:	e8 bc f5 ff ff       	call   801101 <fd2data>
  801b45:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b47:	83 c4 0c             	add    $0xc,%esp
  801b4a:	68 07 04 00 00       	push   $0x407
  801b4f:	50                   	push   %eax
  801b50:	6a 00                	push   $0x0
  801b52:	e8 22 f0 ff ff       	call   800b79 <sys_page_alloc>
  801b57:	89 c3                	mov    %eax,%ebx
  801b59:	83 c4 10             	add    $0x10,%esp
  801b5c:	85 c0                	test   %eax,%eax
  801b5e:	0f 88 89 00 00 00    	js     801bed <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b64:	83 ec 0c             	sub    $0xc,%esp
  801b67:	ff 75 f0             	pushl  -0x10(%ebp)
  801b6a:	e8 92 f5 ff ff       	call   801101 <fd2data>
  801b6f:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801b76:	50                   	push   %eax
  801b77:	6a 00                	push   $0x0
  801b79:	56                   	push   %esi
  801b7a:	6a 00                	push   $0x0
  801b7c:	e8 3b f0 ff ff       	call   800bbc <sys_page_map>
  801b81:	89 c3                	mov    %eax,%ebx
  801b83:	83 c4 20             	add    $0x20,%esp
  801b86:	85 c0                	test   %eax,%eax
  801b88:	78 55                	js     801bdf <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801b8a:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801b90:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b93:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801b95:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b98:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801b9f:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801ba5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ba8:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801baa:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801bad:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801bb4:	83 ec 0c             	sub    $0xc,%esp
  801bb7:	ff 75 f4             	pushl  -0xc(%ebp)
  801bba:	e8 32 f5 ff ff       	call   8010f1 <fd2num>
  801bbf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801bc2:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801bc4:	83 c4 04             	add    $0x4,%esp
  801bc7:	ff 75 f0             	pushl  -0x10(%ebp)
  801bca:	e8 22 f5 ff ff       	call   8010f1 <fd2num>
  801bcf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801bd2:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801bd5:	83 c4 10             	add    $0x10,%esp
  801bd8:	ba 00 00 00 00       	mov    $0x0,%edx
  801bdd:	eb 30                	jmp    801c0f <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801bdf:	83 ec 08             	sub    $0x8,%esp
  801be2:	56                   	push   %esi
  801be3:	6a 00                	push   $0x0
  801be5:	e8 14 f0 ff ff       	call   800bfe <sys_page_unmap>
  801bea:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801bed:	83 ec 08             	sub    $0x8,%esp
  801bf0:	ff 75 f0             	pushl  -0x10(%ebp)
  801bf3:	6a 00                	push   $0x0
  801bf5:	e8 04 f0 ff ff       	call   800bfe <sys_page_unmap>
  801bfa:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801bfd:	83 ec 08             	sub    $0x8,%esp
  801c00:	ff 75 f4             	pushl  -0xc(%ebp)
  801c03:	6a 00                	push   $0x0
  801c05:	e8 f4 ef ff ff       	call   800bfe <sys_page_unmap>
  801c0a:	83 c4 10             	add    $0x10,%esp
  801c0d:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801c0f:	89 d0                	mov    %edx,%eax
  801c11:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c14:	5b                   	pop    %ebx
  801c15:	5e                   	pop    %esi
  801c16:	5d                   	pop    %ebp
  801c17:	c3                   	ret    

00801c18 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801c18:	55                   	push   %ebp
  801c19:	89 e5                	mov    %esp,%ebp
  801c1b:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801c1e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c21:	50                   	push   %eax
  801c22:	ff 75 08             	pushl  0x8(%ebp)
  801c25:	e8 3d f5 ff ff       	call   801167 <fd_lookup>
  801c2a:	83 c4 10             	add    $0x10,%esp
  801c2d:	85 c0                	test   %eax,%eax
  801c2f:	78 18                	js     801c49 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801c31:	83 ec 0c             	sub    $0xc,%esp
  801c34:	ff 75 f4             	pushl  -0xc(%ebp)
  801c37:	e8 c5 f4 ff ff       	call   801101 <fd2data>
	return _pipeisclosed(fd, p);
  801c3c:	89 c2                	mov    %eax,%edx
  801c3e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c41:	e8 21 fd ff ff       	call   801967 <_pipeisclosed>
  801c46:	83 c4 10             	add    $0x10,%esp
}
  801c49:	c9                   	leave  
  801c4a:	c3                   	ret    

00801c4b <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801c4b:	55                   	push   %ebp
  801c4c:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801c4e:	b8 00 00 00 00       	mov    $0x0,%eax
  801c53:	5d                   	pop    %ebp
  801c54:	c3                   	ret    

00801c55 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801c55:	55                   	push   %ebp
  801c56:	89 e5                	mov    %esp,%ebp
  801c58:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801c5b:	68 96 26 80 00       	push   $0x802696
  801c60:	ff 75 0c             	pushl  0xc(%ebp)
  801c63:	e8 0e eb ff ff       	call   800776 <strcpy>
	return 0;
}
  801c68:	b8 00 00 00 00       	mov    $0x0,%eax
  801c6d:	c9                   	leave  
  801c6e:	c3                   	ret    

00801c6f <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801c6f:	55                   	push   %ebp
  801c70:	89 e5                	mov    %esp,%ebp
  801c72:	57                   	push   %edi
  801c73:	56                   	push   %esi
  801c74:	53                   	push   %ebx
  801c75:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801c7b:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801c80:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801c86:	eb 2d                	jmp    801cb5 <devcons_write+0x46>
		m = n - tot;
  801c88:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801c8b:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801c8d:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801c90:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801c95:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801c98:	83 ec 04             	sub    $0x4,%esp
  801c9b:	53                   	push   %ebx
  801c9c:	03 45 0c             	add    0xc(%ebp),%eax
  801c9f:	50                   	push   %eax
  801ca0:	57                   	push   %edi
  801ca1:	e8 62 ec ff ff       	call   800908 <memmove>
		sys_cputs(buf, m);
  801ca6:	83 c4 08             	add    $0x8,%esp
  801ca9:	53                   	push   %ebx
  801caa:	57                   	push   %edi
  801cab:	e8 0d ee ff ff       	call   800abd <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801cb0:	01 de                	add    %ebx,%esi
  801cb2:	83 c4 10             	add    $0x10,%esp
  801cb5:	89 f0                	mov    %esi,%eax
  801cb7:	3b 75 10             	cmp    0x10(%ebp),%esi
  801cba:	72 cc                	jb     801c88 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801cbc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801cbf:	5b                   	pop    %ebx
  801cc0:	5e                   	pop    %esi
  801cc1:	5f                   	pop    %edi
  801cc2:	5d                   	pop    %ebp
  801cc3:	c3                   	ret    

00801cc4 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801cc4:	55                   	push   %ebp
  801cc5:	89 e5                	mov    %esp,%ebp
  801cc7:	83 ec 08             	sub    $0x8,%esp
  801cca:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801ccf:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801cd3:	74 2a                	je     801cff <devcons_read+0x3b>
  801cd5:	eb 05                	jmp    801cdc <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801cd7:	e8 7e ee ff ff       	call   800b5a <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801cdc:	e8 fa ed ff ff       	call   800adb <sys_cgetc>
  801ce1:	85 c0                	test   %eax,%eax
  801ce3:	74 f2                	je     801cd7 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801ce5:	85 c0                	test   %eax,%eax
  801ce7:	78 16                	js     801cff <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801ce9:	83 f8 04             	cmp    $0x4,%eax
  801cec:	74 0c                	je     801cfa <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801cee:	8b 55 0c             	mov    0xc(%ebp),%edx
  801cf1:	88 02                	mov    %al,(%edx)
	return 1;
  801cf3:	b8 01 00 00 00       	mov    $0x1,%eax
  801cf8:	eb 05                	jmp    801cff <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801cfa:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801cff:	c9                   	leave  
  801d00:	c3                   	ret    

00801d01 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801d01:	55                   	push   %ebp
  801d02:	89 e5                	mov    %esp,%ebp
  801d04:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801d07:	8b 45 08             	mov    0x8(%ebp),%eax
  801d0a:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801d0d:	6a 01                	push   $0x1
  801d0f:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801d12:	50                   	push   %eax
  801d13:	e8 a5 ed ff ff       	call   800abd <sys_cputs>
}
  801d18:	83 c4 10             	add    $0x10,%esp
  801d1b:	c9                   	leave  
  801d1c:	c3                   	ret    

00801d1d <getchar>:

int
getchar(void)
{
  801d1d:	55                   	push   %ebp
  801d1e:	89 e5                	mov    %esp,%ebp
  801d20:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801d23:	6a 01                	push   $0x1
  801d25:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801d28:	50                   	push   %eax
  801d29:	6a 00                	push   $0x0
  801d2b:	e8 9d f6 ff ff       	call   8013cd <read>
	if (r < 0)
  801d30:	83 c4 10             	add    $0x10,%esp
  801d33:	85 c0                	test   %eax,%eax
  801d35:	78 0f                	js     801d46 <getchar+0x29>
		return r;
	if (r < 1)
  801d37:	85 c0                	test   %eax,%eax
  801d39:	7e 06                	jle    801d41 <getchar+0x24>
		return -E_EOF;
	return c;
  801d3b:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801d3f:	eb 05                	jmp    801d46 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801d41:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801d46:	c9                   	leave  
  801d47:	c3                   	ret    

00801d48 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801d48:	55                   	push   %ebp
  801d49:	89 e5                	mov    %esp,%ebp
  801d4b:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801d4e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d51:	50                   	push   %eax
  801d52:	ff 75 08             	pushl  0x8(%ebp)
  801d55:	e8 0d f4 ff ff       	call   801167 <fd_lookup>
  801d5a:	83 c4 10             	add    $0x10,%esp
  801d5d:	85 c0                	test   %eax,%eax
  801d5f:	78 11                	js     801d72 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801d61:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d64:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801d6a:	39 10                	cmp    %edx,(%eax)
  801d6c:	0f 94 c0             	sete   %al
  801d6f:	0f b6 c0             	movzbl %al,%eax
}
  801d72:	c9                   	leave  
  801d73:	c3                   	ret    

00801d74 <opencons>:

int
opencons(void)
{
  801d74:	55                   	push   %ebp
  801d75:	89 e5                	mov    %esp,%ebp
  801d77:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801d7a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d7d:	50                   	push   %eax
  801d7e:	e8 95 f3 ff ff       	call   801118 <fd_alloc>
  801d83:	83 c4 10             	add    $0x10,%esp
		return r;
  801d86:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801d88:	85 c0                	test   %eax,%eax
  801d8a:	78 3e                	js     801dca <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801d8c:	83 ec 04             	sub    $0x4,%esp
  801d8f:	68 07 04 00 00       	push   $0x407
  801d94:	ff 75 f4             	pushl  -0xc(%ebp)
  801d97:	6a 00                	push   $0x0
  801d99:	e8 db ed ff ff       	call   800b79 <sys_page_alloc>
  801d9e:	83 c4 10             	add    $0x10,%esp
		return r;
  801da1:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801da3:	85 c0                	test   %eax,%eax
  801da5:	78 23                	js     801dca <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801da7:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801dad:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801db0:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801db2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801db5:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801dbc:	83 ec 0c             	sub    $0xc,%esp
  801dbf:	50                   	push   %eax
  801dc0:	e8 2c f3 ff ff       	call   8010f1 <fd2num>
  801dc5:	89 c2                	mov    %eax,%edx
  801dc7:	83 c4 10             	add    $0x10,%esp
}
  801dca:	89 d0                	mov    %edx,%eax
  801dcc:	c9                   	leave  
  801dcd:	c3                   	ret    

00801dce <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801dce:	55                   	push   %ebp
  801dcf:	89 e5                	mov    %esp,%ebp
  801dd1:	56                   	push   %esi
  801dd2:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801dd3:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801dd6:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801ddc:	e8 5a ed ff ff       	call   800b3b <sys_getenvid>
  801de1:	83 ec 0c             	sub    $0xc,%esp
  801de4:	ff 75 0c             	pushl  0xc(%ebp)
  801de7:	ff 75 08             	pushl  0x8(%ebp)
  801dea:	56                   	push   %esi
  801deb:	50                   	push   %eax
  801dec:	68 a4 26 80 00       	push   $0x8026a4
  801df1:	e8 fb e3 ff ff       	call   8001f1 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801df6:	83 c4 18             	add    $0x18,%esp
  801df9:	53                   	push   %ebx
  801dfa:	ff 75 10             	pushl  0x10(%ebp)
  801dfd:	e8 9e e3 ff ff       	call   8001a0 <vcprintf>
	cprintf("\n");
  801e02:	c7 04 24 8f 26 80 00 	movl   $0x80268f,(%esp)
  801e09:	e8 e3 e3 ff ff       	call   8001f1 <cprintf>
  801e0e:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801e11:	cc                   	int3   
  801e12:	eb fd                	jmp    801e11 <_panic+0x43>

00801e14 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801e14:	55                   	push   %ebp
  801e15:	89 e5                	mov    %esp,%ebp
  801e17:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801e1a:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801e21:	75 2e                	jne    801e51 <set_pgfault_handler+0x3d>
		// First time through!
		// LAB 4: Your code here.
		// panic("set_pgfault_handler not implemented");

		sys_page_alloc(sys_getenvid(), (void *) (UXSTACKTOP - PGSIZE), PTE_SYSCALL);
  801e23:	e8 13 ed ff ff       	call   800b3b <sys_getenvid>
  801e28:	83 ec 04             	sub    $0x4,%esp
  801e2b:	68 07 0e 00 00       	push   $0xe07
  801e30:	68 00 f0 bf ee       	push   $0xeebff000
  801e35:	50                   	push   %eax
  801e36:	e8 3e ed ff ff       	call   800b79 <sys_page_alloc>
		sys_env_set_pgfault_upcall(sys_getenvid(), _pgfault_upcall);
  801e3b:	e8 fb ec ff ff       	call   800b3b <sys_getenvid>
  801e40:	83 c4 08             	add    $0x8,%esp
  801e43:	68 5b 1e 80 00       	push   $0x801e5b
  801e48:	50                   	push   %eax
  801e49:	e8 76 ee ff ff       	call   800cc4 <sys_env_set_pgfault_upcall>
  801e4e:	83 c4 10             	add    $0x10,%esp
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801e51:	8b 45 08             	mov    0x8(%ebp),%eax
  801e54:	a3 00 60 80 00       	mov    %eax,0x806000
}
  801e59:	c9                   	leave  
  801e5a:	c3                   	ret    

00801e5b <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801e5b:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801e5c:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801e61:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801e63:	83 c4 04             	add    $0x4,%esp
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.

	movl 48(%esp), %eax		// trap-time esp
  801e66:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl 40(%esp), %ebx		// trap-time eip
  801e6a:	8b 5c 24 28          	mov    0x28(%esp),%ebx

	// load eip into esp-4
	// in order to return to trap-time eip later, in the meantime not changing trap-time esp
	movl %ebx, -4(%eax)	
  801e6e:	89 58 fc             	mov    %ebx,-0x4(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.

	addl $8, %esp 			// esp now points to trap-time registers
  801e71:	83 c4 08             	add    $0x8,%esp
	popal					// pop to all registers
  801e74:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

	addl $4, %esp			// esp now points to trap-time eflags
  801e75:	83 c4 04             	add    $0x4,%esp
	popfl					// pop to eflags
  801e78:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.

	popl %esp				// pop to esp
  801e79:	5c                   	pop    %esp
	// subl $4, %esp		// arithmetic operation will change eflags!!!
	lea -4(%esp), %esp		// subl $4, %esp
  801e7a:	8d 64 24 fc          	lea    -0x4(%esp),%esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.

	ret
  801e7e:	c3                   	ret    

00801e7f <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801e7f:	55                   	push   %ebp
  801e80:	89 e5                	mov    %esp,%ebp
  801e82:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801e85:	89 d0                	mov    %edx,%eax
  801e87:	c1 e8 16             	shr    $0x16,%eax
  801e8a:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801e91:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801e96:	f6 c1 01             	test   $0x1,%cl
  801e99:	74 1d                	je     801eb8 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801e9b:	c1 ea 0c             	shr    $0xc,%edx
  801e9e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801ea5:	f6 c2 01             	test   $0x1,%dl
  801ea8:	74 0e                	je     801eb8 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801eaa:	c1 ea 0c             	shr    $0xc,%edx
  801ead:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801eb4:	ef 
  801eb5:	0f b7 c0             	movzwl %ax,%eax
}
  801eb8:	5d                   	pop    %ebp
  801eb9:	c3                   	ret    
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
