
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
  80003c:	e8 9f 0f 00 00       	call   800fe0 <sfork>
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
  800082:	e8 da 0f 00 00       	call   801061 <ipc_send>
  800087:	83 c4 20             	add    $0x20,%esp
	}

	while (1) {
		ipc_recv(&who, 0, 0);
  80008a:	83 ec 04             	sub    $0x4,%esp
  80008d:	6a 00                	push   $0x0
  80008f:	6a 00                	push   $0x0
  800091:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800094:	50                   	push   %eax
  800095:	e8 60 0f 00 00       	call   800ffa <ipc_recv>
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
  8000e5:	e8 77 0f 00 00       	call   801061 <ipc_send>
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
  80014a:	e8 6a 11 00 00       	call   8012b9 <close_all>
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
  800b2e:	e8 98 12 00 00       	call   801dcb <_panic>

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
  800baf:	e8 17 12 00 00       	call   801dcb <_panic>

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
  800bf1:	e8 d5 11 00 00       	call   801dcb <_panic>

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
  800c33:	e8 93 11 00 00       	call   801dcb <_panic>

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
  800c75:	e8 51 11 00 00       	call   801dcb <_panic>

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
  800cb7:	e8 0f 11 00 00       	call   801dcb <_panic>

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
  800cf9:	e8 cd 10 00 00       	call   801dcb <_panic>

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
  800d5d:	e8 69 10 00 00       	call   801dcb <_panic>

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
  800d9a:	e8 2c 10 00 00       	call   801dcb <_panic>

	// LAB 4: Your code here.

	// panic("pgfault not implemented");

	addr = ROUNDDOWN(addr, PGSIZE);
  800d9f:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	envid_t envid = sys_getenvid();
  800da5:	e8 91 fd ff ff       	call   800b3b <sys_getenvid>
  800daa:	89 c6                	mov    %eax,%esi

	// envid = 0;

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
  800dc9:	6a 33                	push   $0x33
  800dcb:	68 80 25 80 00       	push   $0x802580
  800dd0:	e8 f6 0f 00 00       	call   801dcb <_panic>
	
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
  800e09:	6a 3b                	push   $0x3b
  800e0b:	68 80 25 80 00       	push   $0x802580
  800e10:	e8 b6 0f 00 00       	call   801dcb <_panic>

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
  800e30:	6a 40                	push   $0x40
  800e32:	68 80 25 80 00       	push   $0x802580
  800e37:	e8 8f 0f 00 00       	call   801dcb <_panic>
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
  800e51:	e8 bb 0f 00 00       	call   801e11 <set_pgfault_handler>
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
  800e62:	0f 88 64 01 00 00    	js     800fcc <fork+0x189>
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
  800e92:	e9 3f 01 00 00       	jmp    800fd6 <fork+0x193>
  800e97:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800e9a:	89 c7                	mov    %eax,%edi

		addr = pn * PGSIZE;
		// pde_t *pgdir =  curenv->env_pgdir;

		// if level-2 page exists
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P) {
  800e9c:	89 d8                	mov    %ebx,%eax
  800e9e:	c1 e8 16             	shr    $0x16,%eax
  800ea1:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800ea8:	a8 01                	test   $0x1,%al
  800eaa:	0f 84 bd 00 00 00    	je     800f6d <fork+0x12a>
			
			// if real PTE exists
			if ((uvpt[PGNUM(addr)] & PTE_P) == PTE_P) {
  800eb0:	89 d8                	mov    %ebx,%eax
  800eb2:	c1 e8 0c             	shr    $0xc,%eax
  800eb5:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800ebc:	f6 c2 01             	test   $0x1,%dl
  800ebf:	0f 84 a8 00 00 00    	je     800f6d <fork+0x12a>

				// For each writable or copy-on-write page
				// if ((uvpt[PGNUM(addr)] & (PTE_W | PTE_COW)) != 0) {
				if ((uvpt[PGNUM(addr)] & PTE_U) != 0) {
  800ec5:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800ecc:	a8 04                	test   $0x4,%al
  800ece:	0f 84 99 00 00 00    	je     800f6d <fork+0x12a>
	// r = envid2env(envid, &env, 1);
	// if (r < 0)
	// 	return r;	// E_BAD_ENV
	// envid_t parent_envid = env->env_parent_id;

	if (uvpt[pn] & PTE_SHARE) {
  800ed4:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800edb:	f6 c4 04             	test   $0x4,%ah
  800ede:	74 17                	je     800ef7 <fork+0xb4>
		sys_page_map(0, (void *)va, envid, (void *)va, PTE_SYSCALL);
  800ee0:	83 ec 0c             	sub    $0xc,%esp
  800ee3:	68 07 0e 00 00       	push   $0xe07
  800ee8:	53                   	push   %ebx
  800ee9:	57                   	push   %edi
  800eea:	53                   	push   %ebx
  800eeb:	6a 00                	push   $0x0
  800eed:	e8 ca fc ff ff       	call   800bbc <sys_page_map>
  800ef2:	83 c4 20             	add    $0x20,%esp
  800ef5:	eb 76                	jmp    800f6d <fork+0x12a>
	}
	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {
  800ef7:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800efe:	a8 02                	test   $0x2,%al
  800f00:	75 0c                	jne    800f0e <fork+0xcb>
  800f02:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800f09:	f6 c4 08             	test   $0x8,%ah
  800f0c:	74 3f                	je     800f4d <fork+0x10a>

		// map the page copy-on-write into the address space of the child
        r = sys_page_map(0, (void *)va, envid, (void *)va, PTE_P|PTE_U|PTE_COW);
  800f0e:	83 ec 0c             	sub    $0xc,%esp
  800f11:	68 05 08 00 00       	push   $0x805
  800f16:	53                   	push   %ebx
  800f17:	57                   	push   %edi
  800f18:	53                   	push   %ebx
  800f19:	6a 00                	push   $0x0
  800f1b:	e8 9c fc ff ff       	call   800bbc <sys_page_map>
		if (r < 0)
  800f20:	83 c4 20             	add    $0x20,%esp
  800f23:	85 c0                	test   %eax,%eax
  800f25:	0f 88 a5 00 00 00    	js     800fd0 <fork+0x18d>
            return r;

		// remap the page copy-on-write in its own(parent) address space
        r = sys_page_map(0, (void *)va, 0, (void *)va, PTE_P|PTE_U|PTE_COW);
  800f2b:	83 ec 0c             	sub    $0xc,%esp
  800f2e:	68 05 08 00 00       	push   $0x805
  800f33:	53                   	push   %ebx
  800f34:	6a 00                	push   $0x0
  800f36:	53                   	push   %ebx
  800f37:	6a 00                	push   $0x0
  800f39:	e8 7e fc ff ff       	call   800bbc <sys_page_map>
  800f3e:	83 c4 20             	add    $0x20,%esp
  800f41:	85 c0                	test   %eax,%eax
  800f43:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f48:	0f 4f c1             	cmovg  %ecx,%eax
  800f4b:	eb 1c                	jmp    800f69 <fork+0x126>
		if (r < 0)
            return r;
    }
    else {
        r = sys_page_map(0, (void *)va, envid, (void *)va, PTE_P|PTE_U);
  800f4d:	83 ec 0c             	sub    $0xc,%esp
  800f50:	6a 05                	push   $0x5
  800f52:	53                   	push   %ebx
  800f53:	57                   	push   %edi
  800f54:	53                   	push   %ebx
  800f55:	6a 00                	push   $0x0
  800f57:	e8 60 fc ff ff       	call   800bbc <sys_page_map>
  800f5c:	83 c4 20             	add    $0x20,%esp
  800f5f:	85 c0                	test   %eax,%eax
  800f61:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f66:	0f 4f c1             	cmovg  %ecx,%eax

				// For each writable or copy-on-write page
				// if ((uvpt[PGNUM(addr)] & (PTE_W | PTE_COW)) != 0) {
				if ((uvpt[PGNUM(addr)] & PTE_U) != 0) {
					r = duppage(envid, pn);
					if (r < 0)
  800f69:	85 c0                	test   %eax,%eax
  800f6b:	78 67                	js     800fd4 <fork+0x191>
        return 0;
	}

	// For each writable or copy-on-write page in its address space below UTOP, the parent calls duppage
	uint32_t addr;
	for (uint32_t pn = PGNUM(UTEXT); pn < PGNUM(USTACKTOP); pn++) {
  800f6d:	83 c6 01             	add    $0x1,%esi
  800f70:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  800f76:	81 fe fe eb 0e 00    	cmp    $0xeebfe,%esi
  800f7c:	0f 85 1a ff ff ff    	jne    800e9c <fork+0x59>
  800f82:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
		}
	}

	// allocate a fresh page in the child for the exception stack
	r = sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U | PTE_P | PTE_W);
  800f85:	83 ec 04             	sub    $0x4,%esp
  800f88:	6a 07                	push   $0x7
  800f8a:	68 00 f0 bf ee       	push   $0xeebff000
  800f8f:	57                   	push   %edi
  800f90:	e8 e4 fb ff ff       	call   800b79 <sys_page_alloc>
	if (r < 0)
  800f95:	83 c4 10             	add    $0x10,%esp
		return r;
  800f98:	89 c2                	mov    %eax,%edx
		}
	}

	// allocate a fresh page in the child for the exception stack
	r = sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U | PTE_P | PTE_W);
	if (r < 0)
  800f9a:	85 c0                	test   %eax,%eax
  800f9c:	78 38                	js     800fd6 <fork+0x193>
		return r;

	// The parent sets the user page fault entrypoint for the child to look like its own
	extern void _pgfault_upcall(void);
	r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  800f9e:	83 ec 08             	sub    $0x8,%esp
  800fa1:	68 58 1e 80 00       	push   $0x801e58
  800fa6:	57                   	push   %edi
  800fa7:	e8 18 fd ff ff       	call   800cc4 <sys_env_set_pgfault_upcall>
	if (r < 0)
  800fac:	83 c4 10             	add    $0x10,%esp
		return r;
  800faf:	89 c2                	mov    %eax,%edx
		return r;

	// The parent sets the user page fault entrypoint for the child to look like its own
	extern void _pgfault_upcall(void);
	r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
	if (r < 0)
  800fb1:	85 c0                	test   %eax,%eax
  800fb3:	78 21                	js     800fd6 <fork+0x193>
		return r;

	// The child is now ready to run, so the parent marks it runnable
	r = sys_env_set_status(envid, ENV_RUNNABLE);
  800fb5:	83 ec 08             	sub    $0x8,%esp
  800fb8:	6a 02                	push   $0x2
  800fba:	57                   	push   %edi
  800fbb:	e8 80 fc ff ff       	call   800c40 <sys_env_set_status>
	if (r < 0)
  800fc0:	83 c4 10             	add    $0x10,%esp
		return r;

	return envid;
  800fc3:	85 c0                	test   %eax,%eax
  800fc5:	0f 48 f8             	cmovs  %eax,%edi
  800fc8:	89 fa                	mov    %edi,%edx
  800fca:	eb 0a                	jmp    800fd6 <fork+0x193>

	set_pgfault_handler(pgfault);

	envid_t envid = sys_exofork();
	if (envid < 0)
		return envid;
  800fcc:	89 c2                	mov    %eax,%edx
  800fce:	eb 06                	jmp    800fd6 <fork+0x193>
		sys_page_map(0, (void *)va, envid, (void *)va, PTE_SYSCALL);
	}
	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {

		// map the page copy-on-write into the address space of the child
        r = sys_page_map(0, (void *)va, envid, (void *)va, PTE_P|PTE_U|PTE_COW);
  800fd0:	89 c2                	mov    %eax,%edx
  800fd2:	eb 02                	jmp    800fd6 <fork+0x193>
  800fd4:	89 c2                	mov    %eax,%edx
	if (r < 0)
		return r;

	return envid;
	// panic("fork not implemented");
}
  800fd6:	89 d0                	mov    %edx,%eax
  800fd8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fdb:	5b                   	pop    %ebx
  800fdc:	5e                   	pop    %esi
  800fdd:	5f                   	pop    %edi
  800fde:	5d                   	pop    %ebp
  800fdf:	c3                   	ret    

