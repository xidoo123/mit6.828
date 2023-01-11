
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
  80003c:	e8 42 10 00 00       	call   801083 <sfork>
  800041:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800044:	85 c0                	test   %eax,%eax
  800046:	74 42                	je     80008a <umain+0x57>
		cprintf("i am %08x; thisenv is %p\n", sys_getenvid(), thisenv);
  800048:	8b 1d 0c 40 80 00    	mov    0x80400c,%ebx
  80004e:	e8 e8 0a 00 00       	call   800b3b <sys_getenvid>
  800053:	83 ec 04             	sub    $0x4,%esp
  800056:	53                   	push   %ebx
  800057:	50                   	push   %eax
  800058:	68 60 26 80 00       	push   $0x802660
  80005d:	e8 8f 01 00 00       	call   8001f1 <cprintf>
		// get the ball rolling
		cprintf("send 0 from %x to %x\n", sys_getenvid(), who);
  800062:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800065:	e8 d1 0a 00 00       	call   800b3b <sys_getenvid>
  80006a:	83 c4 0c             	add    $0xc,%esp
  80006d:	53                   	push   %ebx
  80006e:	50                   	push   %eax
  80006f:	68 7a 26 80 00       	push   $0x80267a
  800074:	e8 78 01 00 00       	call   8001f1 <cprintf>
		ipc_send(who, 0, 0, 0);
  800079:	6a 00                	push   $0x0
  80007b:	6a 00                	push   $0x0
  80007d:	6a 00                	push   $0x0
  80007f:	ff 75 e4             	pushl  -0x1c(%ebp)
  800082:	e8 7d 10 00 00       	call   801104 <ipc_send>
  800087:	83 c4 20             	add    $0x20,%esp
	}

	while (1) {
		ipc_recv(&who, 0, 0);
  80008a:	83 ec 04             	sub    $0x4,%esp
  80008d:	6a 00                	push   $0x0
  80008f:	6a 00                	push   $0x0
  800091:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800094:	50                   	push   %eax
  800095:	e8 03 10 00 00       	call   80109d <ipc_recv>
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
  8000bd:	68 90 26 80 00       	push   $0x802690
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
  8000e5:	e8 1a 10 00 00       	call   801104 <ipc_send>
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
  80014a:	e8 0d 12 00 00       	call   80135c <close_all>
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
  800254:	e8 77 21 00 00       	call   8023d0 <__udivdi3>
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
  800297:	e8 64 22 00 00       	call   802500 <__umoddi3>
  80029c:	83 c4 14             	add    $0x14,%esp
  80029f:	0f be 80 c0 26 80 00 	movsbl 0x8026c0(%eax),%eax
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
  80039b:	ff 24 85 00 28 80 00 	jmp    *0x802800(,%eax,4)
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
  80045f:	8b 14 85 60 29 80 00 	mov    0x802960(,%eax,4),%edx
  800466:	85 d2                	test   %edx,%edx
  800468:	75 18                	jne    800482 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80046a:	50                   	push   %eax
  80046b:	68 d8 26 80 00       	push   $0x8026d8
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
  800483:	68 61 2b 80 00       	push   $0x802b61
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
  8004a7:	b8 d1 26 80 00       	mov    $0x8026d1,%eax
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
  800b22:	68 bf 29 80 00       	push   $0x8029bf
  800b27:	6a 23                	push   $0x23
  800b29:	68 dc 29 80 00       	push   $0x8029dc
  800b2e:	e8 a2 17 00 00       	call   8022d5 <_panic>

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
  800ba3:	68 bf 29 80 00       	push   $0x8029bf
  800ba8:	6a 23                	push   $0x23
  800baa:	68 dc 29 80 00       	push   $0x8029dc
  800baf:	e8 21 17 00 00       	call   8022d5 <_panic>

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
  800be5:	68 bf 29 80 00       	push   $0x8029bf
  800bea:	6a 23                	push   $0x23
  800bec:	68 dc 29 80 00       	push   $0x8029dc
  800bf1:	e8 df 16 00 00       	call   8022d5 <_panic>

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
  800c27:	68 bf 29 80 00       	push   $0x8029bf
  800c2c:	6a 23                	push   $0x23
  800c2e:	68 dc 29 80 00       	push   $0x8029dc
  800c33:	e8 9d 16 00 00       	call   8022d5 <_panic>

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
  800c69:	68 bf 29 80 00       	push   $0x8029bf
  800c6e:	6a 23                	push   $0x23
  800c70:	68 dc 29 80 00       	push   $0x8029dc
  800c75:	e8 5b 16 00 00       	call   8022d5 <_panic>

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
  800cab:	68 bf 29 80 00       	push   $0x8029bf
  800cb0:	6a 23                	push   $0x23
  800cb2:	68 dc 29 80 00       	push   $0x8029dc
  800cb7:	e8 19 16 00 00       	call   8022d5 <_panic>

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
  800ced:	68 bf 29 80 00       	push   $0x8029bf
  800cf2:	6a 23                	push   $0x23
  800cf4:	68 dc 29 80 00       	push   $0x8029dc
  800cf9:	e8 d7 15 00 00       	call   8022d5 <_panic>

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
  800d51:	68 bf 29 80 00       	push   $0x8029bf
  800d56:	6a 23                	push   $0x23
  800d58:	68 dc 29 80 00       	push   $0x8029dc
  800d5d:	e8 73 15 00 00       	call   8022d5 <_panic>

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
  800db2:	68 bf 29 80 00       	push   $0x8029bf
  800db7:	6a 23                	push   $0x23
  800db9:	68 dc 29 80 00       	push   $0x8029dc
  800dbe:	e8 12 15 00 00       	call   8022d5 <_panic>

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

00800dcb <sys_e1000_try_recv>:

int
sys_e1000_try_recv(void *buf, uint32_t* len)
{
  800dcb:	55                   	push   %ebp
  800dcc:	89 e5                	mov    %esp,%ebp
  800dce:	57                   	push   %edi
  800dcf:	56                   	push   %esi
  800dd0:	53                   	push   %ebx
  800dd1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dd4:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dd9:	b8 10 00 00 00       	mov    $0x10,%eax
  800dde:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800de1:	8b 55 08             	mov    0x8(%ebp),%edx
  800de4:	89 df                	mov    %ebx,%edi
  800de6:	89 de                	mov    %ebx,%esi
  800de8:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800dea:	85 c0                	test   %eax,%eax
  800dec:	7e 17                	jle    800e05 <sys_e1000_try_recv+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dee:	83 ec 0c             	sub    $0xc,%esp
  800df1:	50                   	push   %eax
  800df2:	6a 10                	push   $0x10
  800df4:	68 bf 29 80 00       	push   $0x8029bf
  800df9:	6a 23                	push   $0x23
  800dfb:	68 dc 29 80 00       	push   $0x8029dc
  800e00:	e8 d0 14 00 00       	call   8022d5 <_panic>

int
sys_e1000_try_recv(void *buf, uint32_t* len)
{
	return syscall(SYS_e1000_try_recv, 1, (uint32_t)buf, (uint32_t)len, 0, 0, 0);
}
  800e05:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e08:	5b                   	pop    %ebx
  800e09:	5e                   	pop    %esi
  800e0a:	5f                   	pop    %edi
  800e0b:	5d                   	pop    %ebp
  800e0c:	c3                   	ret    

00800e0d <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800e0d:	55                   	push   %ebp
  800e0e:	89 e5                	mov    %esp,%ebp
  800e10:	56                   	push   %esi
  800e11:	53                   	push   %ebx
  800e12:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800e15:	8b 18                	mov    (%eax),%ebx
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.

	if ((err & FEC_WR) != FEC_WR && ((uvpt[PGNUM(addr)] & PTE_COW) != PTE_COW)) {
  800e17:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800e1b:	75 25                	jne    800e42 <pgfault+0x35>
  800e1d:	89 d8                	mov    %ebx,%eax
  800e1f:	c1 e8 0c             	shr    $0xc,%eax
  800e22:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800e29:	f6 c4 08             	test   $0x8,%ah
  800e2c:	75 14                	jne    800e42 <pgfault+0x35>
		panic("pgfault: not due to a write or a COW page");
  800e2e:	83 ec 04             	sub    $0x4,%esp
  800e31:	68 ec 29 80 00       	push   $0x8029ec
  800e36:	6a 1e                	push   $0x1e
  800e38:	68 80 2a 80 00       	push   $0x802a80
  800e3d:	e8 93 14 00 00       	call   8022d5 <_panic>

	// LAB 4: Your code here.

	// panic("pgfault not implemented");

	addr = ROUNDDOWN(addr, PGSIZE);
  800e42:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	envid_t envid = sys_getenvid();
  800e48:	e8 ee fc ff ff       	call   800b3b <sys_getenvid>
  800e4d:	89 c6                	mov    %eax,%esi

	// envid = 0;

	// Allocate a new page, map it at a temporary location (PFTEMP)
	r = sys_page_alloc(envid, (void *)PFTEMP, PTE_U | PTE_P | PTE_W);
  800e4f:	83 ec 04             	sub    $0x4,%esp
  800e52:	6a 07                	push   $0x7
  800e54:	68 00 f0 7f 00       	push   $0x7ff000
  800e59:	50                   	push   %eax
  800e5a:	e8 1a fd ff ff       	call   800b79 <sys_page_alloc>
	if (r < 0)
  800e5f:	83 c4 10             	add    $0x10,%esp
  800e62:	85 c0                	test   %eax,%eax
  800e64:	79 12                	jns    800e78 <pgfault+0x6b>
		panic("pgfault: sys_page_alloc failed: %e\n", r);
  800e66:	50                   	push   %eax
  800e67:	68 18 2a 80 00       	push   $0x802a18
  800e6c:	6a 33                	push   $0x33
  800e6e:	68 80 2a 80 00       	push   $0x802a80
  800e73:	e8 5d 14 00 00       	call   8022d5 <_panic>
	
	// copy the data from the old page to the new page
	memcpy((void *) PFTEMP, (const void *) addr, PGSIZE);
  800e78:	83 ec 04             	sub    $0x4,%esp
  800e7b:	68 00 10 00 00       	push   $0x1000
  800e80:	53                   	push   %ebx
  800e81:	68 00 f0 7f 00       	push   $0x7ff000
  800e86:	e8 e5 fa ff ff       	call   800970 <memcpy>

	// move the new page to the old page's address
	r = sys_page_map(envid, (void *) PFTEMP, envid, addr, PTE_U | PTE_P | PTE_W);
  800e8b:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800e92:	53                   	push   %ebx
  800e93:	56                   	push   %esi
  800e94:	68 00 f0 7f 00       	push   $0x7ff000
  800e99:	56                   	push   %esi
  800e9a:	e8 1d fd ff ff       	call   800bbc <sys_page_map>
	if (r < 0)
  800e9f:	83 c4 20             	add    $0x20,%esp
  800ea2:	85 c0                	test   %eax,%eax
  800ea4:	79 12                	jns    800eb8 <pgfault+0xab>
		panic("pgfault: sys_page_map failed: %e\n", r);
  800ea6:	50                   	push   %eax
  800ea7:	68 3c 2a 80 00       	push   $0x802a3c
  800eac:	6a 3b                	push   $0x3b
  800eae:	68 80 2a 80 00       	push   $0x802a80
  800eb3:	e8 1d 14 00 00       	call   8022d5 <_panic>

	// unmap temporary region
	r = sys_page_unmap(envid, (void *) PFTEMP);
  800eb8:	83 ec 08             	sub    $0x8,%esp
  800ebb:	68 00 f0 7f 00       	push   $0x7ff000
  800ec0:	56                   	push   %esi
  800ec1:	e8 38 fd ff ff       	call   800bfe <sys_page_unmap>
	if (r < 0)
  800ec6:	83 c4 10             	add    $0x10,%esp
  800ec9:	85 c0                	test   %eax,%eax
  800ecb:	79 12                	jns    800edf <pgfault+0xd2>
        panic("pgfault: page unmap failed: %e\n", r);
  800ecd:	50                   	push   %eax
  800ece:	68 60 2a 80 00       	push   $0x802a60
  800ed3:	6a 40                	push   $0x40
  800ed5:	68 80 2a 80 00       	push   $0x802a80
  800eda:	e8 f6 13 00 00       	call   8022d5 <_panic>
}
  800edf:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ee2:	5b                   	pop    %ebx
  800ee3:	5e                   	pop    %esi
  800ee4:	5d                   	pop    %ebp
  800ee5:	c3                   	ret    

00800ee6 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800ee6:	55                   	push   %ebp
  800ee7:	89 e5                	mov    %esp,%ebp
  800ee9:	57                   	push   %edi
  800eea:	56                   	push   %esi
  800eeb:	53                   	push   %ebx
  800eec:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	// cprintf("[fork]\n");
	int r;

	set_pgfault_handler(pgfault);
  800eef:	68 0d 0e 80 00       	push   $0x800e0d
  800ef4:	e8 22 14 00 00       	call   80231b <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800ef9:	b8 07 00 00 00       	mov    $0x7,%eax
  800efe:	cd 30                	int    $0x30

	envid_t envid = sys_exofork();
	if (envid < 0)
  800f00:	83 c4 10             	add    $0x10,%esp
  800f03:	85 c0                	test   %eax,%eax
  800f05:	0f 88 64 01 00 00    	js     80106f <fork+0x189>
  800f0b:	bb 00 00 80 00       	mov    $0x800000,%ebx
  800f10:	be 00 08 00 00       	mov    $0x800,%esi
		return envid;

	// fix "thisenv" in the child process
	if (envid == 0) {
  800f15:	85 c0                	test   %eax,%eax
  800f17:	75 21                	jne    800f3a <fork+0x54>
		thisenv = &envs[ENVX(sys_getenvid())];
  800f19:	e8 1d fc ff ff       	call   800b3b <sys_getenvid>
  800f1e:	25 ff 03 00 00       	and    $0x3ff,%eax
  800f23:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800f26:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800f2b:	a3 0c 40 80 00       	mov    %eax,0x80400c
        return 0;
  800f30:	ba 00 00 00 00       	mov    $0x0,%edx
  800f35:	e9 3f 01 00 00       	jmp    801079 <fork+0x193>
  800f3a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800f3d:	89 c7                	mov    %eax,%edi
	for (uint32_t pn = PGNUM(UTEXT); pn < PGNUM(USTACKTOP); pn++) {

		addr = pn * PGSIZE;

		// if level-2 page exists
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P) {
  800f3f:	89 d8                	mov    %ebx,%eax
  800f41:	c1 e8 16             	shr    $0x16,%eax
  800f44:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f4b:	a8 01                	test   $0x1,%al
  800f4d:	0f 84 bd 00 00 00    	je     801010 <fork+0x12a>
			
			// if real PTE exists
			if ((uvpt[PGNUM(addr)] & PTE_P) == PTE_P) {
  800f53:	89 d8                	mov    %ebx,%eax
  800f55:	c1 e8 0c             	shr    $0xc,%eax
  800f58:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f5f:	f6 c2 01             	test   $0x1,%dl
  800f62:	0f 84 a8 00 00 00    	je     801010 <fork+0x12a>

				// For each writable or copy-on-write page
				// if ((uvpt[PGNUM(addr)] & (PTE_W | PTE_COW)) != 0) {
				if ((uvpt[PGNUM(addr)] & PTE_U) != 0) {
  800f68:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f6f:	a8 04                	test   $0x4,%al
  800f71:	0f 84 99 00 00 00    	je     801010 <fork+0x12a>
	// r = envid2env(envid, &env, 1);
	// if (r < 0)
	// 	return r;	// E_BAD_ENV
	// envid_t parent_envid = env->env_parent_id;

	if (uvpt[pn] & PTE_SHARE) {
  800f77:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800f7e:	f6 c4 04             	test   $0x4,%ah
  800f81:	74 17                	je     800f9a <fork+0xb4>
		sys_page_map(0, (void *)va, envid, (void *)va, PTE_SYSCALL);
  800f83:	83 ec 0c             	sub    $0xc,%esp
  800f86:	68 07 0e 00 00       	push   $0xe07
  800f8b:	53                   	push   %ebx
  800f8c:	57                   	push   %edi
  800f8d:	53                   	push   %ebx
  800f8e:	6a 00                	push   $0x0
  800f90:	e8 27 fc ff ff       	call   800bbc <sys_page_map>
  800f95:	83 c4 20             	add    $0x20,%esp
  800f98:	eb 76                	jmp    801010 <fork+0x12a>
	}
	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {
  800f9a:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800fa1:	a8 02                	test   $0x2,%al
  800fa3:	75 0c                	jne    800fb1 <fork+0xcb>
  800fa5:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800fac:	f6 c4 08             	test   $0x8,%ah
  800faf:	74 3f                	je     800ff0 <fork+0x10a>

		// map the page copy-on-write into the address space of the child
        r = sys_page_map(0, (void *)va, envid, (void *)va, PTE_P|PTE_U|PTE_COW);
  800fb1:	83 ec 0c             	sub    $0xc,%esp
  800fb4:	68 05 08 00 00       	push   $0x805
  800fb9:	53                   	push   %ebx
  800fba:	57                   	push   %edi
  800fbb:	53                   	push   %ebx
  800fbc:	6a 00                	push   $0x0
  800fbe:	e8 f9 fb ff ff       	call   800bbc <sys_page_map>
		if (r < 0)
  800fc3:	83 c4 20             	add    $0x20,%esp
  800fc6:	85 c0                	test   %eax,%eax
  800fc8:	0f 88 a5 00 00 00    	js     801073 <fork+0x18d>
            return r;

		// remap the page copy-on-write in its own(parent) address space
        r = sys_page_map(0, (void *)va, 0, (void *)va, PTE_P|PTE_U|PTE_COW);
  800fce:	83 ec 0c             	sub    $0xc,%esp
  800fd1:	68 05 08 00 00       	push   $0x805
  800fd6:	53                   	push   %ebx
  800fd7:	6a 00                	push   $0x0
  800fd9:	53                   	push   %ebx
  800fda:	6a 00                	push   $0x0
  800fdc:	e8 db fb ff ff       	call   800bbc <sys_page_map>
  800fe1:	83 c4 20             	add    $0x20,%esp
  800fe4:	85 c0                	test   %eax,%eax
  800fe6:	b9 00 00 00 00       	mov    $0x0,%ecx
  800feb:	0f 4f c1             	cmovg  %ecx,%eax
  800fee:	eb 1c                	jmp    80100c <fork+0x126>
		if (r < 0)
            return r;
    }
    else {
        r = sys_page_map(0, (void *)va, envid, (void *)va, PTE_P|PTE_U);
  800ff0:	83 ec 0c             	sub    $0xc,%esp
  800ff3:	6a 05                	push   $0x5
  800ff5:	53                   	push   %ebx
  800ff6:	57                   	push   %edi
  800ff7:	53                   	push   %ebx
  800ff8:	6a 00                	push   $0x0
  800ffa:	e8 bd fb ff ff       	call   800bbc <sys_page_map>
  800fff:	83 c4 20             	add    $0x20,%esp
  801002:	85 c0                	test   %eax,%eax
  801004:	b9 00 00 00 00       	mov    $0x0,%ecx
  801009:	0f 4f c1             	cmovg  %ecx,%eax

				// For each writable or copy-on-write page
				// if ((uvpt[PGNUM(addr)] & (PTE_W | PTE_COW)) != 0) {
				if ((uvpt[PGNUM(addr)] & PTE_U) != 0) {
					r = duppage(envid, pn);
					if (r < 0)
  80100c:	85 c0                	test   %eax,%eax
  80100e:	78 67                	js     801077 <fork+0x191>
        return 0;
	}

	// For each writable or copy-on-write page in its address space below UTOP, the parent calls duppage
	uint32_t addr;
	for (uint32_t pn = PGNUM(UTEXT); pn < PGNUM(USTACKTOP); pn++) {
  801010:	83 c6 01             	add    $0x1,%esi
  801013:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801019:	81 fe fe eb 0e 00    	cmp    $0xeebfe,%esi
  80101f:	0f 85 1a ff ff ff    	jne    800f3f <fork+0x59>
  801025:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
		}
	}

	// allocate a fresh page in the child for the exception stack
	r = sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U | PTE_P | PTE_W);
  801028:	83 ec 04             	sub    $0x4,%esp
  80102b:	6a 07                	push   $0x7
  80102d:	68 00 f0 bf ee       	push   $0xeebff000
  801032:	57                   	push   %edi
  801033:	e8 41 fb ff ff       	call   800b79 <sys_page_alloc>
	if (r < 0)
  801038:	83 c4 10             	add    $0x10,%esp
		return r;
  80103b:	89 c2                	mov    %eax,%edx
		}
	}

	// allocate a fresh page in the child for the exception stack
	r = sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U | PTE_P | PTE_W);
	if (r < 0)
  80103d:	85 c0                	test   %eax,%eax
  80103f:	78 38                	js     801079 <fork+0x193>
		return r;

	// The parent sets the user page fault entrypoint for the child to look like its own
	extern void _pgfault_upcall(void);
	r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  801041:	83 ec 08             	sub    $0x8,%esp
  801044:	68 62 23 80 00       	push   $0x802362
  801049:	57                   	push   %edi
  80104a:	e8 75 fc ff ff       	call   800cc4 <sys_env_set_pgfault_upcall>
	if (r < 0)
  80104f:	83 c4 10             	add    $0x10,%esp
		return r;
  801052:	89 c2                	mov    %eax,%edx
		return r;

	// The parent sets the user page fault entrypoint for the child to look like its own
	extern void _pgfault_upcall(void);
	r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
	if (r < 0)
  801054:	85 c0                	test   %eax,%eax
  801056:	78 21                	js     801079 <fork+0x193>
		return r;

	// The child is now ready to run, so the parent marks it runnable
	r = sys_env_set_status(envid, ENV_RUNNABLE);
  801058:	83 ec 08             	sub    $0x8,%esp
  80105b:	6a 02                	push   $0x2
  80105d:	57                   	push   %edi
  80105e:	e8 dd fb ff ff       	call   800c40 <sys_env_set_status>
	if (r < 0)
  801063:	83 c4 10             	add    $0x10,%esp
		return r;

	return envid;
  801066:	85 c0                	test   %eax,%eax
  801068:	0f 48 f8             	cmovs  %eax,%edi
  80106b:	89 fa                	mov    %edi,%edx
  80106d:	eb 0a                	jmp    801079 <fork+0x193>

	set_pgfault_handler(pgfault);

	envid_t envid = sys_exofork();
	if (envid < 0)
		return envid;
  80106f:	89 c2                	mov    %eax,%edx
  801071:	eb 06                	jmp    801079 <fork+0x193>
		sys_page_map(0, (void *)va, envid, (void *)va, PTE_SYSCALL);
	}
	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {

		// map the page copy-on-write into the address space of the child
        r = sys_page_map(0, (void *)va, envid, (void *)va, PTE_P|PTE_U|PTE_COW);
  801073:	89 c2                	mov    %eax,%edx
  801075:	eb 02                	jmp    801079 <fork+0x193>
  801077:	89 c2                	mov    %eax,%edx
	if (r < 0)
		return r;

	return envid;
	// panic("fork not implemented");
}
  801079:	89 d0                	mov    %edx,%eax
  80107b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80107e:	5b                   	pop    %ebx
  80107f:	5e                   	pop    %esi
  801080:	5f                   	pop    %edi
  801081:	5d                   	pop    %ebp
  801082:	c3                   	ret    

00801083 <sfork>:

// Challenge!
int
sfork(void)
{
  801083:	55                   	push   %ebp
  801084:	89 e5                	mov    %esp,%ebp
  801086:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801089:	68 8b 2a 80 00       	push   $0x802a8b
  80108e:	68 c9 00 00 00       	push   $0xc9
  801093:	68 80 2a 80 00       	push   $0x802a80
  801098:	e8 38 12 00 00       	call   8022d5 <_panic>

0080109d <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80109d:	55                   	push   %ebp
  80109e:	89 e5                	mov    %esp,%ebp
  8010a0:	56                   	push   %esi
  8010a1:	53                   	push   %ebx
  8010a2:	8b 75 08             	mov    0x8(%ebp),%esi
  8010a5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8010a8:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");

	// don't want to recv page
	if (pg == NULL)
  8010ab:	85 c0                	test   %eax,%eax
		pg = (void *)UTOP;
  8010ad:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  8010b2:	0f 44 c2             	cmove  %edx,%eax

	int err = sys_ipc_recv(pg);
  8010b5:	83 ec 0c             	sub    $0xc,%esp
  8010b8:	50                   	push   %eax
  8010b9:	e8 6b fc ff ff       	call   800d29 <sys_ipc_recv>

	if (from_env_store != NULL)
  8010be:	83 c4 10             	add    $0x10,%esp
  8010c1:	85 f6                	test   %esi,%esi
  8010c3:	74 14                	je     8010d9 <ipc_recv+0x3c>
		*from_env_store = err < 0? 0 : thisenv->env_ipc_from;
  8010c5:	ba 00 00 00 00       	mov    $0x0,%edx
  8010ca:	85 c0                	test   %eax,%eax
  8010cc:	78 09                	js     8010d7 <ipc_recv+0x3a>
  8010ce:	8b 15 0c 40 80 00    	mov    0x80400c,%edx
  8010d4:	8b 52 74             	mov    0x74(%edx),%edx
  8010d7:	89 16                	mov    %edx,(%esi)
	
	if (perm_store != NULL)
  8010d9:	85 db                	test   %ebx,%ebx
  8010db:	74 14                	je     8010f1 <ipc_recv+0x54>
		*perm_store = err < 0? 0 : thisenv->env_ipc_perm;
  8010dd:	ba 00 00 00 00       	mov    $0x0,%edx
  8010e2:	85 c0                	test   %eax,%eax
  8010e4:	78 09                	js     8010ef <ipc_recv+0x52>
  8010e6:	8b 15 0c 40 80 00    	mov    0x80400c,%edx
  8010ec:	8b 52 78             	mov    0x78(%edx),%edx
  8010ef:	89 13                	mov    %edx,(%ebx)

	if (err < 0)
  8010f1:	85 c0                	test   %eax,%eax
  8010f3:	78 08                	js     8010fd <ipc_recv+0x60>
		return err;
	return thisenv->env_ipc_value;
  8010f5:	a1 0c 40 80 00       	mov    0x80400c,%eax
  8010fa:	8b 40 70             	mov    0x70(%eax),%eax
}
  8010fd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801100:	5b                   	pop    %ebx
  801101:	5e                   	pop    %esi
  801102:	5d                   	pop    %ebp
  801103:	c3                   	ret    

00801104 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801104:	55                   	push   %ebp
  801105:	89 e5                	mov    %esp,%ebp
  801107:	57                   	push   %edi
  801108:	56                   	push   %esi
  801109:	53                   	push   %ebx
  80110a:	83 ec 0c             	sub    $0xc,%esp
  80110d:	8b 7d 08             	mov    0x8(%ebp),%edi
  801110:	8b 75 0c             	mov    0xc(%ebp),%esi
  801113:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");

	// don't want to send page
	if (pg == NULL)
  801116:	85 db                	test   %ebx,%ebx
		pg = (void *)UTOP;
  801118:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  80111d:	0f 44 d8             	cmove  %eax,%ebx
	
	int err = 0;
	
	do {

		err = sys_ipc_try_send(to_env, val, pg, perm);
  801120:	ff 75 14             	pushl  0x14(%ebp)
  801123:	53                   	push   %ebx
  801124:	56                   	push   %esi
  801125:	57                   	push   %edi
  801126:	e8 db fb ff ff       	call   800d06 <sys_ipc_try_send>

		if (err < 0) {
  80112b:	83 c4 10             	add    $0x10,%esp
  80112e:	85 c0                	test   %eax,%eax
  801130:	79 1e                	jns    801150 <ipc_send+0x4c>
			if (err == -E_IPC_NOT_RECV)
  801132:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801135:	75 07                	jne    80113e <ipc_send+0x3a>
				sys_yield();
  801137:	e8 1e fa ff ff       	call   800b5a <sys_yield>
  80113c:	eb e2                	jmp    801120 <ipc_send+0x1c>
			else 
				panic("ipc_send: %e", err);
  80113e:	50                   	push   %eax
  80113f:	68 a1 2a 80 00       	push   $0x802aa1
  801144:	6a 49                	push   $0x49
  801146:	68 ae 2a 80 00       	push   $0x802aae
  80114b:	e8 85 11 00 00       	call   8022d5 <_panic>
		}

	} while (err < 0);

}
  801150:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801153:	5b                   	pop    %ebx
  801154:	5e                   	pop    %esi
  801155:	5f                   	pop    %edi
  801156:	5d                   	pop    %ebp
  801157:	c3                   	ret    

