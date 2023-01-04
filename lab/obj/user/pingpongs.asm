
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
  80003c:	e8 69 0f 00 00       	call   800faa <sfork>
  800041:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800044:	85 c0                	test   %eax,%eax
  800046:	74 42                	je     80008a <umain+0x57>
		cprintf("i am %08x; thisenv is %p\n", sys_getenvid(), thisenv);
  800048:	8b 1d 08 40 80 00    	mov    0x804008,%ebx
  80004e:	e8 e8 0a 00 00       	call   800b3b <sys_getenvid>
  800053:	83 ec 04             	sub    $0x4,%esp
  800056:	53                   	push   %ebx
  800057:	50                   	push   %eax
  800058:	68 20 21 80 00       	push   $0x802120
  80005d:	e8 8f 01 00 00       	call   8001f1 <cprintf>
		// get the ball rolling
		cprintf("send 0 from %x to %x\n", sys_getenvid(), who);
  800062:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800065:	e8 d1 0a 00 00       	call   800b3b <sys_getenvid>
  80006a:	83 c4 0c             	add    $0xc,%esp
  80006d:	53                   	push   %ebx
  80006e:	50                   	push   %eax
  80006f:	68 3a 21 80 00       	push   $0x80213a
  800074:	e8 78 01 00 00       	call   8001f1 <cprintf>
		ipc_send(who, 0, 0, 0);
  800079:	6a 00                	push   $0x0
  80007b:	6a 00                	push   $0x0
  80007d:	6a 00                	push   $0x0
  80007f:	ff 75 e4             	pushl  -0x1c(%ebp)
  800082:	e8 a4 0f 00 00       	call   80102b <ipc_send>
  800087:	83 c4 20             	add    $0x20,%esp
	}

	while (1) {
		ipc_recv(&who, 0, 0);
  80008a:	83 ec 04             	sub    $0x4,%esp
  80008d:	6a 00                	push   $0x0
  80008f:	6a 00                	push   $0x0
  800091:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800094:	50                   	push   %eax
  800095:	e8 2a 0f 00 00       	call   800fc4 <ipc_recv>
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
  8000bd:	68 50 21 80 00       	push   $0x802150
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
  8000e5:	e8 41 0f 00 00       	call   80102b <ipc_send>
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
  80014a:	e8 34 11 00 00       	call   801283 <close_all>
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
  800254:	e8 37 1c 00 00       	call   801e90 <__udivdi3>
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
  800297:	e8 24 1d 00 00       	call   801fc0 <__umoddi3>
  80029c:	83 c4 14             	add    $0x14,%esp
  80029f:	0f be 80 80 21 80 00 	movsbl 0x802180(%eax),%eax
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
  80039b:	ff 24 85 c0 22 80 00 	jmp    *0x8022c0(,%eax,4)
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
  80045f:	8b 14 85 20 24 80 00 	mov    0x802420(,%eax,4),%edx
  800466:	85 d2                	test   %edx,%edx
  800468:	75 18                	jne    800482 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80046a:	50                   	push   %eax
  80046b:	68 98 21 80 00       	push   $0x802198
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
  800483:	68 1d 26 80 00       	push   $0x80261d
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
  8004a7:	b8 91 21 80 00       	mov    $0x802191,%eax
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
  800b22:	68 7f 24 80 00       	push   $0x80247f
  800b27:	6a 23                	push   $0x23
  800b29:	68 9c 24 80 00       	push   $0x80249c
  800b2e:	e8 62 12 00 00       	call   801d95 <_panic>

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
  800ba3:	68 7f 24 80 00       	push   $0x80247f
  800ba8:	6a 23                	push   $0x23
  800baa:	68 9c 24 80 00       	push   $0x80249c
  800baf:	e8 e1 11 00 00       	call   801d95 <_panic>

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
  800be5:	68 7f 24 80 00       	push   $0x80247f
  800bea:	6a 23                	push   $0x23
  800bec:	68 9c 24 80 00       	push   $0x80249c
  800bf1:	e8 9f 11 00 00       	call   801d95 <_panic>

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
  800c27:	68 7f 24 80 00       	push   $0x80247f
  800c2c:	6a 23                	push   $0x23
  800c2e:	68 9c 24 80 00       	push   $0x80249c
  800c33:	e8 5d 11 00 00       	call   801d95 <_panic>

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
  800c69:	68 7f 24 80 00       	push   $0x80247f
  800c6e:	6a 23                	push   $0x23
  800c70:	68 9c 24 80 00       	push   $0x80249c
  800c75:	e8 1b 11 00 00       	call   801d95 <_panic>

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
  800cab:	68 7f 24 80 00       	push   $0x80247f
  800cb0:	6a 23                	push   $0x23
  800cb2:	68 9c 24 80 00       	push   $0x80249c
  800cb7:	e8 d9 10 00 00       	call   801d95 <_panic>

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
  800ced:	68 7f 24 80 00       	push   $0x80247f
  800cf2:	6a 23                	push   $0x23
  800cf4:	68 9c 24 80 00       	push   $0x80249c
  800cf9:	e8 97 10 00 00       	call   801d95 <_panic>

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
  800d51:	68 7f 24 80 00       	push   $0x80247f
  800d56:	6a 23                	push   $0x23
  800d58:	68 9c 24 80 00       	push   $0x80249c
  800d5d:	e8 33 10 00 00       	call   801d95 <_panic>

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
  800d8e:	68 ac 24 80 00       	push   $0x8024ac
  800d93:	6a 1e                	push   $0x1e
  800d95:	68 40 25 80 00       	push   $0x802540
  800d9a:	e8 f6 0f 00 00       	call   801d95 <_panic>

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
  800dc4:	68 d8 24 80 00       	push   $0x8024d8
  800dc9:	6a 31                	push   $0x31
  800dcb:	68 40 25 80 00       	push   $0x802540
  800dd0:	e8 c0 0f 00 00       	call   801d95 <_panic>
	
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
  800e04:	68 fc 24 80 00       	push   $0x8024fc
  800e09:	6a 39                	push   $0x39
  800e0b:	68 40 25 80 00       	push   $0x802540
  800e10:	e8 80 0f 00 00       	call   801d95 <_panic>

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
  800e2b:	68 20 25 80 00       	push   $0x802520
  800e30:	6a 3e                	push   $0x3e
  800e32:	68 40 25 80 00       	push   $0x802540
  800e37:	e8 59 0f 00 00       	call   801d95 <_panic>
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
  800e51:	e8 85 0f 00 00       	call   801ddb <set_pgfault_handler>
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
  800e62:	0f 88 3a 01 00 00    	js     800fa2 <fork+0x15f>
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
  800e8d:	b8 00 00 00 00       	mov    $0x0,%eax
  800e92:	e9 0b 01 00 00       	jmp    800fa2 <fork+0x15f>
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
  800eaa:	0f 84 99 00 00 00    	je     800f49 <fork+0x106>
			
			// if real PTE exists
			if ((uvpt[PGNUM(addr)] & PTE_P) == PTE_P) {
  800eb0:	89 d8                	mov    %ebx,%eax
  800eb2:	c1 e8 0c             	shr    $0xc,%eax
  800eb5:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800ebc:	f6 c2 01             	test   $0x1,%dl
  800ebf:	0f 84 84 00 00 00    	je     800f49 <fork+0x106>

				// For each writable or copy-on-write page
				if ((uvpt[PGNUM(addr)] & (PTE_W | PTE_COW)) != 0) {
  800ec5:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800ecc:	a9 02 08 00 00       	test   $0x802,%eax
  800ed1:	74 76                	je     800f49 <fork+0x106>
	// r = envid2env(envid, &env, 1);
	// if (r < 0)
	// 	return r;	// E_BAD_ENV
	// envid_t parent_envid = env->env_parent_id;
	
	if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {
  800ed3:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800eda:	a8 02                	test   $0x2,%al
  800edc:	75 0c                	jne    800eea <fork+0xa7>
  800ede:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800ee5:	f6 c4 08             	test   $0x8,%ah
  800ee8:	74 3f                	je     800f29 <fork+0xe6>

		// map the page copy-on-write into the address space of the child
        r = sys_page_map(0, (void *)va, envid, (void *)va, PTE_P|PTE_U|PTE_COW);
  800eea:	83 ec 0c             	sub    $0xc,%esp
  800eed:	68 05 08 00 00       	push   $0x805
  800ef2:	53                   	push   %ebx
  800ef3:	57                   	push   %edi
  800ef4:	53                   	push   %ebx
  800ef5:	6a 00                	push   $0x0
  800ef7:	e8 c0 fc ff ff       	call   800bbc <sys_page_map>
		if (r < 0)
  800efc:	83 c4 20             	add    $0x20,%esp
  800eff:	85 c0                	test   %eax,%eax
  800f01:	0f 88 9b 00 00 00    	js     800fa2 <fork+0x15f>
            return r;

		// remap the page copy-on-write in its own(parent) address space
        r = sys_page_map(0, (void *)va, 0, (void *)va, PTE_P|PTE_U|PTE_COW);
  800f07:	83 ec 0c             	sub    $0xc,%esp
  800f0a:	68 05 08 00 00       	push   $0x805
  800f0f:	53                   	push   %ebx
  800f10:	6a 00                	push   $0x0
  800f12:	53                   	push   %ebx
  800f13:	6a 00                	push   $0x0
  800f15:	e8 a2 fc ff ff       	call   800bbc <sys_page_map>
  800f1a:	83 c4 20             	add    $0x20,%esp
  800f1d:	85 c0                	test   %eax,%eax
  800f1f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f24:	0f 4f c1             	cmovg  %ecx,%eax
  800f27:	eb 1c                	jmp    800f45 <fork+0x102>
		if (r < 0)
            return r;
    }
    else {
        r = sys_page_map(0, (void *)va, envid, (void *)va, PTE_P|PTE_U);
  800f29:	83 ec 0c             	sub    $0xc,%esp
  800f2c:	6a 05                	push   $0x5
  800f2e:	53                   	push   %ebx
  800f2f:	57                   	push   %edi
  800f30:	53                   	push   %ebx
  800f31:	6a 00                	push   $0x0
  800f33:	e8 84 fc ff ff       	call   800bbc <sys_page_map>
  800f38:	83 c4 20             	add    $0x20,%esp
  800f3b:	85 c0                	test   %eax,%eax
  800f3d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f42:	0f 4f c1             	cmovg  %ecx,%eax
			if ((uvpt[PGNUM(addr)] & PTE_P) == PTE_P) {

				// For each writable or copy-on-write page
				if ((uvpt[PGNUM(addr)] & (PTE_W | PTE_COW)) != 0) {
					r = duppage(envid, pn);
					if (r < 0)
  800f45:	85 c0                	test   %eax,%eax
  800f47:	78 59                	js     800fa2 <fork+0x15f>
        return 0;
	}

	// For each writable or copy-on-write page in its address space below UTOP, the parent calls duppage
	uint32_t addr;
	for (uint32_t pn = PGNUM(UTEXT); pn < PGNUM(USTACKTOP); pn++) {
  800f49:	83 c6 01             	add    $0x1,%esi
  800f4c:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  800f52:	81 fe fe eb 0e 00    	cmp    $0xeebfe,%esi
  800f58:	0f 85 3e ff ff ff    	jne    800e9c <fork+0x59>
  800f5e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
		}
	}

	// allocate a fresh page in the child for the exception stack
	r = sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U | PTE_P | PTE_W);
  800f61:	83 ec 04             	sub    $0x4,%esp
  800f64:	6a 07                	push   $0x7
  800f66:	68 00 f0 bf ee       	push   $0xeebff000
  800f6b:	57                   	push   %edi
  800f6c:	e8 08 fc ff ff       	call   800b79 <sys_page_alloc>
	if (r < 0)
  800f71:	83 c4 10             	add    $0x10,%esp
  800f74:	85 c0                	test   %eax,%eax
  800f76:	78 2a                	js     800fa2 <fork+0x15f>
		return r;

	// The parent sets the user page fault entrypoint for the child to look like its own
	extern void _pgfault_upcall(void);
	r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  800f78:	83 ec 08             	sub    $0x8,%esp
  800f7b:	68 22 1e 80 00       	push   $0x801e22
  800f80:	57                   	push   %edi
  800f81:	e8 3e fd ff ff       	call   800cc4 <sys_env_set_pgfault_upcall>
	if (r < 0)
  800f86:	83 c4 10             	add    $0x10,%esp
  800f89:	85 c0                	test   %eax,%eax
  800f8b:	78 15                	js     800fa2 <fork+0x15f>
		return r;

	// The child is now ready to run, so the parent marks it runnable
	r = sys_env_set_status(envid, ENV_RUNNABLE);
  800f8d:	83 ec 08             	sub    $0x8,%esp
  800f90:	6a 02                	push   $0x2
  800f92:	57                   	push   %edi
  800f93:	e8 a8 fc ff ff       	call   800c40 <sys_env_set_status>
	if (r < 0)
  800f98:	83 c4 10             	add    $0x10,%esp
		return r;

	return envid;
  800f9b:	85 c0                	test   %eax,%eax
  800f9d:	0f 49 c7             	cmovns %edi,%eax
  800fa0:	eb 00                	jmp    800fa2 <fork+0x15f>
	// panic("fork not implemented");
}
  800fa2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fa5:	5b                   	pop    %ebx
  800fa6:	5e                   	pop    %esi
  800fa7:	5f                   	pop    %edi
  800fa8:	5d                   	pop    %ebp
  800fa9:	c3                   	ret    

00800faa <sfork>:

// Challenge!
int
sfork(void)
{
  800faa:	55                   	push   %ebp
  800fab:	89 e5                	mov    %esp,%ebp
  800fad:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  800fb0:	68 4b 25 80 00       	push   $0x80254b
  800fb5:	68 c3 00 00 00       	push   $0xc3
  800fba:	68 40 25 80 00       	push   $0x802540
  800fbf:	e8 d1 0d 00 00       	call   801d95 <_panic>

00800fc4 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  800fc4:	55                   	push   %ebp
  800fc5:	89 e5                	mov    %esp,%ebp
  800fc7:	56                   	push   %esi
  800fc8:	53                   	push   %ebx
  800fc9:	8b 75 08             	mov    0x8(%ebp),%esi
  800fcc:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fcf:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");

	// don't want to recv page
	if (pg == NULL)
  800fd2:	85 c0                	test   %eax,%eax
		pg = (void *)UTOP;
  800fd4:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  800fd9:	0f 44 c2             	cmove  %edx,%eax

	int err = sys_ipc_recv(pg);
  800fdc:	83 ec 0c             	sub    $0xc,%esp
  800fdf:	50                   	push   %eax
  800fe0:	e8 44 fd ff ff       	call   800d29 <sys_ipc_recv>

	if (from_env_store != NULL)
  800fe5:	83 c4 10             	add    $0x10,%esp
  800fe8:	85 f6                	test   %esi,%esi
  800fea:	74 14                	je     801000 <ipc_recv+0x3c>
		*from_env_store = err < 0? 0 : thisenv->env_ipc_from;
  800fec:	ba 00 00 00 00       	mov    $0x0,%edx
  800ff1:	85 c0                	test   %eax,%eax
  800ff3:	78 09                	js     800ffe <ipc_recv+0x3a>
  800ff5:	8b 15 08 40 80 00    	mov    0x804008,%edx
  800ffb:	8b 52 74             	mov    0x74(%edx),%edx
  800ffe:	89 16                	mov    %edx,(%esi)
	
	if (perm_store != NULL)
  801000:	85 db                	test   %ebx,%ebx
  801002:	74 14                	je     801018 <ipc_recv+0x54>
		*perm_store = err < 0? 0 : thisenv->env_ipc_perm;
  801004:	ba 00 00 00 00       	mov    $0x0,%edx
  801009:	85 c0                	test   %eax,%eax
  80100b:	78 09                	js     801016 <ipc_recv+0x52>
  80100d:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801013:	8b 52 78             	mov    0x78(%edx),%edx
  801016:	89 13                	mov    %edx,(%ebx)

	if (err < 0)
  801018:	85 c0                	test   %eax,%eax
  80101a:	78 08                	js     801024 <ipc_recv+0x60>
		return err;
	return thisenv->env_ipc_value;
  80101c:	a1 08 40 80 00       	mov    0x804008,%eax
  801021:	8b 40 70             	mov    0x70(%eax),%eax
}
  801024:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801027:	5b                   	pop    %ebx
  801028:	5e                   	pop    %esi
  801029:	5d                   	pop    %ebp
  80102a:	c3                   	ret    

0080102b <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80102b:	55                   	push   %ebp
  80102c:	89 e5                	mov    %esp,%ebp
  80102e:	57                   	push   %edi
  80102f:	56                   	push   %esi
  801030:	53                   	push   %ebx
  801031:	83 ec 0c             	sub    $0xc,%esp
  801034:	8b 7d 08             	mov    0x8(%ebp),%edi
  801037:	8b 75 0c             	mov    0xc(%ebp),%esi
  80103a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");

	// don't want to send page
	if (pg == NULL)
  80103d:	85 db                	test   %ebx,%ebx
		pg = (void *)UTOP;
  80103f:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801044:	0f 44 d8             	cmove  %eax,%ebx
	
	int err = 0;
	
	do {

		err = sys_ipc_try_send(to_env, val, pg, perm);
  801047:	ff 75 14             	pushl  0x14(%ebp)
  80104a:	53                   	push   %ebx
  80104b:	56                   	push   %esi
  80104c:	57                   	push   %edi
  80104d:	e8 b4 fc ff ff       	call   800d06 <sys_ipc_try_send>

		if (err < 0) {
  801052:	83 c4 10             	add    $0x10,%esp
  801055:	85 c0                	test   %eax,%eax
  801057:	79 1e                	jns    801077 <ipc_send+0x4c>
			if (err == -E_IPC_NOT_RECV)
  801059:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80105c:	75 07                	jne    801065 <ipc_send+0x3a>
				sys_yield();
  80105e:	e8 f7 fa ff ff       	call   800b5a <sys_yield>
  801063:	eb e2                	jmp    801047 <ipc_send+0x1c>
			else 
				panic("ipc_send: %e", err);
  801065:	50                   	push   %eax
  801066:	68 61 25 80 00       	push   $0x802561
  80106b:	6a 49                	push   $0x49
  80106d:	68 6e 25 80 00       	push   $0x80256e
  801072:	e8 1e 0d 00 00       	call   801d95 <_panic>
		}

	} while (err < 0);

}
  801077:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80107a:	5b                   	pop    %ebx
  80107b:	5e                   	pop    %esi
  80107c:	5f                   	pop    %edi
  80107d:	5d                   	pop    %ebp
  80107e:	c3                   	ret    

0080107f <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80107f:	55                   	push   %ebp
  801080:	89 e5                	mov    %esp,%ebp
  801082:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801085:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80108a:	6b d0 7c             	imul   $0x7c,%eax,%edx
  80108d:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801093:	8b 52 50             	mov    0x50(%edx),%edx
  801096:	39 ca                	cmp    %ecx,%edx
  801098:	75 0d                	jne    8010a7 <ipc_find_env+0x28>
			return envs[i].env_id;
  80109a:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80109d:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8010a2:	8b 40 48             	mov    0x48(%eax),%eax
  8010a5:	eb 0f                	jmp    8010b6 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8010a7:	83 c0 01             	add    $0x1,%eax
  8010aa:	3d 00 04 00 00       	cmp    $0x400,%eax
  8010af:	75 d9                	jne    80108a <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8010b1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8010b6:	5d                   	pop    %ebp
  8010b7:	c3                   	ret    

008010b8 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8010b8:	55                   	push   %ebp
  8010b9:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8010bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8010be:	05 00 00 00 30       	add    $0x30000000,%eax
  8010c3:	c1 e8 0c             	shr    $0xc,%eax
}
  8010c6:	5d                   	pop    %ebp
  8010c7:	c3                   	ret    