00800fe0 <sfork>:

// Challenge!
int
sfork(void)
{
  800fe0:	55                   	push   %ebp
  800fe1:	89 e5                	mov    %esp,%ebp
  800fe3:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  800fe6:	68 8b 25 80 00       	push   $0x80258b
  800feb:	68 ca 00 00 00       	push   $0xca
  800ff0:	68 80 25 80 00       	push   $0x802580
  800ff5:	e8 d1 0d 00 00       	call   801dcb <_panic>

00800ffa <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  800ffa:	55                   	push   %ebp
  800ffb:	89 e5                	mov    %esp,%ebp
  800ffd:	56                   	push   %esi
  800ffe:	53                   	push   %ebx
  800fff:	8b 75 08             	mov    0x8(%ebp),%esi
  801002:	8b 45 0c             	mov    0xc(%ebp),%eax
  801005:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");

	// don't want to recv page
	if (pg == NULL)
  801008:	85 c0                	test   %eax,%eax
		pg = (void *)UTOP;
  80100a:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  80100f:	0f 44 c2             	cmove  %edx,%eax

	int err = sys_ipc_recv(pg);
  801012:	83 ec 0c             	sub    $0xc,%esp
  801015:	50                   	push   %eax
  801016:	e8 0e fd ff ff       	call   800d29 <sys_ipc_recv>

	if (from_env_store != NULL)
  80101b:	83 c4 10             	add    $0x10,%esp
  80101e:	85 f6                	test   %esi,%esi
  801020:	74 14                	je     801036 <ipc_recv+0x3c>
		*from_env_store = err < 0? 0 : thisenv->env_ipc_from;
  801022:	ba 00 00 00 00       	mov    $0x0,%edx
  801027:	85 c0                	test   %eax,%eax
  801029:	78 09                	js     801034 <ipc_recv+0x3a>
  80102b:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801031:	8b 52 74             	mov    0x74(%edx),%edx
  801034:	89 16                	mov    %edx,(%esi)
	
	if (perm_store != NULL)
  801036:	85 db                	test   %ebx,%ebx
  801038:	74 14                	je     80104e <ipc_recv+0x54>
		*perm_store = err < 0? 0 : thisenv->env_ipc_perm;
  80103a:	ba 00 00 00 00       	mov    $0x0,%edx
  80103f:	85 c0                	test   %eax,%eax
  801041:	78 09                	js     80104c <ipc_recv+0x52>
  801043:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801049:	8b 52 78             	mov    0x78(%edx),%edx
  80104c:	89 13                	mov    %edx,(%ebx)

	if (err < 0)
  80104e:	85 c0                	test   %eax,%eax
  801050:	78 08                	js     80105a <ipc_recv+0x60>
		return err;
	return thisenv->env_ipc_value;
  801052:	a1 08 40 80 00       	mov    0x804008,%eax
  801057:	8b 40 70             	mov    0x70(%eax),%eax
}
  80105a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80105d:	5b                   	pop    %ebx
  80105e:	5e                   	pop    %esi
  80105f:	5d                   	pop    %ebp
  801060:	c3                   	ret    

00801061 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801061:	55                   	push   %ebp
  801062:	89 e5                	mov    %esp,%ebp
  801064:	57                   	push   %edi
  801065:	56                   	push   %esi
  801066:	53                   	push   %ebx
  801067:	83 ec 0c             	sub    $0xc,%esp
  80106a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80106d:	8b 75 0c             	mov    0xc(%ebp),%esi
  801070:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");

	// don't want to send page
	if (pg == NULL)
  801073:	85 db                	test   %ebx,%ebx
		pg = (void *)UTOP;
  801075:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  80107a:	0f 44 d8             	cmove  %eax,%ebx
	
	int err = 0;
	
	do {

		err = sys_ipc_try_send(to_env, val, pg, perm);
  80107d:	ff 75 14             	pushl  0x14(%ebp)
  801080:	53                   	push   %ebx
  801081:	56                   	push   %esi
  801082:	57                   	push   %edi
  801083:	e8 7e fc ff ff       	call   800d06 <sys_ipc_try_send>

		if (err < 0) {
  801088:	83 c4 10             	add    $0x10,%esp
  80108b:	85 c0                	test   %eax,%eax
  80108d:	79 1e                	jns    8010ad <ipc_send+0x4c>
			if (err == -E_IPC_NOT_RECV)
  80108f:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801092:	75 07                	jne    80109b <ipc_send+0x3a>
				sys_yield();
  801094:	e8 c1 fa ff ff       	call   800b5a <sys_yield>
  801099:	eb e2                	jmp    80107d <ipc_send+0x1c>
			else 
				panic("ipc_send: %e", err);
  80109b:	50                   	push   %eax
  80109c:	68 a1 25 80 00       	push   $0x8025a1
  8010a1:	6a 49                	push   $0x49
  8010a3:	68 ae 25 80 00       	push   $0x8025ae
  8010a8:	e8 1e 0d 00 00       	call   801dcb <_panic>
		}

	} while (err < 0);

}
  8010ad:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010b0:	5b                   	pop    %ebx
  8010b1:	5e                   	pop    %esi
  8010b2:	5f                   	pop    %edi
  8010b3:	5d                   	pop    %ebp
  8010b4:	c3                   	ret    

008010b5 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8010b5:	55                   	push   %ebp
  8010b6:	89 e5                	mov    %esp,%ebp
  8010b8:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8010bb:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8010c0:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8010c3:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8010c9:	8b 52 50             	mov    0x50(%edx),%edx
  8010cc:	39 ca                	cmp    %ecx,%edx
  8010ce:	75 0d                	jne    8010dd <ipc_find_env+0x28>
			return envs[i].env_id;
  8010d0:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8010d3:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8010d8:	8b 40 48             	mov    0x48(%eax),%eax
  8010db:	eb 0f                	jmp    8010ec <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8010dd:	83 c0 01             	add    $0x1,%eax
  8010e0:	3d 00 04 00 00       	cmp    $0x400,%eax
  8010e5:	75 d9                	jne    8010c0 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8010e7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8010ec:	5d                   	pop    %ebp
  8010ed:	c3                   	ret    

008010ee <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8010ee:	55                   	push   %ebp
  8010ef:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8010f1:	8b 45 08             	mov    0x8(%ebp),%eax
  8010f4:	05 00 00 00 30       	add    $0x30000000,%eax
  8010f9:	c1 e8 0c             	shr    $0xc,%eax
}
  8010fc:	5d                   	pop    %ebp
  8010fd:	c3                   	ret    

008010fe <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8010fe:	55                   	push   %ebp
  8010ff:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801101:	8b 45 08             	mov    0x8(%ebp),%eax
  801104:	05 00 00 00 30       	add    $0x30000000,%eax
  801109:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80110e:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801113:	5d                   	pop    %ebp
  801114:	c3                   	ret    

00801115 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801115:	55                   	push   %ebp
  801116:	89 e5                	mov    %esp,%ebp
  801118:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80111b:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801120:	89 c2                	mov    %eax,%edx
  801122:	c1 ea 16             	shr    $0x16,%edx
  801125:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80112c:	f6 c2 01             	test   $0x1,%dl
  80112f:	74 11                	je     801142 <fd_alloc+0x2d>
  801131:	89 c2                	mov    %eax,%edx
  801133:	c1 ea 0c             	shr    $0xc,%edx
  801136:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80113d:	f6 c2 01             	test   $0x1,%dl
  801140:	75 09                	jne    80114b <fd_alloc+0x36>
			*fd_store = fd;
  801142:	89 01                	mov    %eax,(%ecx)
			return 0;
  801144:	b8 00 00 00 00       	mov    $0x0,%eax
  801149:	eb 17                	jmp    801162 <fd_alloc+0x4d>
  80114b:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801150:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801155:	75 c9                	jne    801120 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801157:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  80115d:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801162:	5d                   	pop    %ebp
  801163:	c3                   	ret    

00801164 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801164:	55                   	push   %ebp
  801165:	89 e5                	mov    %esp,%ebp
  801167:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80116a:	83 f8 1f             	cmp    $0x1f,%eax
  80116d:	77 36                	ja     8011a5 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80116f:	c1 e0 0c             	shl    $0xc,%eax
  801172:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801177:	89 c2                	mov    %eax,%edx
  801179:	c1 ea 16             	shr    $0x16,%edx
  80117c:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801183:	f6 c2 01             	test   $0x1,%dl
  801186:	74 24                	je     8011ac <fd_lookup+0x48>
  801188:	89 c2                	mov    %eax,%edx
  80118a:	c1 ea 0c             	shr    $0xc,%edx
  80118d:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801194:	f6 c2 01             	test   $0x1,%dl
  801197:	74 1a                	je     8011b3 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801199:	8b 55 0c             	mov    0xc(%ebp),%edx
  80119c:	89 02                	mov    %eax,(%edx)
	return 0;
  80119e:	b8 00 00 00 00       	mov    $0x0,%eax
  8011a3:	eb 13                	jmp    8011b8 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8011a5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011aa:	eb 0c                	jmp    8011b8 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8011ac:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011b1:	eb 05                	jmp    8011b8 <fd_lookup+0x54>
  8011b3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8011b8:	5d                   	pop    %ebp
  8011b9:	c3                   	ret    