00801158 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801158:	55                   	push   %ebp
  801159:	89 e5                	mov    %esp,%ebp
  80115b:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80115e:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801163:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801166:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80116c:	8b 52 50             	mov    0x50(%edx),%edx
  80116f:	39 ca                	cmp    %ecx,%edx
  801171:	75 0d                	jne    801180 <ipc_find_env+0x28>
			return envs[i].env_id;
  801173:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801176:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80117b:	8b 40 48             	mov    0x48(%eax),%eax
  80117e:	eb 0f                	jmp    80118f <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801180:	83 c0 01             	add    $0x1,%eax
  801183:	3d 00 04 00 00       	cmp    $0x400,%eax
  801188:	75 d9                	jne    801163 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  80118a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80118f:	5d                   	pop    %ebp
  801190:	c3                   	ret    

00801191 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801191:	55                   	push   %ebp
  801192:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801194:	8b 45 08             	mov    0x8(%ebp),%eax
  801197:	05 00 00 00 30       	add    $0x30000000,%eax
  80119c:	c1 e8 0c             	shr    $0xc,%eax
}
  80119f:	5d                   	pop    %ebp
  8011a0:	c3                   	ret    

008011a1 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8011a1:	55                   	push   %ebp
  8011a2:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8011a4:	8b 45 08             	mov    0x8(%ebp),%eax
  8011a7:	05 00 00 00 30       	add    $0x30000000,%eax
  8011ac:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8011b1:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8011b6:	5d                   	pop    %ebp
  8011b7:	c3                   	ret    

008011b8 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8011b8:	55                   	push   %ebp
  8011b9:	89 e5                	mov    %esp,%ebp
  8011bb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011be:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8011c3:	89 c2                	mov    %eax,%edx
  8011c5:	c1 ea 16             	shr    $0x16,%edx
  8011c8:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8011cf:	f6 c2 01             	test   $0x1,%dl
  8011d2:	74 11                	je     8011e5 <fd_alloc+0x2d>
  8011d4:	89 c2                	mov    %eax,%edx
  8011d6:	c1 ea 0c             	shr    $0xc,%edx
  8011d9:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8011e0:	f6 c2 01             	test   $0x1,%dl
  8011e3:	75 09                	jne    8011ee <fd_alloc+0x36>
			*fd_store = fd;
  8011e5:	89 01                	mov    %eax,(%ecx)
			return 0;
  8011e7:	b8 00 00 00 00       	mov    $0x0,%eax
  8011ec:	eb 17                	jmp    801205 <fd_alloc+0x4d>
  8011ee:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8011f3:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8011f8:	75 c9                	jne    8011c3 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8011fa:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801200:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801205:	5d                   	pop    %ebp
  801206:	c3                   	ret    

00801207 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801207:	55                   	push   %ebp
  801208:	89 e5                	mov    %esp,%ebp
  80120a:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80120d:	83 f8 1f             	cmp    $0x1f,%eax
  801210:	77 36                	ja     801248 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801212:	c1 e0 0c             	shl    $0xc,%eax
  801215:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80121a:	89 c2                	mov    %eax,%edx
  80121c:	c1 ea 16             	shr    $0x16,%edx
  80121f:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801226:	f6 c2 01             	test   $0x1,%dl
  801229:	74 24                	je     80124f <fd_lookup+0x48>
  80122b:	89 c2                	mov    %eax,%edx
  80122d:	c1 ea 0c             	shr    $0xc,%edx
  801230:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801237:	f6 c2 01             	test   $0x1,%dl
  80123a:	74 1a                	je     801256 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80123c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80123f:	89 02                	mov    %eax,(%edx)
	return 0;
  801241:	b8 00 00 00 00       	mov    $0x0,%eax
  801246:	eb 13                	jmp    80125b <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801248:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80124d:	eb 0c                	jmp    80125b <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80124f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801254:	eb 05                	jmp    80125b <fd_lookup+0x54>
  801256:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80125b:	5d                   	pop    %ebp
  80125c:	c3                   	ret    