008010c8 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8010c8:	55                   	push   %ebp
  8010c9:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8010cb:	8b 45 08             	mov    0x8(%ebp),%eax
  8010ce:	05 00 00 00 30       	add    $0x30000000,%eax
  8010d3:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8010d8:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8010dd:	5d                   	pop    %ebp
  8010de:	c3                   	ret    

008010df <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8010df:	55                   	push   %ebp
  8010e0:	89 e5                	mov    %esp,%ebp
  8010e2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010e5:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8010ea:	89 c2                	mov    %eax,%edx
  8010ec:	c1 ea 16             	shr    $0x16,%edx
  8010ef:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8010f6:	f6 c2 01             	test   $0x1,%dl
  8010f9:	74 11                	je     80110c <fd_alloc+0x2d>
  8010fb:	89 c2                	mov    %eax,%edx
  8010fd:	c1 ea 0c             	shr    $0xc,%edx
  801100:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801107:	f6 c2 01             	test   $0x1,%dl
  80110a:	75 09                	jne    801115 <fd_alloc+0x36>
			*fd_store = fd;
  80110c:	89 01                	mov    %eax,(%ecx)
			return 0;
  80110e:	b8 00 00 00 00       	mov    $0x0,%eax
  801113:	eb 17                	jmp    80112c <fd_alloc+0x4d>
  801115:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80111a:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80111f:	75 c9                	jne    8010ea <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801121:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801127:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80112c:	5d                   	pop    %ebp
  80112d:	c3                   	ret    

0080112e <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80112e:	55                   	push   %ebp
  80112f:	89 e5                	mov    %esp,%ebp
  801131:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801134:	83 f8 1f             	cmp    $0x1f,%eax
  801137:	77 36                	ja     80116f <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801139:	c1 e0 0c             	shl    $0xc,%eax
  80113c:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801141:	89 c2                	mov    %eax,%edx
  801143:	c1 ea 16             	shr    $0x16,%edx
  801146:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80114d:	f6 c2 01             	test   $0x1,%dl
  801150:	74 24                	je     801176 <fd_lookup+0x48>
  801152:	89 c2                	mov    %eax,%edx
  801154:	c1 ea 0c             	shr    $0xc,%edx
  801157:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80115e:	f6 c2 01             	test   $0x1,%dl
  801161:	74 1a                	je     80117d <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801163:	8b 55 0c             	mov    0xc(%ebp),%edx
  801166:	89 02                	mov    %eax,(%edx)
	return 0;
  801168:	b8 00 00 00 00       	mov    $0x0,%eax
  80116d:	eb 13                	jmp    801182 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80116f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801174:	eb 0c                	jmp    801182 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801176:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80117b:	eb 05                	jmp    801182 <fd_lookup+0x54>
  80117d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801182:	5d                   	pop    %ebp
  801183:	c3                   	ret    

00801184 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801184:	55                   	push   %ebp
  801185:	89 e5                	mov    %esp,%ebp
  801187:	83 ec 08             	sub    $0x8,%esp
  80118a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80118d:	ba f4 25 80 00       	mov    $0x8025f4,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801192:	eb 13                	jmp    8011a7 <dev_lookup+0x23>
  801194:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801197:	39 08                	cmp    %ecx,(%eax)
  801199:	75 0c                	jne    8011a7 <dev_lookup+0x23>
			*dev = devtab[i];
  80119b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80119e:	89 01                	mov    %eax,(%ecx)
			return 0;
  8011a0:	b8 00 00 00 00       	mov    $0x0,%eax
  8011a5:	eb 2e                	jmp    8011d5 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8011a7:	8b 02                	mov    (%edx),%eax
  8011a9:	85 c0                	test   %eax,%eax
  8011ab:	75 e7                	jne    801194 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8011ad:	a1 08 40 80 00       	mov    0x804008,%eax
  8011b2:	8b 40 48             	mov    0x48(%eax),%eax
  8011b5:	83 ec 04             	sub    $0x4,%esp
  8011b8:	51                   	push   %ecx
  8011b9:	50                   	push   %eax
  8011ba:	68 78 25 80 00       	push   $0x802578
  8011bf:	e8 2d f0 ff ff       	call   8001f1 <cprintf>
	*dev = 0;
  8011c4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8011c7:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8011cd:	83 c4 10             	add    $0x10,%esp
  8011d0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8011d5:	c9                   	leave  
  8011d6:	c3                   	ret    