008011ba <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8011ba:	55                   	push   %ebp
  8011bb:	89 e5                	mov    %esp,%ebp
  8011bd:	83 ec 08             	sub    $0x8,%esp
  8011c0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011c3:	ba 34 26 80 00       	mov    $0x802634,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8011c8:	eb 13                	jmp    8011dd <dev_lookup+0x23>
  8011ca:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8011cd:	39 08                	cmp    %ecx,(%eax)
  8011cf:	75 0c                	jne    8011dd <dev_lookup+0x23>
			*dev = devtab[i];
  8011d1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011d4:	89 01                	mov    %eax,(%ecx)
			return 0;
  8011d6:	b8 00 00 00 00       	mov    $0x0,%eax
  8011db:	eb 2e                	jmp    80120b <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8011dd:	8b 02                	mov    (%edx),%eax
  8011df:	85 c0                	test   %eax,%eax
  8011e1:	75 e7                	jne    8011ca <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8011e3:	a1 08 40 80 00       	mov    0x804008,%eax
  8011e8:	8b 40 48             	mov    0x48(%eax),%eax
  8011eb:	83 ec 04             	sub    $0x4,%esp
  8011ee:	51                   	push   %ecx
  8011ef:	50                   	push   %eax
  8011f0:	68 b8 25 80 00       	push   $0x8025b8
  8011f5:	e8 f7 ef ff ff       	call   8001f1 <cprintf>
	*dev = 0;
  8011fa:	8b 45 0c             	mov    0xc(%ebp),%eax
  8011fd:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801203:	83 c4 10             	add    $0x10,%esp
  801206:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80120b:	c9                   	leave  
  80120c:	c3                   	ret    

0080120d <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80120d:	55                   	push   %ebp
  80120e:	89 e5                	mov    %esp,%ebp
  801210:	56                   	push   %esi
  801211:	53                   	push   %ebx
  801212:	83 ec 10             	sub    $0x10,%esp
  801215:	8b 75 08             	mov    0x8(%ebp),%esi
  801218:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80121b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80121e:	50                   	push   %eax
  80121f:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801225:	c1 e8 0c             	shr    $0xc,%eax
  801228:	50                   	push   %eax
  801229:	e8 36 ff ff ff       	call   801164 <fd_lookup>
  80122e:	83 c4 08             	add    $0x8,%esp
  801231:	85 c0                	test   %eax,%eax
  801233:	78 05                	js     80123a <fd_close+0x2d>
	    || fd != fd2)
  801235:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801238:	74 0c                	je     801246 <fd_close+0x39>
		return (must_exist ? r : 0);
  80123a:	84 db                	test   %bl,%bl
  80123c:	ba 00 00 00 00       	mov    $0x0,%edx
  801241:	0f 44 c2             	cmove  %edx,%eax
  801244:	eb 41                	jmp    801287 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801246:	83 ec 08             	sub    $0x8,%esp
  801249:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80124c:	50                   	push   %eax
  80124d:	ff 36                	pushl  (%esi)
  80124f:	e8 66 ff ff ff       	call   8011ba <dev_lookup>
  801254:	89 c3                	mov    %eax,%ebx
  801256:	83 c4 10             	add    $0x10,%esp
  801259:	85 c0                	test   %eax,%eax
  80125b:	78 1a                	js     801277 <fd_close+0x6a>
		if (dev->dev_close)
  80125d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801260:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801263:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801268:	85 c0                	test   %eax,%eax
  80126a:	74 0b                	je     801277 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80126c:	83 ec 0c             	sub    $0xc,%esp
  80126f:	56                   	push   %esi
  801270:	ff d0                	call   *%eax
  801272:	89 c3                	mov    %eax,%ebx
  801274:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801277:	83 ec 08             	sub    $0x8,%esp
  80127a:	56                   	push   %esi
  80127b:	6a 00                	push   $0x0
  80127d:	e8 7c f9 ff ff       	call   800bfe <sys_page_unmap>
	return r;
  801282:	83 c4 10             	add    $0x10,%esp
  801285:	89 d8                	mov    %ebx,%eax
}
  801287:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80128a:	5b                   	pop    %ebx
  80128b:	5e                   	pop    %esi
  80128c:	5d                   	pop    %ebp
  80128d:	c3                   	ret    

0080128e <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80128e:	55                   	push   %ebp
  80128f:	89 e5                	mov    %esp,%ebp
  801291:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801294:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801297:	50                   	push   %eax
  801298:	ff 75 08             	pushl  0x8(%ebp)
  80129b:	e8 c4 fe ff ff       	call   801164 <fd_lookup>
  8012a0:	83 c4 08             	add    $0x8,%esp
  8012a3:	85 c0                	test   %eax,%eax
  8012a5:	78 10                	js     8012b7 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8012a7:	83 ec 08             	sub    $0x8,%esp
  8012aa:	6a 01                	push   $0x1
  8012ac:	ff 75 f4             	pushl  -0xc(%ebp)
  8012af:	e8 59 ff ff ff       	call   80120d <fd_close>
  8012b4:	83 c4 10             	add    $0x10,%esp
}
  8012b7:	c9                   	leave  
  8012b8:	c3                   	ret    

008012b9 <close_all>:

void
close_all(void)
{
  8012b9:	55                   	push   %ebp
  8012ba:	89 e5                	mov    %esp,%ebp
  8012bc:	53                   	push   %ebx
  8012bd:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8012c0:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8012c5:	83 ec 0c             	sub    $0xc,%esp
  8012c8:	53                   	push   %ebx
  8012c9:	e8 c0 ff ff ff       	call   80128e <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8012ce:	83 c3 01             	add    $0x1,%ebx
  8012d1:	83 c4 10             	add    $0x10,%esp
  8012d4:	83 fb 20             	cmp    $0x20,%ebx
  8012d7:	75 ec                	jne    8012c5 <close_all+0xc>
		close(i);
}
  8012d9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012dc:	c9                   	leave  
  8012dd:	c3                   	ret    

008012de <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8012de:	55                   	push   %ebp
  8012df:	89 e5                	mov    %esp,%ebp
  8012e1:	57                   	push   %edi
  8012e2:	56                   	push   %esi
  8012e3:	53                   	push   %ebx
  8012e4:	83 ec 2c             	sub    $0x2c,%esp
  8012e7:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8012ea:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8012ed:	50                   	push   %eax
  8012ee:	ff 75 08             	pushl  0x8(%ebp)
  8012f1:	e8 6e fe ff ff       	call   801164 <fd_lookup>
  8012f6:	83 c4 08             	add    $0x8,%esp
  8012f9:	85 c0                	test   %eax,%eax
  8012fb:	0f 88 c1 00 00 00    	js     8013c2 <dup+0xe4>
		return r;
	close(newfdnum);
  801301:	83 ec 0c             	sub    $0xc,%esp
  801304:	56                   	push   %esi
  801305:	e8 84 ff ff ff       	call   80128e <close>

	newfd = INDEX2FD(newfdnum);
  80130a:	89 f3                	mov    %esi,%ebx
  80130c:	c1 e3 0c             	shl    $0xc,%ebx
  80130f:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801315:	83 c4 04             	add    $0x4,%esp
  801318:	ff 75 e4             	pushl  -0x1c(%ebp)
  80131b:	e8 de fd ff ff       	call   8010fe <fd2data>
  801320:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801322:	89 1c 24             	mov    %ebx,(%esp)
  801325:	e8 d4 fd ff ff       	call   8010fe <fd2data>
  80132a:	83 c4 10             	add    $0x10,%esp
  80132d:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801330:	89 f8                	mov    %edi,%eax
  801332:	c1 e8 16             	shr    $0x16,%eax
  801335:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80133c:	a8 01                	test   $0x1,%al
  80133e:	74 37                	je     801377 <dup+0x99>
  801340:	89 f8                	mov    %edi,%eax
  801342:	c1 e8 0c             	shr    $0xc,%eax
  801345:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80134c:	f6 c2 01             	test   $0x1,%dl
  80134f:	74 26                	je     801377 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801351:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801358:	83 ec 0c             	sub    $0xc,%esp
  80135b:	25 07 0e 00 00       	and    $0xe07,%eax
  801360:	50                   	push   %eax
  801361:	ff 75 d4             	pushl  -0x2c(%ebp)
  801364:	6a 00                	push   $0x0
  801366:	57                   	push   %edi
  801367:	6a 00                	push   $0x0
  801369:	e8 4e f8 ff ff       	call   800bbc <sys_page_map>
  80136e:	89 c7                	mov    %eax,%edi
  801370:	83 c4 20             	add    $0x20,%esp
  801373:	85 c0                	test   %eax,%eax
  801375:	78 2e                	js     8013a5 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801377:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80137a:	89 d0                	mov    %edx,%eax
  80137c:	c1 e8 0c             	shr    $0xc,%eax
  80137f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801386:	83 ec 0c             	sub    $0xc,%esp
  801389:	25 07 0e 00 00       	and    $0xe07,%eax
  80138e:	50                   	push   %eax
  80138f:	53                   	push   %ebx
  801390:	6a 00                	push   $0x0
  801392:	52                   	push   %edx
  801393:	6a 00                	push   $0x0
  801395:	e8 22 f8 ff ff       	call   800bbc <sys_page_map>
  80139a:	89 c7                	mov    %eax,%edi
  80139c:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80139f:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8013a1:	85 ff                	test   %edi,%edi
  8013a3:	79 1d                	jns    8013c2 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8013a5:	83 ec 08             	sub    $0x8,%esp
  8013a8:	53                   	push   %ebx
  8013a9:	6a 00                	push   $0x0
  8013ab:	e8 4e f8 ff ff       	call   800bfe <sys_page_unmap>
	sys_page_unmap(0, nva);
  8013b0:	83 c4 08             	add    $0x8,%esp
  8013b3:	ff 75 d4             	pushl  -0x2c(%ebp)
  8013b6:	6a 00                	push   $0x0
  8013b8:	e8 41 f8 ff ff       	call   800bfe <sys_page_unmap>
	return r;
  8013bd:	83 c4 10             	add    $0x10,%esp
  8013c0:	89 f8                	mov    %edi,%eax
}
  8013c2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013c5:	5b                   	pop    %ebx
  8013c6:	5e                   	pop    %esi
  8013c7:	5f                   	pop    %edi
  8013c8:	5d                   	pop    %ebp
  8013c9:	c3                   	ret    