0080125d <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80125d:	55                   	push   %ebp
  80125e:	89 e5                	mov    %esp,%ebp
  801260:	83 ec 08             	sub    $0x8,%esp
  801263:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801266:	ba 34 2b 80 00       	mov    $0x802b34,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80126b:	eb 13                	jmp    801280 <dev_lookup+0x23>
  80126d:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801270:	39 08                	cmp    %ecx,(%eax)
  801272:	75 0c                	jne    801280 <dev_lookup+0x23>
			*dev = devtab[i];
  801274:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801277:	89 01                	mov    %eax,(%ecx)
			return 0;
  801279:	b8 00 00 00 00       	mov    $0x0,%eax
  80127e:	eb 2e                	jmp    8012ae <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801280:	8b 02                	mov    (%edx),%eax
  801282:	85 c0                	test   %eax,%eax
  801284:	75 e7                	jne    80126d <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801286:	a1 0c 40 80 00       	mov    0x80400c,%eax
  80128b:	8b 40 48             	mov    0x48(%eax),%eax
  80128e:	83 ec 04             	sub    $0x4,%esp
  801291:	51                   	push   %ecx
  801292:	50                   	push   %eax
  801293:	68 b8 2a 80 00       	push   $0x802ab8
  801298:	e8 54 ef ff ff       	call   8001f1 <cprintf>
	*dev = 0;
  80129d:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012a0:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8012a6:	83 c4 10             	add    $0x10,%esp
  8012a9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8012ae:	c9                   	leave  
  8012af:	c3                   	ret    

008012b0 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8012b0:	55                   	push   %ebp
  8012b1:	89 e5                	mov    %esp,%ebp
  8012b3:	56                   	push   %esi
  8012b4:	53                   	push   %ebx
  8012b5:	83 ec 10             	sub    $0x10,%esp
  8012b8:	8b 75 08             	mov    0x8(%ebp),%esi
  8012bb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8012be:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012c1:	50                   	push   %eax
  8012c2:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8012c8:	c1 e8 0c             	shr    $0xc,%eax
  8012cb:	50                   	push   %eax
  8012cc:	e8 36 ff ff ff       	call   801207 <fd_lookup>
  8012d1:	83 c4 08             	add    $0x8,%esp
  8012d4:	85 c0                	test   %eax,%eax
  8012d6:	78 05                	js     8012dd <fd_close+0x2d>
	    || fd != fd2)
  8012d8:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8012db:	74 0c                	je     8012e9 <fd_close+0x39>
		return (must_exist ? r : 0);
  8012dd:	84 db                	test   %bl,%bl
  8012df:	ba 00 00 00 00       	mov    $0x0,%edx
  8012e4:	0f 44 c2             	cmove  %edx,%eax
  8012e7:	eb 41                	jmp    80132a <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8012e9:	83 ec 08             	sub    $0x8,%esp
  8012ec:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012ef:	50                   	push   %eax
  8012f0:	ff 36                	pushl  (%esi)
  8012f2:	e8 66 ff ff ff       	call   80125d <dev_lookup>
  8012f7:	89 c3                	mov    %eax,%ebx
  8012f9:	83 c4 10             	add    $0x10,%esp
  8012fc:	85 c0                	test   %eax,%eax
  8012fe:	78 1a                	js     80131a <fd_close+0x6a>
		if (dev->dev_close)
  801300:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801303:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801306:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  80130b:	85 c0                	test   %eax,%eax
  80130d:	74 0b                	je     80131a <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80130f:	83 ec 0c             	sub    $0xc,%esp
  801312:	56                   	push   %esi
  801313:	ff d0                	call   *%eax
  801315:	89 c3                	mov    %eax,%ebx
  801317:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80131a:	83 ec 08             	sub    $0x8,%esp
  80131d:	56                   	push   %esi
  80131e:	6a 00                	push   $0x0
  801320:	e8 d9 f8 ff ff       	call   800bfe <sys_page_unmap>
	return r;
  801325:	83 c4 10             	add    $0x10,%esp
  801328:	89 d8                	mov    %ebx,%eax
}
  80132a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80132d:	5b                   	pop    %ebx
  80132e:	5e                   	pop    %esi
  80132f:	5d                   	pop    %ebp
  801330:	c3                   	ret    

00801331 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801331:	55                   	push   %ebp
  801332:	89 e5                	mov    %esp,%ebp
  801334:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801337:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80133a:	50                   	push   %eax
  80133b:	ff 75 08             	pushl  0x8(%ebp)
  80133e:	e8 c4 fe ff ff       	call   801207 <fd_lookup>
  801343:	83 c4 08             	add    $0x8,%esp
  801346:	85 c0                	test   %eax,%eax
  801348:	78 10                	js     80135a <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80134a:	83 ec 08             	sub    $0x8,%esp
  80134d:	6a 01                	push   $0x1
  80134f:	ff 75 f4             	pushl  -0xc(%ebp)
  801352:	e8 59 ff ff ff       	call   8012b0 <fd_close>
  801357:	83 c4 10             	add    $0x10,%esp
}
  80135a:	c9                   	leave  
  80135b:	c3                   	ret    

0080135c <close_all>:

void
close_all(void)
{
  80135c:	55                   	push   %ebp
  80135d:	89 e5                	mov    %esp,%ebp
  80135f:	53                   	push   %ebx
  801360:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801363:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801368:	83 ec 0c             	sub    $0xc,%esp
  80136b:	53                   	push   %ebx
  80136c:	e8 c0 ff ff ff       	call   801331 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801371:	83 c3 01             	add    $0x1,%ebx
  801374:	83 c4 10             	add    $0x10,%esp
  801377:	83 fb 20             	cmp    $0x20,%ebx
  80137a:	75 ec                	jne    801368 <close_all+0xc>
		close(i);
}
  80137c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80137f:	c9                   	leave  
  801380:	c3                   	ret    

00801381 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801381:	55                   	push   %ebp
  801382:	89 e5                	mov    %esp,%ebp
  801384:	57                   	push   %edi
  801385:	56                   	push   %esi
  801386:	53                   	push   %ebx
  801387:	83 ec 2c             	sub    $0x2c,%esp
  80138a:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80138d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801390:	50                   	push   %eax
  801391:	ff 75 08             	pushl  0x8(%ebp)
  801394:	e8 6e fe ff ff       	call   801207 <fd_lookup>
  801399:	83 c4 08             	add    $0x8,%esp
  80139c:	85 c0                	test   %eax,%eax
  80139e:	0f 88 c1 00 00 00    	js     801465 <dup+0xe4>
		return r;
	close(newfdnum);
  8013a4:	83 ec 0c             	sub    $0xc,%esp
  8013a7:	56                   	push   %esi
  8013a8:	e8 84 ff ff ff       	call   801331 <close>

	newfd = INDEX2FD(newfdnum);
  8013ad:	89 f3                	mov    %esi,%ebx
  8013af:	c1 e3 0c             	shl    $0xc,%ebx
  8013b2:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8013b8:	83 c4 04             	add    $0x4,%esp
  8013bb:	ff 75 e4             	pushl  -0x1c(%ebp)
  8013be:	e8 de fd ff ff       	call   8011a1 <fd2data>
  8013c3:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8013c5:	89 1c 24             	mov    %ebx,(%esp)
  8013c8:	e8 d4 fd ff ff       	call   8011a1 <fd2data>
  8013cd:	83 c4 10             	add    $0x10,%esp
  8013d0:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8013d3:	89 f8                	mov    %edi,%eax
  8013d5:	c1 e8 16             	shr    $0x16,%eax
  8013d8:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8013df:	a8 01                	test   $0x1,%al
  8013e1:	74 37                	je     80141a <dup+0x99>
  8013e3:	89 f8                	mov    %edi,%eax
  8013e5:	c1 e8 0c             	shr    $0xc,%eax
  8013e8:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8013ef:	f6 c2 01             	test   $0x1,%dl
  8013f2:	74 26                	je     80141a <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8013f4:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8013fb:	83 ec 0c             	sub    $0xc,%esp
  8013fe:	25 07 0e 00 00       	and    $0xe07,%eax
  801403:	50                   	push   %eax
  801404:	ff 75 d4             	pushl  -0x2c(%ebp)
  801407:	6a 00                	push   $0x0
  801409:	57                   	push   %edi
  80140a:	6a 00                	push   $0x0
  80140c:	e8 ab f7 ff ff       	call   800bbc <sys_page_map>
  801411:	89 c7                	mov    %eax,%edi
  801413:	83 c4 20             	add    $0x20,%esp
  801416:	85 c0                	test   %eax,%eax
  801418:	78 2e                	js     801448 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80141a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80141d:	89 d0                	mov    %edx,%eax
  80141f:	c1 e8 0c             	shr    $0xc,%eax
  801422:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801429:	83 ec 0c             	sub    $0xc,%esp
  80142c:	25 07 0e 00 00       	and    $0xe07,%eax
  801431:	50                   	push   %eax
  801432:	53                   	push   %ebx
  801433:	6a 00                	push   $0x0
  801435:	52                   	push   %edx
  801436:	6a 00                	push   $0x0
  801438:	e8 7f f7 ff ff       	call   800bbc <sys_page_map>
  80143d:	89 c7                	mov    %eax,%edi
  80143f:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801442:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801444:	85 ff                	test   %edi,%edi
  801446:	79 1d                	jns    801465 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801448:	83 ec 08             	sub    $0x8,%esp
  80144b:	53                   	push   %ebx
  80144c:	6a 00                	push   $0x0
  80144e:	e8 ab f7 ff ff       	call   800bfe <sys_page_unmap>
	sys_page_unmap(0, nva);
  801453:	83 c4 08             	add    $0x8,%esp
  801456:	ff 75 d4             	pushl  -0x2c(%ebp)
  801459:	6a 00                	push   $0x0
  80145b:	e8 9e f7 ff ff       	call   800bfe <sys_page_unmap>
	return r;
  801460:	83 c4 10             	add    $0x10,%esp
  801463:	89 f8                	mov    %edi,%eax
}
  801465:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801468:	5b                   	pop    %ebx
  801469:	5e                   	pop    %esi
  80146a:	5f                   	pop    %edi
  80146b:	5d                   	pop    %ebp
  80146c:	c3                   	ret    

0080146d <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80146d:	55                   	push   %ebp
  80146e:	89 e5                	mov    %esp,%ebp
  801470:	53                   	push   %ebx
  801471:	83 ec 14             	sub    $0x14,%esp
  801474:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801477:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80147a:	50                   	push   %eax
  80147b:	53                   	push   %ebx
  80147c:	e8 86 fd ff ff       	call   801207 <fd_lookup>
  801481:	83 c4 08             	add    $0x8,%esp
  801484:	89 c2                	mov    %eax,%edx
  801486:	85 c0                	test   %eax,%eax
  801488:	78 6d                	js     8014f7 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80148a:	83 ec 08             	sub    $0x8,%esp
  80148d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801490:	50                   	push   %eax
  801491:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801494:	ff 30                	pushl  (%eax)
  801496:	e8 c2 fd ff ff       	call   80125d <dev_lookup>
  80149b:	83 c4 10             	add    $0x10,%esp
  80149e:	85 c0                	test   %eax,%eax
  8014a0:	78 4c                	js     8014ee <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8014a2:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8014a5:	8b 42 08             	mov    0x8(%edx),%eax
  8014a8:	83 e0 03             	and    $0x3,%eax
  8014ab:	83 f8 01             	cmp    $0x1,%eax
  8014ae:	75 21                	jne    8014d1 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8014b0:	a1 0c 40 80 00       	mov    0x80400c,%eax
  8014b5:	8b 40 48             	mov    0x48(%eax),%eax
  8014b8:	83 ec 04             	sub    $0x4,%esp
  8014bb:	53                   	push   %ebx
  8014bc:	50                   	push   %eax
  8014bd:	68 f9 2a 80 00       	push   $0x802af9
  8014c2:	e8 2a ed ff ff       	call   8001f1 <cprintf>
		return -E_INVAL;
  8014c7:	83 c4 10             	add    $0x10,%esp
  8014ca:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8014cf:	eb 26                	jmp    8014f7 <read+0x8a>
	}
	if (!dev->dev_read)
  8014d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014d4:	8b 40 08             	mov    0x8(%eax),%eax
  8014d7:	85 c0                	test   %eax,%eax
  8014d9:	74 17                	je     8014f2 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8014db:	83 ec 04             	sub    $0x4,%esp
  8014de:	ff 75 10             	pushl  0x10(%ebp)
  8014e1:	ff 75 0c             	pushl  0xc(%ebp)
  8014e4:	52                   	push   %edx
  8014e5:	ff d0                	call   *%eax
  8014e7:	89 c2                	mov    %eax,%edx
  8014e9:	83 c4 10             	add    $0x10,%esp
  8014ec:	eb 09                	jmp    8014f7 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014ee:	89 c2                	mov    %eax,%edx
  8014f0:	eb 05                	jmp    8014f7 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8014f2:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8014f7:	89 d0                	mov    %edx,%eax
  8014f9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014fc:	c9                   	leave  
  8014fd:	c3                   	ret    

008014fe <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8014fe:	55                   	push   %ebp
  8014ff:	89 e5                	mov    %esp,%ebp
  801501:	57                   	push   %edi
  801502:	56                   	push   %esi
  801503:	53                   	push   %ebx
  801504:	83 ec 0c             	sub    $0xc,%esp
  801507:	8b 7d 08             	mov    0x8(%ebp),%edi
  80150a:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80150d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801512:	eb 21                	jmp    801535 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801514:	83 ec 04             	sub    $0x4,%esp
  801517:	89 f0                	mov    %esi,%eax
  801519:	29 d8                	sub    %ebx,%eax
  80151b:	50                   	push   %eax
  80151c:	89 d8                	mov    %ebx,%eax
  80151e:	03 45 0c             	add    0xc(%ebp),%eax
  801521:	50                   	push   %eax
  801522:	57                   	push   %edi
  801523:	e8 45 ff ff ff       	call   80146d <read>
		if (m < 0)
  801528:	83 c4 10             	add    $0x10,%esp
  80152b:	85 c0                	test   %eax,%eax
  80152d:	78 10                	js     80153f <readn+0x41>
			return m;
		if (m == 0)
  80152f:	85 c0                	test   %eax,%eax
  801531:	74 0a                	je     80153d <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801533:	01 c3                	add    %eax,%ebx
  801535:	39 f3                	cmp    %esi,%ebx
  801537:	72 db                	jb     801514 <readn+0x16>
  801539:	89 d8                	mov    %ebx,%eax
  80153b:	eb 02                	jmp    80153f <readn+0x41>
  80153d:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80153f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801542:	5b                   	pop    %ebx
  801543:	5e                   	pop    %esi
  801544:	5f                   	pop    %edi
  801545:	5d                   	pop    %ebp
  801546:	c3                   	ret    