008011d7 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8011d7:	55                   	push   %ebp
  8011d8:	89 e5                	mov    %esp,%ebp
  8011da:	56                   	push   %esi
  8011db:	53                   	push   %ebx
  8011dc:	83 ec 10             	sub    $0x10,%esp
  8011df:	8b 75 08             	mov    0x8(%ebp),%esi
  8011e2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8011e5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011e8:	50                   	push   %eax
  8011e9:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8011ef:	c1 e8 0c             	shr    $0xc,%eax
  8011f2:	50                   	push   %eax
  8011f3:	e8 36 ff ff ff       	call   80112e <fd_lookup>
  8011f8:	83 c4 08             	add    $0x8,%esp
  8011fb:	85 c0                	test   %eax,%eax
  8011fd:	78 05                	js     801204 <fd_close+0x2d>
	    || fd != fd2)
  8011ff:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801202:	74 0c                	je     801210 <fd_close+0x39>
		return (must_exist ? r : 0);
  801204:	84 db                	test   %bl,%bl
  801206:	ba 00 00 00 00       	mov    $0x0,%edx
  80120b:	0f 44 c2             	cmove  %edx,%eax
  80120e:	eb 41                	jmp    801251 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801210:	83 ec 08             	sub    $0x8,%esp
  801213:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801216:	50                   	push   %eax
  801217:	ff 36                	pushl  (%esi)
  801219:	e8 66 ff ff ff       	call   801184 <dev_lookup>
  80121e:	89 c3                	mov    %eax,%ebx
  801220:	83 c4 10             	add    $0x10,%esp
  801223:	85 c0                	test   %eax,%eax
  801225:	78 1a                	js     801241 <fd_close+0x6a>
		if (dev->dev_close)
  801227:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80122a:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  80122d:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801232:	85 c0                	test   %eax,%eax
  801234:	74 0b                	je     801241 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801236:	83 ec 0c             	sub    $0xc,%esp
  801239:	56                   	push   %esi
  80123a:	ff d0                	call   *%eax
  80123c:	89 c3                	mov    %eax,%ebx
  80123e:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801241:	83 ec 08             	sub    $0x8,%esp
  801244:	56                   	push   %esi
  801245:	6a 00                	push   $0x0
  801247:	e8 b2 f9 ff ff       	call   800bfe <sys_page_unmap>
	return r;
  80124c:	83 c4 10             	add    $0x10,%esp
  80124f:	89 d8                	mov    %ebx,%eax
}
  801251:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801254:	5b                   	pop    %ebx
  801255:	5e                   	pop    %esi
  801256:	5d                   	pop    %ebp
  801257:	c3                   	ret    

00801258 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801258:	55                   	push   %ebp
  801259:	89 e5                	mov    %esp,%ebp
  80125b:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80125e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801261:	50                   	push   %eax
  801262:	ff 75 08             	pushl  0x8(%ebp)
  801265:	e8 c4 fe ff ff       	call   80112e <fd_lookup>
  80126a:	83 c4 08             	add    $0x8,%esp
  80126d:	85 c0                	test   %eax,%eax
  80126f:	78 10                	js     801281 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801271:	83 ec 08             	sub    $0x8,%esp
  801274:	6a 01                	push   $0x1
  801276:	ff 75 f4             	pushl  -0xc(%ebp)
  801279:	e8 59 ff ff ff       	call   8011d7 <fd_close>
  80127e:	83 c4 10             	add    $0x10,%esp
}
  801281:	c9                   	leave  
  801282:	c3                   	ret    

00801283 <close_all>:

void
close_all(void)
{
  801283:	55                   	push   %ebp
  801284:	89 e5                	mov    %esp,%ebp
  801286:	53                   	push   %ebx
  801287:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80128a:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80128f:	83 ec 0c             	sub    $0xc,%esp
  801292:	53                   	push   %ebx
  801293:	e8 c0 ff ff ff       	call   801258 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801298:	83 c3 01             	add    $0x1,%ebx
  80129b:	83 c4 10             	add    $0x10,%esp
  80129e:	83 fb 20             	cmp    $0x20,%ebx
  8012a1:	75 ec                	jne    80128f <close_all+0xc>
		close(i);
}
  8012a3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012a6:	c9                   	leave  
  8012a7:	c3                   	ret    

008012a8 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8012a8:	55                   	push   %ebp
  8012a9:	89 e5                	mov    %esp,%ebp
  8012ab:	57                   	push   %edi
  8012ac:	56                   	push   %esi
  8012ad:	53                   	push   %ebx
  8012ae:	83 ec 2c             	sub    $0x2c,%esp
  8012b1:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8012b4:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8012b7:	50                   	push   %eax
  8012b8:	ff 75 08             	pushl  0x8(%ebp)
  8012bb:	e8 6e fe ff ff       	call   80112e <fd_lookup>
  8012c0:	83 c4 08             	add    $0x8,%esp
  8012c3:	85 c0                	test   %eax,%eax
  8012c5:	0f 88 c1 00 00 00    	js     80138c <dup+0xe4>
		return r;
	close(newfdnum);
  8012cb:	83 ec 0c             	sub    $0xc,%esp
  8012ce:	56                   	push   %esi
  8012cf:	e8 84 ff ff ff       	call   801258 <close>

	newfd = INDEX2FD(newfdnum);
  8012d4:	89 f3                	mov    %esi,%ebx
  8012d6:	c1 e3 0c             	shl    $0xc,%ebx
  8012d9:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8012df:	83 c4 04             	add    $0x4,%esp
  8012e2:	ff 75 e4             	pushl  -0x1c(%ebp)
  8012e5:	e8 de fd ff ff       	call   8010c8 <fd2data>
  8012ea:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8012ec:	89 1c 24             	mov    %ebx,(%esp)
  8012ef:	e8 d4 fd ff ff       	call   8010c8 <fd2data>
  8012f4:	83 c4 10             	add    $0x10,%esp
  8012f7:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8012fa:	89 f8                	mov    %edi,%eax
  8012fc:	c1 e8 16             	shr    $0x16,%eax
  8012ff:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801306:	a8 01                	test   $0x1,%al
  801308:	74 37                	je     801341 <dup+0x99>
  80130a:	89 f8                	mov    %edi,%eax
  80130c:	c1 e8 0c             	shr    $0xc,%eax
  80130f:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801316:	f6 c2 01             	test   $0x1,%dl
  801319:	74 26                	je     801341 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80131b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801322:	83 ec 0c             	sub    $0xc,%esp
  801325:	25 07 0e 00 00       	and    $0xe07,%eax
  80132a:	50                   	push   %eax
  80132b:	ff 75 d4             	pushl  -0x2c(%ebp)
  80132e:	6a 00                	push   $0x0
  801330:	57                   	push   %edi
  801331:	6a 00                	push   $0x0
  801333:	e8 84 f8 ff ff       	call   800bbc <sys_page_map>
  801338:	89 c7                	mov    %eax,%edi
  80133a:	83 c4 20             	add    $0x20,%esp
  80133d:	85 c0                	test   %eax,%eax
  80133f:	78 2e                	js     80136f <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801341:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801344:	89 d0                	mov    %edx,%eax
  801346:	c1 e8 0c             	shr    $0xc,%eax
  801349:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801350:	83 ec 0c             	sub    $0xc,%esp
  801353:	25 07 0e 00 00       	and    $0xe07,%eax
  801358:	50                   	push   %eax
  801359:	53                   	push   %ebx
  80135a:	6a 00                	push   $0x0
  80135c:	52                   	push   %edx
  80135d:	6a 00                	push   $0x0
  80135f:	e8 58 f8 ff ff       	call   800bbc <sys_page_map>
  801364:	89 c7                	mov    %eax,%edi
  801366:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801369:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80136b:	85 ff                	test   %edi,%edi
  80136d:	79 1d                	jns    80138c <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80136f:	83 ec 08             	sub    $0x8,%esp
  801372:	53                   	push   %ebx
  801373:	6a 00                	push   $0x0
  801375:	e8 84 f8 ff ff       	call   800bfe <sys_page_unmap>
	sys_page_unmap(0, nva);
  80137a:	83 c4 08             	add    $0x8,%esp
  80137d:	ff 75 d4             	pushl  -0x2c(%ebp)
  801380:	6a 00                	push   $0x0
  801382:	e8 77 f8 ff ff       	call   800bfe <sys_page_unmap>
	return r;
  801387:	83 c4 10             	add    $0x10,%esp
  80138a:	89 f8                	mov    %edi,%eax
}
  80138c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80138f:	5b                   	pop    %ebx
  801390:	5e                   	pop    %esi
  801391:	5f                   	pop    %edi
  801392:	5d                   	pop    %ebp
  801393:	c3                   	ret    

00801394 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801394:	55                   	push   %ebp
  801395:	89 e5                	mov    %esp,%ebp
  801397:	53                   	push   %ebx
  801398:	83 ec 14             	sub    $0x14,%esp
  80139b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80139e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013a1:	50                   	push   %eax
  8013a2:	53                   	push   %ebx
  8013a3:	e8 86 fd ff ff       	call   80112e <fd_lookup>
  8013a8:	83 c4 08             	add    $0x8,%esp
  8013ab:	89 c2                	mov    %eax,%edx
  8013ad:	85 c0                	test   %eax,%eax
  8013af:	78 6d                	js     80141e <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013b1:	83 ec 08             	sub    $0x8,%esp
  8013b4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013b7:	50                   	push   %eax
  8013b8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013bb:	ff 30                	pushl  (%eax)
  8013bd:	e8 c2 fd ff ff       	call   801184 <dev_lookup>
  8013c2:	83 c4 10             	add    $0x10,%esp
  8013c5:	85 c0                	test   %eax,%eax
  8013c7:	78 4c                	js     801415 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8013c9:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8013cc:	8b 42 08             	mov    0x8(%edx),%eax
  8013cf:	83 e0 03             	and    $0x3,%eax
  8013d2:	83 f8 01             	cmp    $0x1,%eax
  8013d5:	75 21                	jne    8013f8 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8013d7:	a1 08 40 80 00       	mov    0x804008,%eax
  8013dc:	8b 40 48             	mov    0x48(%eax),%eax
  8013df:	83 ec 04             	sub    $0x4,%esp
  8013e2:	53                   	push   %ebx
  8013e3:	50                   	push   %eax
  8013e4:	68 b9 25 80 00       	push   $0x8025b9
  8013e9:	e8 03 ee ff ff       	call   8001f1 <cprintf>
		return -E_INVAL;
  8013ee:	83 c4 10             	add    $0x10,%esp
  8013f1:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8013f6:	eb 26                	jmp    80141e <read+0x8a>
	}
	if (!dev->dev_read)
  8013f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013fb:	8b 40 08             	mov    0x8(%eax),%eax
  8013fe:	85 c0                	test   %eax,%eax
  801400:	74 17                	je     801419 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801402:	83 ec 04             	sub    $0x4,%esp
  801405:	ff 75 10             	pushl  0x10(%ebp)
  801408:	ff 75 0c             	pushl  0xc(%ebp)
  80140b:	52                   	push   %edx
  80140c:	ff d0                	call   *%eax
  80140e:	89 c2                	mov    %eax,%edx
  801410:	83 c4 10             	add    $0x10,%esp
  801413:	eb 09                	jmp    80141e <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801415:	89 c2                	mov    %eax,%edx
  801417:	eb 05                	jmp    80141e <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801419:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  80141e:	89 d0                	mov    %edx,%eax
  801420:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801423:	c9                   	leave  
  801424:	c3                   	ret    

00801425 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801425:	55                   	push   %ebp
  801426:	89 e5                	mov    %esp,%ebp
  801428:	57                   	push   %edi
  801429:	56                   	push   %esi
  80142a:	53                   	push   %ebx
  80142b:	83 ec 0c             	sub    $0xc,%esp
  80142e:	8b 7d 08             	mov    0x8(%ebp),%edi
  801431:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801434:	bb 00 00 00 00       	mov    $0x0,%ebx
  801439:	eb 21                	jmp    80145c <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80143b:	83 ec 04             	sub    $0x4,%esp
  80143e:	89 f0                	mov    %esi,%eax
  801440:	29 d8                	sub    %ebx,%eax
  801442:	50                   	push   %eax
  801443:	89 d8                	mov    %ebx,%eax
  801445:	03 45 0c             	add    0xc(%ebp),%eax
  801448:	50                   	push   %eax
  801449:	57                   	push   %edi
  80144a:	e8 45 ff ff ff       	call   801394 <read>
		if (m < 0)
  80144f:	83 c4 10             	add    $0x10,%esp
  801452:	85 c0                	test   %eax,%eax
  801454:	78 10                	js     801466 <readn+0x41>
			return m;
		if (m == 0)
  801456:	85 c0                	test   %eax,%eax
  801458:	74 0a                	je     801464 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80145a:	01 c3                	add    %eax,%ebx
  80145c:	39 f3                	cmp    %esi,%ebx
  80145e:	72 db                	jb     80143b <readn+0x16>
  801460:	89 d8                	mov    %ebx,%eax
  801462:	eb 02                	jmp    801466 <readn+0x41>
  801464:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801466:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801469:	5b                   	pop    %ebx
  80146a:	5e                   	pop    %esi
  80146b:	5f                   	pop    %edi
  80146c:	5d                   	pop    %ebp
  80146d:	c3                   	ret    