008013ca <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8013ca:	55                   	push   %ebp
  8013cb:	89 e5                	mov    %esp,%ebp
  8013cd:	53                   	push   %ebx
  8013ce:	83 ec 14             	sub    $0x14,%esp
  8013d1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013d4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013d7:	50                   	push   %eax
  8013d8:	53                   	push   %ebx
  8013d9:	e8 86 fd ff ff       	call   801164 <fd_lookup>
  8013de:	83 c4 08             	add    $0x8,%esp
  8013e1:	89 c2                	mov    %eax,%edx
  8013e3:	85 c0                	test   %eax,%eax
  8013e5:	78 6d                	js     801454 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013e7:	83 ec 08             	sub    $0x8,%esp
  8013ea:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013ed:	50                   	push   %eax
  8013ee:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013f1:	ff 30                	pushl  (%eax)
  8013f3:	e8 c2 fd ff ff       	call   8011ba <dev_lookup>
  8013f8:	83 c4 10             	add    $0x10,%esp
  8013fb:	85 c0                	test   %eax,%eax
  8013fd:	78 4c                	js     80144b <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8013ff:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801402:	8b 42 08             	mov    0x8(%edx),%eax
  801405:	83 e0 03             	and    $0x3,%eax
  801408:	83 f8 01             	cmp    $0x1,%eax
  80140b:	75 21                	jne    80142e <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80140d:	a1 08 40 80 00       	mov    0x804008,%eax
  801412:	8b 40 48             	mov    0x48(%eax),%eax
  801415:	83 ec 04             	sub    $0x4,%esp
  801418:	53                   	push   %ebx
  801419:	50                   	push   %eax
  80141a:	68 f9 25 80 00       	push   $0x8025f9
  80141f:	e8 cd ed ff ff       	call   8001f1 <cprintf>
		return -E_INVAL;
  801424:	83 c4 10             	add    $0x10,%esp
  801427:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80142c:	eb 26                	jmp    801454 <read+0x8a>
	}
	if (!dev->dev_read)
  80142e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801431:	8b 40 08             	mov    0x8(%eax),%eax
  801434:	85 c0                	test   %eax,%eax
  801436:	74 17                	je     80144f <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801438:	83 ec 04             	sub    $0x4,%esp
  80143b:	ff 75 10             	pushl  0x10(%ebp)
  80143e:	ff 75 0c             	pushl  0xc(%ebp)
  801441:	52                   	push   %edx
  801442:	ff d0                	call   *%eax
  801444:	89 c2                	mov    %eax,%edx
  801446:	83 c4 10             	add    $0x10,%esp
  801449:	eb 09                	jmp    801454 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80144b:	89 c2                	mov    %eax,%edx
  80144d:	eb 05                	jmp    801454 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80144f:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801454:	89 d0                	mov    %edx,%eax
  801456:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801459:	c9                   	leave  
  80145a:	c3                   	ret    

0080145b <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80145b:	55                   	push   %ebp
  80145c:	89 e5                	mov    %esp,%ebp
  80145e:	57                   	push   %edi
  80145f:	56                   	push   %esi
  801460:	53                   	push   %ebx
  801461:	83 ec 0c             	sub    $0xc,%esp
  801464:	8b 7d 08             	mov    0x8(%ebp),%edi
  801467:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80146a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80146f:	eb 21                	jmp    801492 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801471:	83 ec 04             	sub    $0x4,%esp
  801474:	89 f0                	mov    %esi,%eax
  801476:	29 d8                	sub    %ebx,%eax
  801478:	50                   	push   %eax
  801479:	89 d8                	mov    %ebx,%eax
  80147b:	03 45 0c             	add    0xc(%ebp),%eax
  80147e:	50                   	push   %eax
  80147f:	57                   	push   %edi
  801480:	e8 45 ff ff ff       	call   8013ca <read>
		if (m < 0)
  801485:	83 c4 10             	add    $0x10,%esp
  801488:	85 c0                	test   %eax,%eax
  80148a:	78 10                	js     80149c <readn+0x41>
			return m;
		if (m == 0)
  80148c:	85 c0                	test   %eax,%eax
  80148e:	74 0a                	je     80149a <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801490:	01 c3                	add    %eax,%ebx
  801492:	39 f3                	cmp    %esi,%ebx
  801494:	72 db                	jb     801471 <readn+0x16>
  801496:	89 d8                	mov    %ebx,%eax
  801498:	eb 02                	jmp    80149c <readn+0x41>
  80149a:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80149c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80149f:	5b                   	pop    %ebx
  8014a0:	5e                   	pop    %esi
  8014a1:	5f                   	pop    %edi
  8014a2:	5d                   	pop    %ebp
  8014a3:	c3                   	ret    

008014a4 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8014a4:	55                   	push   %ebp
  8014a5:	89 e5                	mov    %esp,%ebp
  8014a7:	53                   	push   %ebx
  8014a8:	83 ec 14             	sub    $0x14,%esp
  8014ab:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014ae:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014b1:	50                   	push   %eax
  8014b2:	53                   	push   %ebx
  8014b3:	e8 ac fc ff ff       	call   801164 <fd_lookup>
  8014b8:	83 c4 08             	add    $0x8,%esp
  8014bb:	89 c2                	mov    %eax,%edx
  8014bd:	85 c0                	test   %eax,%eax
  8014bf:	78 68                	js     801529 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014c1:	83 ec 08             	sub    $0x8,%esp
  8014c4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014c7:	50                   	push   %eax
  8014c8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014cb:	ff 30                	pushl  (%eax)
  8014cd:	e8 e8 fc ff ff       	call   8011ba <dev_lookup>
  8014d2:	83 c4 10             	add    $0x10,%esp
  8014d5:	85 c0                	test   %eax,%eax
  8014d7:	78 47                	js     801520 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8014d9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014dc:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8014e0:	75 21                	jne    801503 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8014e2:	a1 08 40 80 00       	mov    0x804008,%eax
  8014e7:	8b 40 48             	mov    0x48(%eax),%eax
  8014ea:	83 ec 04             	sub    $0x4,%esp
  8014ed:	53                   	push   %ebx
  8014ee:	50                   	push   %eax
  8014ef:	68 15 26 80 00       	push   $0x802615
  8014f4:	e8 f8 ec ff ff       	call   8001f1 <cprintf>
		return -E_INVAL;
  8014f9:	83 c4 10             	add    $0x10,%esp
  8014fc:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801501:	eb 26                	jmp    801529 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801503:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801506:	8b 52 0c             	mov    0xc(%edx),%edx
  801509:	85 d2                	test   %edx,%edx
  80150b:	74 17                	je     801524 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80150d:	83 ec 04             	sub    $0x4,%esp
  801510:	ff 75 10             	pushl  0x10(%ebp)
  801513:	ff 75 0c             	pushl  0xc(%ebp)
  801516:	50                   	push   %eax
  801517:	ff d2                	call   *%edx
  801519:	89 c2                	mov    %eax,%edx
  80151b:	83 c4 10             	add    $0x10,%esp
  80151e:	eb 09                	jmp    801529 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801520:	89 c2                	mov    %eax,%edx
  801522:	eb 05                	jmp    801529 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801524:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801529:	89 d0                	mov    %edx,%eax
  80152b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80152e:	c9                   	leave  
  80152f:	c3                   	ret    

00801530 <seek>:

int
seek(int fdnum, off_t offset)
{
  801530:	55                   	push   %ebp
  801531:	89 e5                	mov    %esp,%ebp
  801533:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801536:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801539:	50                   	push   %eax
  80153a:	ff 75 08             	pushl  0x8(%ebp)
  80153d:	e8 22 fc ff ff       	call   801164 <fd_lookup>
  801542:	83 c4 08             	add    $0x8,%esp
  801545:	85 c0                	test   %eax,%eax
  801547:	78 0e                	js     801557 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801549:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80154c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80154f:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801552:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801557:	c9                   	leave  
  801558:	c3                   	ret    

00801559 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801559:	55                   	push   %ebp
  80155a:	89 e5                	mov    %esp,%ebp
  80155c:	53                   	push   %ebx
  80155d:	83 ec 14             	sub    $0x14,%esp
  801560:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801563:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801566:	50                   	push   %eax
  801567:	53                   	push   %ebx
  801568:	e8 f7 fb ff ff       	call   801164 <fd_lookup>
  80156d:	83 c4 08             	add    $0x8,%esp
  801570:	89 c2                	mov    %eax,%edx
  801572:	85 c0                	test   %eax,%eax
  801574:	78 65                	js     8015db <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801576:	83 ec 08             	sub    $0x8,%esp
  801579:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80157c:	50                   	push   %eax
  80157d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801580:	ff 30                	pushl  (%eax)
  801582:	e8 33 fc ff ff       	call   8011ba <dev_lookup>
  801587:	83 c4 10             	add    $0x10,%esp
  80158a:	85 c0                	test   %eax,%eax
  80158c:	78 44                	js     8015d2 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80158e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801591:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801595:	75 21                	jne    8015b8 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801597:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80159c:	8b 40 48             	mov    0x48(%eax),%eax
  80159f:	83 ec 04             	sub    $0x4,%esp
  8015a2:	53                   	push   %ebx
  8015a3:	50                   	push   %eax
  8015a4:	68 d8 25 80 00       	push   $0x8025d8
  8015a9:	e8 43 ec ff ff       	call   8001f1 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8015ae:	83 c4 10             	add    $0x10,%esp
  8015b1:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8015b6:	eb 23                	jmp    8015db <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8015b8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015bb:	8b 52 18             	mov    0x18(%edx),%edx
  8015be:	85 d2                	test   %edx,%edx
  8015c0:	74 14                	je     8015d6 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8015c2:	83 ec 08             	sub    $0x8,%esp
  8015c5:	ff 75 0c             	pushl  0xc(%ebp)
  8015c8:	50                   	push   %eax
  8015c9:	ff d2                	call   *%edx
  8015cb:	89 c2                	mov    %eax,%edx
  8015cd:	83 c4 10             	add    $0x10,%esp
  8015d0:	eb 09                	jmp    8015db <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015d2:	89 c2                	mov    %eax,%edx
  8015d4:	eb 05                	jmp    8015db <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8015d6:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8015db:	89 d0                	mov    %edx,%eax
  8015dd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015e0:	c9                   	leave  
  8015e1:	c3                   	ret    

008015e2 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8015e2:	55                   	push   %ebp
  8015e3:	89 e5                	mov    %esp,%ebp
  8015e5:	53                   	push   %ebx
  8015e6:	83 ec 14             	sub    $0x14,%esp
  8015e9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015ec:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015ef:	50                   	push   %eax
  8015f0:	ff 75 08             	pushl  0x8(%ebp)
  8015f3:	e8 6c fb ff ff       	call   801164 <fd_lookup>
  8015f8:	83 c4 08             	add    $0x8,%esp
  8015fb:	89 c2                	mov    %eax,%edx
  8015fd:	85 c0                	test   %eax,%eax
  8015ff:	78 58                	js     801659 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801601:	83 ec 08             	sub    $0x8,%esp
  801604:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801607:	50                   	push   %eax
  801608:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80160b:	ff 30                	pushl  (%eax)
  80160d:	e8 a8 fb ff ff       	call   8011ba <dev_lookup>
  801612:	83 c4 10             	add    $0x10,%esp
  801615:	85 c0                	test   %eax,%eax
  801617:	78 37                	js     801650 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801619:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80161c:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801620:	74 32                	je     801654 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801622:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801625:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80162c:	00 00 00 
	stat->st_isdir = 0;
  80162f:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801636:	00 00 00 
	stat->st_dev = dev;
  801639:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80163f:	83 ec 08             	sub    $0x8,%esp
  801642:	53                   	push   %ebx
  801643:	ff 75 f0             	pushl  -0x10(%ebp)
  801646:	ff 50 14             	call   *0x14(%eax)
  801649:	89 c2                	mov    %eax,%edx
  80164b:	83 c4 10             	add    $0x10,%esp
  80164e:	eb 09                	jmp    801659 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801650:	89 c2                	mov    %eax,%edx
  801652:	eb 05                	jmp    801659 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801654:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801659:	89 d0                	mov    %edx,%eax
  80165b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80165e:	c9                   	leave  
  80165f:	c3                   	ret    

00801660 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801660:	55                   	push   %ebp
  801661:	89 e5                	mov    %esp,%ebp
  801663:	56                   	push   %esi
  801664:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801665:	83 ec 08             	sub    $0x8,%esp
  801668:	6a 00                	push   $0x0
  80166a:	ff 75 08             	pushl  0x8(%ebp)
  80166d:	e8 d6 01 00 00       	call   801848 <open>
  801672:	89 c3                	mov    %eax,%ebx
  801674:	83 c4 10             	add    $0x10,%esp
  801677:	85 c0                	test   %eax,%eax
  801679:	78 1b                	js     801696 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80167b:	83 ec 08             	sub    $0x8,%esp
  80167e:	ff 75 0c             	pushl  0xc(%ebp)
  801681:	50                   	push   %eax
  801682:	e8 5b ff ff ff       	call   8015e2 <fstat>
  801687:	89 c6                	mov    %eax,%esi
	close(fd);
  801689:	89 1c 24             	mov    %ebx,(%esp)
  80168c:	e8 fd fb ff ff       	call   80128e <close>
	return r;
  801691:	83 c4 10             	add    $0x10,%esp
  801694:	89 f0                	mov    %esi,%eax
}
  801696:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801699:	5b                   	pop    %ebx
  80169a:	5e                   	pop    %esi
  80169b:	5d                   	pop    %ebp
  80169c:	c3                   	ret    

0080169d <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80169d:	55                   	push   %ebp
  80169e:	89 e5                	mov    %esp,%ebp
  8016a0:	56                   	push   %esi
  8016a1:	53                   	push   %ebx
  8016a2:	89 c6                	mov    %eax,%esi
  8016a4:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8016a6:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8016ad:	75 12                	jne    8016c1 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8016af:	83 ec 0c             	sub    $0xc,%esp
  8016b2:	6a 01                	push   $0x1
  8016b4:	e8 fc f9 ff ff       	call   8010b5 <ipc_find_env>
  8016b9:	a3 00 40 80 00       	mov    %eax,0x804000
  8016be:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8016c1:	6a 07                	push   $0x7
  8016c3:	68 00 50 80 00       	push   $0x805000
  8016c8:	56                   	push   %esi
  8016c9:	ff 35 00 40 80 00    	pushl  0x804000
  8016cf:	e8 8d f9 ff ff       	call   801061 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8016d4:	83 c4 0c             	add    $0xc,%esp
  8016d7:	6a 00                	push   $0x0
  8016d9:	53                   	push   %ebx
  8016da:	6a 00                	push   $0x0
  8016dc:	e8 19 f9 ff ff       	call   800ffa <ipc_recv>
}
  8016e1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016e4:	5b                   	pop    %ebx
  8016e5:	5e                   	pop    %esi
  8016e6:	5d                   	pop    %ebp
  8016e7:	c3                   	ret    

008016e8 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8016e8:	55                   	push   %ebp
  8016e9:	89 e5                	mov    %esp,%ebp
  8016eb:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8016ee:	8b 45 08             	mov    0x8(%ebp),%eax
  8016f1:	8b 40 0c             	mov    0xc(%eax),%eax
  8016f4:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8016f9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8016fc:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801701:	ba 00 00 00 00       	mov    $0x0,%edx
  801706:	b8 02 00 00 00       	mov    $0x2,%eax
  80170b:	e8 8d ff ff ff       	call   80169d <fsipc>
}
  801710:	c9                   	leave  
  801711:	c3                   	ret    

00801712 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801712:	55                   	push   %ebp
  801713:	89 e5                	mov    %esp,%ebp
  801715:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801718:	8b 45 08             	mov    0x8(%ebp),%eax
  80171b:	8b 40 0c             	mov    0xc(%eax),%eax
  80171e:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801723:	ba 00 00 00 00       	mov    $0x0,%edx
  801728:	b8 06 00 00 00       	mov    $0x6,%eax
  80172d:	e8 6b ff ff ff       	call   80169d <fsipc>
}
  801732:	c9                   	leave  
  801733:	c3                   	ret    

00801734 <devfile_stat>:

}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801734:	55                   	push   %ebp
  801735:	89 e5                	mov    %esp,%ebp
  801737:	53                   	push   %ebx
  801738:	83 ec 04             	sub    $0x4,%esp
  80173b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80173e:	8b 45 08             	mov    0x8(%ebp),%eax
  801741:	8b 40 0c             	mov    0xc(%eax),%eax
  801744:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801749:	ba 00 00 00 00       	mov    $0x0,%edx
  80174e:	b8 05 00 00 00       	mov    $0x5,%eax
  801753:	e8 45 ff ff ff       	call   80169d <fsipc>
  801758:	85 c0                	test   %eax,%eax
  80175a:	78 2c                	js     801788 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80175c:	83 ec 08             	sub    $0x8,%esp
  80175f:	68 00 50 80 00       	push   $0x805000
  801764:	53                   	push   %ebx
  801765:	e8 0c f0 ff ff       	call   800776 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80176a:	a1 80 50 80 00       	mov    0x805080,%eax
  80176f:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801775:	a1 84 50 80 00       	mov    0x805084,%eax
  80177a:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801780:	83 c4 10             	add    $0x10,%esp
  801783:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801788:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80178b:	c9                   	leave  
  80178c:	c3                   	ret    

0080178d <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  80178d:	55                   	push   %ebp
  80178e:	89 e5                	mov    %esp,%ebp
  801790:	83 ec 0c             	sub    $0xc,%esp
  801793:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	// panic("devfile_write not implemented");

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801796:	8b 55 08             	mov    0x8(%ebp),%edx
  801799:	8b 52 0c             	mov    0xc(%edx),%edx
  80179c:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  8017a2:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  8017a7:	50                   	push   %eax
  8017a8:	ff 75 0c             	pushl  0xc(%ebp)
  8017ab:	68 08 50 80 00       	push   $0x805008
  8017b0:	e8 53 f1 ff ff       	call   800908 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  8017b5:	ba 00 00 00 00       	mov    $0x0,%edx
  8017ba:	b8 04 00 00 00       	mov    $0x4,%eax
  8017bf:	e8 d9 fe ff ff       	call   80169d <fsipc>

}
  8017c4:	c9                   	leave  
  8017c5:	c3                   	ret    

008017c6 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8017c6:	55                   	push   %ebp
  8017c7:	89 e5                	mov    %esp,%ebp
  8017c9:	56                   	push   %esi
  8017ca:	53                   	push   %ebx
  8017cb:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8017ce:	8b 45 08             	mov    0x8(%ebp),%eax
  8017d1:	8b 40 0c             	mov    0xc(%eax),%eax
  8017d4:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8017d9:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8017df:	ba 00 00 00 00       	mov    $0x0,%edx
  8017e4:	b8 03 00 00 00       	mov    $0x3,%eax
  8017e9:	e8 af fe ff ff       	call   80169d <fsipc>
  8017ee:	89 c3                	mov    %eax,%ebx
  8017f0:	85 c0                	test   %eax,%eax
  8017f2:	78 4b                	js     80183f <devfile_read+0x79>
		return r;
	assert(r <= n);
  8017f4:	39 c6                	cmp    %eax,%esi
  8017f6:	73 16                	jae    80180e <devfile_read+0x48>
  8017f8:	68 44 26 80 00       	push   $0x802644
  8017fd:	68 4b 26 80 00       	push   $0x80264b
  801802:	6a 7c                	push   $0x7c
  801804:	68 60 26 80 00       	push   $0x802660
  801809:	e8 bd 05 00 00       	call   801dcb <_panic>
	assert(r <= PGSIZE);
  80180e:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801813:	7e 16                	jle    80182b <devfile_read+0x65>
  801815:	68 6b 26 80 00       	push   $0x80266b
  80181a:	68 4b 26 80 00       	push   $0x80264b
  80181f:	6a 7d                	push   $0x7d
  801821:	68 60 26 80 00       	push   $0x802660
  801826:	e8 a0 05 00 00       	call   801dcb <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80182b:	83 ec 04             	sub    $0x4,%esp
  80182e:	50                   	push   %eax
  80182f:	68 00 50 80 00       	push   $0x805000
  801834:	ff 75 0c             	pushl  0xc(%ebp)
  801837:	e8 cc f0 ff ff       	call   800908 <memmove>
	return r;
  80183c:	83 c4 10             	add    $0x10,%esp
}
  80183f:	89 d8                	mov    %ebx,%eax
  801841:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801844:	5b                   	pop    %ebx
  801845:	5e                   	pop    %esi
  801846:	5d                   	pop    %ebp
  801847:	c3                   	ret    