00801547 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801547:	55                   	push   %ebp
  801548:	89 e5                	mov    %esp,%ebp
  80154a:	53                   	push   %ebx
  80154b:	83 ec 14             	sub    $0x14,%esp
  80154e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801551:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801554:	50                   	push   %eax
  801555:	53                   	push   %ebx
  801556:	e8 ac fc ff ff       	call   801207 <fd_lookup>
  80155b:	83 c4 08             	add    $0x8,%esp
  80155e:	89 c2                	mov    %eax,%edx
  801560:	85 c0                	test   %eax,%eax
  801562:	78 68                	js     8015cc <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801564:	83 ec 08             	sub    $0x8,%esp
  801567:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80156a:	50                   	push   %eax
  80156b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80156e:	ff 30                	pushl  (%eax)
  801570:	e8 e8 fc ff ff       	call   80125d <dev_lookup>
  801575:	83 c4 10             	add    $0x10,%esp
  801578:	85 c0                	test   %eax,%eax
  80157a:	78 47                	js     8015c3 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80157c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80157f:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801583:	75 21                	jne    8015a6 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801585:	a1 0c 40 80 00       	mov    0x80400c,%eax
  80158a:	8b 40 48             	mov    0x48(%eax),%eax
  80158d:	83 ec 04             	sub    $0x4,%esp
  801590:	53                   	push   %ebx
  801591:	50                   	push   %eax
  801592:	68 15 2b 80 00       	push   $0x802b15
  801597:	e8 55 ec ff ff       	call   8001f1 <cprintf>
		return -E_INVAL;
  80159c:	83 c4 10             	add    $0x10,%esp
  80159f:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8015a4:	eb 26                	jmp    8015cc <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8015a6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015a9:	8b 52 0c             	mov    0xc(%edx),%edx
  8015ac:	85 d2                	test   %edx,%edx
  8015ae:	74 17                	je     8015c7 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8015b0:	83 ec 04             	sub    $0x4,%esp
  8015b3:	ff 75 10             	pushl  0x10(%ebp)
  8015b6:	ff 75 0c             	pushl  0xc(%ebp)
  8015b9:	50                   	push   %eax
  8015ba:	ff d2                	call   *%edx
  8015bc:	89 c2                	mov    %eax,%edx
  8015be:	83 c4 10             	add    $0x10,%esp
  8015c1:	eb 09                	jmp    8015cc <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015c3:	89 c2                	mov    %eax,%edx
  8015c5:	eb 05                	jmp    8015cc <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8015c7:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8015cc:	89 d0                	mov    %edx,%eax
  8015ce:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015d1:	c9                   	leave  
  8015d2:	c3                   	ret    

008015d3 <seek>:

int
seek(int fdnum, off_t offset)
{
  8015d3:	55                   	push   %ebp
  8015d4:	89 e5                	mov    %esp,%ebp
  8015d6:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8015d9:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8015dc:	50                   	push   %eax
  8015dd:	ff 75 08             	pushl  0x8(%ebp)
  8015e0:	e8 22 fc ff ff       	call   801207 <fd_lookup>
  8015e5:	83 c4 08             	add    $0x8,%esp
  8015e8:	85 c0                	test   %eax,%eax
  8015ea:	78 0e                	js     8015fa <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8015ec:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8015ef:	8b 55 0c             	mov    0xc(%ebp),%edx
  8015f2:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8015f5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8015fa:	c9                   	leave  
  8015fb:	c3                   	ret    

008015fc <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8015fc:	55                   	push   %ebp
  8015fd:	89 e5                	mov    %esp,%ebp
  8015ff:	53                   	push   %ebx
  801600:	83 ec 14             	sub    $0x14,%esp
  801603:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801606:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801609:	50                   	push   %eax
  80160a:	53                   	push   %ebx
  80160b:	e8 f7 fb ff ff       	call   801207 <fd_lookup>
  801610:	83 c4 08             	add    $0x8,%esp
  801613:	89 c2                	mov    %eax,%edx
  801615:	85 c0                	test   %eax,%eax
  801617:	78 65                	js     80167e <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801619:	83 ec 08             	sub    $0x8,%esp
  80161c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80161f:	50                   	push   %eax
  801620:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801623:	ff 30                	pushl  (%eax)
  801625:	e8 33 fc ff ff       	call   80125d <dev_lookup>
  80162a:	83 c4 10             	add    $0x10,%esp
  80162d:	85 c0                	test   %eax,%eax
  80162f:	78 44                	js     801675 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801631:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801634:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801638:	75 21                	jne    80165b <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80163a:	a1 0c 40 80 00       	mov    0x80400c,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80163f:	8b 40 48             	mov    0x48(%eax),%eax
  801642:	83 ec 04             	sub    $0x4,%esp
  801645:	53                   	push   %ebx
  801646:	50                   	push   %eax
  801647:	68 d8 2a 80 00       	push   $0x802ad8
  80164c:	e8 a0 eb ff ff       	call   8001f1 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801651:	83 c4 10             	add    $0x10,%esp
  801654:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801659:	eb 23                	jmp    80167e <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  80165b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80165e:	8b 52 18             	mov    0x18(%edx),%edx
  801661:	85 d2                	test   %edx,%edx
  801663:	74 14                	je     801679 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801665:	83 ec 08             	sub    $0x8,%esp
  801668:	ff 75 0c             	pushl  0xc(%ebp)
  80166b:	50                   	push   %eax
  80166c:	ff d2                	call   *%edx
  80166e:	89 c2                	mov    %eax,%edx
  801670:	83 c4 10             	add    $0x10,%esp
  801673:	eb 09                	jmp    80167e <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801675:	89 c2                	mov    %eax,%edx
  801677:	eb 05                	jmp    80167e <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801679:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  80167e:	89 d0                	mov    %edx,%eax
  801680:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801683:	c9                   	leave  
  801684:	c3                   	ret    

00801685 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801685:	55                   	push   %ebp
  801686:	89 e5                	mov    %esp,%ebp
  801688:	53                   	push   %ebx
  801689:	83 ec 14             	sub    $0x14,%esp
  80168c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80168f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801692:	50                   	push   %eax
  801693:	ff 75 08             	pushl  0x8(%ebp)
  801696:	e8 6c fb ff ff       	call   801207 <fd_lookup>
  80169b:	83 c4 08             	add    $0x8,%esp
  80169e:	89 c2                	mov    %eax,%edx
  8016a0:	85 c0                	test   %eax,%eax
  8016a2:	78 58                	js     8016fc <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016a4:	83 ec 08             	sub    $0x8,%esp
  8016a7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016aa:	50                   	push   %eax
  8016ab:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016ae:	ff 30                	pushl  (%eax)
  8016b0:	e8 a8 fb ff ff       	call   80125d <dev_lookup>
  8016b5:	83 c4 10             	add    $0x10,%esp
  8016b8:	85 c0                	test   %eax,%eax
  8016ba:	78 37                	js     8016f3 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8016bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016bf:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8016c3:	74 32                	je     8016f7 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8016c5:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8016c8:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8016cf:	00 00 00 
	stat->st_isdir = 0;
  8016d2:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8016d9:	00 00 00 
	stat->st_dev = dev;
  8016dc:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8016e2:	83 ec 08             	sub    $0x8,%esp
  8016e5:	53                   	push   %ebx
  8016e6:	ff 75 f0             	pushl  -0x10(%ebp)
  8016e9:	ff 50 14             	call   *0x14(%eax)
  8016ec:	89 c2                	mov    %eax,%edx
  8016ee:	83 c4 10             	add    $0x10,%esp
  8016f1:	eb 09                	jmp    8016fc <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016f3:	89 c2                	mov    %eax,%edx
  8016f5:	eb 05                	jmp    8016fc <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8016f7:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8016fc:	89 d0                	mov    %edx,%eax
  8016fe:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801701:	c9                   	leave  
  801702:	c3                   	ret    

00801703 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801703:	55                   	push   %ebp
  801704:	89 e5                	mov    %esp,%ebp
  801706:	56                   	push   %esi
  801707:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801708:	83 ec 08             	sub    $0x8,%esp
  80170b:	6a 00                	push   $0x0
  80170d:	ff 75 08             	pushl  0x8(%ebp)
  801710:	e8 d6 01 00 00       	call   8018eb <open>
  801715:	89 c3                	mov    %eax,%ebx
  801717:	83 c4 10             	add    $0x10,%esp
  80171a:	85 c0                	test   %eax,%eax
  80171c:	78 1b                	js     801739 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80171e:	83 ec 08             	sub    $0x8,%esp
  801721:	ff 75 0c             	pushl  0xc(%ebp)
  801724:	50                   	push   %eax
  801725:	e8 5b ff ff ff       	call   801685 <fstat>
  80172a:	89 c6                	mov    %eax,%esi
	close(fd);
  80172c:	89 1c 24             	mov    %ebx,(%esp)
  80172f:	e8 fd fb ff ff       	call   801331 <close>
	return r;
  801734:	83 c4 10             	add    $0x10,%esp
  801737:	89 f0                	mov    %esi,%eax
}
  801739:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80173c:	5b                   	pop    %ebx
  80173d:	5e                   	pop    %esi
  80173e:	5d                   	pop    %ebp
  80173f:	c3                   	ret    

00801740 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801740:	55                   	push   %ebp
  801741:	89 e5                	mov    %esp,%ebp
  801743:	56                   	push   %esi
  801744:	53                   	push   %ebx
  801745:	89 c6                	mov    %eax,%esi
  801747:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801749:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801750:	75 12                	jne    801764 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801752:	83 ec 0c             	sub    $0xc,%esp
  801755:	6a 01                	push   $0x1
  801757:	e8 fc f9 ff ff       	call   801158 <ipc_find_env>
  80175c:	a3 00 40 80 00       	mov    %eax,0x804000
  801761:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801764:	6a 07                	push   $0x7
  801766:	68 00 50 80 00       	push   $0x805000
  80176b:	56                   	push   %esi
  80176c:	ff 35 00 40 80 00    	pushl  0x804000
  801772:	e8 8d f9 ff ff       	call   801104 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801777:	83 c4 0c             	add    $0xc,%esp
  80177a:	6a 00                	push   $0x0
  80177c:	53                   	push   %ebx
  80177d:	6a 00                	push   $0x0
  80177f:	e8 19 f9 ff ff       	call   80109d <ipc_recv>
}
  801784:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801787:	5b                   	pop    %ebx
  801788:	5e                   	pop    %esi
  801789:	5d                   	pop    %ebp
  80178a:	c3                   	ret    

0080178b <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80178b:	55                   	push   %ebp
  80178c:	89 e5                	mov    %esp,%ebp
  80178e:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801791:	8b 45 08             	mov    0x8(%ebp),%eax
  801794:	8b 40 0c             	mov    0xc(%eax),%eax
  801797:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80179c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80179f:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8017a4:	ba 00 00 00 00       	mov    $0x0,%edx
  8017a9:	b8 02 00 00 00       	mov    $0x2,%eax
  8017ae:	e8 8d ff ff ff       	call   801740 <fsipc>
}
  8017b3:	c9                   	leave  
  8017b4:	c3                   	ret    

008017b5 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8017b5:	55                   	push   %ebp
  8017b6:	89 e5                	mov    %esp,%ebp
  8017b8:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8017bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8017be:	8b 40 0c             	mov    0xc(%eax),%eax
  8017c1:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8017c6:	ba 00 00 00 00       	mov    $0x0,%edx
  8017cb:	b8 06 00 00 00       	mov    $0x6,%eax
  8017d0:	e8 6b ff ff ff       	call   801740 <fsipc>
}
  8017d5:	c9                   	leave  
  8017d6:	c3                   	ret    

008017d7 <devfile_stat>:

}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8017d7:	55                   	push   %ebp
  8017d8:	89 e5                	mov    %esp,%ebp
  8017da:	53                   	push   %ebx
  8017db:	83 ec 04             	sub    $0x4,%esp
  8017de:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8017e1:	8b 45 08             	mov    0x8(%ebp),%eax
  8017e4:	8b 40 0c             	mov    0xc(%eax),%eax
  8017e7:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8017ec:	ba 00 00 00 00       	mov    $0x0,%edx
  8017f1:	b8 05 00 00 00       	mov    $0x5,%eax
  8017f6:	e8 45 ff ff ff       	call   801740 <fsipc>
  8017fb:	85 c0                	test   %eax,%eax
  8017fd:	78 2c                	js     80182b <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8017ff:	83 ec 08             	sub    $0x8,%esp
  801802:	68 00 50 80 00       	push   $0x805000
  801807:	53                   	push   %ebx
  801808:	e8 69 ef ff ff       	call   800776 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80180d:	a1 80 50 80 00       	mov    0x805080,%eax
  801812:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801818:	a1 84 50 80 00       	mov    0x805084,%eax
  80181d:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801823:	83 c4 10             	add    $0x10,%esp
  801826:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80182b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80182e:	c9                   	leave  
  80182f:	c3                   	ret    

00801830 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801830:	55                   	push   %ebp
  801831:	89 e5                	mov    %esp,%ebp
  801833:	83 ec 0c             	sub    $0xc,%esp
  801836:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	// panic("devfile_write not implemented");

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801839:	8b 55 08             	mov    0x8(%ebp),%edx
  80183c:	8b 52 0c             	mov    0xc(%edx),%edx
  80183f:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  801845:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  80184a:	50                   	push   %eax
  80184b:	ff 75 0c             	pushl  0xc(%ebp)
  80184e:	68 08 50 80 00       	push   $0x805008
  801853:	e8 b0 f0 ff ff       	call   800908 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  801858:	ba 00 00 00 00       	mov    $0x0,%edx
  80185d:	b8 04 00 00 00       	mov    $0x4,%eax
  801862:	e8 d9 fe ff ff       	call   801740 <fsipc>

}
  801867:	c9                   	leave  
  801868:	c3                   	ret    

00801869 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801869:	55                   	push   %ebp
  80186a:	89 e5                	mov    %esp,%ebp
  80186c:	56                   	push   %esi
  80186d:	53                   	push   %ebx
  80186e:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801871:	8b 45 08             	mov    0x8(%ebp),%eax
  801874:	8b 40 0c             	mov    0xc(%eax),%eax
  801877:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80187c:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801882:	ba 00 00 00 00       	mov    $0x0,%edx
  801887:	b8 03 00 00 00       	mov    $0x3,%eax
  80188c:	e8 af fe ff ff       	call   801740 <fsipc>
  801891:	89 c3                	mov    %eax,%ebx
  801893:	85 c0                	test   %eax,%eax
  801895:	78 4b                	js     8018e2 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801897:	39 c6                	cmp    %eax,%esi
  801899:	73 16                	jae    8018b1 <devfile_read+0x48>
  80189b:	68 48 2b 80 00       	push   $0x802b48
  8018a0:	68 4f 2b 80 00       	push   $0x802b4f
  8018a5:	6a 7c                	push   $0x7c
  8018a7:	68 64 2b 80 00       	push   $0x802b64
  8018ac:	e8 24 0a 00 00       	call   8022d5 <_panic>
	assert(r <= PGSIZE);
  8018b1:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8018b6:	7e 16                	jle    8018ce <devfile_read+0x65>
  8018b8:	68 6f 2b 80 00       	push   $0x802b6f
  8018bd:	68 4f 2b 80 00       	push   $0x802b4f
  8018c2:	6a 7d                	push   $0x7d
  8018c4:	68 64 2b 80 00       	push   $0x802b64
  8018c9:	e8 07 0a 00 00       	call   8022d5 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8018ce:	83 ec 04             	sub    $0x4,%esp
  8018d1:	50                   	push   %eax
  8018d2:	68 00 50 80 00       	push   $0x805000
  8018d7:	ff 75 0c             	pushl  0xc(%ebp)
  8018da:	e8 29 f0 ff ff       	call   800908 <memmove>
	return r;
  8018df:	83 c4 10             	add    $0x10,%esp
}
  8018e2:	89 d8                	mov    %ebx,%eax
  8018e4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018e7:	5b                   	pop    %ebx
  8018e8:	5e                   	pop    %esi
  8018e9:	5d                   	pop    %ebp
  8018ea:	c3                   	ret    

008018eb <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8018eb:	55                   	push   %ebp
  8018ec:	89 e5                	mov    %esp,%ebp
  8018ee:	53                   	push   %ebx
  8018ef:	83 ec 20             	sub    $0x20,%esp
  8018f2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8018f5:	53                   	push   %ebx
  8018f6:	e8 42 ee ff ff       	call   80073d <strlen>
  8018fb:	83 c4 10             	add    $0x10,%esp
  8018fe:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801903:	7f 67                	jg     80196c <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801905:	83 ec 0c             	sub    $0xc,%esp
  801908:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80190b:	50                   	push   %eax
  80190c:	e8 a7 f8 ff ff       	call   8011b8 <fd_alloc>
  801911:	83 c4 10             	add    $0x10,%esp
		return r;
  801914:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801916:	85 c0                	test   %eax,%eax
  801918:	78 57                	js     801971 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  80191a:	83 ec 08             	sub    $0x8,%esp
  80191d:	53                   	push   %ebx
  80191e:	68 00 50 80 00       	push   $0x805000
  801923:	e8 4e ee ff ff       	call   800776 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801928:	8b 45 0c             	mov    0xc(%ebp),%eax
  80192b:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801930:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801933:	b8 01 00 00 00       	mov    $0x1,%eax
  801938:	e8 03 fe ff ff       	call   801740 <fsipc>
  80193d:	89 c3                	mov    %eax,%ebx
  80193f:	83 c4 10             	add    $0x10,%esp
  801942:	85 c0                	test   %eax,%eax
  801944:	79 14                	jns    80195a <open+0x6f>
		fd_close(fd, 0);
  801946:	83 ec 08             	sub    $0x8,%esp
  801949:	6a 00                	push   $0x0
  80194b:	ff 75 f4             	pushl  -0xc(%ebp)
  80194e:	e8 5d f9 ff ff       	call   8012b0 <fd_close>
		return r;
  801953:	83 c4 10             	add    $0x10,%esp
  801956:	89 da                	mov    %ebx,%edx
  801958:	eb 17                	jmp    801971 <open+0x86>
	}

	return fd2num(fd);
  80195a:	83 ec 0c             	sub    $0xc,%esp
  80195d:	ff 75 f4             	pushl  -0xc(%ebp)
  801960:	e8 2c f8 ff ff       	call   801191 <fd2num>
  801965:	89 c2                	mov    %eax,%edx
  801967:	83 c4 10             	add    $0x10,%esp
  80196a:	eb 05                	jmp    801971 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  80196c:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801971:	89 d0                	mov    %edx,%eax
  801973:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801976:	c9                   	leave  
  801977:	c3                   	ret    