0080146e <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80146e:	55                   	push   %ebp
  80146f:	89 e5                	mov    %esp,%ebp
  801471:	53                   	push   %ebx
  801472:	83 ec 14             	sub    $0x14,%esp
  801475:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801478:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80147b:	50                   	push   %eax
  80147c:	53                   	push   %ebx
  80147d:	e8 ac fc ff ff       	call   80112e <fd_lookup>
  801482:	83 c4 08             	add    $0x8,%esp
  801485:	89 c2                	mov    %eax,%edx
  801487:	85 c0                	test   %eax,%eax
  801489:	78 68                	js     8014f3 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80148b:	83 ec 08             	sub    $0x8,%esp
  80148e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801491:	50                   	push   %eax
  801492:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801495:	ff 30                	pushl  (%eax)
  801497:	e8 e8 fc ff ff       	call   801184 <dev_lookup>
  80149c:	83 c4 10             	add    $0x10,%esp
  80149f:	85 c0                	test   %eax,%eax
  8014a1:	78 47                	js     8014ea <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8014a3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014a6:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8014aa:	75 21                	jne    8014cd <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8014ac:	a1 08 40 80 00       	mov    0x804008,%eax
  8014b1:	8b 40 48             	mov    0x48(%eax),%eax
  8014b4:	83 ec 04             	sub    $0x4,%esp
  8014b7:	53                   	push   %ebx
  8014b8:	50                   	push   %eax
  8014b9:	68 d5 25 80 00       	push   $0x8025d5
  8014be:	e8 2e ed ff ff       	call   8001f1 <cprintf>
		return -E_INVAL;
  8014c3:	83 c4 10             	add    $0x10,%esp
  8014c6:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8014cb:	eb 26                	jmp    8014f3 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8014cd:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8014d0:	8b 52 0c             	mov    0xc(%edx),%edx
  8014d3:	85 d2                	test   %edx,%edx
  8014d5:	74 17                	je     8014ee <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8014d7:	83 ec 04             	sub    $0x4,%esp
  8014da:	ff 75 10             	pushl  0x10(%ebp)
  8014dd:	ff 75 0c             	pushl  0xc(%ebp)
  8014e0:	50                   	push   %eax
  8014e1:	ff d2                	call   *%edx
  8014e3:	89 c2                	mov    %eax,%edx
  8014e5:	83 c4 10             	add    $0x10,%esp
  8014e8:	eb 09                	jmp    8014f3 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014ea:	89 c2                	mov    %eax,%edx
  8014ec:	eb 05                	jmp    8014f3 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8014ee:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8014f3:	89 d0                	mov    %edx,%eax
  8014f5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014f8:	c9                   	leave  
  8014f9:	c3                   	ret    

008014fa <seek>:

int
seek(int fdnum, off_t offset)
{
  8014fa:	55                   	push   %ebp
  8014fb:	89 e5                	mov    %esp,%ebp
  8014fd:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801500:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801503:	50                   	push   %eax
  801504:	ff 75 08             	pushl  0x8(%ebp)
  801507:	e8 22 fc ff ff       	call   80112e <fd_lookup>
  80150c:	83 c4 08             	add    $0x8,%esp
  80150f:	85 c0                	test   %eax,%eax
  801511:	78 0e                	js     801521 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801513:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801516:	8b 55 0c             	mov    0xc(%ebp),%edx
  801519:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80151c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801521:	c9                   	leave  
  801522:	c3                   	ret    

00801523 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801523:	55                   	push   %ebp
  801524:	89 e5                	mov    %esp,%ebp
  801526:	53                   	push   %ebx
  801527:	83 ec 14             	sub    $0x14,%esp
  80152a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80152d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801530:	50                   	push   %eax
  801531:	53                   	push   %ebx
  801532:	e8 f7 fb ff ff       	call   80112e <fd_lookup>
  801537:	83 c4 08             	add    $0x8,%esp
  80153a:	89 c2                	mov    %eax,%edx
  80153c:	85 c0                	test   %eax,%eax
  80153e:	78 65                	js     8015a5 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801540:	83 ec 08             	sub    $0x8,%esp
  801543:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801546:	50                   	push   %eax
  801547:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80154a:	ff 30                	pushl  (%eax)
  80154c:	e8 33 fc ff ff       	call   801184 <dev_lookup>
  801551:	83 c4 10             	add    $0x10,%esp
  801554:	85 c0                	test   %eax,%eax
  801556:	78 44                	js     80159c <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801558:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80155b:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80155f:	75 21                	jne    801582 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801561:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801566:	8b 40 48             	mov    0x48(%eax),%eax
  801569:	83 ec 04             	sub    $0x4,%esp
  80156c:	53                   	push   %ebx
  80156d:	50                   	push   %eax
  80156e:	68 98 25 80 00       	push   $0x802598
  801573:	e8 79 ec ff ff       	call   8001f1 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801578:	83 c4 10             	add    $0x10,%esp
  80157b:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801580:	eb 23                	jmp    8015a5 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801582:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801585:	8b 52 18             	mov    0x18(%edx),%edx
  801588:	85 d2                	test   %edx,%edx
  80158a:	74 14                	je     8015a0 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80158c:	83 ec 08             	sub    $0x8,%esp
  80158f:	ff 75 0c             	pushl  0xc(%ebp)
  801592:	50                   	push   %eax
  801593:	ff d2                	call   *%edx
  801595:	89 c2                	mov    %eax,%edx
  801597:	83 c4 10             	add    $0x10,%esp
  80159a:	eb 09                	jmp    8015a5 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80159c:	89 c2                	mov    %eax,%edx
  80159e:	eb 05                	jmp    8015a5 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8015a0:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8015a5:	89 d0                	mov    %edx,%eax
  8015a7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015aa:	c9                   	leave  
  8015ab:	c3                   	ret    

008015ac <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8015ac:	55                   	push   %ebp
  8015ad:	89 e5                	mov    %esp,%ebp
  8015af:	53                   	push   %ebx
  8015b0:	83 ec 14             	sub    $0x14,%esp
  8015b3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015b6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015b9:	50                   	push   %eax
  8015ba:	ff 75 08             	pushl  0x8(%ebp)
  8015bd:	e8 6c fb ff ff       	call   80112e <fd_lookup>
  8015c2:	83 c4 08             	add    $0x8,%esp
  8015c5:	89 c2                	mov    %eax,%edx
  8015c7:	85 c0                	test   %eax,%eax
  8015c9:	78 58                	js     801623 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015cb:	83 ec 08             	sub    $0x8,%esp
  8015ce:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015d1:	50                   	push   %eax
  8015d2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015d5:	ff 30                	pushl  (%eax)
  8015d7:	e8 a8 fb ff ff       	call   801184 <dev_lookup>
  8015dc:	83 c4 10             	add    $0x10,%esp
  8015df:	85 c0                	test   %eax,%eax
  8015e1:	78 37                	js     80161a <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8015e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015e6:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8015ea:	74 32                	je     80161e <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8015ec:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8015ef:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8015f6:	00 00 00 
	stat->st_isdir = 0;
  8015f9:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801600:	00 00 00 
	stat->st_dev = dev;
  801603:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801609:	83 ec 08             	sub    $0x8,%esp
  80160c:	53                   	push   %ebx
  80160d:	ff 75 f0             	pushl  -0x10(%ebp)
  801610:	ff 50 14             	call   *0x14(%eax)
  801613:	89 c2                	mov    %eax,%edx
  801615:	83 c4 10             	add    $0x10,%esp
  801618:	eb 09                	jmp    801623 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80161a:	89 c2                	mov    %eax,%edx
  80161c:	eb 05                	jmp    801623 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80161e:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801623:	89 d0                	mov    %edx,%eax
  801625:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801628:	c9                   	leave  
  801629:	c3                   	ret    

0080162a <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80162a:	55                   	push   %ebp
  80162b:	89 e5                	mov    %esp,%ebp
  80162d:	56                   	push   %esi
  80162e:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80162f:	83 ec 08             	sub    $0x8,%esp
  801632:	6a 00                	push   $0x0
  801634:	ff 75 08             	pushl  0x8(%ebp)
  801637:	e8 d6 01 00 00       	call   801812 <open>
  80163c:	89 c3                	mov    %eax,%ebx
  80163e:	83 c4 10             	add    $0x10,%esp
  801641:	85 c0                	test   %eax,%eax
  801643:	78 1b                	js     801660 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801645:	83 ec 08             	sub    $0x8,%esp
  801648:	ff 75 0c             	pushl  0xc(%ebp)
  80164b:	50                   	push   %eax
  80164c:	e8 5b ff ff ff       	call   8015ac <fstat>
  801651:	89 c6                	mov    %eax,%esi
	close(fd);
  801653:	89 1c 24             	mov    %ebx,(%esp)
  801656:	e8 fd fb ff ff       	call   801258 <close>
	return r;
  80165b:	83 c4 10             	add    $0x10,%esp
  80165e:	89 f0                	mov    %esi,%eax
}
  801660:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801663:	5b                   	pop    %ebx
  801664:	5e                   	pop    %esi
  801665:	5d                   	pop    %ebp
  801666:	c3                   	ret    

00801667 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801667:	55                   	push   %ebp
  801668:	89 e5                	mov    %esp,%ebp
  80166a:	56                   	push   %esi
  80166b:	53                   	push   %ebx
  80166c:	89 c6                	mov    %eax,%esi
  80166e:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801670:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801677:	75 12                	jne    80168b <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801679:	83 ec 0c             	sub    $0xc,%esp
  80167c:	6a 01                	push   $0x1
  80167e:	e8 fc f9 ff ff       	call   80107f <ipc_find_env>
  801683:	a3 00 40 80 00       	mov    %eax,0x804000
  801688:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80168b:	6a 07                	push   $0x7
  80168d:	68 00 50 80 00       	push   $0x805000
  801692:	56                   	push   %esi
  801693:	ff 35 00 40 80 00    	pushl  0x804000
  801699:	e8 8d f9 ff ff       	call   80102b <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80169e:	83 c4 0c             	add    $0xc,%esp
  8016a1:	6a 00                	push   $0x0
  8016a3:	53                   	push   %ebx
  8016a4:	6a 00                	push   $0x0
  8016a6:	e8 19 f9 ff ff       	call   800fc4 <ipc_recv>
}
  8016ab:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016ae:	5b                   	pop    %ebx
  8016af:	5e                   	pop    %esi
  8016b0:	5d                   	pop    %ebp
  8016b1:	c3                   	ret    

008016b2 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8016b2:	55                   	push   %ebp
  8016b3:	89 e5                	mov    %esp,%ebp
  8016b5:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8016b8:	8b 45 08             	mov    0x8(%ebp),%eax
  8016bb:	8b 40 0c             	mov    0xc(%eax),%eax
  8016be:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8016c3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8016c6:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8016cb:	ba 00 00 00 00       	mov    $0x0,%edx
  8016d0:	b8 02 00 00 00       	mov    $0x2,%eax
  8016d5:	e8 8d ff ff ff       	call   801667 <fsipc>
}
  8016da:	c9                   	leave  
  8016db:	c3                   	ret    

008016dc <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8016dc:	55                   	push   %ebp
  8016dd:	89 e5                	mov    %esp,%ebp
  8016df:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8016e2:	8b 45 08             	mov    0x8(%ebp),%eax
  8016e5:	8b 40 0c             	mov    0xc(%eax),%eax
  8016e8:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8016ed:	ba 00 00 00 00       	mov    $0x0,%edx
  8016f2:	b8 06 00 00 00       	mov    $0x6,%eax
  8016f7:	e8 6b ff ff ff       	call   801667 <fsipc>
}
  8016fc:	c9                   	leave  
  8016fd:	c3                   	ret    

008016fe <devfile_stat>:

}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8016fe:	55                   	push   %ebp
  8016ff:	89 e5                	mov    %esp,%ebp
  801701:	53                   	push   %ebx
  801702:	83 ec 04             	sub    $0x4,%esp
  801705:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801708:	8b 45 08             	mov    0x8(%ebp),%eax
  80170b:	8b 40 0c             	mov    0xc(%eax),%eax
  80170e:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801713:	ba 00 00 00 00       	mov    $0x0,%edx
  801718:	b8 05 00 00 00       	mov    $0x5,%eax
  80171d:	e8 45 ff ff ff       	call   801667 <fsipc>
  801722:	85 c0                	test   %eax,%eax
  801724:	78 2c                	js     801752 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801726:	83 ec 08             	sub    $0x8,%esp
  801729:	68 00 50 80 00       	push   $0x805000
  80172e:	53                   	push   %ebx
  80172f:	e8 42 f0 ff ff       	call   800776 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801734:	a1 80 50 80 00       	mov    0x805080,%eax
  801739:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80173f:	a1 84 50 80 00       	mov    0x805084,%eax
  801744:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80174a:	83 c4 10             	add    $0x10,%esp
  80174d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801752:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801755:	c9                   	leave  
  801756:	c3                   	ret    