00801848 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801848:	55                   	push   %ebp
  801849:	89 e5                	mov    %esp,%ebp
  80184b:	53                   	push   %ebx
  80184c:	83 ec 20             	sub    $0x20,%esp
  80184f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801852:	53                   	push   %ebx
  801853:	e8 e5 ee ff ff       	call   80073d <strlen>
  801858:	83 c4 10             	add    $0x10,%esp
  80185b:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801860:	7f 67                	jg     8018c9 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801862:	83 ec 0c             	sub    $0xc,%esp
  801865:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801868:	50                   	push   %eax
  801869:	e8 a7 f8 ff ff       	call   801115 <fd_alloc>
  80186e:	83 c4 10             	add    $0x10,%esp
		return r;
  801871:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801873:	85 c0                	test   %eax,%eax
  801875:	78 57                	js     8018ce <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801877:	83 ec 08             	sub    $0x8,%esp
  80187a:	53                   	push   %ebx
  80187b:	68 00 50 80 00       	push   $0x805000
  801880:	e8 f1 ee ff ff       	call   800776 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801885:	8b 45 0c             	mov    0xc(%ebp),%eax
  801888:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80188d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801890:	b8 01 00 00 00       	mov    $0x1,%eax
  801895:	e8 03 fe ff ff       	call   80169d <fsipc>
  80189a:	89 c3                	mov    %eax,%ebx
  80189c:	83 c4 10             	add    $0x10,%esp
  80189f:	85 c0                	test   %eax,%eax
  8018a1:	79 14                	jns    8018b7 <open+0x6f>
		fd_close(fd, 0);
  8018a3:	83 ec 08             	sub    $0x8,%esp
  8018a6:	6a 00                	push   $0x0
  8018a8:	ff 75 f4             	pushl  -0xc(%ebp)
  8018ab:	e8 5d f9 ff ff       	call   80120d <fd_close>
		return r;
  8018b0:	83 c4 10             	add    $0x10,%esp
  8018b3:	89 da                	mov    %ebx,%edx
  8018b5:	eb 17                	jmp    8018ce <open+0x86>
	}

	return fd2num(fd);
  8018b7:	83 ec 0c             	sub    $0xc,%esp
  8018ba:	ff 75 f4             	pushl  -0xc(%ebp)
  8018bd:	e8 2c f8 ff ff       	call   8010ee <fd2num>
  8018c2:	89 c2                	mov    %eax,%edx
  8018c4:	83 c4 10             	add    $0x10,%esp
  8018c7:	eb 05                	jmp    8018ce <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8018c9:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8018ce:	89 d0                	mov    %edx,%eax
  8018d0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018d3:	c9                   	leave  
  8018d4:	c3                   	ret    

008018d5 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8018d5:	55                   	push   %ebp
  8018d6:	89 e5                	mov    %esp,%ebp
  8018d8:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8018db:	ba 00 00 00 00       	mov    $0x0,%edx
  8018e0:	b8 08 00 00 00       	mov    $0x8,%eax
  8018e5:	e8 b3 fd ff ff       	call   80169d <fsipc>
}
  8018ea:	c9                   	leave  
  8018eb:	c3                   	ret    

008018ec <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8018ec:	55                   	push   %ebp
  8018ed:	89 e5                	mov    %esp,%ebp
  8018ef:	56                   	push   %esi
  8018f0:	53                   	push   %ebx
  8018f1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8018f4:	83 ec 0c             	sub    $0xc,%esp
  8018f7:	ff 75 08             	pushl  0x8(%ebp)
  8018fa:	e8 ff f7 ff ff       	call   8010fe <fd2data>
  8018ff:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801901:	83 c4 08             	add    $0x8,%esp
  801904:	68 77 26 80 00       	push   $0x802677
  801909:	53                   	push   %ebx
  80190a:	e8 67 ee ff ff       	call   800776 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  80190f:	8b 46 04             	mov    0x4(%esi),%eax
  801912:	2b 06                	sub    (%esi),%eax
  801914:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80191a:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801921:	00 00 00 
	stat->st_dev = &devpipe;
  801924:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  80192b:	30 80 00 
	return 0;
}
  80192e:	b8 00 00 00 00       	mov    $0x0,%eax
  801933:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801936:	5b                   	pop    %ebx
  801937:	5e                   	pop    %esi
  801938:	5d                   	pop    %ebp
  801939:	c3                   	ret    

0080193a <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80193a:	55                   	push   %ebp
  80193b:	89 e5                	mov    %esp,%ebp
  80193d:	53                   	push   %ebx
  80193e:	83 ec 0c             	sub    $0xc,%esp
  801941:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801944:	53                   	push   %ebx
  801945:	6a 00                	push   $0x0
  801947:	e8 b2 f2 ff ff       	call   800bfe <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  80194c:	89 1c 24             	mov    %ebx,(%esp)
  80194f:	e8 aa f7 ff ff       	call   8010fe <fd2data>
  801954:	83 c4 08             	add    $0x8,%esp
  801957:	50                   	push   %eax
  801958:	6a 00                	push   $0x0
  80195a:	e8 9f f2 ff ff       	call   800bfe <sys_page_unmap>
}
  80195f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801962:	c9                   	leave  
  801963:	c3                   	ret    

00801964 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801964:	55                   	push   %ebp
  801965:	89 e5                	mov    %esp,%ebp
  801967:	57                   	push   %edi
  801968:	56                   	push   %esi
  801969:	53                   	push   %ebx
  80196a:	83 ec 1c             	sub    $0x1c,%esp
  80196d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801970:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801972:	a1 08 40 80 00       	mov    0x804008,%eax
  801977:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  80197a:	83 ec 0c             	sub    $0xc,%esp
  80197d:	ff 75 e0             	pushl  -0x20(%ebp)
  801980:	e8 f7 04 00 00       	call   801e7c <pageref>
  801985:	89 c3                	mov    %eax,%ebx
  801987:	89 3c 24             	mov    %edi,(%esp)
  80198a:	e8 ed 04 00 00       	call   801e7c <pageref>
  80198f:	83 c4 10             	add    $0x10,%esp
  801992:	39 c3                	cmp    %eax,%ebx
  801994:	0f 94 c1             	sete   %cl
  801997:	0f b6 c9             	movzbl %cl,%ecx
  80199a:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  80199d:	8b 15 08 40 80 00    	mov    0x804008,%edx
  8019a3:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8019a6:	39 ce                	cmp    %ecx,%esi
  8019a8:	74 1b                	je     8019c5 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  8019aa:	39 c3                	cmp    %eax,%ebx
  8019ac:	75 c4                	jne    801972 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8019ae:	8b 42 58             	mov    0x58(%edx),%eax
  8019b1:	ff 75 e4             	pushl  -0x1c(%ebp)
  8019b4:	50                   	push   %eax
  8019b5:	56                   	push   %esi
  8019b6:	68 7e 26 80 00       	push   $0x80267e
  8019bb:	e8 31 e8 ff ff       	call   8001f1 <cprintf>
  8019c0:	83 c4 10             	add    $0x10,%esp
  8019c3:	eb ad                	jmp    801972 <_pipeisclosed+0xe>
	}
}
  8019c5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8019c8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8019cb:	5b                   	pop    %ebx
  8019cc:	5e                   	pop    %esi
  8019cd:	5f                   	pop    %edi
  8019ce:	5d                   	pop    %ebp
  8019cf:	c3                   	ret    

008019d0 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8019d0:	55                   	push   %ebp
  8019d1:	89 e5                	mov    %esp,%ebp
  8019d3:	57                   	push   %edi
  8019d4:	56                   	push   %esi
  8019d5:	53                   	push   %ebx
  8019d6:	83 ec 28             	sub    $0x28,%esp
  8019d9:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8019dc:	56                   	push   %esi
  8019dd:	e8 1c f7 ff ff       	call   8010fe <fd2data>
  8019e2:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8019e4:	83 c4 10             	add    $0x10,%esp
  8019e7:	bf 00 00 00 00       	mov    $0x0,%edi
  8019ec:	eb 4b                	jmp    801a39 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8019ee:	89 da                	mov    %ebx,%edx
  8019f0:	89 f0                	mov    %esi,%eax
  8019f2:	e8 6d ff ff ff       	call   801964 <_pipeisclosed>
  8019f7:	85 c0                	test   %eax,%eax
  8019f9:	75 48                	jne    801a43 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8019fb:	e8 5a f1 ff ff       	call   800b5a <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801a00:	8b 43 04             	mov    0x4(%ebx),%eax
  801a03:	8b 0b                	mov    (%ebx),%ecx
  801a05:	8d 51 20             	lea    0x20(%ecx),%edx
  801a08:	39 d0                	cmp    %edx,%eax
  801a0a:	73 e2                	jae    8019ee <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801a0c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a0f:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801a13:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801a16:	89 c2                	mov    %eax,%edx
  801a18:	c1 fa 1f             	sar    $0x1f,%edx
  801a1b:	89 d1                	mov    %edx,%ecx
  801a1d:	c1 e9 1b             	shr    $0x1b,%ecx
  801a20:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801a23:	83 e2 1f             	and    $0x1f,%edx
  801a26:	29 ca                	sub    %ecx,%edx
  801a28:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801a2c:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801a30:	83 c0 01             	add    $0x1,%eax
  801a33:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a36:	83 c7 01             	add    $0x1,%edi
  801a39:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801a3c:	75 c2                	jne    801a00 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801a3e:	8b 45 10             	mov    0x10(%ebp),%eax
  801a41:	eb 05                	jmp    801a48 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801a43:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801a48:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a4b:	5b                   	pop    %ebx
  801a4c:	5e                   	pop    %esi
  801a4d:	5f                   	pop    %edi
  801a4e:	5d                   	pop    %ebp
  801a4f:	c3                   	ret    