00801978 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801978:	55                   	push   %ebp
  801979:	89 e5                	mov    %esp,%ebp
  80197b:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80197e:	ba 00 00 00 00       	mov    $0x0,%edx
  801983:	b8 08 00 00 00       	mov    $0x8,%eax
  801988:	e8 b3 fd ff ff       	call   801740 <fsipc>
}
  80198d:	c9                   	leave  
  80198e:	c3                   	ret    

0080198f <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  80198f:	55                   	push   %ebp
  801990:	89 e5                	mov    %esp,%ebp
  801992:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  801995:	68 7b 2b 80 00       	push   $0x802b7b
  80199a:	ff 75 0c             	pushl  0xc(%ebp)
  80199d:	e8 d4 ed ff ff       	call   800776 <strcpy>
	return 0;
}
  8019a2:	b8 00 00 00 00       	mov    $0x0,%eax
  8019a7:	c9                   	leave  
  8019a8:	c3                   	ret    

008019a9 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  8019a9:	55                   	push   %ebp
  8019aa:	89 e5                	mov    %esp,%ebp
  8019ac:	53                   	push   %ebx
  8019ad:	83 ec 10             	sub    $0x10,%esp
  8019b0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  8019b3:	53                   	push   %ebx
  8019b4:	e8 cd 09 00 00       	call   802386 <pageref>
  8019b9:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  8019bc:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  8019c1:	83 f8 01             	cmp    $0x1,%eax
  8019c4:	75 10                	jne    8019d6 <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  8019c6:	83 ec 0c             	sub    $0xc,%esp
  8019c9:	ff 73 0c             	pushl  0xc(%ebx)
  8019cc:	e8 c0 02 00 00       	call   801c91 <nsipc_close>
  8019d1:	89 c2                	mov    %eax,%edx
  8019d3:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  8019d6:	89 d0                	mov    %edx,%eax
  8019d8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019db:	c9                   	leave  
  8019dc:	c3                   	ret    

008019dd <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  8019dd:	55                   	push   %ebp
  8019de:	89 e5                	mov    %esp,%ebp
  8019e0:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  8019e3:	6a 00                	push   $0x0
  8019e5:	ff 75 10             	pushl  0x10(%ebp)
  8019e8:	ff 75 0c             	pushl  0xc(%ebp)
  8019eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8019ee:	ff 70 0c             	pushl  0xc(%eax)
  8019f1:	e8 78 03 00 00       	call   801d6e <nsipc_send>
}
  8019f6:	c9                   	leave  
  8019f7:	c3                   	ret    

008019f8 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  8019f8:	55                   	push   %ebp
  8019f9:	89 e5                	mov    %esp,%ebp
  8019fb:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  8019fe:	6a 00                	push   $0x0
  801a00:	ff 75 10             	pushl  0x10(%ebp)
  801a03:	ff 75 0c             	pushl  0xc(%ebp)
  801a06:	8b 45 08             	mov    0x8(%ebp),%eax
  801a09:	ff 70 0c             	pushl  0xc(%eax)
  801a0c:	e8 f1 02 00 00       	call   801d02 <nsipc_recv>
}
  801a11:	c9                   	leave  
  801a12:	c3                   	ret    

00801a13 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801a13:	55                   	push   %ebp
  801a14:	89 e5                	mov    %esp,%ebp
  801a16:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801a19:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801a1c:	52                   	push   %edx
  801a1d:	50                   	push   %eax
  801a1e:	e8 e4 f7 ff ff       	call   801207 <fd_lookup>
  801a23:	83 c4 10             	add    $0x10,%esp
  801a26:	85 c0                	test   %eax,%eax
  801a28:	78 17                	js     801a41 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801a2a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a2d:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  801a33:	39 08                	cmp    %ecx,(%eax)
  801a35:	75 05                	jne    801a3c <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801a37:	8b 40 0c             	mov    0xc(%eax),%eax
  801a3a:	eb 05                	jmp    801a41 <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801a3c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801a41:	c9                   	leave  
  801a42:	c3                   	ret    

00801a43 <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  801a43:	55                   	push   %ebp
  801a44:	89 e5                	mov    %esp,%ebp
  801a46:	56                   	push   %esi
  801a47:	53                   	push   %ebx
  801a48:	83 ec 1c             	sub    $0x1c,%esp
  801a4b:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801a4d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a50:	50                   	push   %eax
  801a51:	e8 62 f7 ff ff       	call   8011b8 <fd_alloc>
  801a56:	89 c3                	mov    %eax,%ebx
  801a58:	83 c4 10             	add    $0x10,%esp
  801a5b:	85 c0                	test   %eax,%eax
  801a5d:	78 1b                	js     801a7a <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801a5f:	83 ec 04             	sub    $0x4,%esp
  801a62:	68 07 04 00 00       	push   $0x407
  801a67:	ff 75 f4             	pushl  -0xc(%ebp)
  801a6a:	6a 00                	push   $0x0
  801a6c:	e8 08 f1 ff ff       	call   800b79 <sys_page_alloc>
  801a71:	89 c3                	mov    %eax,%ebx
  801a73:	83 c4 10             	add    $0x10,%esp
  801a76:	85 c0                	test   %eax,%eax
  801a78:	79 10                	jns    801a8a <alloc_sockfd+0x47>
		nsipc_close(sockid);
  801a7a:	83 ec 0c             	sub    $0xc,%esp
  801a7d:	56                   	push   %esi
  801a7e:	e8 0e 02 00 00       	call   801c91 <nsipc_close>
		return r;
  801a83:	83 c4 10             	add    $0x10,%esp
  801a86:	89 d8                	mov    %ebx,%eax
  801a88:	eb 24                	jmp    801aae <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801a8a:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801a90:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a93:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801a95:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a98:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801a9f:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801aa2:	83 ec 0c             	sub    $0xc,%esp
  801aa5:	50                   	push   %eax
  801aa6:	e8 e6 f6 ff ff       	call   801191 <fd2num>
  801aab:	83 c4 10             	add    $0x10,%esp
}
  801aae:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ab1:	5b                   	pop    %ebx
  801ab2:	5e                   	pop    %esi
  801ab3:	5d                   	pop    %ebp
  801ab4:	c3                   	ret    

00801ab5 <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801ab5:	55                   	push   %ebp
  801ab6:	89 e5                	mov    %esp,%ebp
  801ab8:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801abb:	8b 45 08             	mov    0x8(%ebp),%eax
  801abe:	e8 50 ff ff ff       	call   801a13 <fd2sockid>
		return r;
  801ac3:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  801ac5:	85 c0                	test   %eax,%eax
  801ac7:	78 1f                	js     801ae8 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801ac9:	83 ec 04             	sub    $0x4,%esp
  801acc:	ff 75 10             	pushl  0x10(%ebp)
  801acf:	ff 75 0c             	pushl  0xc(%ebp)
  801ad2:	50                   	push   %eax
  801ad3:	e8 12 01 00 00       	call   801bea <nsipc_accept>
  801ad8:	83 c4 10             	add    $0x10,%esp
		return r;
  801adb:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801add:	85 c0                	test   %eax,%eax
  801adf:	78 07                	js     801ae8 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  801ae1:	e8 5d ff ff ff       	call   801a43 <alloc_sockfd>
  801ae6:	89 c1                	mov    %eax,%ecx
}
  801ae8:	89 c8                	mov    %ecx,%eax
  801aea:	c9                   	leave  
  801aeb:	c3                   	ret    

00801aec <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801aec:	55                   	push   %ebp
  801aed:	89 e5                	mov    %esp,%ebp
  801aef:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801af2:	8b 45 08             	mov    0x8(%ebp),%eax
  801af5:	e8 19 ff ff ff       	call   801a13 <fd2sockid>
  801afa:	85 c0                	test   %eax,%eax
  801afc:	78 12                	js     801b10 <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  801afe:	83 ec 04             	sub    $0x4,%esp
  801b01:	ff 75 10             	pushl  0x10(%ebp)
  801b04:	ff 75 0c             	pushl  0xc(%ebp)
  801b07:	50                   	push   %eax
  801b08:	e8 2d 01 00 00       	call   801c3a <nsipc_bind>
  801b0d:	83 c4 10             	add    $0x10,%esp
}
  801b10:	c9                   	leave  
  801b11:	c3                   	ret    

00801b12 <shutdown>:

int
shutdown(int s, int how)
{
  801b12:	55                   	push   %ebp
  801b13:	89 e5                	mov    %esp,%ebp
  801b15:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801b18:	8b 45 08             	mov    0x8(%ebp),%eax
  801b1b:	e8 f3 fe ff ff       	call   801a13 <fd2sockid>
  801b20:	85 c0                	test   %eax,%eax
  801b22:	78 0f                	js     801b33 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801b24:	83 ec 08             	sub    $0x8,%esp
  801b27:	ff 75 0c             	pushl  0xc(%ebp)
  801b2a:	50                   	push   %eax
  801b2b:	e8 3f 01 00 00       	call   801c6f <nsipc_shutdown>
  801b30:	83 c4 10             	add    $0x10,%esp
}
  801b33:	c9                   	leave  
  801b34:	c3                   	ret    

00801b35 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801b35:	55                   	push   %ebp
  801b36:	89 e5                	mov    %esp,%ebp
  801b38:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801b3b:	8b 45 08             	mov    0x8(%ebp),%eax
  801b3e:	e8 d0 fe ff ff       	call   801a13 <fd2sockid>
  801b43:	85 c0                	test   %eax,%eax
  801b45:	78 12                	js     801b59 <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  801b47:	83 ec 04             	sub    $0x4,%esp
  801b4a:	ff 75 10             	pushl  0x10(%ebp)
  801b4d:	ff 75 0c             	pushl  0xc(%ebp)
  801b50:	50                   	push   %eax
  801b51:	e8 55 01 00 00       	call   801cab <nsipc_connect>
  801b56:	83 c4 10             	add    $0x10,%esp
}
  801b59:	c9                   	leave  
  801b5a:	c3                   	ret    

00801b5b <listen>:

int
listen(int s, int backlog)
{
  801b5b:	55                   	push   %ebp
  801b5c:	89 e5                	mov    %esp,%ebp
  801b5e:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801b61:	8b 45 08             	mov    0x8(%ebp),%eax
  801b64:	e8 aa fe ff ff       	call   801a13 <fd2sockid>
  801b69:	85 c0                	test   %eax,%eax
  801b6b:	78 0f                	js     801b7c <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801b6d:	83 ec 08             	sub    $0x8,%esp
  801b70:	ff 75 0c             	pushl  0xc(%ebp)
  801b73:	50                   	push   %eax
  801b74:	e8 67 01 00 00       	call   801ce0 <nsipc_listen>
  801b79:	83 c4 10             	add    $0x10,%esp
}
  801b7c:	c9                   	leave  
  801b7d:	c3                   	ret    

00801b7e <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801b7e:	55                   	push   %ebp
  801b7f:	89 e5                	mov    %esp,%ebp
  801b81:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801b84:	ff 75 10             	pushl  0x10(%ebp)
  801b87:	ff 75 0c             	pushl  0xc(%ebp)
  801b8a:	ff 75 08             	pushl  0x8(%ebp)
  801b8d:	e8 3a 02 00 00       	call   801dcc <nsipc_socket>
  801b92:	83 c4 10             	add    $0x10,%esp
  801b95:	85 c0                	test   %eax,%eax
  801b97:	78 05                	js     801b9e <socket+0x20>
		return r;
	return alloc_sockfd(r);
  801b99:	e8 a5 fe ff ff       	call   801a43 <alloc_sockfd>
}
  801b9e:	c9                   	leave  
  801b9f:	c3                   	ret    

00801ba0 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801ba0:	55                   	push   %ebp
  801ba1:	89 e5                	mov    %esp,%ebp
  801ba3:	53                   	push   %ebx
  801ba4:	83 ec 04             	sub    $0x4,%esp
  801ba7:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801ba9:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801bb0:	75 12                	jne    801bc4 <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801bb2:	83 ec 0c             	sub    $0xc,%esp
  801bb5:	6a 02                	push   $0x2
  801bb7:	e8 9c f5 ff ff       	call   801158 <ipc_find_env>
  801bbc:	a3 04 40 80 00       	mov    %eax,0x804004
  801bc1:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801bc4:	6a 07                	push   $0x7
  801bc6:	68 00 60 80 00       	push   $0x806000
  801bcb:	53                   	push   %ebx
  801bcc:	ff 35 04 40 80 00    	pushl  0x804004
  801bd2:	e8 2d f5 ff ff       	call   801104 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801bd7:	83 c4 0c             	add    $0xc,%esp
  801bda:	6a 00                	push   $0x0
  801bdc:	6a 00                	push   $0x0
  801bde:	6a 00                	push   $0x0
  801be0:	e8 b8 f4 ff ff       	call   80109d <ipc_recv>
}
  801be5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801be8:	c9                   	leave  
  801be9:	c3                   	ret    

00801bea <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801bea:	55                   	push   %ebp
  801beb:	89 e5                	mov    %esp,%ebp
  801bed:	56                   	push   %esi
  801bee:	53                   	push   %ebx
  801bef:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801bf2:	8b 45 08             	mov    0x8(%ebp),%eax
  801bf5:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801bfa:	8b 06                	mov    (%esi),%eax
  801bfc:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801c01:	b8 01 00 00 00       	mov    $0x1,%eax
  801c06:	e8 95 ff ff ff       	call   801ba0 <nsipc>
  801c0b:	89 c3                	mov    %eax,%ebx
  801c0d:	85 c0                	test   %eax,%eax
  801c0f:	78 20                	js     801c31 <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801c11:	83 ec 04             	sub    $0x4,%esp
  801c14:	ff 35 10 60 80 00    	pushl  0x806010
  801c1a:	68 00 60 80 00       	push   $0x806000
  801c1f:	ff 75 0c             	pushl  0xc(%ebp)
  801c22:	e8 e1 ec ff ff       	call   800908 <memmove>
		*addrlen = ret->ret_addrlen;
  801c27:	a1 10 60 80 00       	mov    0x806010,%eax
  801c2c:	89 06                	mov    %eax,(%esi)
  801c2e:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  801c31:	89 d8                	mov    %ebx,%eax
  801c33:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c36:	5b                   	pop    %ebx
  801c37:	5e                   	pop    %esi
  801c38:	5d                   	pop    %ebp
  801c39:	c3                   	ret    

00801c3a <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801c3a:	55                   	push   %ebp
  801c3b:	89 e5                	mov    %esp,%ebp
  801c3d:	53                   	push   %ebx
  801c3e:	83 ec 08             	sub    $0x8,%esp
  801c41:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801c44:	8b 45 08             	mov    0x8(%ebp),%eax
  801c47:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801c4c:	53                   	push   %ebx
  801c4d:	ff 75 0c             	pushl  0xc(%ebp)
  801c50:	68 04 60 80 00       	push   $0x806004
  801c55:	e8 ae ec ff ff       	call   800908 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801c5a:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801c60:	b8 02 00 00 00       	mov    $0x2,%eax
  801c65:	e8 36 ff ff ff       	call   801ba0 <nsipc>
}
  801c6a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c6d:	c9                   	leave  
  801c6e:	c3                   	ret    