00801757 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801757:	55                   	push   %ebp
  801758:	89 e5                	mov    %esp,%ebp
  80175a:	83 ec 0c             	sub    $0xc,%esp
  80175d:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	// panic("devfile_write not implemented");

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801760:	8b 55 08             	mov    0x8(%ebp),%edx
  801763:	8b 52 0c             	mov    0xc(%edx),%edx
  801766:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  80176c:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  801771:	50                   	push   %eax
  801772:	ff 75 0c             	pushl  0xc(%ebp)
  801775:	68 08 50 80 00       	push   $0x805008
  80177a:	e8 89 f1 ff ff       	call   800908 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  80177f:	ba 00 00 00 00       	mov    $0x0,%edx
  801784:	b8 04 00 00 00       	mov    $0x4,%eax
  801789:	e8 d9 fe ff ff       	call   801667 <fsipc>

}
  80178e:	c9                   	leave  
  80178f:	c3                   	ret    

00801790 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801790:	55                   	push   %ebp
  801791:	89 e5                	mov    %esp,%ebp
  801793:	56                   	push   %esi
  801794:	53                   	push   %ebx
  801795:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801798:	8b 45 08             	mov    0x8(%ebp),%eax
  80179b:	8b 40 0c             	mov    0xc(%eax),%eax
  80179e:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8017a3:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8017a9:	ba 00 00 00 00       	mov    $0x0,%edx
  8017ae:	b8 03 00 00 00       	mov    $0x3,%eax
  8017b3:	e8 af fe ff ff       	call   801667 <fsipc>
  8017b8:	89 c3                	mov    %eax,%ebx
  8017ba:	85 c0                	test   %eax,%eax
  8017bc:	78 4b                	js     801809 <devfile_read+0x79>
		return r;
	assert(r <= n);
  8017be:	39 c6                	cmp    %eax,%esi
  8017c0:	73 16                	jae    8017d8 <devfile_read+0x48>
  8017c2:	68 04 26 80 00       	push   $0x802604
  8017c7:	68 0b 26 80 00       	push   $0x80260b
  8017cc:	6a 7c                	push   $0x7c
  8017ce:	68 20 26 80 00       	push   $0x802620
  8017d3:	e8 bd 05 00 00       	call   801d95 <_panic>
	assert(r <= PGSIZE);
  8017d8:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8017dd:	7e 16                	jle    8017f5 <devfile_read+0x65>
  8017df:	68 2b 26 80 00       	push   $0x80262b
  8017e4:	68 0b 26 80 00       	push   $0x80260b
  8017e9:	6a 7d                	push   $0x7d
  8017eb:	68 20 26 80 00       	push   $0x802620
  8017f0:	e8 a0 05 00 00       	call   801d95 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8017f5:	83 ec 04             	sub    $0x4,%esp
  8017f8:	50                   	push   %eax
  8017f9:	68 00 50 80 00       	push   $0x805000
  8017fe:	ff 75 0c             	pushl  0xc(%ebp)
  801801:	e8 02 f1 ff ff       	call   800908 <memmove>
	return r;
  801806:	83 c4 10             	add    $0x10,%esp
}
  801809:	89 d8                	mov    %ebx,%eax
  80180b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80180e:	5b                   	pop    %ebx
  80180f:	5e                   	pop    %esi
  801810:	5d                   	pop    %ebp
  801811:	c3                   	ret    

00801812 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801812:	55                   	push   %ebp
  801813:	89 e5                	mov    %esp,%ebp
  801815:	53                   	push   %ebx
  801816:	83 ec 20             	sub    $0x20,%esp
  801819:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  80181c:	53                   	push   %ebx
  80181d:	e8 1b ef ff ff       	call   80073d <strlen>
  801822:	83 c4 10             	add    $0x10,%esp
  801825:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80182a:	7f 67                	jg     801893 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80182c:	83 ec 0c             	sub    $0xc,%esp
  80182f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801832:	50                   	push   %eax
  801833:	e8 a7 f8 ff ff       	call   8010df <fd_alloc>
  801838:	83 c4 10             	add    $0x10,%esp
		return r;
  80183b:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80183d:	85 c0                	test   %eax,%eax
  80183f:	78 57                	js     801898 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801841:	83 ec 08             	sub    $0x8,%esp
  801844:	53                   	push   %ebx
  801845:	68 00 50 80 00       	push   $0x805000
  80184a:	e8 27 ef ff ff       	call   800776 <strcpy>
	fsipcbuf.open.req_omode = mode;
  80184f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801852:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801857:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80185a:	b8 01 00 00 00       	mov    $0x1,%eax
  80185f:	e8 03 fe ff ff       	call   801667 <fsipc>
  801864:	89 c3                	mov    %eax,%ebx
  801866:	83 c4 10             	add    $0x10,%esp
  801869:	85 c0                	test   %eax,%eax
  80186b:	79 14                	jns    801881 <open+0x6f>
		fd_close(fd, 0);
  80186d:	83 ec 08             	sub    $0x8,%esp
  801870:	6a 00                	push   $0x0
  801872:	ff 75 f4             	pushl  -0xc(%ebp)
  801875:	e8 5d f9 ff ff       	call   8011d7 <fd_close>
		return r;
  80187a:	83 c4 10             	add    $0x10,%esp
  80187d:	89 da                	mov    %ebx,%edx
  80187f:	eb 17                	jmp    801898 <open+0x86>
	}

	return fd2num(fd);
  801881:	83 ec 0c             	sub    $0xc,%esp
  801884:	ff 75 f4             	pushl  -0xc(%ebp)
  801887:	e8 2c f8 ff ff       	call   8010b8 <fd2num>
  80188c:	89 c2                	mov    %eax,%edx
  80188e:	83 c4 10             	add    $0x10,%esp
  801891:	eb 05                	jmp    801898 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801893:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801898:	89 d0                	mov    %edx,%eax
  80189a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80189d:	c9                   	leave  
  80189e:	c3                   	ret    

0080189f <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80189f:	55                   	push   %ebp
  8018a0:	89 e5                	mov    %esp,%ebp
  8018a2:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8018a5:	ba 00 00 00 00       	mov    $0x0,%edx
  8018aa:	b8 08 00 00 00       	mov    $0x8,%eax
  8018af:	e8 b3 fd ff ff       	call   801667 <fsipc>
}
  8018b4:	c9                   	leave  
  8018b5:	c3                   	ret    

008018b6 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8018b6:	55                   	push   %ebp
  8018b7:	89 e5                	mov    %esp,%ebp
  8018b9:	56                   	push   %esi
  8018ba:	53                   	push   %ebx
  8018bb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8018be:	83 ec 0c             	sub    $0xc,%esp
  8018c1:	ff 75 08             	pushl  0x8(%ebp)
  8018c4:	e8 ff f7 ff ff       	call   8010c8 <fd2data>
  8018c9:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8018cb:	83 c4 08             	add    $0x8,%esp
  8018ce:	68 37 26 80 00       	push   $0x802637
  8018d3:	53                   	push   %ebx
  8018d4:	e8 9d ee ff ff       	call   800776 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8018d9:	8b 46 04             	mov    0x4(%esi),%eax
  8018dc:	2b 06                	sub    (%esi),%eax
  8018de:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8018e4:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8018eb:	00 00 00 
	stat->st_dev = &devpipe;
  8018ee:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  8018f5:	30 80 00 
	return 0;
}
  8018f8:	b8 00 00 00 00       	mov    $0x0,%eax
  8018fd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801900:	5b                   	pop    %ebx
  801901:	5e                   	pop    %esi
  801902:	5d                   	pop    %ebp
  801903:	c3                   	ret    

00801904 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801904:	55                   	push   %ebp
  801905:	89 e5                	mov    %esp,%ebp
  801907:	53                   	push   %ebx
  801908:	83 ec 0c             	sub    $0xc,%esp
  80190b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  80190e:	53                   	push   %ebx
  80190f:	6a 00                	push   $0x0
  801911:	e8 e8 f2 ff ff       	call   800bfe <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801916:	89 1c 24             	mov    %ebx,(%esp)
  801919:	e8 aa f7 ff ff       	call   8010c8 <fd2data>
  80191e:	83 c4 08             	add    $0x8,%esp
  801921:	50                   	push   %eax
  801922:	6a 00                	push   $0x0
  801924:	e8 d5 f2 ff ff       	call   800bfe <sys_page_unmap>
}
  801929:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80192c:	c9                   	leave  
  80192d:	c3                   	ret    

0080192e <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  80192e:	55                   	push   %ebp
  80192f:	89 e5                	mov    %esp,%ebp
  801931:	57                   	push   %edi
  801932:	56                   	push   %esi
  801933:	53                   	push   %ebx
  801934:	83 ec 1c             	sub    $0x1c,%esp
  801937:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80193a:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  80193c:	a1 08 40 80 00       	mov    0x804008,%eax
  801941:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801944:	83 ec 0c             	sub    $0xc,%esp
  801947:	ff 75 e0             	pushl  -0x20(%ebp)
  80194a:	e8 f7 04 00 00       	call   801e46 <pageref>
  80194f:	89 c3                	mov    %eax,%ebx
  801951:	89 3c 24             	mov    %edi,(%esp)
  801954:	e8 ed 04 00 00       	call   801e46 <pageref>
  801959:	83 c4 10             	add    $0x10,%esp
  80195c:	39 c3                	cmp    %eax,%ebx
  80195e:	0f 94 c1             	sete   %cl
  801961:	0f b6 c9             	movzbl %cl,%ecx
  801964:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801967:	8b 15 08 40 80 00    	mov    0x804008,%edx
  80196d:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801970:	39 ce                	cmp    %ecx,%esi
  801972:	74 1b                	je     80198f <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801974:	39 c3                	cmp    %eax,%ebx
  801976:	75 c4                	jne    80193c <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801978:	8b 42 58             	mov    0x58(%edx),%eax
  80197b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80197e:	50                   	push   %eax
  80197f:	56                   	push   %esi
  801980:	68 3e 26 80 00       	push   $0x80263e
  801985:	e8 67 e8 ff ff       	call   8001f1 <cprintf>
  80198a:	83 c4 10             	add    $0x10,%esp
  80198d:	eb ad                	jmp    80193c <_pipeisclosed+0xe>
	}
}
  80198f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801992:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801995:	5b                   	pop    %ebx
  801996:	5e                   	pop    %esi
  801997:	5f                   	pop    %edi
  801998:	5d                   	pop    %ebp
  801999:	c3                   	ret    

0080199a <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80199a:	55                   	push   %ebp
  80199b:	89 e5                	mov    %esp,%ebp
  80199d:	57                   	push   %edi
  80199e:	56                   	push   %esi
  80199f:	53                   	push   %ebx
  8019a0:	83 ec 28             	sub    $0x28,%esp
  8019a3:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8019a6:	56                   	push   %esi
  8019a7:	e8 1c f7 ff ff       	call   8010c8 <fd2data>
  8019ac:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8019ae:	83 c4 10             	add    $0x10,%esp
  8019b1:	bf 00 00 00 00       	mov    $0x0,%edi
  8019b6:	eb 4b                	jmp    801a03 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8019b8:	89 da                	mov    %ebx,%edx
  8019ba:	89 f0                	mov    %esi,%eax
  8019bc:	e8 6d ff ff ff       	call   80192e <_pipeisclosed>
  8019c1:	85 c0                	test   %eax,%eax
  8019c3:	75 48                	jne    801a0d <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8019c5:	e8 90 f1 ff ff       	call   800b5a <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8019ca:	8b 43 04             	mov    0x4(%ebx),%eax
  8019cd:	8b 0b                	mov    (%ebx),%ecx
  8019cf:	8d 51 20             	lea    0x20(%ecx),%edx
  8019d2:	39 d0                	cmp    %edx,%eax
  8019d4:	73 e2                	jae    8019b8 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8019d6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8019d9:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  8019dd:	88 4d e7             	mov    %cl,-0x19(%ebp)
  8019e0:	89 c2                	mov    %eax,%edx
  8019e2:	c1 fa 1f             	sar    $0x1f,%edx
  8019e5:	89 d1                	mov    %edx,%ecx
  8019e7:	c1 e9 1b             	shr    $0x1b,%ecx
  8019ea:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  8019ed:	83 e2 1f             	and    $0x1f,%edx
  8019f0:	29 ca                	sub    %ecx,%edx
  8019f2:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  8019f6:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8019fa:	83 c0 01             	add    $0x1,%eax
  8019fd:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a00:	83 c7 01             	add    $0x1,%edi
  801a03:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801a06:	75 c2                	jne    8019ca <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801a08:	8b 45 10             	mov    0x10(%ebp),%eax
  801a0b:	eb 05                	jmp    801a12 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801a0d:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801a12:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a15:	5b                   	pop    %ebx
  801a16:	5e                   	pop    %esi
  801a17:	5f                   	pop    %edi
  801a18:	5d                   	pop    %ebp
  801a19:	c3                   	ret    