00801a50 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801a50:	55                   	push   %ebp
  801a51:	89 e5                	mov    %esp,%ebp
  801a53:	57                   	push   %edi
  801a54:	56                   	push   %esi
  801a55:	53                   	push   %ebx
  801a56:	83 ec 18             	sub    $0x18,%esp
  801a59:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801a5c:	57                   	push   %edi
  801a5d:	e8 9c f6 ff ff       	call   8010fe <fd2data>
  801a62:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a64:	83 c4 10             	add    $0x10,%esp
  801a67:	bb 00 00 00 00       	mov    $0x0,%ebx
  801a6c:	eb 3d                	jmp    801aab <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801a6e:	85 db                	test   %ebx,%ebx
  801a70:	74 04                	je     801a76 <devpipe_read+0x26>
				return i;
  801a72:	89 d8                	mov    %ebx,%eax
  801a74:	eb 44                	jmp    801aba <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801a76:	89 f2                	mov    %esi,%edx
  801a78:	89 f8                	mov    %edi,%eax
  801a7a:	e8 e5 fe ff ff       	call   801964 <_pipeisclosed>
  801a7f:	85 c0                	test   %eax,%eax
  801a81:	75 32                	jne    801ab5 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801a83:	e8 d2 f0 ff ff       	call   800b5a <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801a88:	8b 06                	mov    (%esi),%eax
  801a8a:	3b 46 04             	cmp    0x4(%esi),%eax
  801a8d:	74 df                	je     801a6e <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801a8f:	99                   	cltd   
  801a90:	c1 ea 1b             	shr    $0x1b,%edx
  801a93:	01 d0                	add    %edx,%eax
  801a95:	83 e0 1f             	and    $0x1f,%eax
  801a98:	29 d0                	sub    %edx,%eax
  801a9a:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801a9f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801aa2:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801aa5:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801aa8:	83 c3 01             	add    $0x1,%ebx
  801aab:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801aae:	75 d8                	jne    801a88 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801ab0:	8b 45 10             	mov    0x10(%ebp),%eax
  801ab3:	eb 05                	jmp    801aba <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801ab5:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801aba:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801abd:	5b                   	pop    %ebx
  801abe:	5e                   	pop    %esi
  801abf:	5f                   	pop    %edi
  801ac0:	5d                   	pop    %ebp
  801ac1:	c3                   	ret    

00801ac2 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801ac2:	55                   	push   %ebp
  801ac3:	89 e5                	mov    %esp,%ebp
  801ac5:	56                   	push   %esi
  801ac6:	53                   	push   %ebx
  801ac7:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801aca:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801acd:	50                   	push   %eax
  801ace:	e8 42 f6 ff ff       	call   801115 <fd_alloc>
  801ad3:	83 c4 10             	add    $0x10,%esp
  801ad6:	89 c2                	mov    %eax,%edx
  801ad8:	85 c0                	test   %eax,%eax
  801ada:	0f 88 2c 01 00 00    	js     801c0c <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ae0:	83 ec 04             	sub    $0x4,%esp
  801ae3:	68 07 04 00 00       	push   $0x407
  801ae8:	ff 75 f4             	pushl  -0xc(%ebp)
  801aeb:	6a 00                	push   $0x0
  801aed:	e8 87 f0 ff ff       	call   800b79 <sys_page_alloc>
  801af2:	83 c4 10             	add    $0x10,%esp
  801af5:	89 c2                	mov    %eax,%edx
  801af7:	85 c0                	test   %eax,%eax
  801af9:	0f 88 0d 01 00 00    	js     801c0c <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801aff:	83 ec 0c             	sub    $0xc,%esp
  801b02:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801b05:	50                   	push   %eax
  801b06:	e8 0a f6 ff ff       	call   801115 <fd_alloc>
  801b0b:	89 c3                	mov    %eax,%ebx
  801b0d:	83 c4 10             	add    $0x10,%esp
  801b10:	85 c0                	test   %eax,%eax
  801b12:	0f 88 e2 00 00 00    	js     801bfa <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b18:	83 ec 04             	sub    $0x4,%esp
  801b1b:	68 07 04 00 00       	push   $0x407
  801b20:	ff 75 f0             	pushl  -0x10(%ebp)
  801b23:	6a 00                	push   $0x0
  801b25:	e8 4f f0 ff ff       	call   800b79 <sys_page_alloc>
  801b2a:	89 c3                	mov    %eax,%ebx
  801b2c:	83 c4 10             	add    $0x10,%esp
  801b2f:	85 c0                	test   %eax,%eax
  801b31:	0f 88 c3 00 00 00    	js     801bfa <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801b37:	83 ec 0c             	sub    $0xc,%esp
  801b3a:	ff 75 f4             	pushl  -0xc(%ebp)
  801b3d:	e8 bc f5 ff ff       	call   8010fe <fd2data>
  801b42:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b44:	83 c4 0c             	add    $0xc,%esp
  801b47:	68 07 04 00 00       	push   $0x407
  801b4c:	50                   	push   %eax
  801b4d:	6a 00                	push   $0x0
  801b4f:	e8 25 f0 ff ff       	call   800b79 <sys_page_alloc>
  801b54:	89 c3                	mov    %eax,%ebx
  801b56:	83 c4 10             	add    $0x10,%esp
  801b59:	85 c0                	test   %eax,%eax
  801b5b:	0f 88 89 00 00 00    	js     801bea <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b61:	83 ec 0c             	sub    $0xc,%esp
  801b64:	ff 75 f0             	pushl  -0x10(%ebp)
  801b67:	e8 92 f5 ff ff       	call   8010fe <fd2data>
  801b6c:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801b73:	50                   	push   %eax
  801b74:	6a 00                	push   $0x0
  801b76:	56                   	push   %esi
  801b77:	6a 00                	push   $0x0
  801b79:	e8 3e f0 ff ff       	call   800bbc <sys_page_map>
  801b7e:	89 c3                	mov    %eax,%ebx
  801b80:	83 c4 20             	add    $0x20,%esp
  801b83:	85 c0                	test   %eax,%eax
  801b85:	78 55                	js     801bdc <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801b87:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801b8d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b90:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801b92:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b95:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801b9c:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801ba2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ba5:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801ba7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801baa:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801bb1:	83 ec 0c             	sub    $0xc,%esp
  801bb4:	ff 75 f4             	pushl  -0xc(%ebp)
  801bb7:	e8 32 f5 ff ff       	call   8010ee <fd2num>
  801bbc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801bbf:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801bc1:	83 c4 04             	add    $0x4,%esp
  801bc4:	ff 75 f0             	pushl  -0x10(%ebp)
  801bc7:	e8 22 f5 ff ff       	call   8010ee <fd2num>
  801bcc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801bcf:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801bd2:	83 c4 10             	add    $0x10,%esp
  801bd5:	ba 00 00 00 00       	mov    $0x0,%edx
  801bda:	eb 30                	jmp    801c0c <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801bdc:	83 ec 08             	sub    $0x8,%esp
  801bdf:	56                   	push   %esi
  801be0:	6a 00                	push   $0x0
  801be2:	e8 17 f0 ff ff       	call   800bfe <sys_page_unmap>
  801be7:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801bea:	83 ec 08             	sub    $0x8,%esp
  801bed:	ff 75 f0             	pushl  -0x10(%ebp)
  801bf0:	6a 00                	push   $0x0
  801bf2:	e8 07 f0 ff ff       	call   800bfe <sys_page_unmap>
  801bf7:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801bfa:	83 ec 08             	sub    $0x8,%esp
  801bfd:	ff 75 f4             	pushl  -0xc(%ebp)
  801c00:	6a 00                	push   $0x0
  801c02:	e8 f7 ef ff ff       	call   800bfe <sys_page_unmap>
  801c07:	83 c4 10             	add    $0x10,%esp
  801c0a:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801c0c:	89 d0                	mov    %edx,%eax
  801c0e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c11:	5b                   	pop    %ebx
  801c12:	5e                   	pop    %esi
  801c13:	5d                   	pop    %ebp
  801c14:	c3                   	ret    

00801c15 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801c15:	55                   	push   %ebp
  801c16:	89 e5                	mov    %esp,%ebp
  801c18:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801c1b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c1e:	50                   	push   %eax
  801c1f:	ff 75 08             	pushl  0x8(%ebp)
  801c22:	e8 3d f5 ff ff       	call   801164 <fd_lookup>
  801c27:	83 c4 10             	add    $0x10,%esp
  801c2a:	85 c0                	test   %eax,%eax
  801c2c:	78 18                	js     801c46 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801c2e:	83 ec 0c             	sub    $0xc,%esp
  801c31:	ff 75 f4             	pushl  -0xc(%ebp)
  801c34:	e8 c5 f4 ff ff       	call   8010fe <fd2data>
	return _pipeisclosed(fd, p);
  801c39:	89 c2                	mov    %eax,%edx
  801c3b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c3e:	e8 21 fd ff ff       	call   801964 <_pipeisclosed>
  801c43:	83 c4 10             	add    $0x10,%esp
}
  801c46:	c9                   	leave  
  801c47:	c3                   	ret    

00801c48 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801c48:	55                   	push   %ebp
  801c49:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801c4b:	b8 00 00 00 00       	mov    $0x0,%eax
  801c50:	5d                   	pop    %ebp
  801c51:	c3                   	ret    

00801c52 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801c52:	55                   	push   %ebp
  801c53:	89 e5                	mov    %esp,%ebp
  801c55:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801c58:	68 96 26 80 00       	push   $0x802696
  801c5d:	ff 75 0c             	pushl  0xc(%ebp)
  801c60:	e8 11 eb ff ff       	call   800776 <strcpy>
	return 0;
}
  801c65:	b8 00 00 00 00       	mov    $0x0,%eax
  801c6a:	c9                   	leave  
  801c6b:	c3                   	ret    

00801c6c <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801c6c:	55                   	push   %ebp
  801c6d:	89 e5                	mov    %esp,%ebp
  801c6f:	57                   	push   %edi
  801c70:	56                   	push   %esi
  801c71:	53                   	push   %ebx
  801c72:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801c78:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801c7d:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801c83:	eb 2d                	jmp    801cb2 <devcons_write+0x46>
		m = n - tot;
  801c85:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801c88:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801c8a:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801c8d:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801c92:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801c95:	83 ec 04             	sub    $0x4,%esp
  801c98:	53                   	push   %ebx
  801c99:	03 45 0c             	add    0xc(%ebp),%eax
  801c9c:	50                   	push   %eax
  801c9d:	57                   	push   %edi
  801c9e:	e8 65 ec ff ff       	call   800908 <memmove>
		sys_cputs(buf, m);
  801ca3:	83 c4 08             	add    $0x8,%esp
  801ca6:	53                   	push   %ebx
  801ca7:	57                   	push   %edi
  801ca8:	e8 10 ee ff ff       	call   800abd <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801cad:	01 de                	add    %ebx,%esi
  801caf:	83 c4 10             	add    $0x10,%esp
  801cb2:	89 f0                	mov    %esi,%eax
  801cb4:	3b 75 10             	cmp    0x10(%ebp),%esi
  801cb7:	72 cc                	jb     801c85 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801cb9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801cbc:	5b                   	pop    %ebx
  801cbd:	5e                   	pop    %esi
  801cbe:	5f                   	pop    %edi
  801cbf:	5d                   	pop    %ebp
  801cc0:	c3                   	ret    