00801c6f <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801c6f:	55                   	push   %ebp
  801c70:	89 e5                	mov    %esp,%ebp
  801c72:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801c75:	8b 45 08             	mov    0x8(%ebp),%eax
  801c78:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801c7d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c80:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801c85:	b8 03 00 00 00       	mov    $0x3,%eax
  801c8a:	e8 11 ff ff ff       	call   801ba0 <nsipc>
}
  801c8f:	c9                   	leave  
  801c90:	c3                   	ret    

00801c91 <nsipc_close>:

int
nsipc_close(int s)
{
  801c91:	55                   	push   %ebp
  801c92:	89 e5                	mov    %esp,%ebp
  801c94:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801c97:	8b 45 08             	mov    0x8(%ebp),%eax
  801c9a:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801c9f:	b8 04 00 00 00       	mov    $0x4,%eax
  801ca4:	e8 f7 fe ff ff       	call   801ba0 <nsipc>
}
  801ca9:	c9                   	leave  
  801caa:	c3                   	ret    

00801cab <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801cab:	55                   	push   %ebp
  801cac:	89 e5                	mov    %esp,%ebp
  801cae:	53                   	push   %ebx
  801caf:	83 ec 08             	sub    $0x8,%esp
  801cb2:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801cb5:	8b 45 08             	mov    0x8(%ebp),%eax
  801cb8:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801cbd:	53                   	push   %ebx
  801cbe:	ff 75 0c             	pushl  0xc(%ebp)
  801cc1:	68 04 60 80 00       	push   $0x806004
  801cc6:	e8 3d ec ff ff       	call   800908 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801ccb:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801cd1:	b8 05 00 00 00       	mov    $0x5,%eax
  801cd6:	e8 c5 fe ff ff       	call   801ba0 <nsipc>
}
  801cdb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801cde:	c9                   	leave  
  801cdf:	c3                   	ret    

00801ce0 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801ce0:	55                   	push   %ebp
  801ce1:	89 e5                	mov    %esp,%ebp
  801ce3:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801ce6:	8b 45 08             	mov    0x8(%ebp),%eax
  801ce9:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801cee:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cf1:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801cf6:	b8 06 00 00 00       	mov    $0x6,%eax
  801cfb:	e8 a0 fe ff ff       	call   801ba0 <nsipc>
}
  801d00:	c9                   	leave  
  801d01:	c3                   	ret    

00801d02 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801d02:	55                   	push   %ebp
  801d03:	89 e5                	mov    %esp,%ebp
  801d05:	56                   	push   %esi
  801d06:	53                   	push   %ebx
  801d07:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801d0a:	8b 45 08             	mov    0x8(%ebp),%eax
  801d0d:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801d12:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801d18:	8b 45 14             	mov    0x14(%ebp),%eax
  801d1b:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801d20:	b8 07 00 00 00       	mov    $0x7,%eax
  801d25:	e8 76 fe ff ff       	call   801ba0 <nsipc>
  801d2a:	89 c3                	mov    %eax,%ebx
  801d2c:	85 c0                	test   %eax,%eax
  801d2e:	78 35                	js     801d65 <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  801d30:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801d35:	7f 04                	jg     801d3b <nsipc_recv+0x39>
  801d37:	39 c6                	cmp    %eax,%esi
  801d39:	7d 16                	jge    801d51 <nsipc_recv+0x4f>
  801d3b:	68 87 2b 80 00       	push   $0x802b87
  801d40:	68 4f 2b 80 00       	push   $0x802b4f
  801d45:	6a 62                	push   $0x62
  801d47:	68 9c 2b 80 00       	push   $0x802b9c
  801d4c:	e8 84 05 00 00       	call   8022d5 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801d51:	83 ec 04             	sub    $0x4,%esp
  801d54:	50                   	push   %eax
  801d55:	68 00 60 80 00       	push   $0x806000
  801d5a:	ff 75 0c             	pushl  0xc(%ebp)
  801d5d:	e8 a6 eb ff ff       	call   800908 <memmove>
  801d62:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801d65:	89 d8                	mov    %ebx,%eax
  801d67:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d6a:	5b                   	pop    %ebx
  801d6b:	5e                   	pop    %esi
  801d6c:	5d                   	pop    %ebp
  801d6d:	c3                   	ret    

00801d6e <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801d6e:	55                   	push   %ebp
  801d6f:	89 e5                	mov    %esp,%ebp
  801d71:	53                   	push   %ebx
  801d72:	83 ec 04             	sub    $0x4,%esp
  801d75:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801d78:	8b 45 08             	mov    0x8(%ebp),%eax
  801d7b:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801d80:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801d86:	7e 16                	jle    801d9e <nsipc_send+0x30>
  801d88:	68 a8 2b 80 00       	push   $0x802ba8
  801d8d:	68 4f 2b 80 00       	push   $0x802b4f
  801d92:	6a 6d                	push   $0x6d
  801d94:	68 9c 2b 80 00       	push   $0x802b9c
  801d99:	e8 37 05 00 00       	call   8022d5 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801d9e:	83 ec 04             	sub    $0x4,%esp
  801da1:	53                   	push   %ebx
  801da2:	ff 75 0c             	pushl  0xc(%ebp)
  801da5:	68 0c 60 80 00       	push   $0x80600c
  801daa:	e8 59 eb ff ff       	call   800908 <memmove>
	nsipcbuf.send.req_size = size;
  801daf:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801db5:	8b 45 14             	mov    0x14(%ebp),%eax
  801db8:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801dbd:	b8 08 00 00 00       	mov    $0x8,%eax
  801dc2:	e8 d9 fd ff ff       	call   801ba0 <nsipc>
}
  801dc7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801dca:	c9                   	leave  
  801dcb:	c3                   	ret    

00801dcc <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801dcc:	55                   	push   %ebp
  801dcd:	89 e5                	mov    %esp,%ebp
  801dcf:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801dd2:	8b 45 08             	mov    0x8(%ebp),%eax
  801dd5:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801dda:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ddd:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801de2:	8b 45 10             	mov    0x10(%ebp),%eax
  801de5:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801dea:	b8 09 00 00 00       	mov    $0x9,%eax
  801def:	e8 ac fd ff ff       	call   801ba0 <nsipc>
}
  801df4:	c9                   	leave  
  801df5:	c3                   	ret    

00801df6 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801df6:	55                   	push   %ebp
  801df7:	89 e5                	mov    %esp,%ebp
  801df9:	56                   	push   %esi
  801dfa:	53                   	push   %ebx
  801dfb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801dfe:	83 ec 0c             	sub    $0xc,%esp
  801e01:	ff 75 08             	pushl  0x8(%ebp)
  801e04:	e8 98 f3 ff ff       	call   8011a1 <fd2data>
  801e09:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801e0b:	83 c4 08             	add    $0x8,%esp
  801e0e:	68 b4 2b 80 00       	push   $0x802bb4
  801e13:	53                   	push   %ebx
  801e14:	e8 5d e9 ff ff       	call   800776 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801e19:	8b 46 04             	mov    0x4(%esi),%eax
  801e1c:	2b 06                	sub    (%esi),%eax
  801e1e:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801e24:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801e2b:	00 00 00 
	stat->st_dev = &devpipe;
  801e2e:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801e35:	30 80 00 
	return 0;
}
  801e38:	b8 00 00 00 00       	mov    $0x0,%eax
  801e3d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e40:	5b                   	pop    %ebx
  801e41:	5e                   	pop    %esi
  801e42:	5d                   	pop    %ebp
  801e43:	c3                   	ret    

00801e44 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801e44:	55                   	push   %ebp
  801e45:	89 e5                	mov    %esp,%ebp
  801e47:	53                   	push   %ebx
  801e48:	83 ec 0c             	sub    $0xc,%esp
  801e4b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801e4e:	53                   	push   %ebx
  801e4f:	6a 00                	push   $0x0
  801e51:	e8 a8 ed ff ff       	call   800bfe <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801e56:	89 1c 24             	mov    %ebx,(%esp)
  801e59:	e8 43 f3 ff ff       	call   8011a1 <fd2data>
  801e5e:	83 c4 08             	add    $0x8,%esp
  801e61:	50                   	push   %eax
  801e62:	6a 00                	push   $0x0
  801e64:	e8 95 ed ff ff       	call   800bfe <sys_page_unmap>
}
  801e69:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801e6c:	c9                   	leave  
  801e6d:	c3                   	ret    

00801e6e <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801e6e:	55                   	push   %ebp
  801e6f:	89 e5                	mov    %esp,%ebp
  801e71:	57                   	push   %edi
  801e72:	56                   	push   %esi
  801e73:	53                   	push   %ebx
  801e74:	83 ec 1c             	sub    $0x1c,%esp
  801e77:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801e7a:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801e7c:	a1 0c 40 80 00       	mov    0x80400c,%eax
  801e81:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801e84:	83 ec 0c             	sub    $0xc,%esp
  801e87:	ff 75 e0             	pushl  -0x20(%ebp)
  801e8a:	e8 f7 04 00 00       	call   802386 <pageref>
  801e8f:	89 c3                	mov    %eax,%ebx
  801e91:	89 3c 24             	mov    %edi,(%esp)
  801e94:	e8 ed 04 00 00       	call   802386 <pageref>
  801e99:	83 c4 10             	add    $0x10,%esp
  801e9c:	39 c3                	cmp    %eax,%ebx
  801e9e:	0f 94 c1             	sete   %cl
  801ea1:	0f b6 c9             	movzbl %cl,%ecx
  801ea4:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801ea7:	8b 15 0c 40 80 00    	mov    0x80400c,%edx
  801ead:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801eb0:	39 ce                	cmp    %ecx,%esi
  801eb2:	74 1b                	je     801ecf <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801eb4:	39 c3                	cmp    %eax,%ebx
  801eb6:	75 c4                	jne    801e7c <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801eb8:	8b 42 58             	mov    0x58(%edx),%eax
  801ebb:	ff 75 e4             	pushl  -0x1c(%ebp)
  801ebe:	50                   	push   %eax
  801ebf:	56                   	push   %esi
  801ec0:	68 bb 2b 80 00       	push   $0x802bbb
  801ec5:	e8 27 e3 ff ff       	call   8001f1 <cprintf>
  801eca:	83 c4 10             	add    $0x10,%esp
  801ecd:	eb ad                	jmp    801e7c <_pipeisclosed+0xe>
	}
}
  801ecf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801ed2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ed5:	5b                   	pop    %ebx
  801ed6:	5e                   	pop    %esi
  801ed7:	5f                   	pop    %edi
  801ed8:	5d                   	pop    %ebp
  801ed9:	c3                   	ret    

00801eda <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801eda:	55                   	push   %ebp
  801edb:	89 e5                	mov    %esp,%ebp
  801edd:	57                   	push   %edi
  801ede:	56                   	push   %esi
  801edf:	53                   	push   %ebx
  801ee0:	83 ec 28             	sub    $0x28,%esp
  801ee3:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801ee6:	56                   	push   %esi
  801ee7:	e8 b5 f2 ff ff       	call   8011a1 <fd2data>
  801eec:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801eee:	83 c4 10             	add    $0x10,%esp
  801ef1:	bf 00 00 00 00       	mov    $0x0,%edi
  801ef6:	eb 4b                	jmp    801f43 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801ef8:	89 da                	mov    %ebx,%edx
  801efa:	89 f0                	mov    %esi,%eax
  801efc:	e8 6d ff ff ff       	call   801e6e <_pipeisclosed>
  801f01:	85 c0                	test   %eax,%eax
  801f03:	75 48                	jne    801f4d <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801f05:	e8 50 ec ff ff       	call   800b5a <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801f0a:	8b 43 04             	mov    0x4(%ebx),%eax
  801f0d:	8b 0b                	mov    (%ebx),%ecx
  801f0f:	8d 51 20             	lea    0x20(%ecx),%edx
  801f12:	39 d0                	cmp    %edx,%eax
  801f14:	73 e2                	jae    801ef8 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801f16:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801f19:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801f1d:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801f20:	89 c2                	mov    %eax,%edx
  801f22:	c1 fa 1f             	sar    $0x1f,%edx
  801f25:	89 d1                	mov    %edx,%ecx
  801f27:	c1 e9 1b             	shr    $0x1b,%ecx
  801f2a:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801f2d:	83 e2 1f             	and    $0x1f,%edx
  801f30:	29 ca                	sub    %ecx,%edx
  801f32:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801f36:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801f3a:	83 c0 01             	add    $0x1,%eax
  801f3d:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801f40:	83 c7 01             	add    $0x1,%edi
  801f43:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801f46:	75 c2                	jne    801f0a <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801f48:	8b 45 10             	mov    0x10(%ebp),%eax
  801f4b:	eb 05                	jmp    801f52 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801f4d:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801f52:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f55:	5b                   	pop    %ebx
  801f56:	5e                   	pop    %esi
  801f57:	5f                   	pop    %edi
  801f58:	5d                   	pop    %ebp
  801f59:	c3                   	ret    

00801f5a <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801f5a:	55                   	push   %ebp
  801f5b:	89 e5                	mov    %esp,%ebp
  801f5d:	57                   	push   %edi
  801f5e:	56                   	push   %esi
  801f5f:	53                   	push   %ebx
  801f60:	83 ec 18             	sub    $0x18,%esp
  801f63:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801f66:	57                   	push   %edi
  801f67:	e8 35 f2 ff ff       	call   8011a1 <fd2data>
  801f6c:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801f6e:	83 c4 10             	add    $0x10,%esp
  801f71:	bb 00 00 00 00       	mov    $0x0,%ebx
  801f76:	eb 3d                	jmp    801fb5 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801f78:	85 db                	test   %ebx,%ebx
  801f7a:	74 04                	je     801f80 <devpipe_read+0x26>
				return i;
  801f7c:	89 d8                	mov    %ebx,%eax
  801f7e:	eb 44                	jmp    801fc4 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801f80:	89 f2                	mov    %esi,%edx
  801f82:	89 f8                	mov    %edi,%eax
  801f84:	e8 e5 fe ff ff       	call   801e6e <_pipeisclosed>
  801f89:	85 c0                	test   %eax,%eax
  801f8b:	75 32                	jne    801fbf <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801f8d:	e8 c8 eb ff ff       	call   800b5a <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801f92:	8b 06                	mov    (%esi),%eax
  801f94:	3b 46 04             	cmp    0x4(%esi),%eax
  801f97:	74 df                	je     801f78 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801f99:	99                   	cltd   
  801f9a:	c1 ea 1b             	shr    $0x1b,%edx
  801f9d:	01 d0                	add    %edx,%eax
  801f9f:	83 e0 1f             	and    $0x1f,%eax
  801fa2:	29 d0                	sub    %edx,%eax
  801fa4:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801fa9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801fac:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801faf:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801fb2:	83 c3 01             	add    $0x1,%ebx
  801fb5:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801fb8:	75 d8                	jne    801f92 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801fba:	8b 45 10             	mov    0x10(%ebp),%eax
  801fbd:	eb 05                	jmp    801fc4 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801fbf:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801fc4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801fc7:	5b                   	pop    %ebx
  801fc8:	5e                   	pop    %esi
  801fc9:	5f                   	pop    %edi
  801fca:	5d                   	pop    %ebp
  801fcb:	c3                   	ret    