00801a1a <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801a1a:	55                   	push   %ebp
  801a1b:	89 e5                	mov    %esp,%ebp
  801a1d:	57                   	push   %edi
  801a1e:	56                   	push   %esi
  801a1f:	53                   	push   %ebx
  801a20:	83 ec 18             	sub    $0x18,%esp
  801a23:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801a26:	57                   	push   %edi
  801a27:	e8 9c f6 ff ff       	call   8010c8 <fd2data>
  801a2c:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a2e:	83 c4 10             	add    $0x10,%esp
  801a31:	bb 00 00 00 00       	mov    $0x0,%ebx
  801a36:	eb 3d                	jmp    801a75 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801a38:	85 db                	test   %ebx,%ebx
  801a3a:	74 04                	je     801a40 <devpipe_read+0x26>
				return i;
  801a3c:	89 d8                	mov    %ebx,%eax
  801a3e:	eb 44                	jmp    801a84 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801a40:	89 f2                	mov    %esi,%edx
  801a42:	89 f8                	mov    %edi,%eax
  801a44:	e8 e5 fe ff ff       	call   80192e <_pipeisclosed>
  801a49:	85 c0                	test   %eax,%eax
  801a4b:	75 32                	jne    801a7f <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801a4d:	e8 08 f1 ff ff       	call   800b5a <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801a52:	8b 06                	mov    (%esi),%eax
  801a54:	3b 46 04             	cmp    0x4(%esi),%eax
  801a57:	74 df                	je     801a38 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801a59:	99                   	cltd   
  801a5a:	c1 ea 1b             	shr    $0x1b,%edx
  801a5d:	01 d0                	add    %edx,%eax
  801a5f:	83 e0 1f             	and    $0x1f,%eax
  801a62:	29 d0                	sub    %edx,%eax
  801a64:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801a69:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a6c:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801a6f:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a72:	83 c3 01             	add    $0x1,%ebx
  801a75:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801a78:	75 d8                	jne    801a52 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801a7a:	8b 45 10             	mov    0x10(%ebp),%eax
  801a7d:	eb 05                	jmp    801a84 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801a7f:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801a84:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a87:	5b                   	pop    %ebx
  801a88:	5e                   	pop    %esi
  801a89:	5f                   	pop    %edi
  801a8a:	5d                   	pop    %ebp
  801a8b:	c3                   	ret    

00801a8c <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801a8c:	55                   	push   %ebp
  801a8d:	89 e5                	mov    %esp,%ebp
  801a8f:	56                   	push   %esi
  801a90:	53                   	push   %ebx
  801a91:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801a94:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a97:	50                   	push   %eax
  801a98:	e8 42 f6 ff ff       	call   8010df <fd_alloc>
  801a9d:	83 c4 10             	add    $0x10,%esp
  801aa0:	89 c2                	mov    %eax,%edx
  801aa2:	85 c0                	test   %eax,%eax
  801aa4:	0f 88 2c 01 00 00    	js     801bd6 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801aaa:	83 ec 04             	sub    $0x4,%esp
  801aad:	68 07 04 00 00       	push   $0x407
  801ab2:	ff 75 f4             	pushl  -0xc(%ebp)
  801ab5:	6a 00                	push   $0x0
  801ab7:	e8 bd f0 ff ff       	call   800b79 <sys_page_alloc>
  801abc:	83 c4 10             	add    $0x10,%esp
  801abf:	89 c2                	mov    %eax,%edx
  801ac1:	85 c0                	test   %eax,%eax
  801ac3:	0f 88 0d 01 00 00    	js     801bd6 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801ac9:	83 ec 0c             	sub    $0xc,%esp
  801acc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801acf:	50                   	push   %eax
  801ad0:	e8 0a f6 ff ff       	call   8010df <fd_alloc>
  801ad5:	89 c3                	mov    %eax,%ebx
  801ad7:	83 c4 10             	add    $0x10,%esp
  801ada:	85 c0                	test   %eax,%eax
  801adc:	0f 88 e2 00 00 00    	js     801bc4 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ae2:	83 ec 04             	sub    $0x4,%esp
  801ae5:	68 07 04 00 00       	push   $0x407
  801aea:	ff 75 f0             	pushl  -0x10(%ebp)
  801aed:	6a 00                	push   $0x0
  801aef:	e8 85 f0 ff ff       	call   800b79 <sys_page_alloc>
  801af4:	89 c3                	mov    %eax,%ebx
  801af6:	83 c4 10             	add    $0x10,%esp
  801af9:	85 c0                	test   %eax,%eax
  801afb:	0f 88 c3 00 00 00    	js     801bc4 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801b01:	83 ec 0c             	sub    $0xc,%esp
  801b04:	ff 75 f4             	pushl  -0xc(%ebp)
  801b07:	e8 bc f5 ff ff       	call   8010c8 <fd2data>
  801b0c:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b0e:	83 c4 0c             	add    $0xc,%esp
  801b11:	68 07 04 00 00       	push   $0x407
  801b16:	50                   	push   %eax
  801b17:	6a 00                	push   $0x0
  801b19:	e8 5b f0 ff ff       	call   800b79 <sys_page_alloc>
  801b1e:	89 c3                	mov    %eax,%ebx
  801b20:	83 c4 10             	add    $0x10,%esp
  801b23:	85 c0                	test   %eax,%eax
  801b25:	0f 88 89 00 00 00    	js     801bb4 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b2b:	83 ec 0c             	sub    $0xc,%esp
  801b2e:	ff 75 f0             	pushl  -0x10(%ebp)
  801b31:	e8 92 f5 ff ff       	call   8010c8 <fd2data>
  801b36:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801b3d:	50                   	push   %eax
  801b3e:	6a 00                	push   $0x0
  801b40:	56                   	push   %esi
  801b41:	6a 00                	push   $0x0
  801b43:	e8 74 f0 ff ff       	call   800bbc <sys_page_map>
  801b48:	89 c3                	mov    %eax,%ebx
  801b4a:	83 c4 20             	add    $0x20,%esp
  801b4d:	85 c0                	test   %eax,%eax
  801b4f:	78 55                	js     801ba6 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801b51:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801b57:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b5a:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801b5c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b5f:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801b66:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801b6c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b6f:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801b71:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b74:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801b7b:	83 ec 0c             	sub    $0xc,%esp
  801b7e:	ff 75 f4             	pushl  -0xc(%ebp)
  801b81:	e8 32 f5 ff ff       	call   8010b8 <fd2num>
  801b86:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b89:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801b8b:	83 c4 04             	add    $0x4,%esp
  801b8e:	ff 75 f0             	pushl  -0x10(%ebp)
  801b91:	e8 22 f5 ff ff       	call   8010b8 <fd2num>
  801b96:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b99:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801b9c:	83 c4 10             	add    $0x10,%esp
  801b9f:	ba 00 00 00 00       	mov    $0x0,%edx
  801ba4:	eb 30                	jmp    801bd6 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801ba6:	83 ec 08             	sub    $0x8,%esp
  801ba9:	56                   	push   %esi
  801baa:	6a 00                	push   $0x0
  801bac:	e8 4d f0 ff ff       	call   800bfe <sys_page_unmap>
  801bb1:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801bb4:	83 ec 08             	sub    $0x8,%esp
  801bb7:	ff 75 f0             	pushl  -0x10(%ebp)
  801bba:	6a 00                	push   $0x0
  801bbc:	e8 3d f0 ff ff       	call   800bfe <sys_page_unmap>
  801bc1:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801bc4:	83 ec 08             	sub    $0x8,%esp
  801bc7:	ff 75 f4             	pushl  -0xc(%ebp)
  801bca:	6a 00                	push   $0x0
  801bcc:	e8 2d f0 ff ff       	call   800bfe <sys_page_unmap>
  801bd1:	83 c4 10             	add    $0x10,%esp
  801bd4:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801bd6:	89 d0                	mov    %edx,%eax
  801bd8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801bdb:	5b                   	pop    %ebx
  801bdc:	5e                   	pop    %esi
  801bdd:	5d                   	pop    %ebp
  801bde:	c3                   	ret    

00801bdf <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801bdf:	55                   	push   %ebp
  801be0:	89 e5                	mov    %esp,%ebp
  801be2:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801be5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801be8:	50                   	push   %eax
  801be9:	ff 75 08             	pushl  0x8(%ebp)
  801bec:	e8 3d f5 ff ff       	call   80112e <fd_lookup>
  801bf1:	83 c4 10             	add    $0x10,%esp
  801bf4:	85 c0                	test   %eax,%eax
  801bf6:	78 18                	js     801c10 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801bf8:	83 ec 0c             	sub    $0xc,%esp
  801bfb:	ff 75 f4             	pushl  -0xc(%ebp)
  801bfe:	e8 c5 f4 ff ff       	call   8010c8 <fd2data>
	return _pipeisclosed(fd, p);
  801c03:	89 c2                	mov    %eax,%edx
  801c05:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c08:	e8 21 fd ff ff       	call   80192e <_pipeisclosed>
  801c0d:	83 c4 10             	add    $0x10,%esp
}
  801c10:	c9                   	leave  
  801c11:	c3                   	ret    

00801c12 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801c12:	55                   	push   %ebp
  801c13:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801c15:	b8 00 00 00 00       	mov    $0x0,%eax
  801c1a:	5d                   	pop    %ebp
  801c1b:	c3                   	ret    

00801c1c <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801c1c:	55                   	push   %ebp
  801c1d:	89 e5                	mov    %esp,%ebp
  801c1f:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801c22:	68 56 26 80 00       	push   $0x802656
  801c27:	ff 75 0c             	pushl  0xc(%ebp)
  801c2a:	e8 47 eb ff ff       	call   800776 <strcpy>
	return 0;
}
  801c2f:	b8 00 00 00 00       	mov    $0x0,%eax
  801c34:	c9                   	leave  
  801c35:	c3                   	ret    

00801c36 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801c36:	55                   	push   %ebp
  801c37:	89 e5                	mov    %esp,%ebp
  801c39:	57                   	push   %edi
  801c3a:	56                   	push   %esi
  801c3b:	53                   	push   %ebx
  801c3c:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801c42:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801c47:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801c4d:	eb 2d                	jmp    801c7c <devcons_write+0x46>
		m = n - tot;
  801c4f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801c52:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801c54:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801c57:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801c5c:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801c5f:	83 ec 04             	sub    $0x4,%esp
  801c62:	53                   	push   %ebx
  801c63:	03 45 0c             	add    0xc(%ebp),%eax
  801c66:	50                   	push   %eax
  801c67:	57                   	push   %edi
  801c68:	e8 9b ec ff ff       	call   800908 <memmove>
		sys_cputs(buf, m);
  801c6d:	83 c4 08             	add    $0x8,%esp
  801c70:	53                   	push   %ebx
  801c71:	57                   	push   %edi
  801c72:	e8 46 ee ff ff       	call   800abd <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801c77:	01 de                	add    %ebx,%esi
  801c79:	83 c4 10             	add    $0x10,%esp
  801c7c:	89 f0                	mov    %esi,%eax
  801c7e:	3b 75 10             	cmp    0x10(%ebp),%esi
  801c81:	72 cc                	jb     801c4f <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801c83:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c86:	5b                   	pop    %ebx
  801c87:	5e                   	pop    %esi
  801c88:	5f                   	pop    %edi
  801c89:	5d                   	pop    %ebp
  801c8a:	c3                   	ret    