00801cc1 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801cc1:	55                   	push   %ebp
  801cc2:	89 e5                	mov    %esp,%ebp
  801cc4:	83 ec 08             	sub    $0x8,%esp
  801cc7:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801ccc:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801cd0:	74 2a                	je     801cfc <devcons_read+0x3b>
  801cd2:	eb 05                	jmp    801cd9 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801cd4:	e8 81 ee ff ff       	call   800b5a <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801cd9:	e8 fd ed ff ff       	call   800adb <sys_cgetc>
  801cde:	85 c0                	test   %eax,%eax
  801ce0:	74 f2                	je     801cd4 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801ce2:	85 c0                	test   %eax,%eax
  801ce4:	78 16                	js     801cfc <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801ce6:	83 f8 04             	cmp    $0x4,%eax
  801ce9:	74 0c                	je     801cf7 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801ceb:	8b 55 0c             	mov    0xc(%ebp),%edx
  801cee:	88 02                	mov    %al,(%edx)
	return 1;
  801cf0:	b8 01 00 00 00       	mov    $0x1,%eax
  801cf5:	eb 05                	jmp    801cfc <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801cf7:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801cfc:	c9                   	leave  
  801cfd:	c3                   	ret    

00801cfe <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801cfe:	55                   	push   %ebp
  801cff:	89 e5                	mov    %esp,%ebp
  801d01:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801d04:	8b 45 08             	mov    0x8(%ebp),%eax
  801d07:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801d0a:	6a 01                	push   $0x1
  801d0c:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801d0f:	50                   	push   %eax
  801d10:	e8 a8 ed ff ff       	call   800abd <sys_cputs>
}
  801d15:	83 c4 10             	add    $0x10,%esp
  801d18:	c9                   	leave  
  801d19:	c3                   	ret    

00801d1a <getchar>:

int
getchar(void)
{
  801d1a:	55                   	push   %ebp
  801d1b:	89 e5                	mov    %esp,%ebp
  801d1d:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801d20:	6a 01                	push   $0x1
  801d22:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801d25:	50                   	push   %eax
  801d26:	6a 00                	push   $0x0
  801d28:	e8 9d f6 ff ff       	call   8013ca <read>
	if (r < 0)
  801d2d:	83 c4 10             	add    $0x10,%esp
  801d30:	85 c0                	test   %eax,%eax
  801d32:	78 0f                	js     801d43 <getchar+0x29>
		return r;
	if (r < 1)
  801d34:	85 c0                	test   %eax,%eax
  801d36:	7e 06                	jle    801d3e <getchar+0x24>
		return -E_EOF;
	return c;
  801d38:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801d3c:	eb 05                	jmp    801d43 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801d3e:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801d43:	c9                   	leave  
  801d44:	c3                   	ret    

00801d45 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801d45:	55                   	push   %ebp
  801d46:	89 e5                	mov    %esp,%ebp
  801d48:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801d4b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d4e:	50                   	push   %eax
  801d4f:	ff 75 08             	pushl  0x8(%ebp)
  801d52:	e8 0d f4 ff ff       	call   801164 <fd_lookup>
  801d57:	83 c4 10             	add    $0x10,%esp
  801d5a:	85 c0                	test   %eax,%eax
  801d5c:	78 11                	js     801d6f <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801d5e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d61:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801d67:	39 10                	cmp    %edx,(%eax)
  801d69:	0f 94 c0             	sete   %al
  801d6c:	0f b6 c0             	movzbl %al,%eax
}
  801d6f:	c9                   	leave  
  801d70:	c3                   	ret    

00801d71 <opencons>:

int
opencons(void)
{
  801d71:	55                   	push   %ebp
  801d72:	89 e5                	mov    %esp,%ebp
  801d74:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801d77:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d7a:	50                   	push   %eax
  801d7b:	e8 95 f3 ff ff       	call   801115 <fd_alloc>
  801d80:	83 c4 10             	add    $0x10,%esp
		return r;
  801d83:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801d85:	85 c0                	test   %eax,%eax
  801d87:	78 3e                	js     801dc7 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801d89:	83 ec 04             	sub    $0x4,%esp
  801d8c:	68 07 04 00 00       	push   $0x407
  801d91:	ff 75 f4             	pushl  -0xc(%ebp)
  801d94:	6a 00                	push   $0x0
  801d96:	e8 de ed ff ff       	call   800b79 <sys_page_alloc>
  801d9b:	83 c4 10             	add    $0x10,%esp
		return r;
  801d9e:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801da0:	85 c0                	test   %eax,%eax
  801da2:	78 23                	js     801dc7 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801da4:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801daa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801dad:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801daf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801db2:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801db9:	83 ec 0c             	sub    $0xc,%esp
  801dbc:	50                   	push   %eax
  801dbd:	e8 2c f3 ff ff       	call   8010ee <fd2num>
  801dc2:	89 c2                	mov    %eax,%edx
  801dc4:	83 c4 10             	add    $0x10,%esp
}
  801dc7:	89 d0                	mov    %edx,%eax
  801dc9:	c9                   	leave  
  801dca:	c3                   	ret    

00801dcb <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801dcb:	55                   	push   %ebp
  801dcc:	89 e5                	mov    %esp,%ebp
  801dce:	56                   	push   %esi
  801dcf:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801dd0:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801dd3:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801dd9:	e8 5d ed ff ff       	call   800b3b <sys_getenvid>
  801dde:	83 ec 0c             	sub    $0xc,%esp
  801de1:	ff 75 0c             	pushl  0xc(%ebp)
  801de4:	ff 75 08             	pushl  0x8(%ebp)
  801de7:	56                   	push   %esi
  801de8:	50                   	push   %eax
  801de9:	68 a4 26 80 00       	push   $0x8026a4
  801dee:	e8 fe e3 ff ff       	call   8001f1 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801df3:	83 c4 18             	add    $0x18,%esp
  801df6:	53                   	push   %ebx
  801df7:	ff 75 10             	pushl  0x10(%ebp)
  801dfa:	e8 a1 e3 ff ff       	call   8001a0 <vcprintf>
	cprintf("\n");
  801dff:	c7 04 24 8f 26 80 00 	movl   $0x80268f,(%esp)
  801e06:	e8 e6 e3 ff ff       	call   8001f1 <cprintf>
  801e0b:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801e0e:	cc                   	int3   
  801e0f:	eb fd                	jmp    801e0e <_panic+0x43>

00801e11 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801e11:	55                   	push   %ebp
  801e12:	89 e5                	mov    %esp,%ebp
  801e14:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801e17:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801e1e:	75 2e                	jne    801e4e <set_pgfault_handler+0x3d>
		// First time through!
		// LAB 4: Your code here.
		// panic("set_pgfault_handler not implemented");

		sys_page_alloc(sys_getenvid(), (void *) (UXSTACKTOP - PGSIZE), PTE_SYSCALL);
  801e20:	e8 16 ed ff ff       	call   800b3b <sys_getenvid>
  801e25:	83 ec 04             	sub    $0x4,%esp
  801e28:	68 07 0e 00 00       	push   $0xe07
  801e2d:	68 00 f0 bf ee       	push   $0xeebff000
  801e32:	50                   	push   %eax
  801e33:	e8 41 ed ff ff       	call   800b79 <sys_page_alloc>
		sys_env_set_pgfault_upcall(sys_getenvid(), _pgfault_upcall);
  801e38:	e8 fe ec ff ff       	call   800b3b <sys_getenvid>
  801e3d:	83 c4 08             	add    $0x8,%esp
  801e40:	68 58 1e 80 00       	push   $0x801e58
  801e45:	50                   	push   %eax
  801e46:	e8 79 ee ff ff       	call   800cc4 <sys_env_set_pgfault_upcall>
  801e4b:	83 c4 10             	add    $0x10,%esp
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801e4e:	8b 45 08             	mov    0x8(%ebp),%eax
  801e51:	a3 00 60 80 00       	mov    %eax,0x806000
}
  801e56:	c9                   	leave  
  801e57:	c3                   	ret    

00801e58 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801e58:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801e59:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801e5e:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801e60:	83 c4 04             	add    $0x4,%esp
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.

	movl 48(%esp), %eax		// trap-time esp
  801e63:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl 40(%esp), %ebx		// trap-time eip
  801e67:	8b 5c 24 28          	mov    0x28(%esp),%ebx

	// load eip into esp-4
	// in order to return to trap-time eip later, in the meantime not changing trap-time esp
	movl %ebx, -4(%eax)	
  801e6b:	89 58 fc             	mov    %ebx,-0x4(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.

	addl $8, %esp 			// esp now points to trap-time registers
  801e6e:	83 c4 08             	add    $0x8,%esp
	popal					// pop to all registers
  801e71:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

	addl $4, %esp			// esp now points to trap-time eflags
  801e72:	83 c4 04             	add    $0x4,%esp
	popfl					// pop to eflags
  801e75:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.

	popl %esp				// pop to esp
  801e76:	5c                   	pop    %esp
	// subl $4, %esp		// arithmetic operation will change eflags!!!
	lea -4(%esp), %esp		// subl $4, %esp
  801e77:	8d 64 24 fc          	lea    -0x4(%esp),%esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.

	ret
  801e7b:	c3                   	ret    

00801e7c <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801e7c:	55                   	push   %ebp
  801e7d:	89 e5                	mov    %esp,%ebp
  801e7f:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801e82:	89 d0                	mov    %edx,%eax
  801e84:	c1 e8 16             	shr    $0x16,%eax
  801e87:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801e8e:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801e93:	f6 c1 01             	test   $0x1,%cl
  801e96:	74 1d                	je     801eb5 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801e98:	c1 ea 0c             	shr    $0xc,%edx
  801e9b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801ea2:	f6 c2 01             	test   $0x1,%dl
  801ea5:	74 0e                	je     801eb5 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801ea7:	c1 ea 0c             	shr    $0xc,%edx
  801eaa:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801eb1:	ef 
  801eb2:	0f b7 c0             	movzwl %ax,%eax
}
  801eb5:	5d                   	pop    %ebp
  801eb6:	c3                   	ret    
  801eb7:	66 90                	xchg   %ax,%ax
  801eb9:	66 90                	xchg   %ax,%ax
  801ebb:	66 90                	xchg   %ax,%ax
  801ebd:	66 90                	xchg   %ax,%ax
  801ebf:	90                   	nop

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