00801fcc <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801fcc:	55                   	push   %ebp
  801fcd:	89 e5                	mov    %esp,%ebp
  801fcf:	56                   	push   %esi
  801fd0:	53                   	push   %ebx
  801fd1:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801fd4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801fd7:	50                   	push   %eax
  801fd8:	e8 db f1 ff ff       	call   8011b8 <fd_alloc>
  801fdd:	83 c4 10             	add    $0x10,%esp
  801fe0:	89 c2                	mov    %eax,%edx
  801fe2:	85 c0                	test   %eax,%eax
  801fe4:	0f 88 2c 01 00 00    	js     802116 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801fea:	83 ec 04             	sub    $0x4,%esp
  801fed:	68 07 04 00 00       	push   $0x407
  801ff2:	ff 75 f4             	pushl  -0xc(%ebp)
  801ff5:	6a 00                	push   $0x0
  801ff7:	e8 7d eb ff ff       	call   800b79 <sys_page_alloc>
  801ffc:	83 c4 10             	add    $0x10,%esp
  801fff:	89 c2                	mov    %eax,%edx
  802001:	85 c0                	test   %eax,%eax
  802003:	0f 88 0d 01 00 00    	js     802116 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  802009:	83 ec 0c             	sub    $0xc,%esp
  80200c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80200f:	50                   	push   %eax
  802010:	e8 a3 f1 ff ff       	call   8011b8 <fd_alloc>
  802015:	89 c3                	mov    %eax,%ebx
  802017:	83 c4 10             	add    $0x10,%esp
  80201a:	85 c0                	test   %eax,%eax
  80201c:	0f 88 e2 00 00 00    	js     802104 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802022:	83 ec 04             	sub    $0x4,%esp
  802025:	68 07 04 00 00       	push   $0x407
  80202a:	ff 75 f0             	pushl  -0x10(%ebp)
  80202d:	6a 00                	push   $0x0
  80202f:	e8 45 eb ff ff       	call   800b79 <sys_page_alloc>
  802034:	89 c3                	mov    %eax,%ebx
  802036:	83 c4 10             	add    $0x10,%esp
  802039:	85 c0                	test   %eax,%eax
  80203b:	0f 88 c3 00 00 00    	js     802104 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  802041:	83 ec 0c             	sub    $0xc,%esp
  802044:	ff 75 f4             	pushl  -0xc(%ebp)
  802047:	e8 55 f1 ff ff       	call   8011a1 <fd2data>
  80204c:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80204e:	83 c4 0c             	add    $0xc,%esp
  802051:	68 07 04 00 00       	push   $0x407
  802056:	50                   	push   %eax
  802057:	6a 00                	push   $0x0
  802059:	e8 1b eb ff ff       	call   800b79 <sys_page_alloc>
  80205e:	89 c3                	mov    %eax,%ebx
  802060:	83 c4 10             	add    $0x10,%esp
  802063:	85 c0                	test   %eax,%eax
  802065:	0f 88 89 00 00 00    	js     8020f4 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80206b:	83 ec 0c             	sub    $0xc,%esp
  80206e:	ff 75 f0             	pushl  -0x10(%ebp)
  802071:	e8 2b f1 ff ff       	call   8011a1 <fd2data>
  802076:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  80207d:	50                   	push   %eax
  80207e:	6a 00                	push   $0x0
  802080:	56                   	push   %esi
  802081:	6a 00                	push   $0x0
  802083:	e8 34 eb ff ff       	call   800bbc <sys_page_map>
  802088:	89 c3                	mov    %eax,%ebx
  80208a:	83 c4 20             	add    $0x20,%esp
  80208d:	85 c0                	test   %eax,%eax
  80208f:	78 55                	js     8020e6 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  802091:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  802097:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80209a:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  80209c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80209f:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8020a6:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8020ac:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8020af:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8020b1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8020b4:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8020bb:	83 ec 0c             	sub    $0xc,%esp
  8020be:	ff 75 f4             	pushl  -0xc(%ebp)
  8020c1:	e8 cb f0 ff ff       	call   801191 <fd2num>
  8020c6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8020c9:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8020cb:	83 c4 04             	add    $0x4,%esp
  8020ce:	ff 75 f0             	pushl  -0x10(%ebp)
  8020d1:	e8 bb f0 ff ff       	call   801191 <fd2num>
  8020d6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8020d9:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8020dc:	83 c4 10             	add    $0x10,%esp
  8020df:	ba 00 00 00 00       	mov    $0x0,%edx
  8020e4:	eb 30                	jmp    802116 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  8020e6:	83 ec 08             	sub    $0x8,%esp
  8020e9:	56                   	push   %esi
  8020ea:	6a 00                	push   $0x0
  8020ec:	e8 0d eb ff ff       	call   800bfe <sys_page_unmap>
  8020f1:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  8020f4:	83 ec 08             	sub    $0x8,%esp
  8020f7:	ff 75 f0             	pushl  -0x10(%ebp)
  8020fa:	6a 00                	push   $0x0
  8020fc:	e8 fd ea ff ff       	call   800bfe <sys_page_unmap>
  802101:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  802104:	83 ec 08             	sub    $0x8,%esp
  802107:	ff 75 f4             	pushl  -0xc(%ebp)
  80210a:	6a 00                	push   $0x0
  80210c:	e8 ed ea ff ff       	call   800bfe <sys_page_unmap>
  802111:	83 c4 10             	add    $0x10,%esp
  802114:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  802116:	89 d0                	mov    %edx,%eax
  802118:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80211b:	5b                   	pop    %ebx
  80211c:	5e                   	pop    %esi
  80211d:	5d                   	pop    %ebp
  80211e:	c3                   	ret    

0080211f <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  80211f:	55                   	push   %ebp
  802120:	89 e5                	mov    %esp,%ebp
  802122:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802125:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802128:	50                   	push   %eax
  802129:	ff 75 08             	pushl  0x8(%ebp)
  80212c:	e8 d6 f0 ff ff       	call   801207 <fd_lookup>
  802131:	83 c4 10             	add    $0x10,%esp
  802134:	85 c0                	test   %eax,%eax
  802136:	78 18                	js     802150 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  802138:	83 ec 0c             	sub    $0xc,%esp
  80213b:	ff 75 f4             	pushl  -0xc(%ebp)
  80213e:	e8 5e f0 ff ff       	call   8011a1 <fd2data>
	return _pipeisclosed(fd, p);
  802143:	89 c2                	mov    %eax,%edx
  802145:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802148:	e8 21 fd ff ff       	call   801e6e <_pipeisclosed>
  80214d:	83 c4 10             	add    $0x10,%esp
}
  802150:	c9                   	leave  
  802151:	c3                   	ret    

00802152 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  802152:	55                   	push   %ebp
  802153:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  802155:	b8 00 00 00 00       	mov    $0x0,%eax
  80215a:	5d                   	pop    %ebp
  80215b:	c3                   	ret    

0080215c <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80215c:	55                   	push   %ebp
  80215d:	89 e5                	mov    %esp,%ebp
  80215f:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  802162:	68 d3 2b 80 00       	push   $0x802bd3
  802167:	ff 75 0c             	pushl  0xc(%ebp)
  80216a:	e8 07 e6 ff ff       	call   800776 <strcpy>
	return 0;
}
  80216f:	b8 00 00 00 00       	mov    $0x0,%eax
  802174:	c9                   	leave  
  802175:	c3                   	ret    

00802176 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802176:	55                   	push   %ebp
  802177:	89 e5                	mov    %esp,%ebp
  802179:	57                   	push   %edi
  80217a:	56                   	push   %esi
  80217b:	53                   	push   %ebx
  80217c:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802182:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802187:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80218d:	eb 2d                	jmp    8021bc <devcons_write+0x46>
		m = n - tot;
  80218f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802192:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  802194:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  802197:	ba 7f 00 00 00       	mov    $0x7f,%edx
  80219c:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80219f:	83 ec 04             	sub    $0x4,%esp
  8021a2:	53                   	push   %ebx
  8021a3:	03 45 0c             	add    0xc(%ebp),%eax
  8021a6:	50                   	push   %eax
  8021a7:	57                   	push   %edi
  8021a8:	e8 5b e7 ff ff       	call   800908 <memmove>
		sys_cputs(buf, m);
  8021ad:	83 c4 08             	add    $0x8,%esp
  8021b0:	53                   	push   %ebx
  8021b1:	57                   	push   %edi
  8021b2:	e8 06 e9 ff ff       	call   800abd <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8021b7:	01 de                	add    %ebx,%esi
  8021b9:	83 c4 10             	add    $0x10,%esp
  8021bc:	89 f0                	mov    %esi,%eax
  8021be:	3b 75 10             	cmp    0x10(%ebp),%esi
  8021c1:	72 cc                	jb     80218f <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8021c3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8021c6:	5b                   	pop    %ebx
  8021c7:	5e                   	pop    %esi
  8021c8:	5f                   	pop    %edi
  8021c9:	5d                   	pop    %ebp
  8021ca:	c3                   	ret    

008021cb <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8021cb:	55                   	push   %ebp
  8021cc:	89 e5                	mov    %esp,%ebp
  8021ce:	83 ec 08             	sub    $0x8,%esp
  8021d1:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  8021d6:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8021da:	74 2a                	je     802206 <devcons_read+0x3b>
  8021dc:	eb 05                	jmp    8021e3 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8021de:	e8 77 e9 ff ff       	call   800b5a <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8021e3:	e8 f3 e8 ff ff       	call   800adb <sys_cgetc>
  8021e8:	85 c0                	test   %eax,%eax
  8021ea:	74 f2                	je     8021de <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8021ec:	85 c0                	test   %eax,%eax
  8021ee:	78 16                	js     802206 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8021f0:	83 f8 04             	cmp    $0x4,%eax
  8021f3:	74 0c                	je     802201 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  8021f5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8021f8:	88 02                	mov    %al,(%edx)
	return 1;
  8021fa:	b8 01 00 00 00       	mov    $0x1,%eax
  8021ff:	eb 05                	jmp    802206 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  802201:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  802206:	c9                   	leave  
  802207:	c3                   	ret    

00802208 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  802208:	55                   	push   %ebp
  802209:	89 e5                	mov    %esp,%ebp
  80220b:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  80220e:	8b 45 08             	mov    0x8(%ebp),%eax
  802211:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  802214:	6a 01                	push   $0x1
  802216:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802219:	50                   	push   %eax
  80221a:	e8 9e e8 ff ff       	call   800abd <sys_cputs>
}
  80221f:	83 c4 10             	add    $0x10,%esp
  802222:	c9                   	leave  
  802223:	c3                   	ret    

00802224 <getchar>:

int
getchar(void)
{
  802224:	55                   	push   %ebp
  802225:	89 e5                	mov    %esp,%ebp
  802227:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  80222a:	6a 01                	push   $0x1
  80222c:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80222f:	50                   	push   %eax
  802230:	6a 00                	push   $0x0
  802232:	e8 36 f2 ff ff       	call   80146d <read>
	if (r < 0)
  802237:	83 c4 10             	add    $0x10,%esp
  80223a:	85 c0                	test   %eax,%eax
  80223c:	78 0f                	js     80224d <getchar+0x29>
		return r;
	if (r < 1)
  80223e:	85 c0                	test   %eax,%eax
  802240:	7e 06                	jle    802248 <getchar+0x24>
		return -E_EOF;
	return c;
  802242:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  802246:	eb 05                	jmp    80224d <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  802248:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80224d:	c9                   	leave  
  80224e:	c3                   	ret    

0080224f <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  80224f:	55                   	push   %ebp
  802250:	89 e5                	mov    %esp,%ebp
  802252:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802255:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802258:	50                   	push   %eax
  802259:	ff 75 08             	pushl  0x8(%ebp)
  80225c:	e8 a6 ef ff ff       	call   801207 <fd_lookup>
  802261:	83 c4 10             	add    $0x10,%esp
  802264:	85 c0                	test   %eax,%eax
  802266:	78 11                	js     802279 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  802268:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80226b:	8b 15 58 30 80 00    	mov    0x803058,%edx
  802271:	39 10                	cmp    %edx,(%eax)
  802273:	0f 94 c0             	sete   %al
  802276:	0f b6 c0             	movzbl %al,%eax
}
  802279:	c9                   	leave  
  80227a:	c3                   	ret    

0080227b <opencons>:

int
opencons(void)
{
  80227b:	55                   	push   %ebp
  80227c:	89 e5                	mov    %esp,%ebp
  80227e:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802281:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802284:	50                   	push   %eax
  802285:	e8 2e ef ff ff       	call   8011b8 <fd_alloc>
  80228a:	83 c4 10             	add    $0x10,%esp
		return r;
  80228d:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80228f:	85 c0                	test   %eax,%eax
  802291:	78 3e                	js     8022d1 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802293:	83 ec 04             	sub    $0x4,%esp
  802296:	68 07 04 00 00       	push   $0x407
  80229b:	ff 75 f4             	pushl  -0xc(%ebp)
  80229e:	6a 00                	push   $0x0
  8022a0:	e8 d4 e8 ff ff       	call   800b79 <sys_page_alloc>
  8022a5:	83 c4 10             	add    $0x10,%esp
		return r;
  8022a8:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8022aa:	85 c0                	test   %eax,%eax
  8022ac:	78 23                	js     8022d1 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8022ae:	8b 15 58 30 80 00    	mov    0x803058,%edx
  8022b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022b7:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8022b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022bc:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8022c3:	83 ec 0c             	sub    $0xc,%esp
  8022c6:	50                   	push   %eax
  8022c7:	e8 c5 ee ff ff       	call   801191 <fd2num>
  8022cc:	89 c2                	mov    %eax,%edx
  8022ce:	83 c4 10             	add    $0x10,%esp
}
  8022d1:	89 d0                	mov    %edx,%eax
  8022d3:	c9                   	leave  
  8022d4:	c3                   	ret    

008022d5 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8022d5:	55                   	push   %ebp
  8022d6:	89 e5                	mov    %esp,%ebp
  8022d8:	56                   	push   %esi
  8022d9:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8022da:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8022dd:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8022e3:	e8 53 e8 ff ff       	call   800b3b <sys_getenvid>
  8022e8:	83 ec 0c             	sub    $0xc,%esp
  8022eb:	ff 75 0c             	pushl  0xc(%ebp)
  8022ee:	ff 75 08             	pushl  0x8(%ebp)
  8022f1:	56                   	push   %esi
  8022f2:	50                   	push   %eax
  8022f3:	68 e0 2b 80 00       	push   $0x802be0
  8022f8:	e8 f4 de ff ff       	call   8001f1 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8022fd:	83 c4 18             	add    $0x18,%esp
  802300:	53                   	push   %ebx
  802301:	ff 75 10             	pushl  0x10(%ebp)
  802304:	e8 97 de ff ff       	call   8001a0 <vcprintf>
	cprintf("\n");
  802309:	c7 04 24 cc 2b 80 00 	movl   $0x802bcc,(%esp)
  802310:	e8 dc de ff ff       	call   8001f1 <cprintf>
  802315:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  802318:	cc                   	int3   
  802319:	eb fd                	jmp    802318 <_panic+0x43>

0080231b <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  80231b:	55                   	push   %ebp
  80231c:	89 e5                	mov    %esp,%ebp
  80231e:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  802321:	83 3d 00 70 80 00 00 	cmpl   $0x0,0x807000
  802328:	75 2e                	jne    802358 <set_pgfault_handler+0x3d>
		// First time through!
		// LAB 4: Your code here.
		// panic("set_pgfault_handler not implemented");

		sys_page_alloc(sys_getenvid(), (void *) (UXSTACKTOP - PGSIZE), PTE_SYSCALL);
  80232a:	e8 0c e8 ff ff       	call   800b3b <sys_getenvid>
  80232f:	83 ec 04             	sub    $0x4,%esp
  802332:	68 07 0e 00 00       	push   $0xe07
  802337:	68 00 f0 bf ee       	push   $0xeebff000
  80233c:	50                   	push   %eax
  80233d:	e8 37 e8 ff ff       	call   800b79 <sys_page_alloc>
		sys_env_set_pgfault_upcall(sys_getenvid(), _pgfault_upcall);
  802342:	e8 f4 e7 ff ff       	call   800b3b <sys_getenvid>
  802347:	83 c4 08             	add    $0x8,%esp
  80234a:	68 62 23 80 00       	push   $0x802362
  80234f:	50                   	push   %eax
  802350:	e8 6f e9 ff ff       	call   800cc4 <sys_env_set_pgfault_upcall>
  802355:	83 c4 10             	add    $0x10,%esp
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802358:	8b 45 08             	mov    0x8(%ebp),%eax
  80235b:	a3 00 70 80 00       	mov    %eax,0x807000
}
  802360:	c9                   	leave  
  802361:	c3                   	ret    