00801c8b <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801c8b:	55                   	push   %ebp
  801c8c:	89 e5                	mov    %esp,%ebp
  801c8e:	83 ec 08             	sub    $0x8,%esp
  801c91:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801c96:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801c9a:	74 2a                	je     801cc6 <devcons_read+0x3b>
  801c9c:	eb 05                	jmp    801ca3 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801c9e:	e8 b7 ee ff ff       	call   800b5a <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801ca3:	e8 33 ee ff ff       	call   800adb <sys_cgetc>
  801ca8:	85 c0                	test   %eax,%eax
  801caa:	74 f2                	je     801c9e <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801cac:	85 c0                	test   %eax,%eax
  801cae:	78 16                	js     801cc6 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801cb0:	83 f8 04             	cmp    $0x4,%eax
  801cb3:	74 0c                	je     801cc1 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801cb5:	8b 55 0c             	mov    0xc(%ebp),%edx
  801cb8:	88 02                	mov    %al,(%edx)
	return 1;
  801cba:	b8 01 00 00 00       	mov    $0x1,%eax
  801cbf:	eb 05                	jmp    801cc6 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801cc1:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801cc6:	c9                   	leave  
  801cc7:	c3                   	ret    

00801cc8 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801cc8:	55                   	push   %ebp
  801cc9:	89 e5                	mov    %esp,%ebp
  801ccb:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801cce:	8b 45 08             	mov    0x8(%ebp),%eax
  801cd1:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801cd4:	6a 01                	push   $0x1
  801cd6:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801cd9:	50                   	push   %eax
  801cda:	e8 de ed ff ff       	call   800abd <sys_cputs>
}
  801cdf:	83 c4 10             	add    $0x10,%esp
  801ce2:	c9                   	leave  
  801ce3:	c3                   	ret    

00801ce4 <getchar>:

int
getchar(void)
{
  801ce4:	55                   	push   %ebp
  801ce5:	89 e5                	mov    %esp,%ebp
  801ce7:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801cea:	6a 01                	push   $0x1
  801cec:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801cef:	50                   	push   %eax
  801cf0:	6a 00                	push   $0x0
  801cf2:	e8 9d f6 ff ff       	call   801394 <read>
	if (r < 0)
  801cf7:	83 c4 10             	add    $0x10,%esp
  801cfa:	85 c0                	test   %eax,%eax
  801cfc:	78 0f                	js     801d0d <getchar+0x29>
		return r;
	if (r < 1)
  801cfe:	85 c0                	test   %eax,%eax
  801d00:	7e 06                	jle    801d08 <getchar+0x24>
		return -E_EOF;
	return c;
  801d02:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801d06:	eb 05                	jmp    801d0d <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801d08:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801d0d:	c9                   	leave  
  801d0e:	c3                   	ret    

00801d0f <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801d0f:	55                   	push   %ebp
  801d10:	89 e5                	mov    %esp,%ebp
  801d12:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801d15:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d18:	50                   	push   %eax
  801d19:	ff 75 08             	pushl  0x8(%ebp)
  801d1c:	e8 0d f4 ff ff       	call   80112e <fd_lookup>
  801d21:	83 c4 10             	add    $0x10,%esp
  801d24:	85 c0                	test   %eax,%eax
  801d26:	78 11                	js     801d39 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801d28:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d2b:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801d31:	39 10                	cmp    %edx,(%eax)
  801d33:	0f 94 c0             	sete   %al
  801d36:	0f b6 c0             	movzbl %al,%eax
}
  801d39:	c9                   	leave  
  801d3a:	c3                   	ret    

00801d3b <opencons>:

int
opencons(void)
{
  801d3b:	55                   	push   %ebp
  801d3c:	89 e5                	mov    %esp,%ebp
  801d3e:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801d41:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d44:	50                   	push   %eax
  801d45:	e8 95 f3 ff ff       	call   8010df <fd_alloc>
  801d4a:	83 c4 10             	add    $0x10,%esp
		return r;
  801d4d:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801d4f:	85 c0                	test   %eax,%eax
  801d51:	78 3e                	js     801d91 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801d53:	83 ec 04             	sub    $0x4,%esp
  801d56:	68 07 04 00 00       	push   $0x407
  801d5b:	ff 75 f4             	pushl  -0xc(%ebp)
  801d5e:	6a 00                	push   $0x0
  801d60:	e8 14 ee ff ff       	call   800b79 <sys_page_alloc>
  801d65:	83 c4 10             	add    $0x10,%esp
		return r;
  801d68:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801d6a:	85 c0                	test   %eax,%eax
  801d6c:	78 23                	js     801d91 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801d6e:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801d74:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d77:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801d79:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d7c:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801d83:	83 ec 0c             	sub    $0xc,%esp
  801d86:	50                   	push   %eax
  801d87:	e8 2c f3 ff ff       	call   8010b8 <fd2num>
  801d8c:	89 c2                	mov    %eax,%edx
  801d8e:	83 c4 10             	add    $0x10,%esp
}
  801d91:	89 d0                	mov    %edx,%eax
  801d93:	c9                   	leave  
  801d94:	c3                   	ret    

00801d95 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801d95:	55                   	push   %ebp
  801d96:	89 e5                	mov    %esp,%ebp
  801d98:	56                   	push   %esi
  801d99:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801d9a:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801d9d:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801da3:	e8 93 ed ff ff       	call   800b3b <sys_getenvid>
  801da8:	83 ec 0c             	sub    $0xc,%esp
  801dab:	ff 75 0c             	pushl  0xc(%ebp)
  801dae:	ff 75 08             	pushl  0x8(%ebp)
  801db1:	56                   	push   %esi
  801db2:	50                   	push   %eax
  801db3:	68 64 26 80 00       	push   $0x802664
  801db8:	e8 34 e4 ff ff       	call   8001f1 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801dbd:	83 c4 18             	add    $0x18,%esp
  801dc0:	53                   	push   %ebx
  801dc1:	ff 75 10             	pushl  0x10(%ebp)
  801dc4:	e8 d7 e3 ff ff       	call   8001a0 <vcprintf>
	cprintf("\n");
  801dc9:	c7 04 24 4f 26 80 00 	movl   $0x80264f,(%esp)
  801dd0:	e8 1c e4 ff ff       	call   8001f1 <cprintf>
  801dd5:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801dd8:	cc                   	int3   
  801dd9:	eb fd                	jmp    801dd8 <_panic+0x43>

00801ddb <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801ddb:	55                   	push   %ebp
  801ddc:	89 e5                	mov    %esp,%ebp
  801dde:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801de1:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801de8:	75 2e                	jne    801e18 <set_pgfault_handler+0x3d>
		// First time through!
		// LAB 4: Your code here.
		// panic("set_pgfault_handler not implemented");

		sys_page_alloc(sys_getenvid(), (void *) (UXSTACKTOP - PGSIZE), PTE_SYSCALL);
  801dea:	e8 4c ed ff ff       	call   800b3b <sys_getenvid>
  801def:	83 ec 04             	sub    $0x4,%esp
  801df2:	68 07 0e 00 00       	push   $0xe07
  801df7:	68 00 f0 bf ee       	push   $0xeebff000
  801dfc:	50                   	push   %eax
  801dfd:	e8 77 ed ff ff       	call   800b79 <sys_page_alloc>
		sys_env_set_pgfault_upcall(sys_getenvid(), _pgfault_upcall);
  801e02:	e8 34 ed ff ff       	call   800b3b <sys_getenvid>
  801e07:	83 c4 08             	add    $0x8,%esp
  801e0a:	68 22 1e 80 00       	push   $0x801e22
  801e0f:	50                   	push   %eax
  801e10:	e8 af ee ff ff       	call   800cc4 <sys_env_set_pgfault_upcall>
  801e15:	83 c4 10             	add    $0x10,%esp
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801e18:	8b 45 08             	mov    0x8(%ebp),%eax
  801e1b:	a3 00 60 80 00       	mov    %eax,0x806000
}
  801e20:	c9                   	leave  
  801e21:	c3                   	ret    

00801e22 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801e22:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801e23:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801e28:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801e2a:	83 c4 04             	add    $0x4,%esp
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.

	movl 48(%esp), %eax		// trap-time esp
  801e2d:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl 40(%esp), %ebx		// trap-time eip
  801e31:	8b 5c 24 28          	mov    0x28(%esp),%ebx

	// load eip into esp-4
	// in order to return to trap-time eip later, in the meantime not changing trap-time esp
	movl %ebx, -4(%eax)	
  801e35:	89 58 fc             	mov    %ebx,-0x4(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.

	addl $8, %esp 			// esp now points to trap-time registers
  801e38:	83 c4 08             	add    $0x8,%esp
	popal					// pop to all registers
  801e3b:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

	addl $4, %esp			// esp now points to trap-time eflags
  801e3c:	83 c4 04             	add    $0x4,%esp
	popfl					// pop to eflags
  801e3f:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.

	popl %esp				// pop to esp
  801e40:	5c                   	pop    %esp
	// subl $4, %esp		// arithmetic operation will change eflags!!!
	lea -4(%esp), %esp		// subl $4, %esp
  801e41:	8d 64 24 fc          	lea    -0x4(%esp),%esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.

	ret
  801e45:	c3                   	ret    

00801e46 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801e46:	55                   	push   %ebp
  801e47:	89 e5                	mov    %esp,%ebp
  801e49:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801e4c:	89 d0                	mov    %edx,%eax
  801e4e:	c1 e8 16             	shr    $0x16,%eax
  801e51:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801e58:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801e5d:	f6 c1 01             	test   $0x1,%cl
  801e60:	74 1d                	je     801e7f <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801e62:	c1 ea 0c             	shr    $0xc,%edx
  801e65:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801e6c:	f6 c2 01             	test   $0x1,%dl
  801e6f:	74 0e                	je     801e7f <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801e71:	c1 ea 0c             	shr    $0xc,%edx
  801e74:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801e7b:	ef 
  801e7c:	0f b7 c0             	movzwl %ax,%eax
}
  801e7f:	5d                   	pop    %ebp
  801e80:	c3                   	ret    
  801e81:	66 90                	xchg   %ax,%ax
  801e83:	66 90                	xchg   %ax,%ax
  801e85:	66 90                	xchg   %ax,%ax
  801e87:	66 90                	xchg   %ax,%ax
  801e89:	66 90                	xchg   %ax,%ax
  801e8b:	66 90                	xchg   %ax,%ax
  801e8d:	66 90                	xchg   %ax,%ax
  801e8f:	90                   	nop

00801e90 <__udivdi3>:
  801e90:	55                   	push   %ebp
  801e91:	57                   	push   %edi
  801e92:	56                   	push   %esi
  801e93:	53                   	push   %ebx
  801e94:	83 ec 1c             	sub    $0x1c,%esp
  801e97:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801e9b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801e9f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801ea3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801ea7:	85 f6                	test   %esi,%esi
  801ea9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801ead:	89 ca                	mov    %ecx,%edx
  801eaf:	89 f8                	mov    %edi,%eax
  801eb1:	75 3d                	jne    801ef0 <__udivdi3+0x60>
  801eb3:	39 cf                	cmp    %ecx,%edi
  801eb5:	0f 87 c5 00 00 00    	ja     801f80 <__udivdi3+0xf0>
  801ebb:	85 ff                	test   %edi,%edi
  801ebd:	89 fd                	mov    %edi,%ebp
  801ebf:	75 0b                	jne    801ecc <__udivdi3+0x3c>
  801ec1:	b8 01 00 00 00       	mov    $0x1,%eax
  801ec6:	31 d2                	xor    %edx,%edx
  801ec8:	f7 f7                	div    %edi
  801eca:	89 c5                	mov    %eax,%ebp
  801ecc:	89 c8                	mov    %ecx,%eax
  801ece:	31 d2                	xor    %edx,%edx
  801ed0:	f7 f5                	div    %ebp
  801ed2:	89 c1                	mov    %eax,%ecx
  801ed4:	89 d8                	mov    %ebx,%eax
  801ed6:	89 cf                	mov    %ecx,%edi
  801ed8:	f7 f5                	div    %ebp
  801eda:	89 c3                	mov    %eax,%ebx
  801edc:	89 d8                	mov    %ebx,%eax
  801ede:	89 fa                	mov    %edi,%edx
  801ee0:	83 c4 1c             	add    $0x1c,%esp
  801ee3:	5b                   	pop    %ebx
  801ee4:	5e                   	pop    %esi
  801ee5:	5f                   	pop    %edi
  801ee6:	5d                   	pop    %ebp
  801ee7:	c3                   	ret    
  801ee8:	90                   	nop
  801ee9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801ef0:	39 ce                	cmp    %ecx,%esi
  801ef2:	77 74                	ja     801f68 <__udivdi3+0xd8>
  801ef4:	0f bd fe             	bsr    %esi,%edi
  801ef7:	83 f7 1f             	xor    $0x1f,%edi
  801efa:	0f 84 98 00 00 00    	je     801f98 <__udivdi3+0x108>
  801f00:	bb 20 00 00 00       	mov    $0x20,%ebx
  801f05:	89 f9                	mov    %edi,%ecx
  801f07:	89 c5                	mov    %eax,%ebp
  801f09:	29 fb                	sub    %edi,%ebx
  801f0b:	d3 e6                	shl    %cl,%esi
  801f0d:	89 d9                	mov    %ebx,%ecx
  801f0f:	d3 ed                	shr    %cl,%ebp
  801f11:	89 f9                	mov    %edi,%ecx
  801f13:	d3 e0                	shl    %cl,%eax
  801f15:	09 ee                	or     %ebp,%esi
  801f17:	89 d9                	mov    %ebx,%ecx
  801f19:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801f1d:	89 d5                	mov    %edx,%ebp
  801f1f:	8b 44 24 08          	mov    0x8(%esp),%eax
  801f23:	d3 ed                	shr    %cl,%ebp
  801f25:	89 f9                	mov    %edi,%ecx
  801f27:	d3 e2                	shl    %cl,%edx
  801f29:	89 d9                	mov    %ebx,%ecx
  801f2b:	d3 e8                	shr    %cl,%eax
  801f2d:	09 c2                	or     %eax,%edx
  801f2f:	89 d0                	mov    %edx,%eax
  801f31:	89 ea                	mov    %ebp,%edx
  801f33:	f7 f6                	div    %esi
  801f35:	89 d5                	mov    %edx,%ebp
  801f37:	89 c3                	mov    %eax,%ebx
  801f39:	f7 64 24 0c          	mull   0xc(%esp)
  801f3d:	39 d5                	cmp    %edx,%ebp
  801f3f:	72 10                	jb     801f51 <__udivdi3+0xc1>
  801f41:	8b 74 24 08          	mov    0x8(%esp),%esi
  801f45:	89 f9                	mov    %edi,%ecx
  801f47:	d3 e6                	shl    %cl,%esi
  801f49:	39 c6                	cmp    %eax,%esi
  801f4b:	73 07                	jae    801f54 <__udivdi3+0xc4>
  801f4d:	39 d5                	cmp    %edx,%ebp
  801f4f:	75 03                	jne    801f54 <__udivdi3+0xc4>
  801f51:	83 eb 01             	sub    $0x1,%ebx
  801f54:	31 ff                	xor    %edi,%edi
  801f56:	89 d8                	mov    %ebx,%eax
  801f58:	89 fa                	mov    %edi,%edx
  801f5a:	83 c4 1c             	add    $0x1c,%esp
  801f5d:	5b                   	pop    %ebx
  801f5e:	5e                   	pop    %esi
  801f5f:	5f                   	pop    %edi
  801f60:	5d                   	pop    %ebp
  801f61:	c3                   	ret    
  801f62:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801f68:	31 ff                	xor    %edi,%edi
  801f6a:	31 db                	xor    %ebx,%ebx
  801f6c:	89 d8                	mov    %ebx,%eax
  801f6e:	89 fa                	mov    %edi,%edx
  801f70:	83 c4 1c             	add    $0x1c,%esp
  801f73:	5b                   	pop    %ebx
  801f74:	5e                   	pop    %esi
  801f75:	5f                   	pop    %edi
  801f76:	5d                   	pop    %ebp
  801f77:	c3                   	ret    
  801f78:	90                   	nop
  801f79:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801f80:	89 d8                	mov    %ebx,%eax
  801f82:	f7 f7                	div    %edi
  801f84:	31 ff                	xor    %edi,%edi
  801f86:	89 c3                	mov    %eax,%ebx
  801f88:	89 d8                	mov    %ebx,%eax
  801f8a:	89 fa                	mov    %edi,%edx
  801f8c:	83 c4 1c             	add    $0x1c,%esp
  801f8f:	5b                   	pop    %ebx
  801f90:	5e                   	pop    %esi
  801f91:	5f                   	pop    %edi
  801f92:	5d                   	pop    %ebp
  801f93:	c3                   	ret    
  801f94:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801f98:	39 ce                	cmp    %ecx,%esi
  801f9a:	72 0c                	jb     801fa8 <__udivdi3+0x118>
  801f9c:	31 db                	xor    %ebx,%ebx
  801f9e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801fa2:	0f 87 34 ff ff ff    	ja     801edc <__udivdi3+0x4c>
  801fa8:	bb 01 00 00 00       	mov    $0x1,%ebx
  801fad:	e9 2a ff ff ff       	jmp    801edc <__udivdi3+0x4c>
  801fb2:	66 90                	xchg   %ax,%ax
  801fb4:	66 90                	xchg   %ax,%ax
  801fb6:	66 90                	xchg   %ax,%ax
  801fb8:	66 90                	xchg   %ax,%ax
  801fba:	66 90                	xchg   %ax,%ax
  801fbc:	66 90                	xchg   %ax,%ax
  801fbe:	66 90                	xchg   %ax,%ax

00801fc0 <__umoddi3>:
  801fc0:	55                   	push   %ebp
  801fc1:	57                   	push   %edi
  801fc2:	56                   	push   %esi
  801fc3:	53                   	push   %ebx
  801fc4:	83 ec 1c             	sub    $0x1c,%esp
  801fc7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801fcb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801fcf:	8b 74 24 34          	mov    0x34(%esp),%esi
  801fd3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801fd7:	85 d2                	test   %edx,%edx
  801fd9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801fdd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801fe1:	89 f3                	mov    %esi,%ebx
  801fe3:	89 3c 24             	mov    %edi,(%esp)
  801fe6:	89 74 24 04          	mov    %esi,0x4(%esp)
  801fea:	75 1c                	jne    802008 <__umoddi3+0x48>
  801fec:	39 f7                	cmp    %esi,%edi
  801fee:	76 50                	jbe    802040 <__umoddi3+0x80>
  801ff0:	89 c8                	mov    %ecx,%eax
  801ff2:	89 f2                	mov    %esi,%edx
  801ff4:	f7 f7                	div    %edi
  801ff6:	89 d0                	mov    %edx,%eax
  801ff8:	31 d2                	xor    %edx,%edx
  801ffa:	83 c4 1c             	add    $0x1c,%esp
  801ffd:	5b                   	pop    %ebx
  801ffe:	5e                   	pop    %esi
  801fff:	5f                   	pop    %edi
  802000:	5d                   	pop    %ebp
  802001:	c3                   	ret    
  802002:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802008:	39 f2                	cmp    %esi,%edx
  80200a:	89 d0                	mov    %edx,%eax
  80200c:	77 52                	ja     802060 <__umoddi3+0xa0>
  80200e:	0f bd ea             	bsr    %edx,%ebp
  802011:	83 f5 1f             	xor    $0x1f,%ebp
  802014:	75 5a                	jne    802070 <__umoddi3+0xb0>
  802016:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80201a:	0f 82 e0 00 00 00    	jb     802100 <__umoddi3+0x140>
  802020:	39 0c 24             	cmp    %ecx,(%esp)
  802023:	0f 86 d7 00 00 00    	jbe    802100 <__umoddi3+0x140>
  802029:	8b 44 24 08          	mov    0x8(%esp),%eax
  80202d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802031:	83 c4 1c             	add    $0x1c,%esp
  802034:	5b                   	pop    %ebx
  802035:	5e                   	pop    %esi
  802036:	5f                   	pop    %edi
  802037:	5d                   	pop    %ebp
  802038:	c3                   	ret    
  802039:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802040:	85 ff                	test   %edi,%edi
  802042:	89 fd                	mov    %edi,%ebp
  802044:	75 0b                	jne    802051 <__umoddi3+0x91>
  802046:	b8 01 00 00 00       	mov    $0x1,%eax
  80204b:	31 d2                	xor    %edx,%edx
  80204d:	f7 f7                	div    %edi
  80204f:	89 c5                	mov    %eax,%ebp
  802051:	89 f0                	mov    %esi,%eax
  802053:	31 d2                	xor    %edx,%edx
  802055:	f7 f5                	div    %ebp
  802057:	89 c8                	mov    %ecx,%eax
  802059:	f7 f5                	div    %ebp
  80205b:	89 d0                	mov    %edx,%eax
  80205d:	eb 99                	jmp    801ff8 <__umoddi3+0x38>
  80205f:	90                   	nop
  802060:	89 c8                	mov    %ecx,%eax
  802062:	89 f2                	mov    %esi,%edx
  802064:	83 c4 1c             	add    $0x1c,%esp
  802067:	5b                   	pop    %ebx
  802068:	5e                   	pop    %esi
  802069:	5f                   	pop    %edi
  80206a:	5d                   	pop    %ebp
  80206b:	c3                   	ret    
  80206c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802070:	8b 34 24             	mov    (%esp),%esi
  802073:	bf 20 00 00 00       	mov    $0x20,%edi
  802078:	89 e9                	mov    %ebp,%ecx
  80207a:	29 ef                	sub    %ebp,%edi
  80207c:	d3 e0                	shl    %cl,%eax
  80207e:	89 f9                	mov    %edi,%ecx
  802080:	89 f2                	mov    %esi,%edx
  802082:	d3 ea                	shr    %cl,%edx
  802084:	89 e9                	mov    %ebp,%ecx
  802086:	09 c2                	or     %eax,%edx
  802088:	89 d8                	mov    %ebx,%eax
  80208a:	89 14 24             	mov    %edx,(%esp)
  80208d:	89 f2                	mov    %esi,%edx
  80208f:	d3 e2                	shl    %cl,%edx
  802091:	89 f9                	mov    %edi,%ecx
  802093:	89 54 24 04          	mov    %edx,0x4(%esp)
  802097:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80209b:	d3 e8                	shr    %cl,%eax
  80209d:	89 e9                	mov    %ebp,%ecx
  80209f:	89 c6                	mov    %eax,%esi
  8020a1:	d3 e3                	shl    %cl,%ebx
  8020a3:	89 f9                	mov    %edi,%ecx
  8020a5:	89 d0                	mov    %edx,%eax
  8020a7:	d3 e8                	shr    %cl,%eax
  8020a9:	89 e9                	mov    %ebp,%ecx
  8020ab:	09 d8                	or     %ebx,%eax
  8020ad:	89 d3                	mov    %edx,%ebx
  8020af:	89 f2                	mov    %esi,%edx
  8020b1:	f7 34 24             	divl   (%esp)
  8020b4:	89 d6                	mov    %edx,%esi
  8020b6:	d3 e3                	shl    %cl,%ebx
  8020b8:	f7 64 24 04          	mull   0x4(%esp)
  8020bc:	39 d6                	cmp    %edx,%esi
  8020be:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8020c2:	89 d1                	mov    %edx,%ecx
  8020c4:	89 c3                	mov    %eax,%ebx
  8020c6:	72 08                	jb     8020d0 <__umoddi3+0x110>
  8020c8:	75 11                	jne    8020db <__umoddi3+0x11b>
  8020ca:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8020ce:	73 0b                	jae    8020db <__umoddi3+0x11b>
  8020d0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8020d4:	1b 14 24             	sbb    (%esp),%edx
  8020d7:	89 d1                	mov    %edx,%ecx
  8020d9:	89 c3                	mov    %eax,%ebx
  8020db:	8b 54 24 08          	mov    0x8(%esp),%edx
  8020df:	29 da                	sub    %ebx,%edx
  8020e1:	19 ce                	sbb    %ecx,%esi
  8020e3:	89 f9                	mov    %edi,%ecx
  8020e5:	89 f0                	mov    %esi,%eax
  8020e7:	d3 e0                	shl    %cl,%eax
  8020e9:	89 e9                	mov    %ebp,%ecx
  8020eb:	d3 ea                	shr    %cl,%edx
  8020ed:	89 e9                	mov    %ebp,%ecx
  8020ef:	d3 ee                	shr    %cl,%esi
  8020f1:	09 d0                	or     %edx,%eax
  8020f3:	89 f2                	mov    %esi,%edx
  8020f5:	83 c4 1c             	add    $0x1c,%esp
  8020f8:	5b                   	pop    %ebx
  8020f9:	5e                   	pop    %esi
  8020fa:	5f                   	pop    %edi
  8020fb:	5d                   	pop    %ebp
  8020fc:	c3                   	ret    
  8020fd:	8d 76 00             	lea    0x0(%esi),%esi
  802100:	29 f9                	sub    %edi,%ecx
  802102:	19 d6                	sbb    %edx,%esi
  802104:	89 74 24 04          	mov    %esi,0x4(%esp)
  802108:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80210c:	e9 18 ff ff ff       	jmp    802029 <__umoddi3+0x69>