00802362 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802362:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802363:	a1 00 70 80 00       	mov    0x807000,%eax
	call *%eax
  802368:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  80236a:	83 c4 04             	add    $0x4,%esp
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.

	movl 48(%esp), %eax		// trap-time esp
  80236d:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl 40(%esp), %ebx		// trap-time eip
  802371:	8b 5c 24 28          	mov    0x28(%esp),%ebx

	// load eip into esp-4
	// in order to return to trap-time eip later, in the meantime not changing trap-time esp
	movl %ebx, -4(%eax)	
  802375:	89 58 fc             	mov    %ebx,-0x4(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.

	addl $8, %esp 			// esp now points to trap-time registers
  802378:	83 c4 08             	add    $0x8,%esp
	popal					// pop to all registers
  80237b:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

	addl $4, %esp			// esp now points to trap-time eflags
  80237c:	83 c4 04             	add    $0x4,%esp
	popfl					// pop to eflags
  80237f:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.

	popl %esp				// pop to esp
  802380:	5c                   	pop    %esp
	// subl $4, %esp		// arithmetic operation will change eflags!!!
	lea -4(%esp), %esp		// subl $4, %esp
  802381:	8d 64 24 fc          	lea    -0x4(%esp),%esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.

	ret
  802385:	c3                   	ret    

00802386 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802386:	55                   	push   %ebp
  802387:	89 e5                	mov    %esp,%ebp
  802389:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80238c:	89 d0                	mov    %edx,%eax
  80238e:	c1 e8 16             	shr    $0x16,%eax
  802391:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802398:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80239d:	f6 c1 01             	test   $0x1,%cl
  8023a0:	74 1d                	je     8023bf <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  8023a2:	c1 ea 0c             	shr    $0xc,%edx
  8023a5:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  8023ac:	f6 c2 01             	test   $0x1,%dl
  8023af:	74 0e                	je     8023bf <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8023b1:	c1 ea 0c             	shr    $0xc,%edx
  8023b4:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8023bb:	ef 
  8023bc:	0f b7 c0             	movzwl %ax,%eax
}
  8023bf:	5d                   	pop    %ebp
  8023c0:	c3                   	ret    
  8023c1:	66 90                	xchg   %ax,%ax
  8023c3:	66 90                	xchg   %ax,%ax
  8023c5:	66 90                	xchg   %ax,%ax
  8023c7:	66 90                	xchg   %ax,%ax
  8023c9:	66 90                	xchg   %ax,%ax
  8023cb:	66 90                	xchg   %ax,%ax
  8023cd:	66 90                	xchg   %ax,%ax
  8023cf:	90                   	nop

008023d0 <__udivdi3>:
  8023d0:	55                   	push   %ebp
  8023d1:	57                   	push   %edi
  8023d2:	56                   	push   %esi
  8023d3:	53                   	push   %ebx
  8023d4:	83 ec 1c             	sub    $0x1c,%esp
  8023d7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  8023db:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  8023df:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  8023e3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8023e7:	85 f6                	test   %esi,%esi
  8023e9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8023ed:	89 ca                	mov    %ecx,%edx
  8023ef:	89 f8                	mov    %edi,%eax
  8023f1:	75 3d                	jne    802430 <__udivdi3+0x60>
  8023f3:	39 cf                	cmp    %ecx,%edi
  8023f5:	0f 87 c5 00 00 00    	ja     8024c0 <__udivdi3+0xf0>
  8023fb:	85 ff                	test   %edi,%edi
  8023fd:	89 fd                	mov    %edi,%ebp
  8023ff:	75 0b                	jne    80240c <__udivdi3+0x3c>
  802401:	b8 01 00 00 00       	mov    $0x1,%eax
  802406:	31 d2                	xor    %edx,%edx
  802408:	f7 f7                	div    %edi
  80240a:	89 c5                	mov    %eax,%ebp
  80240c:	89 c8                	mov    %ecx,%eax
  80240e:	31 d2                	xor    %edx,%edx
  802410:	f7 f5                	div    %ebp
  802412:	89 c1                	mov    %eax,%ecx
  802414:	89 d8                	mov    %ebx,%eax
  802416:	89 cf                	mov    %ecx,%edi
  802418:	f7 f5                	div    %ebp
  80241a:	89 c3                	mov    %eax,%ebx
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
  802430:	39 ce                	cmp    %ecx,%esi
  802432:	77 74                	ja     8024a8 <__udivdi3+0xd8>
  802434:	0f bd fe             	bsr    %esi,%edi
  802437:	83 f7 1f             	xor    $0x1f,%edi
  80243a:	0f 84 98 00 00 00    	je     8024d8 <__udivdi3+0x108>
  802440:	bb 20 00 00 00       	mov    $0x20,%ebx
  802445:	89 f9                	mov    %edi,%ecx
  802447:	89 c5                	mov    %eax,%ebp
  802449:	29 fb                	sub    %edi,%ebx
  80244b:	d3 e6                	shl    %cl,%esi
  80244d:	89 d9                	mov    %ebx,%ecx
  80244f:	d3 ed                	shr    %cl,%ebp
  802451:	89 f9                	mov    %edi,%ecx
  802453:	d3 e0                	shl    %cl,%eax
  802455:	09 ee                	or     %ebp,%esi
  802457:	89 d9                	mov    %ebx,%ecx
  802459:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80245d:	89 d5                	mov    %edx,%ebp
  80245f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802463:	d3 ed                	shr    %cl,%ebp
  802465:	89 f9                	mov    %edi,%ecx
  802467:	d3 e2                	shl    %cl,%edx
  802469:	89 d9                	mov    %ebx,%ecx
  80246b:	d3 e8                	shr    %cl,%eax
  80246d:	09 c2                	or     %eax,%edx
  80246f:	89 d0                	mov    %edx,%eax
  802471:	89 ea                	mov    %ebp,%edx
  802473:	f7 f6                	div    %esi
  802475:	89 d5                	mov    %edx,%ebp
  802477:	89 c3                	mov    %eax,%ebx
  802479:	f7 64 24 0c          	mull   0xc(%esp)
  80247d:	39 d5                	cmp    %edx,%ebp
  80247f:	72 10                	jb     802491 <__udivdi3+0xc1>
  802481:	8b 74 24 08          	mov    0x8(%esp),%esi
  802485:	89 f9                	mov    %edi,%ecx
  802487:	d3 e6                	shl    %cl,%esi
  802489:	39 c6                	cmp    %eax,%esi
  80248b:	73 07                	jae    802494 <__udivdi3+0xc4>
  80248d:	39 d5                	cmp    %edx,%ebp
  80248f:	75 03                	jne    802494 <__udivdi3+0xc4>
  802491:	83 eb 01             	sub    $0x1,%ebx
  802494:	31 ff                	xor    %edi,%edi
  802496:	89 d8                	mov    %ebx,%eax
  802498:	89 fa                	mov    %edi,%edx
  80249a:	83 c4 1c             	add    $0x1c,%esp
  80249d:	5b                   	pop    %ebx
  80249e:	5e                   	pop    %esi
  80249f:	5f                   	pop    %edi
  8024a0:	5d                   	pop    %ebp
  8024a1:	c3                   	ret    
  8024a2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8024a8:	31 ff                	xor    %edi,%edi
  8024aa:	31 db                	xor    %ebx,%ebx
  8024ac:	89 d8                	mov    %ebx,%eax
  8024ae:	89 fa                	mov    %edi,%edx
  8024b0:	83 c4 1c             	add    $0x1c,%esp
  8024b3:	5b                   	pop    %ebx
  8024b4:	5e                   	pop    %esi
  8024b5:	5f                   	pop    %edi
  8024b6:	5d                   	pop    %ebp
  8024b7:	c3                   	ret    
  8024b8:	90                   	nop
  8024b9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8024c0:	89 d8                	mov    %ebx,%eax
  8024c2:	f7 f7                	div    %edi
  8024c4:	31 ff                	xor    %edi,%edi
  8024c6:	89 c3                	mov    %eax,%ebx
  8024c8:	89 d8                	mov    %ebx,%eax
  8024ca:	89 fa                	mov    %edi,%edx
  8024cc:	83 c4 1c             	add    $0x1c,%esp
  8024cf:	5b                   	pop    %ebx
  8024d0:	5e                   	pop    %esi
  8024d1:	5f                   	pop    %edi
  8024d2:	5d                   	pop    %ebp
  8024d3:	c3                   	ret    
  8024d4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8024d8:	39 ce                	cmp    %ecx,%esi
  8024da:	72 0c                	jb     8024e8 <__udivdi3+0x118>
  8024dc:	31 db                	xor    %ebx,%ebx
  8024de:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8024e2:	0f 87 34 ff ff ff    	ja     80241c <__udivdi3+0x4c>
  8024e8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8024ed:	e9 2a ff ff ff       	jmp    80241c <__udivdi3+0x4c>
  8024f2:	66 90                	xchg   %ax,%ax
  8024f4:	66 90                	xchg   %ax,%ax
  8024f6:	66 90                	xchg   %ax,%ax
  8024f8:	66 90                	xchg   %ax,%ax
  8024fa:	66 90                	xchg   %ax,%ax
  8024fc:	66 90                	xchg   %ax,%ax
  8024fe:	66 90                	xchg   %ax,%ax

00802500 <__umoddi3>:
  802500:	55                   	push   %ebp
  802501:	57                   	push   %edi
  802502:	56                   	push   %esi
  802503:	53                   	push   %ebx
  802504:	83 ec 1c             	sub    $0x1c,%esp
  802507:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80250b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80250f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802513:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802517:	85 d2                	test   %edx,%edx
  802519:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80251d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802521:	89 f3                	mov    %esi,%ebx
  802523:	89 3c 24             	mov    %edi,(%esp)
  802526:	89 74 24 04          	mov    %esi,0x4(%esp)
  80252a:	75 1c                	jne    802548 <__umoddi3+0x48>
  80252c:	39 f7                	cmp    %esi,%edi
  80252e:	76 50                	jbe    802580 <__umoddi3+0x80>
  802530:	89 c8                	mov    %ecx,%eax
  802532:	89 f2                	mov    %esi,%edx
  802534:	f7 f7                	div    %edi
  802536:	89 d0                	mov    %edx,%eax
  802538:	31 d2                	xor    %edx,%edx
  80253a:	83 c4 1c             	add    $0x1c,%esp
  80253d:	5b                   	pop    %ebx
  80253e:	5e                   	pop    %esi
  80253f:	5f                   	pop    %edi
  802540:	5d                   	pop    %ebp
  802541:	c3                   	ret    
  802542:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802548:	39 f2                	cmp    %esi,%edx
  80254a:	89 d0                	mov    %edx,%eax
  80254c:	77 52                	ja     8025a0 <__umoddi3+0xa0>
  80254e:	0f bd ea             	bsr    %edx,%ebp
  802551:	83 f5 1f             	xor    $0x1f,%ebp
  802554:	75 5a                	jne    8025b0 <__umoddi3+0xb0>
  802556:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80255a:	0f 82 e0 00 00 00    	jb     802640 <__umoddi3+0x140>
  802560:	39 0c 24             	cmp    %ecx,(%esp)
  802563:	0f 86 d7 00 00 00    	jbe    802640 <__umoddi3+0x140>
  802569:	8b 44 24 08          	mov    0x8(%esp),%eax
  80256d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802571:	83 c4 1c             	add    $0x1c,%esp
  802574:	5b                   	pop    %ebx
  802575:	5e                   	pop    %esi
  802576:	5f                   	pop    %edi
  802577:	5d                   	pop    %ebp
  802578:	c3                   	ret    
  802579:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802580:	85 ff                	test   %edi,%edi
  802582:	89 fd                	mov    %edi,%ebp
  802584:	75 0b                	jne    802591 <__umoddi3+0x91>
  802586:	b8 01 00 00 00       	mov    $0x1,%eax
  80258b:	31 d2                	xor    %edx,%edx
  80258d:	f7 f7                	div    %edi
  80258f:	89 c5                	mov    %eax,%ebp
  802591:	89 f0                	mov    %esi,%eax
  802593:	31 d2                	xor    %edx,%edx
  802595:	f7 f5                	div    %ebp
  802597:	89 c8                	mov    %ecx,%eax
  802599:	f7 f5                	div    %ebp
  80259b:	89 d0                	mov    %edx,%eax
  80259d:	eb 99                	jmp    802538 <__umoddi3+0x38>
  80259f:	90                   	nop
  8025a0:	89 c8                	mov    %ecx,%eax
  8025a2:	89 f2                	mov    %esi,%edx
  8025a4:	83 c4 1c             	add    $0x1c,%esp
  8025a7:	5b                   	pop    %ebx
  8025a8:	5e                   	pop    %esi
  8025a9:	5f                   	pop    %edi
  8025aa:	5d                   	pop    %ebp
  8025ab:	c3                   	ret    
  8025ac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8025b0:	8b 34 24             	mov    (%esp),%esi
  8025b3:	bf 20 00 00 00       	mov    $0x20,%edi
  8025b8:	89 e9                	mov    %ebp,%ecx
  8025ba:	29 ef                	sub    %ebp,%edi
  8025bc:	d3 e0                	shl    %cl,%eax
  8025be:	89 f9                	mov    %edi,%ecx
  8025c0:	89 f2                	mov    %esi,%edx
  8025c2:	d3 ea                	shr    %cl,%edx
  8025c4:	89 e9                	mov    %ebp,%ecx
  8025c6:	09 c2                	or     %eax,%edx
  8025c8:	89 d8                	mov    %ebx,%eax
  8025ca:	89 14 24             	mov    %edx,(%esp)
  8025cd:	89 f2                	mov    %esi,%edx
  8025cf:	d3 e2                	shl    %cl,%edx
  8025d1:	89 f9                	mov    %edi,%ecx
  8025d3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8025d7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8025db:	d3 e8                	shr    %cl,%eax
  8025dd:	89 e9                	mov    %ebp,%ecx
  8025df:	89 c6                	mov    %eax,%esi
  8025e1:	d3 e3                	shl    %cl,%ebx
  8025e3:	89 f9                	mov    %edi,%ecx
  8025e5:	89 d0                	mov    %edx,%eax
  8025e7:	d3 e8                	shr    %cl,%eax
  8025e9:	89 e9                	mov    %ebp,%ecx
  8025eb:	09 d8                	or     %ebx,%eax
  8025ed:	89 d3                	mov    %edx,%ebx
  8025ef:	89 f2                	mov    %esi,%edx
  8025f1:	f7 34 24             	divl   (%esp)
  8025f4:	89 d6                	mov    %edx,%esi
  8025f6:	d3 e3                	shl    %cl,%ebx
  8025f8:	f7 64 24 04          	mull   0x4(%esp)
  8025fc:	39 d6                	cmp    %edx,%esi
  8025fe:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802602:	89 d1                	mov    %edx,%ecx
  802604:	89 c3                	mov    %eax,%ebx
  802606:	72 08                	jb     802610 <__umoddi3+0x110>
  802608:	75 11                	jne    80261b <__umoddi3+0x11b>
  80260a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80260e:	73 0b                	jae    80261b <__umoddi3+0x11b>
  802610:	2b 44 24 04          	sub    0x4(%esp),%eax
  802614:	1b 14 24             	sbb    (%esp),%edx
  802617:	89 d1                	mov    %edx,%ecx
  802619:	89 c3                	mov    %eax,%ebx
  80261b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80261f:	29 da                	sub    %ebx,%edx
  802621:	19 ce                	sbb    %ecx,%esi
  802623:	89 f9                	mov    %edi,%ecx
  802625:	89 f0                	mov    %esi,%eax
  802627:	d3 e0                	shl    %cl,%eax
  802629:	89 e9                	mov    %ebp,%ecx
  80262b:	d3 ea                	shr    %cl,%edx
  80262d:	89 e9                	mov    %ebp,%ecx
  80262f:	d3 ee                	shr    %cl,%esi
  802631:	09 d0                	or     %edx,%eax
  802633:	89 f2                	mov    %esi,%edx
  802635:	83 c4 1c             	add    $0x1c,%esp
  802638:	5b                   	pop    %ebx
  802639:	5e                   	pop    %esi
  80263a:	5f                   	pop    %edi
  80263b:	5d                   	pop    %ebp
  80263c:	c3                   	ret    
  80263d:	8d 76 00             	lea    0x0(%esi),%esi
  802640:	29 f9                	sub    %edi,%ecx
  802642:	19 d6                	sbb    %edx,%esi
  802644:	89 74 24 04          	mov    %esi,0x4(%esp)
  802648:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80264c:	e9 18 ff ff ff       	jmp    802569 <__umoddi3+0x69>
