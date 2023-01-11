
obj/user/icode.debug:     file format elf32-i386


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
  80002c:	e8 03 01 00 00       	call   800134 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:
#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	56                   	push   %esi
  800037:	53                   	push   %ebx
  800038:	81 ec 1c 02 00 00    	sub    $0x21c,%esp
	int fd, n, r;
	char buf[512+1];

	binaryname = "icode";
  80003e:	c7 05 00 30 80 00 80 	movl   $0x802980,0x803000
  800045:	29 80 00 

	cprintf("icode startup\n");
  800048:	68 86 29 80 00       	push   $0x802986
  80004d:	e8 1b 02 00 00       	call   80026d <cprintf>

	cprintf("icode: open /motd\n");
  800052:	c7 04 24 95 29 80 00 	movl   $0x802995,(%esp)
  800059:	e8 0f 02 00 00       	call   80026d <cprintf>
	if ((fd = open("/motd", O_RDONLY)) < 0)
  80005e:	83 c4 08             	add    $0x8,%esp
  800061:	6a 00                	push   $0x0
  800063:	68 a8 29 80 00       	push   $0x8029a8
  800068:	e8 76 15 00 00       	call   8015e3 <open>
  80006d:	89 c6                	mov    %eax,%esi
  80006f:	83 c4 10             	add    $0x10,%esp
  800072:	85 c0                	test   %eax,%eax
  800074:	79 12                	jns    800088 <umain+0x55>
		panic("icode: open /motd: %e", fd);
  800076:	50                   	push   %eax
  800077:	68 ae 29 80 00       	push   $0x8029ae
  80007c:	6a 0f                	push   $0xf
  80007e:	68 c4 29 80 00       	push   $0x8029c4
  800083:	e8 0c 01 00 00       	call   800194 <_panic>

	cprintf("icode: read /motd\n");
  800088:	83 ec 0c             	sub    $0xc,%esp
  80008b:	68 d1 29 80 00       	push   $0x8029d1
  800090:	e8 d8 01 00 00       	call   80026d <cprintf>
	while ((n = read(fd, buf, sizeof buf-1)) > 0)
  800095:	83 c4 10             	add    $0x10,%esp
  800098:	8d 9d f7 fd ff ff    	lea    -0x209(%ebp),%ebx
  80009e:	eb 0d                	jmp    8000ad <umain+0x7a>
		sys_cputs(buf, n);
  8000a0:	83 ec 08             	sub    $0x8,%esp
  8000a3:	50                   	push   %eax
  8000a4:	53                   	push   %ebx
  8000a5:	e8 8f 0a 00 00       	call   800b39 <sys_cputs>
  8000aa:	83 c4 10             	add    $0x10,%esp
	cprintf("icode: open /motd\n");
	if ((fd = open("/motd", O_RDONLY)) < 0)
		panic("icode: open /motd: %e", fd);

	cprintf("icode: read /motd\n");
	while ((n = read(fd, buf, sizeof buf-1)) > 0)
  8000ad:	83 ec 04             	sub    $0x4,%esp
  8000b0:	68 00 02 00 00       	push   $0x200
  8000b5:	53                   	push   %ebx
  8000b6:	56                   	push   %esi
  8000b7:	e8 a9 10 00 00       	call   801165 <read>
  8000bc:	83 c4 10             	add    $0x10,%esp
  8000bf:	85 c0                	test   %eax,%eax
  8000c1:	7f dd                	jg     8000a0 <umain+0x6d>
		sys_cputs(buf, n);

	cprintf("icode: close /motd\n");
  8000c3:	83 ec 0c             	sub    $0xc,%esp
  8000c6:	68 e4 29 80 00       	push   $0x8029e4
  8000cb:	e8 9d 01 00 00       	call   80026d <cprintf>
	close(fd);
  8000d0:	89 34 24             	mov    %esi,(%esp)
  8000d3:	e8 51 0f 00 00       	call   801029 <close>

	cprintf("icode: spawn /init\n");
  8000d8:	c7 04 24 f8 29 80 00 	movl   $0x8029f8,(%esp)
  8000df:	e8 89 01 00 00       	call   80026d <cprintf>
	if ((r = spawnl("/init", "init", "initarg1", "initarg2", (char*)0)) < 0)
  8000e4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000eb:	68 0c 2a 80 00       	push   $0x802a0c
  8000f0:	68 15 2a 80 00       	push   $0x802a15
  8000f5:	68 1f 2a 80 00       	push   $0x802a1f
  8000fa:	68 1e 2a 80 00       	push   $0x802a1e
  8000ff:	e8 00 1b 00 00       	call   801c04 <spawnl>
  800104:	83 c4 20             	add    $0x20,%esp
  800107:	85 c0                	test   %eax,%eax
  800109:	79 12                	jns    80011d <umain+0xea>
		panic("icode: spawn /init: %e", r);
  80010b:	50                   	push   %eax
  80010c:	68 24 2a 80 00       	push   $0x802a24
  800111:	6a 1a                	push   $0x1a
  800113:	68 c4 29 80 00       	push   $0x8029c4
  800118:	e8 77 00 00 00       	call   800194 <_panic>

	cprintf("icode: exiting\n");
  80011d:	83 ec 0c             	sub    $0xc,%esp
  800120:	68 3b 2a 80 00       	push   $0x802a3b
  800125:	e8 43 01 00 00       	call   80026d <cprintf>
}
  80012a:	83 c4 10             	add    $0x10,%esp
  80012d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800130:	5b                   	pop    %ebx
  800131:	5e                   	pop    %esi
  800132:	5d                   	pop    %ebp
  800133:	c3                   	ret    

00800134 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800134:	55                   	push   %ebp
  800135:	89 e5                	mov    %esp,%ebp
  800137:	56                   	push   %esi
  800138:	53                   	push   %ebx
  800139:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80013c:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  80013f:	e8 73 0a 00 00       	call   800bb7 <sys_getenvid>
  800144:	25 ff 03 00 00       	and    $0x3ff,%eax
  800149:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80014c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800151:	a3 08 40 80 00       	mov    %eax,0x804008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800156:	85 db                	test   %ebx,%ebx
  800158:	7e 07                	jle    800161 <libmain+0x2d>
		binaryname = argv[0];
  80015a:	8b 06                	mov    (%esi),%eax
  80015c:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800161:	83 ec 08             	sub    $0x8,%esp
  800164:	56                   	push   %esi
  800165:	53                   	push   %ebx
  800166:	e8 c8 fe ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80016b:	e8 0a 00 00 00       	call   80017a <exit>
}
  800170:	83 c4 10             	add    $0x10,%esp
  800173:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800176:	5b                   	pop    %ebx
  800177:	5e                   	pop    %esi
  800178:	5d                   	pop    %ebp
  800179:	c3                   	ret    

0080017a <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80017a:	55                   	push   %ebp
  80017b:	89 e5                	mov    %esp,%ebp
  80017d:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800180:	e8 cf 0e 00 00       	call   801054 <close_all>
	sys_env_destroy(0);
  800185:	83 ec 0c             	sub    $0xc,%esp
  800188:	6a 00                	push   $0x0
  80018a:	e8 e7 09 00 00       	call   800b76 <sys_env_destroy>
}
  80018f:	83 c4 10             	add    $0x10,%esp
  800192:	c9                   	leave  
  800193:	c3                   	ret    

00800194 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800194:	55                   	push   %ebp
  800195:	89 e5                	mov    %esp,%ebp
  800197:	56                   	push   %esi
  800198:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800199:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80019c:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8001a2:	e8 10 0a 00 00       	call   800bb7 <sys_getenvid>
  8001a7:	83 ec 0c             	sub    $0xc,%esp
  8001aa:	ff 75 0c             	pushl  0xc(%ebp)
  8001ad:	ff 75 08             	pushl  0x8(%ebp)
  8001b0:	56                   	push   %esi
  8001b1:	50                   	push   %eax
  8001b2:	68 58 2a 80 00       	push   $0x802a58
  8001b7:	e8 b1 00 00 00       	call   80026d <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001bc:	83 c4 18             	add    $0x18,%esp
  8001bf:	53                   	push   %ebx
  8001c0:	ff 75 10             	pushl  0x10(%ebp)
  8001c3:	e8 54 00 00 00       	call   80021c <vcprintf>
	cprintf("\n");
  8001c8:	c7 04 24 75 2f 80 00 	movl   $0x802f75,(%esp)
  8001cf:	e8 99 00 00 00       	call   80026d <cprintf>
  8001d4:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001d7:	cc                   	int3   
  8001d8:	eb fd                	jmp    8001d7 <_panic+0x43>

008001da <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001da:	55                   	push   %ebp
  8001db:	89 e5                	mov    %esp,%ebp
  8001dd:	53                   	push   %ebx
  8001de:	83 ec 04             	sub    $0x4,%esp
  8001e1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001e4:	8b 13                	mov    (%ebx),%edx
  8001e6:	8d 42 01             	lea    0x1(%edx),%eax
  8001e9:	89 03                	mov    %eax,(%ebx)
  8001eb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001ee:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001f2:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001f7:	75 1a                	jne    800213 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8001f9:	83 ec 08             	sub    $0x8,%esp
  8001fc:	68 ff 00 00 00       	push   $0xff
  800201:	8d 43 08             	lea    0x8(%ebx),%eax
  800204:	50                   	push   %eax
  800205:	e8 2f 09 00 00       	call   800b39 <sys_cputs>
		b->idx = 0;
  80020a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800210:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800213:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800217:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80021a:	c9                   	leave  
  80021b:	c3                   	ret    

0080021c <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80021c:	55                   	push   %ebp
  80021d:	89 e5                	mov    %esp,%ebp
  80021f:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800225:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80022c:	00 00 00 
	b.cnt = 0;
  80022f:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800236:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800239:	ff 75 0c             	pushl  0xc(%ebp)
  80023c:	ff 75 08             	pushl  0x8(%ebp)
  80023f:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800245:	50                   	push   %eax
  800246:	68 da 01 80 00       	push   $0x8001da
  80024b:	e8 54 01 00 00       	call   8003a4 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800250:	83 c4 08             	add    $0x8,%esp
  800253:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800259:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80025f:	50                   	push   %eax
  800260:	e8 d4 08 00 00       	call   800b39 <sys_cputs>

	return b.cnt;
}
  800265:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80026b:	c9                   	leave  
  80026c:	c3                   	ret    

0080026d <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80026d:	55                   	push   %ebp
  80026e:	89 e5                	mov    %esp,%ebp
  800270:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800273:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800276:	50                   	push   %eax
  800277:	ff 75 08             	pushl  0x8(%ebp)
  80027a:	e8 9d ff ff ff       	call   80021c <vcprintf>
	va_end(ap);

	return cnt;
}
  80027f:	c9                   	leave  
  800280:	c3                   	ret    

00800281 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800281:	55                   	push   %ebp
  800282:	89 e5                	mov    %esp,%ebp
  800284:	57                   	push   %edi
  800285:	56                   	push   %esi
  800286:	53                   	push   %ebx
  800287:	83 ec 1c             	sub    $0x1c,%esp
  80028a:	89 c7                	mov    %eax,%edi
  80028c:	89 d6                	mov    %edx,%esi
  80028e:	8b 45 08             	mov    0x8(%ebp),%eax
  800291:	8b 55 0c             	mov    0xc(%ebp),%edx
  800294:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800297:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80029a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80029d:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002a2:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8002a5:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8002a8:	39 d3                	cmp    %edx,%ebx
  8002aa:	72 05                	jb     8002b1 <printnum+0x30>
  8002ac:	39 45 10             	cmp    %eax,0x10(%ebp)
  8002af:	77 45                	ja     8002f6 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002b1:	83 ec 0c             	sub    $0xc,%esp
  8002b4:	ff 75 18             	pushl  0x18(%ebp)
  8002b7:	8b 45 14             	mov    0x14(%ebp),%eax
  8002ba:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8002bd:	53                   	push   %ebx
  8002be:	ff 75 10             	pushl  0x10(%ebp)
  8002c1:	83 ec 08             	sub    $0x8,%esp
  8002c4:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002c7:	ff 75 e0             	pushl  -0x20(%ebp)
  8002ca:	ff 75 dc             	pushl  -0x24(%ebp)
  8002cd:	ff 75 d8             	pushl  -0x28(%ebp)
  8002d0:	e8 1b 24 00 00       	call   8026f0 <__udivdi3>
  8002d5:	83 c4 18             	add    $0x18,%esp
  8002d8:	52                   	push   %edx
  8002d9:	50                   	push   %eax
  8002da:	89 f2                	mov    %esi,%edx
  8002dc:	89 f8                	mov    %edi,%eax
  8002de:	e8 9e ff ff ff       	call   800281 <printnum>
  8002e3:	83 c4 20             	add    $0x20,%esp
  8002e6:	eb 18                	jmp    800300 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002e8:	83 ec 08             	sub    $0x8,%esp
  8002eb:	56                   	push   %esi
  8002ec:	ff 75 18             	pushl  0x18(%ebp)
  8002ef:	ff d7                	call   *%edi
  8002f1:	83 c4 10             	add    $0x10,%esp
  8002f4:	eb 03                	jmp    8002f9 <printnum+0x78>
  8002f6:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002f9:	83 eb 01             	sub    $0x1,%ebx
  8002fc:	85 db                	test   %ebx,%ebx
  8002fe:	7f e8                	jg     8002e8 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800300:	83 ec 08             	sub    $0x8,%esp
  800303:	56                   	push   %esi
  800304:	83 ec 04             	sub    $0x4,%esp
  800307:	ff 75 e4             	pushl  -0x1c(%ebp)
  80030a:	ff 75 e0             	pushl  -0x20(%ebp)
  80030d:	ff 75 dc             	pushl  -0x24(%ebp)
  800310:	ff 75 d8             	pushl  -0x28(%ebp)
  800313:	e8 08 25 00 00       	call   802820 <__umoddi3>
  800318:	83 c4 14             	add    $0x14,%esp
  80031b:	0f be 80 7b 2a 80 00 	movsbl 0x802a7b(%eax),%eax
  800322:	50                   	push   %eax
  800323:	ff d7                	call   *%edi
}
  800325:	83 c4 10             	add    $0x10,%esp
  800328:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80032b:	5b                   	pop    %ebx
  80032c:	5e                   	pop    %esi
  80032d:	5f                   	pop    %edi
  80032e:	5d                   	pop    %ebp
  80032f:	c3                   	ret    

00800330 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800330:	55                   	push   %ebp
  800331:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800333:	83 fa 01             	cmp    $0x1,%edx
  800336:	7e 0e                	jle    800346 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800338:	8b 10                	mov    (%eax),%edx
  80033a:	8d 4a 08             	lea    0x8(%edx),%ecx
  80033d:	89 08                	mov    %ecx,(%eax)
  80033f:	8b 02                	mov    (%edx),%eax
  800341:	8b 52 04             	mov    0x4(%edx),%edx
  800344:	eb 22                	jmp    800368 <getuint+0x38>
	else if (lflag)
  800346:	85 d2                	test   %edx,%edx
  800348:	74 10                	je     80035a <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80034a:	8b 10                	mov    (%eax),%edx
  80034c:	8d 4a 04             	lea    0x4(%edx),%ecx
  80034f:	89 08                	mov    %ecx,(%eax)
  800351:	8b 02                	mov    (%edx),%eax
  800353:	ba 00 00 00 00       	mov    $0x0,%edx
  800358:	eb 0e                	jmp    800368 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80035a:	8b 10                	mov    (%eax),%edx
  80035c:	8d 4a 04             	lea    0x4(%edx),%ecx
  80035f:	89 08                	mov    %ecx,(%eax)
  800361:	8b 02                	mov    (%edx),%eax
  800363:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800368:	5d                   	pop    %ebp
  800369:	c3                   	ret    

0080036a <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80036a:	55                   	push   %ebp
  80036b:	89 e5                	mov    %esp,%ebp
  80036d:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800370:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800374:	8b 10                	mov    (%eax),%edx
  800376:	3b 50 04             	cmp    0x4(%eax),%edx
  800379:	73 0a                	jae    800385 <sprintputch+0x1b>
		*b->buf++ = ch;
  80037b:	8d 4a 01             	lea    0x1(%edx),%ecx
  80037e:	89 08                	mov    %ecx,(%eax)
  800380:	8b 45 08             	mov    0x8(%ebp),%eax
  800383:	88 02                	mov    %al,(%edx)
}
  800385:	5d                   	pop    %ebp
  800386:	c3                   	ret    

00800387 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800387:	55                   	push   %ebp
  800388:	89 e5                	mov    %esp,%ebp
  80038a:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80038d:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800390:	50                   	push   %eax
  800391:	ff 75 10             	pushl  0x10(%ebp)
  800394:	ff 75 0c             	pushl  0xc(%ebp)
  800397:	ff 75 08             	pushl  0x8(%ebp)
  80039a:	e8 05 00 00 00       	call   8003a4 <vprintfmt>
	va_end(ap);
}
  80039f:	83 c4 10             	add    $0x10,%esp
  8003a2:	c9                   	leave  
  8003a3:	c3                   	ret    

008003a4 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8003a4:	55                   	push   %ebp
  8003a5:	89 e5                	mov    %esp,%ebp
  8003a7:	57                   	push   %edi
  8003a8:	56                   	push   %esi
  8003a9:	53                   	push   %ebx
  8003aa:	83 ec 2c             	sub    $0x2c,%esp
  8003ad:	8b 75 08             	mov    0x8(%ebp),%esi
  8003b0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8003b3:	8b 7d 10             	mov    0x10(%ebp),%edi
  8003b6:	eb 12                	jmp    8003ca <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8003b8:	85 c0                	test   %eax,%eax
  8003ba:	0f 84 89 03 00 00    	je     800749 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  8003c0:	83 ec 08             	sub    $0x8,%esp
  8003c3:	53                   	push   %ebx
  8003c4:	50                   	push   %eax
  8003c5:	ff d6                	call   *%esi
  8003c7:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003ca:	83 c7 01             	add    $0x1,%edi
  8003cd:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8003d1:	83 f8 25             	cmp    $0x25,%eax
  8003d4:	75 e2                	jne    8003b8 <vprintfmt+0x14>
  8003d6:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8003da:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8003e1:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003e8:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8003ef:	ba 00 00 00 00       	mov    $0x0,%edx
  8003f4:	eb 07                	jmp    8003fd <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003f6:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8003f9:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003fd:	8d 47 01             	lea    0x1(%edi),%eax
  800400:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800403:	0f b6 07             	movzbl (%edi),%eax
  800406:	0f b6 c8             	movzbl %al,%ecx
  800409:	83 e8 23             	sub    $0x23,%eax
  80040c:	3c 55                	cmp    $0x55,%al
  80040e:	0f 87 1a 03 00 00    	ja     80072e <vprintfmt+0x38a>
  800414:	0f b6 c0             	movzbl %al,%eax
  800417:	ff 24 85 c0 2b 80 00 	jmp    *0x802bc0(,%eax,4)
  80041e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800421:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800425:	eb d6                	jmp    8003fd <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800427:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80042a:	b8 00 00 00 00       	mov    $0x0,%eax
  80042f:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800432:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800435:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800439:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  80043c:	8d 51 d0             	lea    -0x30(%ecx),%edx
  80043f:	83 fa 09             	cmp    $0x9,%edx
  800442:	77 39                	ja     80047d <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800444:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800447:	eb e9                	jmp    800432 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800449:	8b 45 14             	mov    0x14(%ebp),%eax
  80044c:	8d 48 04             	lea    0x4(%eax),%ecx
  80044f:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800452:	8b 00                	mov    (%eax),%eax
  800454:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800457:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80045a:	eb 27                	jmp    800483 <vprintfmt+0xdf>
  80045c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80045f:	85 c0                	test   %eax,%eax
  800461:	b9 00 00 00 00       	mov    $0x0,%ecx
  800466:	0f 49 c8             	cmovns %eax,%ecx
  800469:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80046c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80046f:	eb 8c                	jmp    8003fd <vprintfmt+0x59>
  800471:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800474:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80047b:	eb 80                	jmp    8003fd <vprintfmt+0x59>
  80047d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800480:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800483:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800487:	0f 89 70 ff ff ff    	jns    8003fd <vprintfmt+0x59>
				width = precision, precision = -1;
  80048d:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800490:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800493:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80049a:	e9 5e ff ff ff       	jmp    8003fd <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80049f:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004a2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8004a5:	e9 53 ff ff ff       	jmp    8003fd <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8004aa:	8b 45 14             	mov    0x14(%ebp),%eax
  8004ad:	8d 50 04             	lea    0x4(%eax),%edx
  8004b0:	89 55 14             	mov    %edx,0x14(%ebp)
  8004b3:	83 ec 08             	sub    $0x8,%esp
  8004b6:	53                   	push   %ebx
  8004b7:	ff 30                	pushl  (%eax)
  8004b9:	ff d6                	call   *%esi
			break;
  8004bb:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004be:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8004c1:	e9 04 ff ff ff       	jmp    8003ca <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8004c6:	8b 45 14             	mov    0x14(%ebp),%eax
  8004c9:	8d 50 04             	lea    0x4(%eax),%edx
  8004cc:	89 55 14             	mov    %edx,0x14(%ebp)
  8004cf:	8b 00                	mov    (%eax),%eax
  8004d1:	99                   	cltd   
  8004d2:	31 d0                	xor    %edx,%eax
  8004d4:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004d6:	83 f8 0f             	cmp    $0xf,%eax
  8004d9:	7f 0b                	jg     8004e6 <vprintfmt+0x142>
  8004db:	8b 14 85 20 2d 80 00 	mov    0x802d20(,%eax,4),%edx
  8004e2:	85 d2                	test   %edx,%edx
  8004e4:	75 18                	jne    8004fe <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8004e6:	50                   	push   %eax
  8004e7:	68 93 2a 80 00       	push   $0x802a93
  8004ec:	53                   	push   %ebx
  8004ed:	56                   	push   %esi
  8004ee:	e8 94 fe ff ff       	call   800387 <printfmt>
  8004f3:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004f6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8004f9:	e9 cc fe ff ff       	jmp    8003ca <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8004fe:	52                   	push   %edx
  8004ff:	68 55 2e 80 00       	push   $0x802e55
  800504:	53                   	push   %ebx
  800505:	56                   	push   %esi
  800506:	e8 7c fe ff ff       	call   800387 <printfmt>
  80050b:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80050e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800511:	e9 b4 fe ff ff       	jmp    8003ca <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800516:	8b 45 14             	mov    0x14(%ebp),%eax
  800519:	8d 50 04             	lea    0x4(%eax),%edx
  80051c:	89 55 14             	mov    %edx,0x14(%ebp)
  80051f:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800521:	85 ff                	test   %edi,%edi
  800523:	b8 8c 2a 80 00       	mov    $0x802a8c,%eax
  800528:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80052b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80052f:	0f 8e 94 00 00 00    	jle    8005c9 <vprintfmt+0x225>
  800535:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800539:	0f 84 98 00 00 00    	je     8005d7 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  80053f:	83 ec 08             	sub    $0x8,%esp
  800542:	ff 75 d0             	pushl  -0x30(%ebp)
  800545:	57                   	push   %edi
  800546:	e8 86 02 00 00       	call   8007d1 <strnlen>
  80054b:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80054e:	29 c1                	sub    %eax,%ecx
  800550:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800553:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800556:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80055a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80055d:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800560:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800562:	eb 0f                	jmp    800573 <vprintfmt+0x1cf>
					putch(padc, putdat);
  800564:	83 ec 08             	sub    $0x8,%esp
  800567:	53                   	push   %ebx
  800568:	ff 75 e0             	pushl  -0x20(%ebp)
  80056b:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80056d:	83 ef 01             	sub    $0x1,%edi
  800570:	83 c4 10             	add    $0x10,%esp
  800573:	85 ff                	test   %edi,%edi
  800575:	7f ed                	jg     800564 <vprintfmt+0x1c0>
  800577:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80057a:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80057d:	85 c9                	test   %ecx,%ecx
  80057f:	b8 00 00 00 00       	mov    $0x0,%eax
  800584:	0f 49 c1             	cmovns %ecx,%eax
  800587:	29 c1                	sub    %eax,%ecx
  800589:	89 75 08             	mov    %esi,0x8(%ebp)
  80058c:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80058f:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800592:	89 cb                	mov    %ecx,%ebx
  800594:	eb 4d                	jmp    8005e3 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800596:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80059a:	74 1b                	je     8005b7 <vprintfmt+0x213>
  80059c:	0f be c0             	movsbl %al,%eax
  80059f:	83 e8 20             	sub    $0x20,%eax
  8005a2:	83 f8 5e             	cmp    $0x5e,%eax
  8005a5:	76 10                	jbe    8005b7 <vprintfmt+0x213>
					putch('?', putdat);
  8005a7:	83 ec 08             	sub    $0x8,%esp
  8005aa:	ff 75 0c             	pushl  0xc(%ebp)
  8005ad:	6a 3f                	push   $0x3f
  8005af:	ff 55 08             	call   *0x8(%ebp)
  8005b2:	83 c4 10             	add    $0x10,%esp
  8005b5:	eb 0d                	jmp    8005c4 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  8005b7:	83 ec 08             	sub    $0x8,%esp
  8005ba:	ff 75 0c             	pushl  0xc(%ebp)
  8005bd:	52                   	push   %edx
  8005be:	ff 55 08             	call   *0x8(%ebp)
  8005c1:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005c4:	83 eb 01             	sub    $0x1,%ebx
  8005c7:	eb 1a                	jmp    8005e3 <vprintfmt+0x23f>
  8005c9:	89 75 08             	mov    %esi,0x8(%ebp)
  8005cc:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005cf:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005d2:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8005d5:	eb 0c                	jmp    8005e3 <vprintfmt+0x23f>
  8005d7:	89 75 08             	mov    %esi,0x8(%ebp)
  8005da:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005dd:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005e0:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8005e3:	83 c7 01             	add    $0x1,%edi
  8005e6:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8005ea:	0f be d0             	movsbl %al,%edx
  8005ed:	85 d2                	test   %edx,%edx
  8005ef:	74 23                	je     800614 <vprintfmt+0x270>
  8005f1:	85 f6                	test   %esi,%esi
  8005f3:	78 a1                	js     800596 <vprintfmt+0x1f2>
  8005f5:	83 ee 01             	sub    $0x1,%esi
  8005f8:	79 9c                	jns    800596 <vprintfmt+0x1f2>
  8005fa:	89 df                	mov    %ebx,%edi
  8005fc:	8b 75 08             	mov    0x8(%ebp),%esi
  8005ff:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800602:	eb 18                	jmp    80061c <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800604:	83 ec 08             	sub    $0x8,%esp
  800607:	53                   	push   %ebx
  800608:	6a 20                	push   $0x20
  80060a:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80060c:	83 ef 01             	sub    $0x1,%edi
  80060f:	83 c4 10             	add    $0x10,%esp
  800612:	eb 08                	jmp    80061c <vprintfmt+0x278>
  800614:	89 df                	mov    %ebx,%edi
  800616:	8b 75 08             	mov    0x8(%ebp),%esi
  800619:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80061c:	85 ff                	test   %edi,%edi
  80061e:	7f e4                	jg     800604 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800620:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800623:	e9 a2 fd ff ff       	jmp    8003ca <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800628:	83 fa 01             	cmp    $0x1,%edx
  80062b:	7e 16                	jle    800643 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  80062d:	8b 45 14             	mov    0x14(%ebp),%eax
  800630:	8d 50 08             	lea    0x8(%eax),%edx
  800633:	89 55 14             	mov    %edx,0x14(%ebp)
  800636:	8b 50 04             	mov    0x4(%eax),%edx
  800639:	8b 00                	mov    (%eax),%eax
  80063b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80063e:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800641:	eb 32                	jmp    800675 <vprintfmt+0x2d1>
	else if (lflag)
  800643:	85 d2                	test   %edx,%edx
  800645:	74 18                	je     80065f <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  800647:	8b 45 14             	mov    0x14(%ebp),%eax
  80064a:	8d 50 04             	lea    0x4(%eax),%edx
  80064d:	89 55 14             	mov    %edx,0x14(%ebp)
  800650:	8b 00                	mov    (%eax),%eax
  800652:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800655:	89 c1                	mov    %eax,%ecx
  800657:	c1 f9 1f             	sar    $0x1f,%ecx
  80065a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80065d:	eb 16                	jmp    800675 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  80065f:	8b 45 14             	mov    0x14(%ebp),%eax
  800662:	8d 50 04             	lea    0x4(%eax),%edx
  800665:	89 55 14             	mov    %edx,0x14(%ebp)
  800668:	8b 00                	mov    (%eax),%eax
  80066a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80066d:	89 c1                	mov    %eax,%ecx
  80066f:	c1 f9 1f             	sar    $0x1f,%ecx
  800672:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800675:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800678:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80067b:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800680:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800684:	79 74                	jns    8006fa <vprintfmt+0x356>
				putch('-', putdat);
  800686:	83 ec 08             	sub    $0x8,%esp
  800689:	53                   	push   %ebx
  80068a:	6a 2d                	push   $0x2d
  80068c:	ff d6                	call   *%esi
				num = -(long long) num;
  80068e:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800691:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800694:	f7 d8                	neg    %eax
  800696:	83 d2 00             	adc    $0x0,%edx
  800699:	f7 da                	neg    %edx
  80069b:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80069e:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8006a3:	eb 55                	jmp    8006fa <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8006a5:	8d 45 14             	lea    0x14(%ebp),%eax
  8006a8:	e8 83 fc ff ff       	call   800330 <getuint>
			base = 10;
  8006ad:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8006b2:	eb 46                	jmp    8006fa <vprintfmt+0x356>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
  8006b4:	8d 45 14             	lea    0x14(%ebp),%eax
  8006b7:	e8 74 fc ff ff       	call   800330 <getuint>
			base = 8;
  8006bc:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  8006c1:	eb 37                	jmp    8006fa <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  8006c3:	83 ec 08             	sub    $0x8,%esp
  8006c6:	53                   	push   %ebx
  8006c7:	6a 30                	push   $0x30
  8006c9:	ff d6                	call   *%esi
			putch('x', putdat);
  8006cb:	83 c4 08             	add    $0x8,%esp
  8006ce:	53                   	push   %ebx
  8006cf:	6a 78                	push   $0x78
  8006d1:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8006d3:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d6:	8d 50 04             	lea    0x4(%eax),%edx
  8006d9:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8006dc:	8b 00                	mov    (%eax),%eax
  8006de:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8006e3:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8006e6:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8006eb:	eb 0d                	jmp    8006fa <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006ed:	8d 45 14             	lea    0x14(%ebp),%eax
  8006f0:	e8 3b fc ff ff       	call   800330 <getuint>
			base = 16;
  8006f5:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006fa:	83 ec 0c             	sub    $0xc,%esp
  8006fd:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800701:	57                   	push   %edi
  800702:	ff 75 e0             	pushl  -0x20(%ebp)
  800705:	51                   	push   %ecx
  800706:	52                   	push   %edx
  800707:	50                   	push   %eax
  800708:	89 da                	mov    %ebx,%edx
  80070a:	89 f0                	mov    %esi,%eax
  80070c:	e8 70 fb ff ff       	call   800281 <printnum>
			break;
  800711:	83 c4 20             	add    $0x20,%esp
  800714:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800717:	e9 ae fc ff ff       	jmp    8003ca <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80071c:	83 ec 08             	sub    $0x8,%esp
  80071f:	53                   	push   %ebx
  800720:	51                   	push   %ecx
  800721:	ff d6                	call   *%esi
			break;
  800723:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800726:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800729:	e9 9c fc ff ff       	jmp    8003ca <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80072e:	83 ec 08             	sub    $0x8,%esp
  800731:	53                   	push   %ebx
  800732:	6a 25                	push   $0x25
  800734:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800736:	83 c4 10             	add    $0x10,%esp
  800739:	eb 03                	jmp    80073e <vprintfmt+0x39a>
  80073b:	83 ef 01             	sub    $0x1,%edi
  80073e:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800742:	75 f7                	jne    80073b <vprintfmt+0x397>
  800744:	e9 81 fc ff ff       	jmp    8003ca <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800749:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80074c:	5b                   	pop    %ebx
  80074d:	5e                   	pop    %esi
  80074e:	5f                   	pop    %edi
  80074f:	5d                   	pop    %ebp
  800750:	c3                   	ret    

00800751 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800751:	55                   	push   %ebp
  800752:	89 e5                	mov    %esp,%ebp
  800754:	83 ec 18             	sub    $0x18,%esp
  800757:	8b 45 08             	mov    0x8(%ebp),%eax
  80075a:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80075d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800760:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800764:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800767:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80076e:	85 c0                	test   %eax,%eax
  800770:	74 26                	je     800798 <vsnprintf+0x47>
  800772:	85 d2                	test   %edx,%edx
  800774:	7e 22                	jle    800798 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800776:	ff 75 14             	pushl  0x14(%ebp)
  800779:	ff 75 10             	pushl  0x10(%ebp)
  80077c:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80077f:	50                   	push   %eax
  800780:	68 6a 03 80 00       	push   $0x80036a
  800785:	e8 1a fc ff ff       	call   8003a4 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80078a:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80078d:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800790:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800793:	83 c4 10             	add    $0x10,%esp
  800796:	eb 05                	jmp    80079d <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800798:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80079d:	c9                   	leave  
  80079e:	c3                   	ret    

0080079f <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80079f:	55                   	push   %ebp
  8007a0:	89 e5                	mov    %esp,%ebp
  8007a2:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007a5:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007a8:	50                   	push   %eax
  8007a9:	ff 75 10             	pushl  0x10(%ebp)
  8007ac:	ff 75 0c             	pushl  0xc(%ebp)
  8007af:	ff 75 08             	pushl  0x8(%ebp)
  8007b2:	e8 9a ff ff ff       	call   800751 <vsnprintf>
	va_end(ap);

	return rc;
}
  8007b7:	c9                   	leave  
  8007b8:	c3                   	ret    

008007b9 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007b9:	55                   	push   %ebp
  8007ba:	89 e5                	mov    %esp,%ebp
  8007bc:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007bf:	b8 00 00 00 00       	mov    $0x0,%eax
  8007c4:	eb 03                	jmp    8007c9 <strlen+0x10>
		n++;
  8007c6:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007c9:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007cd:	75 f7                	jne    8007c6 <strlen+0xd>
		n++;
	return n;
}
  8007cf:	5d                   	pop    %ebp
  8007d0:	c3                   	ret    

008007d1 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007d1:	55                   	push   %ebp
  8007d2:	89 e5                	mov    %esp,%ebp
  8007d4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007d7:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007da:	ba 00 00 00 00       	mov    $0x0,%edx
  8007df:	eb 03                	jmp    8007e4 <strnlen+0x13>
		n++;
  8007e1:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007e4:	39 c2                	cmp    %eax,%edx
  8007e6:	74 08                	je     8007f0 <strnlen+0x1f>
  8007e8:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8007ec:	75 f3                	jne    8007e1 <strnlen+0x10>
  8007ee:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8007f0:	5d                   	pop    %ebp
  8007f1:	c3                   	ret    

008007f2 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007f2:	55                   	push   %ebp
  8007f3:	89 e5                	mov    %esp,%ebp
  8007f5:	53                   	push   %ebx
  8007f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8007f9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007fc:	89 c2                	mov    %eax,%edx
  8007fe:	83 c2 01             	add    $0x1,%edx
  800801:	83 c1 01             	add    $0x1,%ecx
  800804:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800808:	88 5a ff             	mov    %bl,-0x1(%edx)
  80080b:	84 db                	test   %bl,%bl
  80080d:	75 ef                	jne    8007fe <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80080f:	5b                   	pop    %ebx
  800810:	5d                   	pop    %ebp
  800811:	c3                   	ret    

00800812 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800812:	55                   	push   %ebp
  800813:	89 e5                	mov    %esp,%ebp
  800815:	53                   	push   %ebx
  800816:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800819:	53                   	push   %ebx
  80081a:	e8 9a ff ff ff       	call   8007b9 <strlen>
  80081f:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800822:	ff 75 0c             	pushl  0xc(%ebp)
  800825:	01 d8                	add    %ebx,%eax
  800827:	50                   	push   %eax
  800828:	e8 c5 ff ff ff       	call   8007f2 <strcpy>
	return dst;
}
  80082d:	89 d8                	mov    %ebx,%eax
  80082f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800832:	c9                   	leave  
  800833:	c3                   	ret    

00800834 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800834:	55                   	push   %ebp
  800835:	89 e5                	mov    %esp,%ebp
  800837:	56                   	push   %esi
  800838:	53                   	push   %ebx
  800839:	8b 75 08             	mov    0x8(%ebp),%esi
  80083c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80083f:	89 f3                	mov    %esi,%ebx
  800841:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800844:	89 f2                	mov    %esi,%edx
  800846:	eb 0f                	jmp    800857 <strncpy+0x23>
		*dst++ = *src;
  800848:	83 c2 01             	add    $0x1,%edx
  80084b:	0f b6 01             	movzbl (%ecx),%eax
  80084e:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800851:	80 39 01             	cmpb   $0x1,(%ecx)
  800854:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800857:	39 da                	cmp    %ebx,%edx
  800859:	75 ed                	jne    800848 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80085b:	89 f0                	mov    %esi,%eax
  80085d:	5b                   	pop    %ebx
  80085e:	5e                   	pop    %esi
  80085f:	5d                   	pop    %ebp
  800860:	c3                   	ret    

00800861 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800861:	55                   	push   %ebp
  800862:	89 e5                	mov    %esp,%ebp
  800864:	56                   	push   %esi
  800865:	53                   	push   %ebx
  800866:	8b 75 08             	mov    0x8(%ebp),%esi
  800869:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80086c:	8b 55 10             	mov    0x10(%ebp),%edx
  80086f:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800871:	85 d2                	test   %edx,%edx
  800873:	74 21                	je     800896 <strlcpy+0x35>
  800875:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800879:	89 f2                	mov    %esi,%edx
  80087b:	eb 09                	jmp    800886 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80087d:	83 c2 01             	add    $0x1,%edx
  800880:	83 c1 01             	add    $0x1,%ecx
  800883:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800886:	39 c2                	cmp    %eax,%edx
  800888:	74 09                	je     800893 <strlcpy+0x32>
  80088a:	0f b6 19             	movzbl (%ecx),%ebx
  80088d:	84 db                	test   %bl,%bl
  80088f:	75 ec                	jne    80087d <strlcpy+0x1c>
  800891:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800893:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800896:	29 f0                	sub    %esi,%eax
}
  800898:	5b                   	pop    %ebx
  800899:	5e                   	pop    %esi
  80089a:	5d                   	pop    %ebp
  80089b:	c3                   	ret    

0080089c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80089c:	55                   	push   %ebp
  80089d:	89 e5                	mov    %esp,%ebp
  80089f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008a2:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008a5:	eb 06                	jmp    8008ad <strcmp+0x11>
		p++, q++;
  8008a7:	83 c1 01             	add    $0x1,%ecx
  8008aa:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008ad:	0f b6 01             	movzbl (%ecx),%eax
  8008b0:	84 c0                	test   %al,%al
  8008b2:	74 04                	je     8008b8 <strcmp+0x1c>
  8008b4:	3a 02                	cmp    (%edx),%al
  8008b6:	74 ef                	je     8008a7 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008b8:	0f b6 c0             	movzbl %al,%eax
  8008bb:	0f b6 12             	movzbl (%edx),%edx
  8008be:	29 d0                	sub    %edx,%eax
}
  8008c0:	5d                   	pop    %ebp
  8008c1:	c3                   	ret    

008008c2 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008c2:	55                   	push   %ebp
  8008c3:	89 e5                	mov    %esp,%ebp
  8008c5:	53                   	push   %ebx
  8008c6:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008cc:	89 c3                	mov    %eax,%ebx
  8008ce:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008d1:	eb 06                	jmp    8008d9 <strncmp+0x17>
		n--, p++, q++;
  8008d3:	83 c0 01             	add    $0x1,%eax
  8008d6:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008d9:	39 d8                	cmp    %ebx,%eax
  8008db:	74 15                	je     8008f2 <strncmp+0x30>
  8008dd:	0f b6 08             	movzbl (%eax),%ecx
  8008e0:	84 c9                	test   %cl,%cl
  8008e2:	74 04                	je     8008e8 <strncmp+0x26>
  8008e4:	3a 0a                	cmp    (%edx),%cl
  8008e6:	74 eb                	je     8008d3 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008e8:	0f b6 00             	movzbl (%eax),%eax
  8008eb:	0f b6 12             	movzbl (%edx),%edx
  8008ee:	29 d0                	sub    %edx,%eax
  8008f0:	eb 05                	jmp    8008f7 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008f2:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008f7:	5b                   	pop    %ebx
  8008f8:	5d                   	pop    %ebp
  8008f9:	c3                   	ret    

008008fa <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008fa:	55                   	push   %ebp
  8008fb:	89 e5                	mov    %esp,%ebp
  8008fd:	8b 45 08             	mov    0x8(%ebp),%eax
  800900:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800904:	eb 07                	jmp    80090d <strchr+0x13>
		if (*s == c)
  800906:	38 ca                	cmp    %cl,%dl
  800908:	74 0f                	je     800919 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80090a:	83 c0 01             	add    $0x1,%eax
  80090d:	0f b6 10             	movzbl (%eax),%edx
  800910:	84 d2                	test   %dl,%dl
  800912:	75 f2                	jne    800906 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800914:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800919:	5d                   	pop    %ebp
  80091a:	c3                   	ret    

0080091b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80091b:	55                   	push   %ebp
  80091c:	89 e5                	mov    %esp,%ebp
  80091e:	8b 45 08             	mov    0x8(%ebp),%eax
  800921:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800925:	eb 03                	jmp    80092a <strfind+0xf>
  800927:	83 c0 01             	add    $0x1,%eax
  80092a:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80092d:	38 ca                	cmp    %cl,%dl
  80092f:	74 04                	je     800935 <strfind+0x1a>
  800931:	84 d2                	test   %dl,%dl
  800933:	75 f2                	jne    800927 <strfind+0xc>
			break;
	return (char *) s;
}
  800935:	5d                   	pop    %ebp
  800936:	c3                   	ret    

00800937 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800937:	55                   	push   %ebp
  800938:	89 e5                	mov    %esp,%ebp
  80093a:	57                   	push   %edi
  80093b:	56                   	push   %esi
  80093c:	53                   	push   %ebx
  80093d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800940:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800943:	85 c9                	test   %ecx,%ecx
  800945:	74 36                	je     80097d <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800947:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80094d:	75 28                	jne    800977 <memset+0x40>
  80094f:	f6 c1 03             	test   $0x3,%cl
  800952:	75 23                	jne    800977 <memset+0x40>
		c &= 0xFF;
  800954:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800958:	89 d3                	mov    %edx,%ebx
  80095a:	c1 e3 08             	shl    $0x8,%ebx
  80095d:	89 d6                	mov    %edx,%esi
  80095f:	c1 e6 18             	shl    $0x18,%esi
  800962:	89 d0                	mov    %edx,%eax
  800964:	c1 e0 10             	shl    $0x10,%eax
  800967:	09 f0                	or     %esi,%eax
  800969:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  80096b:	89 d8                	mov    %ebx,%eax
  80096d:	09 d0                	or     %edx,%eax
  80096f:	c1 e9 02             	shr    $0x2,%ecx
  800972:	fc                   	cld    
  800973:	f3 ab                	rep stos %eax,%es:(%edi)
  800975:	eb 06                	jmp    80097d <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800977:	8b 45 0c             	mov    0xc(%ebp),%eax
  80097a:	fc                   	cld    
  80097b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80097d:	89 f8                	mov    %edi,%eax
  80097f:	5b                   	pop    %ebx
  800980:	5e                   	pop    %esi
  800981:	5f                   	pop    %edi
  800982:	5d                   	pop    %ebp
  800983:	c3                   	ret    

00800984 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800984:	55                   	push   %ebp
  800985:	89 e5                	mov    %esp,%ebp
  800987:	57                   	push   %edi
  800988:	56                   	push   %esi
  800989:	8b 45 08             	mov    0x8(%ebp),%eax
  80098c:	8b 75 0c             	mov    0xc(%ebp),%esi
  80098f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800992:	39 c6                	cmp    %eax,%esi
  800994:	73 35                	jae    8009cb <memmove+0x47>
  800996:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800999:	39 d0                	cmp    %edx,%eax
  80099b:	73 2e                	jae    8009cb <memmove+0x47>
		s += n;
		d += n;
  80099d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009a0:	89 d6                	mov    %edx,%esi
  8009a2:	09 fe                	or     %edi,%esi
  8009a4:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009aa:	75 13                	jne    8009bf <memmove+0x3b>
  8009ac:	f6 c1 03             	test   $0x3,%cl
  8009af:	75 0e                	jne    8009bf <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8009b1:	83 ef 04             	sub    $0x4,%edi
  8009b4:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009b7:	c1 e9 02             	shr    $0x2,%ecx
  8009ba:	fd                   	std    
  8009bb:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009bd:	eb 09                	jmp    8009c8 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009bf:	83 ef 01             	sub    $0x1,%edi
  8009c2:	8d 72 ff             	lea    -0x1(%edx),%esi
  8009c5:	fd                   	std    
  8009c6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009c8:	fc                   	cld    
  8009c9:	eb 1d                	jmp    8009e8 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009cb:	89 f2                	mov    %esi,%edx
  8009cd:	09 c2                	or     %eax,%edx
  8009cf:	f6 c2 03             	test   $0x3,%dl
  8009d2:	75 0f                	jne    8009e3 <memmove+0x5f>
  8009d4:	f6 c1 03             	test   $0x3,%cl
  8009d7:	75 0a                	jne    8009e3 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8009d9:	c1 e9 02             	shr    $0x2,%ecx
  8009dc:	89 c7                	mov    %eax,%edi
  8009de:	fc                   	cld    
  8009df:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009e1:	eb 05                	jmp    8009e8 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009e3:	89 c7                	mov    %eax,%edi
  8009e5:	fc                   	cld    
  8009e6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009e8:	5e                   	pop    %esi
  8009e9:	5f                   	pop    %edi
  8009ea:	5d                   	pop    %ebp
  8009eb:	c3                   	ret    

008009ec <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009ec:	55                   	push   %ebp
  8009ed:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8009ef:	ff 75 10             	pushl  0x10(%ebp)
  8009f2:	ff 75 0c             	pushl  0xc(%ebp)
  8009f5:	ff 75 08             	pushl  0x8(%ebp)
  8009f8:	e8 87 ff ff ff       	call   800984 <memmove>
}
  8009fd:	c9                   	leave  
  8009fe:	c3                   	ret    

008009ff <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009ff:	55                   	push   %ebp
  800a00:	89 e5                	mov    %esp,%ebp
  800a02:	56                   	push   %esi
  800a03:	53                   	push   %ebx
  800a04:	8b 45 08             	mov    0x8(%ebp),%eax
  800a07:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a0a:	89 c6                	mov    %eax,%esi
  800a0c:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a0f:	eb 1a                	jmp    800a2b <memcmp+0x2c>
		if (*s1 != *s2)
  800a11:	0f b6 08             	movzbl (%eax),%ecx
  800a14:	0f b6 1a             	movzbl (%edx),%ebx
  800a17:	38 d9                	cmp    %bl,%cl
  800a19:	74 0a                	je     800a25 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800a1b:	0f b6 c1             	movzbl %cl,%eax
  800a1e:	0f b6 db             	movzbl %bl,%ebx
  800a21:	29 d8                	sub    %ebx,%eax
  800a23:	eb 0f                	jmp    800a34 <memcmp+0x35>
		s1++, s2++;
  800a25:	83 c0 01             	add    $0x1,%eax
  800a28:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a2b:	39 f0                	cmp    %esi,%eax
  800a2d:	75 e2                	jne    800a11 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a2f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a34:	5b                   	pop    %ebx
  800a35:	5e                   	pop    %esi
  800a36:	5d                   	pop    %ebp
  800a37:	c3                   	ret    

00800a38 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a38:	55                   	push   %ebp
  800a39:	89 e5                	mov    %esp,%ebp
  800a3b:	53                   	push   %ebx
  800a3c:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a3f:	89 c1                	mov    %eax,%ecx
  800a41:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800a44:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a48:	eb 0a                	jmp    800a54 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a4a:	0f b6 10             	movzbl (%eax),%edx
  800a4d:	39 da                	cmp    %ebx,%edx
  800a4f:	74 07                	je     800a58 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a51:	83 c0 01             	add    $0x1,%eax
  800a54:	39 c8                	cmp    %ecx,%eax
  800a56:	72 f2                	jb     800a4a <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a58:	5b                   	pop    %ebx
  800a59:	5d                   	pop    %ebp
  800a5a:	c3                   	ret    

00800a5b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a5b:	55                   	push   %ebp
  800a5c:	89 e5                	mov    %esp,%ebp
  800a5e:	57                   	push   %edi
  800a5f:	56                   	push   %esi
  800a60:	53                   	push   %ebx
  800a61:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a64:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a67:	eb 03                	jmp    800a6c <strtol+0x11>
		s++;
  800a69:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a6c:	0f b6 01             	movzbl (%ecx),%eax
  800a6f:	3c 20                	cmp    $0x20,%al
  800a71:	74 f6                	je     800a69 <strtol+0xe>
  800a73:	3c 09                	cmp    $0x9,%al
  800a75:	74 f2                	je     800a69 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a77:	3c 2b                	cmp    $0x2b,%al
  800a79:	75 0a                	jne    800a85 <strtol+0x2a>
		s++;
  800a7b:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a7e:	bf 00 00 00 00       	mov    $0x0,%edi
  800a83:	eb 11                	jmp    800a96 <strtol+0x3b>
  800a85:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a8a:	3c 2d                	cmp    $0x2d,%al
  800a8c:	75 08                	jne    800a96 <strtol+0x3b>
		s++, neg = 1;
  800a8e:	83 c1 01             	add    $0x1,%ecx
  800a91:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a96:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a9c:	75 15                	jne    800ab3 <strtol+0x58>
  800a9e:	80 39 30             	cmpb   $0x30,(%ecx)
  800aa1:	75 10                	jne    800ab3 <strtol+0x58>
  800aa3:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800aa7:	75 7c                	jne    800b25 <strtol+0xca>
		s += 2, base = 16;
  800aa9:	83 c1 02             	add    $0x2,%ecx
  800aac:	bb 10 00 00 00       	mov    $0x10,%ebx
  800ab1:	eb 16                	jmp    800ac9 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800ab3:	85 db                	test   %ebx,%ebx
  800ab5:	75 12                	jne    800ac9 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800ab7:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800abc:	80 39 30             	cmpb   $0x30,(%ecx)
  800abf:	75 08                	jne    800ac9 <strtol+0x6e>
		s++, base = 8;
  800ac1:	83 c1 01             	add    $0x1,%ecx
  800ac4:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800ac9:	b8 00 00 00 00       	mov    $0x0,%eax
  800ace:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800ad1:	0f b6 11             	movzbl (%ecx),%edx
  800ad4:	8d 72 d0             	lea    -0x30(%edx),%esi
  800ad7:	89 f3                	mov    %esi,%ebx
  800ad9:	80 fb 09             	cmp    $0x9,%bl
  800adc:	77 08                	ja     800ae6 <strtol+0x8b>
			dig = *s - '0';
  800ade:	0f be d2             	movsbl %dl,%edx
  800ae1:	83 ea 30             	sub    $0x30,%edx
  800ae4:	eb 22                	jmp    800b08 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800ae6:	8d 72 9f             	lea    -0x61(%edx),%esi
  800ae9:	89 f3                	mov    %esi,%ebx
  800aeb:	80 fb 19             	cmp    $0x19,%bl
  800aee:	77 08                	ja     800af8 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800af0:	0f be d2             	movsbl %dl,%edx
  800af3:	83 ea 57             	sub    $0x57,%edx
  800af6:	eb 10                	jmp    800b08 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800af8:	8d 72 bf             	lea    -0x41(%edx),%esi
  800afb:	89 f3                	mov    %esi,%ebx
  800afd:	80 fb 19             	cmp    $0x19,%bl
  800b00:	77 16                	ja     800b18 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800b02:	0f be d2             	movsbl %dl,%edx
  800b05:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800b08:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b0b:	7d 0b                	jge    800b18 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800b0d:	83 c1 01             	add    $0x1,%ecx
  800b10:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b14:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800b16:	eb b9                	jmp    800ad1 <strtol+0x76>

	if (endptr)
  800b18:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b1c:	74 0d                	je     800b2b <strtol+0xd0>
		*endptr = (char *) s;
  800b1e:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b21:	89 0e                	mov    %ecx,(%esi)
  800b23:	eb 06                	jmp    800b2b <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b25:	85 db                	test   %ebx,%ebx
  800b27:	74 98                	je     800ac1 <strtol+0x66>
  800b29:	eb 9e                	jmp    800ac9 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800b2b:	89 c2                	mov    %eax,%edx
  800b2d:	f7 da                	neg    %edx
  800b2f:	85 ff                	test   %edi,%edi
  800b31:	0f 45 c2             	cmovne %edx,%eax
}
  800b34:	5b                   	pop    %ebx
  800b35:	5e                   	pop    %esi
  800b36:	5f                   	pop    %edi
  800b37:	5d                   	pop    %ebp
  800b38:	c3                   	ret    

00800b39 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b39:	55                   	push   %ebp
  800b3a:	89 e5                	mov    %esp,%ebp
  800b3c:	57                   	push   %edi
  800b3d:	56                   	push   %esi
  800b3e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b3f:	b8 00 00 00 00       	mov    $0x0,%eax
  800b44:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b47:	8b 55 08             	mov    0x8(%ebp),%edx
  800b4a:	89 c3                	mov    %eax,%ebx
  800b4c:	89 c7                	mov    %eax,%edi
  800b4e:	89 c6                	mov    %eax,%esi
  800b50:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b52:	5b                   	pop    %ebx
  800b53:	5e                   	pop    %esi
  800b54:	5f                   	pop    %edi
  800b55:	5d                   	pop    %ebp
  800b56:	c3                   	ret    

00800b57 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b57:	55                   	push   %ebp
  800b58:	89 e5                	mov    %esp,%ebp
  800b5a:	57                   	push   %edi
  800b5b:	56                   	push   %esi
  800b5c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b5d:	ba 00 00 00 00       	mov    $0x0,%edx
  800b62:	b8 01 00 00 00       	mov    $0x1,%eax
  800b67:	89 d1                	mov    %edx,%ecx
  800b69:	89 d3                	mov    %edx,%ebx
  800b6b:	89 d7                	mov    %edx,%edi
  800b6d:	89 d6                	mov    %edx,%esi
  800b6f:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b71:	5b                   	pop    %ebx
  800b72:	5e                   	pop    %esi
  800b73:	5f                   	pop    %edi
  800b74:	5d                   	pop    %ebp
  800b75:	c3                   	ret    

00800b76 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b76:	55                   	push   %ebp
  800b77:	89 e5                	mov    %esp,%ebp
  800b79:	57                   	push   %edi
  800b7a:	56                   	push   %esi
  800b7b:	53                   	push   %ebx
  800b7c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b7f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b84:	b8 03 00 00 00       	mov    $0x3,%eax
  800b89:	8b 55 08             	mov    0x8(%ebp),%edx
  800b8c:	89 cb                	mov    %ecx,%ebx
  800b8e:	89 cf                	mov    %ecx,%edi
  800b90:	89 ce                	mov    %ecx,%esi
  800b92:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b94:	85 c0                	test   %eax,%eax
  800b96:	7e 17                	jle    800baf <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b98:	83 ec 0c             	sub    $0xc,%esp
  800b9b:	50                   	push   %eax
  800b9c:	6a 03                	push   $0x3
  800b9e:	68 7f 2d 80 00       	push   $0x802d7f
  800ba3:	6a 23                	push   $0x23
  800ba5:	68 9c 2d 80 00       	push   $0x802d9c
  800baa:	e8 e5 f5 ff ff       	call   800194 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800baf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bb2:	5b                   	pop    %ebx
  800bb3:	5e                   	pop    %esi
  800bb4:	5f                   	pop    %edi
  800bb5:	5d                   	pop    %ebp
  800bb6:	c3                   	ret    

00800bb7 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800bb7:	55                   	push   %ebp
  800bb8:	89 e5                	mov    %esp,%ebp
  800bba:	57                   	push   %edi
  800bbb:	56                   	push   %esi
  800bbc:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bbd:	ba 00 00 00 00       	mov    $0x0,%edx
  800bc2:	b8 02 00 00 00       	mov    $0x2,%eax
  800bc7:	89 d1                	mov    %edx,%ecx
  800bc9:	89 d3                	mov    %edx,%ebx
  800bcb:	89 d7                	mov    %edx,%edi
  800bcd:	89 d6                	mov    %edx,%esi
  800bcf:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800bd1:	5b                   	pop    %ebx
  800bd2:	5e                   	pop    %esi
  800bd3:	5f                   	pop    %edi
  800bd4:	5d                   	pop    %ebp
  800bd5:	c3                   	ret    

00800bd6 <sys_yield>:

void
sys_yield(void)
{
  800bd6:	55                   	push   %ebp
  800bd7:	89 e5                	mov    %esp,%ebp
  800bd9:	57                   	push   %edi
  800bda:	56                   	push   %esi
  800bdb:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bdc:	ba 00 00 00 00       	mov    $0x0,%edx
  800be1:	b8 0b 00 00 00       	mov    $0xb,%eax
  800be6:	89 d1                	mov    %edx,%ecx
  800be8:	89 d3                	mov    %edx,%ebx
  800bea:	89 d7                	mov    %edx,%edi
  800bec:	89 d6                	mov    %edx,%esi
  800bee:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800bf0:	5b                   	pop    %ebx
  800bf1:	5e                   	pop    %esi
  800bf2:	5f                   	pop    %edi
  800bf3:	5d                   	pop    %ebp
  800bf4:	c3                   	ret    

00800bf5 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800bf5:	55                   	push   %ebp
  800bf6:	89 e5                	mov    %esp,%ebp
  800bf8:	57                   	push   %edi
  800bf9:	56                   	push   %esi
  800bfa:	53                   	push   %ebx
  800bfb:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bfe:	be 00 00 00 00       	mov    $0x0,%esi
  800c03:	b8 04 00 00 00       	mov    $0x4,%eax
  800c08:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c0b:	8b 55 08             	mov    0x8(%ebp),%edx
  800c0e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c11:	89 f7                	mov    %esi,%edi
  800c13:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c15:	85 c0                	test   %eax,%eax
  800c17:	7e 17                	jle    800c30 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c19:	83 ec 0c             	sub    $0xc,%esp
  800c1c:	50                   	push   %eax
  800c1d:	6a 04                	push   $0x4
  800c1f:	68 7f 2d 80 00       	push   $0x802d7f
  800c24:	6a 23                	push   $0x23
  800c26:	68 9c 2d 80 00       	push   $0x802d9c
  800c2b:	e8 64 f5 ff ff       	call   800194 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c30:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c33:	5b                   	pop    %ebx
  800c34:	5e                   	pop    %esi
  800c35:	5f                   	pop    %edi
  800c36:	5d                   	pop    %ebp
  800c37:	c3                   	ret    

00800c38 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c38:	55                   	push   %ebp
  800c39:	89 e5                	mov    %esp,%ebp
  800c3b:	57                   	push   %edi
  800c3c:	56                   	push   %esi
  800c3d:	53                   	push   %ebx
  800c3e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c41:	b8 05 00 00 00       	mov    $0x5,%eax
  800c46:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c49:	8b 55 08             	mov    0x8(%ebp),%edx
  800c4c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c4f:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c52:	8b 75 18             	mov    0x18(%ebp),%esi
  800c55:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c57:	85 c0                	test   %eax,%eax
  800c59:	7e 17                	jle    800c72 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c5b:	83 ec 0c             	sub    $0xc,%esp
  800c5e:	50                   	push   %eax
  800c5f:	6a 05                	push   $0x5
  800c61:	68 7f 2d 80 00       	push   $0x802d7f
  800c66:	6a 23                	push   $0x23
  800c68:	68 9c 2d 80 00       	push   $0x802d9c
  800c6d:	e8 22 f5 ff ff       	call   800194 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c72:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c75:	5b                   	pop    %ebx
  800c76:	5e                   	pop    %esi
  800c77:	5f                   	pop    %edi
  800c78:	5d                   	pop    %ebp
  800c79:	c3                   	ret    

00800c7a <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c7a:	55                   	push   %ebp
  800c7b:	89 e5                	mov    %esp,%ebp
  800c7d:	57                   	push   %edi
  800c7e:	56                   	push   %esi
  800c7f:	53                   	push   %ebx
  800c80:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c83:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c88:	b8 06 00 00 00       	mov    $0x6,%eax
  800c8d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c90:	8b 55 08             	mov    0x8(%ebp),%edx
  800c93:	89 df                	mov    %ebx,%edi
  800c95:	89 de                	mov    %ebx,%esi
  800c97:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c99:	85 c0                	test   %eax,%eax
  800c9b:	7e 17                	jle    800cb4 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c9d:	83 ec 0c             	sub    $0xc,%esp
  800ca0:	50                   	push   %eax
  800ca1:	6a 06                	push   $0x6
  800ca3:	68 7f 2d 80 00       	push   $0x802d7f
  800ca8:	6a 23                	push   $0x23
  800caa:	68 9c 2d 80 00       	push   $0x802d9c
  800caf:	e8 e0 f4 ff ff       	call   800194 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800cb4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cb7:	5b                   	pop    %ebx
  800cb8:	5e                   	pop    %esi
  800cb9:	5f                   	pop    %edi
  800cba:	5d                   	pop    %ebp
  800cbb:	c3                   	ret    

00800cbc <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800cbc:	55                   	push   %ebp
  800cbd:	89 e5                	mov    %esp,%ebp
  800cbf:	57                   	push   %edi
  800cc0:	56                   	push   %esi
  800cc1:	53                   	push   %ebx
  800cc2:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cc5:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cca:	b8 08 00 00 00       	mov    $0x8,%eax
  800ccf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cd2:	8b 55 08             	mov    0x8(%ebp),%edx
  800cd5:	89 df                	mov    %ebx,%edi
  800cd7:	89 de                	mov    %ebx,%esi
  800cd9:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cdb:	85 c0                	test   %eax,%eax
  800cdd:	7e 17                	jle    800cf6 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cdf:	83 ec 0c             	sub    $0xc,%esp
  800ce2:	50                   	push   %eax
  800ce3:	6a 08                	push   $0x8
  800ce5:	68 7f 2d 80 00       	push   $0x802d7f
  800cea:	6a 23                	push   $0x23
  800cec:	68 9c 2d 80 00       	push   $0x802d9c
  800cf1:	e8 9e f4 ff ff       	call   800194 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800cf6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cf9:	5b                   	pop    %ebx
  800cfa:	5e                   	pop    %esi
  800cfb:	5f                   	pop    %edi
  800cfc:	5d                   	pop    %ebp
  800cfd:	c3                   	ret    

00800cfe <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800cfe:	55                   	push   %ebp
  800cff:	89 e5                	mov    %esp,%ebp
  800d01:	57                   	push   %edi
  800d02:	56                   	push   %esi
  800d03:	53                   	push   %ebx
  800d04:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d07:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d0c:	b8 09 00 00 00       	mov    $0x9,%eax
  800d11:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d14:	8b 55 08             	mov    0x8(%ebp),%edx
  800d17:	89 df                	mov    %ebx,%edi
  800d19:	89 de                	mov    %ebx,%esi
  800d1b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d1d:	85 c0                	test   %eax,%eax
  800d1f:	7e 17                	jle    800d38 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d21:	83 ec 0c             	sub    $0xc,%esp
  800d24:	50                   	push   %eax
  800d25:	6a 09                	push   $0x9
  800d27:	68 7f 2d 80 00       	push   $0x802d7f
  800d2c:	6a 23                	push   $0x23
  800d2e:	68 9c 2d 80 00       	push   $0x802d9c
  800d33:	e8 5c f4 ff ff       	call   800194 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d38:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d3b:	5b                   	pop    %ebx
  800d3c:	5e                   	pop    %esi
  800d3d:	5f                   	pop    %edi
  800d3e:	5d                   	pop    %ebp
  800d3f:	c3                   	ret    

00800d40 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d40:	55                   	push   %ebp
  800d41:	89 e5                	mov    %esp,%ebp
  800d43:	57                   	push   %edi
  800d44:	56                   	push   %esi
  800d45:	53                   	push   %ebx
  800d46:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d49:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d4e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d53:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d56:	8b 55 08             	mov    0x8(%ebp),%edx
  800d59:	89 df                	mov    %ebx,%edi
  800d5b:	89 de                	mov    %ebx,%esi
  800d5d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d5f:	85 c0                	test   %eax,%eax
  800d61:	7e 17                	jle    800d7a <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d63:	83 ec 0c             	sub    $0xc,%esp
  800d66:	50                   	push   %eax
  800d67:	6a 0a                	push   $0xa
  800d69:	68 7f 2d 80 00       	push   $0x802d7f
  800d6e:	6a 23                	push   $0x23
  800d70:	68 9c 2d 80 00       	push   $0x802d9c
  800d75:	e8 1a f4 ff ff       	call   800194 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d7a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d7d:	5b                   	pop    %ebx
  800d7e:	5e                   	pop    %esi
  800d7f:	5f                   	pop    %edi
  800d80:	5d                   	pop    %ebp
  800d81:	c3                   	ret    

00800d82 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d82:	55                   	push   %ebp
  800d83:	89 e5                	mov    %esp,%ebp
  800d85:	57                   	push   %edi
  800d86:	56                   	push   %esi
  800d87:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d88:	be 00 00 00 00       	mov    $0x0,%esi
  800d8d:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d92:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d95:	8b 55 08             	mov    0x8(%ebp),%edx
  800d98:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d9b:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d9e:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800da0:	5b                   	pop    %ebx
  800da1:	5e                   	pop    %esi
  800da2:	5f                   	pop    %edi
  800da3:	5d                   	pop    %ebp
  800da4:	c3                   	ret    

00800da5 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800da5:	55                   	push   %ebp
  800da6:	89 e5                	mov    %esp,%ebp
  800da8:	57                   	push   %edi
  800da9:	56                   	push   %esi
  800daa:	53                   	push   %ebx
  800dab:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dae:	b9 00 00 00 00       	mov    $0x0,%ecx
  800db3:	b8 0d 00 00 00       	mov    $0xd,%eax
  800db8:	8b 55 08             	mov    0x8(%ebp),%edx
  800dbb:	89 cb                	mov    %ecx,%ebx
  800dbd:	89 cf                	mov    %ecx,%edi
  800dbf:	89 ce                	mov    %ecx,%esi
  800dc1:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800dc3:	85 c0                	test   %eax,%eax
  800dc5:	7e 17                	jle    800dde <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dc7:	83 ec 0c             	sub    $0xc,%esp
  800dca:	50                   	push   %eax
  800dcb:	6a 0d                	push   $0xd
  800dcd:	68 7f 2d 80 00       	push   $0x802d7f
  800dd2:	6a 23                	push   $0x23
  800dd4:	68 9c 2d 80 00       	push   $0x802d9c
  800dd9:	e8 b6 f3 ff ff       	call   800194 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800dde:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800de1:	5b                   	pop    %ebx
  800de2:	5e                   	pop    %esi
  800de3:	5f                   	pop    %edi
  800de4:	5d                   	pop    %ebp
  800de5:	c3                   	ret    

00800de6 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800de6:	55                   	push   %ebp
  800de7:	89 e5                	mov    %esp,%ebp
  800de9:	57                   	push   %edi
  800dea:	56                   	push   %esi
  800deb:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dec:	ba 00 00 00 00       	mov    $0x0,%edx
  800df1:	b8 0e 00 00 00       	mov    $0xe,%eax
  800df6:	89 d1                	mov    %edx,%ecx
  800df8:	89 d3                	mov    %edx,%ebx
  800dfa:	89 d7                	mov    %edx,%edi
  800dfc:	89 d6                	mov    %edx,%esi
  800dfe:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800e00:	5b                   	pop    %ebx
  800e01:	5e                   	pop    %esi
  800e02:	5f                   	pop    %edi
  800e03:	5d                   	pop    %ebp
  800e04:	c3                   	ret    

00800e05 <sys_e1000_try_send>:

int
sys_e1000_try_send(void *data, uint32_t len)
{
  800e05:	55                   	push   %ebp
  800e06:	89 e5                	mov    %esp,%ebp
  800e08:	57                   	push   %edi
  800e09:	56                   	push   %esi
  800e0a:	53                   	push   %ebx
  800e0b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e0e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e13:	b8 0f 00 00 00       	mov    $0xf,%eax
  800e18:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e1b:	8b 55 08             	mov    0x8(%ebp),%edx
  800e1e:	89 df                	mov    %ebx,%edi
  800e20:	89 de                	mov    %ebx,%esi
  800e22:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e24:	85 c0                	test   %eax,%eax
  800e26:	7e 17                	jle    800e3f <sys_e1000_try_send+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e28:	83 ec 0c             	sub    $0xc,%esp
  800e2b:	50                   	push   %eax
  800e2c:	6a 0f                	push   $0xf
  800e2e:	68 7f 2d 80 00       	push   $0x802d7f
  800e33:	6a 23                	push   $0x23
  800e35:	68 9c 2d 80 00       	push   $0x802d9c
  800e3a:	e8 55 f3 ff ff       	call   800194 <_panic>

int
sys_e1000_try_send(void *data, uint32_t len)
{
	return syscall(SYS_e1000_try_send, 1, (uint32_t)data, len, 0, 0, 0);
}
  800e3f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e42:	5b                   	pop    %ebx
  800e43:	5e                   	pop    %esi
  800e44:	5f                   	pop    %edi
  800e45:	5d                   	pop    %ebp
  800e46:	c3                   	ret    

00800e47 <sys_e1000_try_recv>:

int
sys_e1000_try_recv(void *buf, uint32_t* len)
{
  800e47:	55                   	push   %ebp
  800e48:	89 e5                	mov    %esp,%ebp
  800e4a:	57                   	push   %edi
  800e4b:	56                   	push   %esi
  800e4c:	53                   	push   %ebx
  800e4d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e50:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e55:	b8 10 00 00 00       	mov    $0x10,%eax
  800e5a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e5d:	8b 55 08             	mov    0x8(%ebp),%edx
  800e60:	89 df                	mov    %ebx,%edi
  800e62:	89 de                	mov    %ebx,%esi
  800e64:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e66:	85 c0                	test   %eax,%eax
  800e68:	7e 17                	jle    800e81 <sys_e1000_try_recv+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e6a:	83 ec 0c             	sub    $0xc,%esp
  800e6d:	50                   	push   %eax
  800e6e:	6a 10                	push   $0x10
  800e70:	68 7f 2d 80 00       	push   $0x802d7f
  800e75:	6a 23                	push   $0x23
  800e77:	68 9c 2d 80 00       	push   $0x802d9c
  800e7c:	e8 13 f3 ff ff       	call   800194 <_panic>

int
sys_e1000_try_recv(void *buf, uint32_t* len)
{
	return syscall(SYS_e1000_try_recv, 1, (uint32_t)buf, (uint32_t)len, 0, 0, 0);
}
  800e81:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e84:	5b                   	pop    %ebx
  800e85:	5e                   	pop    %esi
  800e86:	5f                   	pop    %edi
  800e87:	5d                   	pop    %ebp
  800e88:	c3                   	ret    

00800e89 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800e89:	55                   	push   %ebp
  800e8a:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800e8c:	8b 45 08             	mov    0x8(%ebp),%eax
  800e8f:	05 00 00 00 30       	add    $0x30000000,%eax
  800e94:	c1 e8 0c             	shr    $0xc,%eax
}
  800e97:	5d                   	pop    %ebp
  800e98:	c3                   	ret    

00800e99 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800e99:	55                   	push   %ebp
  800e9a:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800e9c:	8b 45 08             	mov    0x8(%ebp),%eax
  800e9f:	05 00 00 00 30       	add    $0x30000000,%eax
  800ea4:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800ea9:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800eae:	5d                   	pop    %ebp
  800eaf:	c3                   	ret    

00800eb0 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800eb0:	55                   	push   %ebp
  800eb1:	89 e5                	mov    %esp,%ebp
  800eb3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800eb6:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800ebb:	89 c2                	mov    %eax,%edx
  800ebd:	c1 ea 16             	shr    $0x16,%edx
  800ec0:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800ec7:	f6 c2 01             	test   $0x1,%dl
  800eca:	74 11                	je     800edd <fd_alloc+0x2d>
  800ecc:	89 c2                	mov    %eax,%edx
  800ece:	c1 ea 0c             	shr    $0xc,%edx
  800ed1:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800ed8:	f6 c2 01             	test   $0x1,%dl
  800edb:	75 09                	jne    800ee6 <fd_alloc+0x36>
			*fd_store = fd;
  800edd:	89 01                	mov    %eax,(%ecx)
			return 0;
  800edf:	b8 00 00 00 00       	mov    $0x0,%eax
  800ee4:	eb 17                	jmp    800efd <fd_alloc+0x4d>
  800ee6:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800eeb:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800ef0:	75 c9                	jne    800ebb <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800ef2:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800ef8:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800efd:	5d                   	pop    %ebp
  800efe:	c3                   	ret    

00800eff <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800eff:	55                   	push   %ebp
  800f00:	89 e5                	mov    %esp,%ebp
  800f02:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800f05:	83 f8 1f             	cmp    $0x1f,%eax
  800f08:	77 36                	ja     800f40 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800f0a:	c1 e0 0c             	shl    $0xc,%eax
  800f0d:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800f12:	89 c2                	mov    %eax,%edx
  800f14:	c1 ea 16             	shr    $0x16,%edx
  800f17:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800f1e:	f6 c2 01             	test   $0x1,%dl
  800f21:	74 24                	je     800f47 <fd_lookup+0x48>
  800f23:	89 c2                	mov    %eax,%edx
  800f25:	c1 ea 0c             	shr    $0xc,%edx
  800f28:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f2f:	f6 c2 01             	test   $0x1,%dl
  800f32:	74 1a                	je     800f4e <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800f34:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f37:	89 02                	mov    %eax,(%edx)
	return 0;
  800f39:	b8 00 00 00 00       	mov    $0x0,%eax
  800f3e:	eb 13                	jmp    800f53 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800f40:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f45:	eb 0c                	jmp    800f53 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800f47:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f4c:	eb 05                	jmp    800f53 <fd_lookup+0x54>
  800f4e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800f53:	5d                   	pop    %ebp
  800f54:	c3                   	ret    

00800f55 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800f55:	55                   	push   %ebp
  800f56:	89 e5                	mov    %esp,%ebp
  800f58:	83 ec 08             	sub    $0x8,%esp
  800f5b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f5e:	ba 28 2e 80 00       	mov    $0x802e28,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800f63:	eb 13                	jmp    800f78 <dev_lookup+0x23>
  800f65:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800f68:	39 08                	cmp    %ecx,(%eax)
  800f6a:	75 0c                	jne    800f78 <dev_lookup+0x23>
			*dev = devtab[i];
  800f6c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f6f:	89 01                	mov    %eax,(%ecx)
			return 0;
  800f71:	b8 00 00 00 00       	mov    $0x0,%eax
  800f76:	eb 2e                	jmp    800fa6 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800f78:	8b 02                	mov    (%edx),%eax
  800f7a:	85 c0                	test   %eax,%eax
  800f7c:	75 e7                	jne    800f65 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800f7e:	a1 08 40 80 00       	mov    0x804008,%eax
  800f83:	8b 40 48             	mov    0x48(%eax),%eax
  800f86:	83 ec 04             	sub    $0x4,%esp
  800f89:	51                   	push   %ecx
  800f8a:	50                   	push   %eax
  800f8b:	68 ac 2d 80 00       	push   $0x802dac
  800f90:	e8 d8 f2 ff ff       	call   80026d <cprintf>
	*dev = 0;
  800f95:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f98:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800f9e:	83 c4 10             	add    $0x10,%esp
  800fa1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800fa6:	c9                   	leave  
  800fa7:	c3                   	ret    

00800fa8 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800fa8:	55                   	push   %ebp
  800fa9:	89 e5                	mov    %esp,%ebp
  800fab:	56                   	push   %esi
  800fac:	53                   	push   %ebx
  800fad:	83 ec 10             	sub    $0x10,%esp
  800fb0:	8b 75 08             	mov    0x8(%ebp),%esi
  800fb3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800fb6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fb9:	50                   	push   %eax
  800fba:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800fc0:	c1 e8 0c             	shr    $0xc,%eax
  800fc3:	50                   	push   %eax
  800fc4:	e8 36 ff ff ff       	call   800eff <fd_lookup>
  800fc9:	83 c4 08             	add    $0x8,%esp
  800fcc:	85 c0                	test   %eax,%eax
  800fce:	78 05                	js     800fd5 <fd_close+0x2d>
	    || fd != fd2)
  800fd0:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800fd3:	74 0c                	je     800fe1 <fd_close+0x39>
		return (must_exist ? r : 0);
  800fd5:	84 db                	test   %bl,%bl
  800fd7:	ba 00 00 00 00       	mov    $0x0,%edx
  800fdc:	0f 44 c2             	cmove  %edx,%eax
  800fdf:	eb 41                	jmp    801022 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800fe1:	83 ec 08             	sub    $0x8,%esp
  800fe4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800fe7:	50                   	push   %eax
  800fe8:	ff 36                	pushl  (%esi)
  800fea:	e8 66 ff ff ff       	call   800f55 <dev_lookup>
  800fef:	89 c3                	mov    %eax,%ebx
  800ff1:	83 c4 10             	add    $0x10,%esp
  800ff4:	85 c0                	test   %eax,%eax
  800ff6:	78 1a                	js     801012 <fd_close+0x6a>
		if (dev->dev_close)
  800ff8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ffb:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800ffe:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801003:	85 c0                	test   %eax,%eax
  801005:	74 0b                	je     801012 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801007:	83 ec 0c             	sub    $0xc,%esp
  80100a:	56                   	push   %esi
  80100b:	ff d0                	call   *%eax
  80100d:	89 c3                	mov    %eax,%ebx
  80100f:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801012:	83 ec 08             	sub    $0x8,%esp
  801015:	56                   	push   %esi
  801016:	6a 00                	push   $0x0
  801018:	e8 5d fc ff ff       	call   800c7a <sys_page_unmap>
	return r;
  80101d:	83 c4 10             	add    $0x10,%esp
  801020:	89 d8                	mov    %ebx,%eax
}
  801022:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801025:	5b                   	pop    %ebx
  801026:	5e                   	pop    %esi
  801027:	5d                   	pop    %ebp
  801028:	c3                   	ret    

00801029 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801029:	55                   	push   %ebp
  80102a:	89 e5                	mov    %esp,%ebp
  80102c:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80102f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801032:	50                   	push   %eax
  801033:	ff 75 08             	pushl  0x8(%ebp)
  801036:	e8 c4 fe ff ff       	call   800eff <fd_lookup>
  80103b:	83 c4 08             	add    $0x8,%esp
  80103e:	85 c0                	test   %eax,%eax
  801040:	78 10                	js     801052 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801042:	83 ec 08             	sub    $0x8,%esp
  801045:	6a 01                	push   $0x1
  801047:	ff 75 f4             	pushl  -0xc(%ebp)
  80104a:	e8 59 ff ff ff       	call   800fa8 <fd_close>
  80104f:	83 c4 10             	add    $0x10,%esp
}
  801052:	c9                   	leave  
  801053:	c3                   	ret    

00801054 <close_all>:

void
close_all(void)
{
  801054:	55                   	push   %ebp
  801055:	89 e5                	mov    %esp,%ebp
  801057:	53                   	push   %ebx
  801058:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80105b:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801060:	83 ec 0c             	sub    $0xc,%esp
  801063:	53                   	push   %ebx
  801064:	e8 c0 ff ff ff       	call   801029 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801069:	83 c3 01             	add    $0x1,%ebx
  80106c:	83 c4 10             	add    $0x10,%esp
  80106f:	83 fb 20             	cmp    $0x20,%ebx
  801072:	75 ec                	jne    801060 <close_all+0xc>
		close(i);
}
  801074:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801077:	c9                   	leave  
  801078:	c3                   	ret    

00801079 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801079:	55                   	push   %ebp
  80107a:	89 e5                	mov    %esp,%ebp
  80107c:	57                   	push   %edi
  80107d:	56                   	push   %esi
  80107e:	53                   	push   %ebx
  80107f:	83 ec 2c             	sub    $0x2c,%esp
  801082:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801085:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801088:	50                   	push   %eax
  801089:	ff 75 08             	pushl  0x8(%ebp)
  80108c:	e8 6e fe ff ff       	call   800eff <fd_lookup>
  801091:	83 c4 08             	add    $0x8,%esp
  801094:	85 c0                	test   %eax,%eax
  801096:	0f 88 c1 00 00 00    	js     80115d <dup+0xe4>
		return r;
	close(newfdnum);
  80109c:	83 ec 0c             	sub    $0xc,%esp
  80109f:	56                   	push   %esi
  8010a0:	e8 84 ff ff ff       	call   801029 <close>

	newfd = INDEX2FD(newfdnum);
  8010a5:	89 f3                	mov    %esi,%ebx
  8010a7:	c1 e3 0c             	shl    $0xc,%ebx
  8010aa:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8010b0:	83 c4 04             	add    $0x4,%esp
  8010b3:	ff 75 e4             	pushl  -0x1c(%ebp)
  8010b6:	e8 de fd ff ff       	call   800e99 <fd2data>
  8010bb:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8010bd:	89 1c 24             	mov    %ebx,(%esp)
  8010c0:	e8 d4 fd ff ff       	call   800e99 <fd2data>
  8010c5:	83 c4 10             	add    $0x10,%esp
  8010c8:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8010cb:	89 f8                	mov    %edi,%eax
  8010cd:	c1 e8 16             	shr    $0x16,%eax
  8010d0:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8010d7:	a8 01                	test   $0x1,%al
  8010d9:	74 37                	je     801112 <dup+0x99>
  8010db:	89 f8                	mov    %edi,%eax
  8010dd:	c1 e8 0c             	shr    $0xc,%eax
  8010e0:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8010e7:	f6 c2 01             	test   $0x1,%dl
  8010ea:	74 26                	je     801112 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8010ec:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8010f3:	83 ec 0c             	sub    $0xc,%esp
  8010f6:	25 07 0e 00 00       	and    $0xe07,%eax
  8010fb:	50                   	push   %eax
  8010fc:	ff 75 d4             	pushl  -0x2c(%ebp)
  8010ff:	6a 00                	push   $0x0
  801101:	57                   	push   %edi
  801102:	6a 00                	push   $0x0
  801104:	e8 2f fb ff ff       	call   800c38 <sys_page_map>
  801109:	89 c7                	mov    %eax,%edi
  80110b:	83 c4 20             	add    $0x20,%esp
  80110e:	85 c0                	test   %eax,%eax
  801110:	78 2e                	js     801140 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801112:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801115:	89 d0                	mov    %edx,%eax
  801117:	c1 e8 0c             	shr    $0xc,%eax
  80111a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801121:	83 ec 0c             	sub    $0xc,%esp
  801124:	25 07 0e 00 00       	and    $0xe07,%eax
  801129:	50                   	push   %eax
  80112a:	53                   	push   %ebx
  80112b:	6a 00                	push   $0x0
  80112d:	52                   	push   %edx
  80112e:	6a 00                	push   $0x0
  801130:	e8 03 fb ff ff       	call   800c38 <sys_page_map>
  801135:	89 c7                	mov    %eax,%edi
  801137:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80113a:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80113c:	85 ff                	test   %edi,%edi
  80113e:	79 1d                	jns    80115d <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801140:	83 ec 08             	sub    $0x8,%esp
  801143:	53                   	push   %ebx
  801144:	6a 00                	push   $0x0
  801146:	e8 2f fb ff ff       	call   800c7a <sys_page_unmap>
	sys_page_unmap(0, nva);
  80114b:	83 c4 08             	add    $0x8,%esp
  80114e:	ff 75 d4             	pushl  -0x2c(%ebp)
  801151:	6a 00                	push   $0x0
  801153:	e8 22 fb ff ff       	call   800c7a <sys_page_unmap>
	return r;
  801158:	83 c4 10             	add    $0x10,%esp
  80115b:	89 f8                	mov    %edi,%eax
}
  80115d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801160:	5b                   	pop    %ebx
  801161:	5e                   	pop    %esi
  801162:	5f                   	pop    %edi
  801163:	5d                   	pop    %ebp
  801164:	c3                   	ret    

00801165 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801165:	55                   	push   %ebp
  801166:	89 e5                	mov    %esp,%ebp
  801168:	53                   	push   %ebx
  801169:	83 ec 14             	sub    $0x14,%esp
  80116c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80116f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801172:	50                   	push   %eax
  801173:	53                   	push   %ebx
  801174:	e8 86 fd ff ff       	call   800eff <fd_lookup>
  801179:	83 c4 08             	add    $0x8,%esp
  80117c:	89 c2                	mov    %eax,%edx
  80117e:	85 c0                	test   %eax,%eax
  801180:	78 6d                	js     8011ef <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801182:	83 ec 08             	sub    $0x8,%esp
  801185:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801188:	50                   	push   %eax
  801189:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80118c:	ff 30                	pushl  (%eax)
  80118e:	e8 c2 fd ff ff       	call   800f55 <dev_lookup>
  801193:	83 c4 10             	add    $0x10,%esp
  801196:	85 c0                	test   %eax,%eax
  801198:	78 4c                	js     8011e6 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80119a:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80119d:	8b 42 08             	mov    0x8(%edx),%eax
  8011a0:	83 e0 03             	and    $0x3,%eax
  8011a3:	83 f8 01             	cmp    $0x1,%eax
  8011a6:	75 21                	jne    8011c9 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8011a8:	a1 08 40 80 00       	mov    0x804008,%eax
  8011ad:	8b 40 48             	mov    0x48(%eax),%eax
  8011b0:	83 ec 04             	sub    $0x4,%esp
  8011b3:	53                   	push   %ebx
  8011b4:	50                   	push   %eax
  8011b5:	68 ed 2d 80 00       	push   $0x802ded
  8011ba:	e8 ae f0 ff ff       	call   80026d <cprintf>
		return -E_INVAL;
  8011bf:	83 c4 10             	add    $0x10,%esp
  8011c2:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8011c7:	eb 26                	jmp    8011ef <read+0x8a>
	}
	if (!dev->dev_read)
  8011c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011cc:	8b 40 08             	mov    0x8(%eax),%eax
  8011cf:	85 c0                	test   %eax,%eax
  8011d1:	74 17                	je     8011ea <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8011d3:	83 ec 04             	sub    $0x4,%esp
  8011d6:	ff 75 10             	pushl  0x10(%ebp)
  8011d9:	ff 75 0c             	pushl  0xc(%ebp)
  8011dc:	52                   	push   %edx
  8011dd:	ff d0                	call   *%eax
  8011df:	89 c2                	mov    %eax,%edx
  8011e1:	83 c4 10             	add    $0x10,%esp
  8011e4:	eb 09                	jmp    8011ef <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011e6:	89 c2                	mov    %eax,%edx
  8011e8:	eb 05                	jmp    8011ef <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8011ea:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8011ef:	89 d0                	mov    %edx,%eax
  8011f1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011f4:	c9                   	leave  
  8011f5:	c3                   	ret    

008011f6 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8011f6:	55                   	push   %ebp
  8011f7:	89 e5                	mov    %esp,%ebp
  8011f9:	57                   	push   %edi
  8011fa:	56                   	push   %esi
  8011fb:	53                   	push   %ebx
  8011fc:	83 ec 0c             	sub    $0xc,%esp
  8011ff:	8b 7d 08             	mov    0x8(%ebp),%edi
  801202:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801205:	bb 00 00 00 00       	mov    $0x0,%ebx
  80120a:	eb 21                	jmp    80122d <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80120c:	83 ec 04             	sub    $0x4,%esp
  80120f:	89 f0                	mov    %esi,%eax
  801211:	29 d8                	sub    %ebx,%eax
  801213:	50                   	push   %eax
  801214:	89 d8                	mov    %ebx,%eax
  801216:	03 45 0c             	add    0xc(%ebp),%eax
  801219:	50                   	push   %eax
  80121a:	57                   	push   %edi
  80121b:	e8 45 ff ff ff       	call   801165 <read>
		if (m < 0)
  801220:	83 c4 10             	add    $0x10,%esp
  801223:	85 c0                	test   %eax,%eax
  801225:	78 10                	js     801237 <readn+0x41>
			return m;
		if (m == 0)
  801227:	85 c0                	test   %eax,%eax
  801229:	74 0a                	je     801235 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80122b:	01 c3                	add    %eax,%ebx
  80122d:	39 f3                	cmp    %esi,%ebx
  80122f:	72 db                	jb     80120c <readn+0x16>
  801231:	89 d8                	mov    %ebx,%eax
  801233:	eb 02                	jmp    801237 <readn+0x41>
  801235:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801237:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80123a:	5b                   	pop    %ebx
  80123b:	5e                   	pop    %esi
  80123c:	5f                   	pop    %edi
  80123d:	5d                   	pop    %ebp
  80123e:	c3                   	ret    

0080123f <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80123f:	55                   	push   %ebp
  801240:	89 e5                	mov    %esp,%ebp
  801242:	53                   	push   %ebx
  801243:	83 ec 14             	sub    $0x14,%esp
  801246:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801249:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80124c:	50                   	push   %eax
  80124d:	53                   	push   %ebx
  80124e:	e8 ac fc ff ff       	call   800eff <fd_lookup>
  801253:	83 c4 08             	add    $0x8,%esp
  801256:	89 c2                	mov    %eax,%edx
  801258:	85 c0                	test   %eax,%eax
  80125a:	78 68                	js     8012c4 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80125c:	83 ec 08             	sub    $0x8,%esp
  80125f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801262:	50                   	push   %eax
  801263:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801266:	ff 30                	pushl  (%eax)
  801268:	e8 e8 fc ff ff       	call   800f55 <dev_lookup>
  80126d:	83 c4 10             	add    $0x10,%esp
  801270:	85 c0                	test   %eax,%eax
  801272:	78 47                	js     8012bb <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801274:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801277:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80127b:	75 21                	jne    80129e <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80127d:	a1 08 40 80 00       	mov    0x804008,%eax
  801282:	8b 40 48             	mov    0x48(%eax),%eax
  801285:	83 ec 04             	sub    $0x4,%esp
  801288:	53                   	push   %ebx
  801289:	50                   	push   %eax
  80128a:	68 09 2e 80 00       	push   $0x802e09
  80128f:	e8 d9 ef ff ff       	call   80026d <cprintf>
		return -E_INVAL;
  801294:	83 c4 10             	add    $0x10,%esp
  801297:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80129c:	eb 26                	jmp    8012c4 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80129e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8012a1:	8b 52 0c             	mov    0xc(%edx),%edx
  8012a4:	85 d2                	test   %edx,%edx
  8012a6:	74 17                	je     8012bf <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8012a8:	83 ec 04             	sub    $0x4,%esp
  8012ab:	ff 75 10             	pushl  0x10(%ebp)
  8012ae:	ff 75 0c             	pushl  0xc(%ebp)
  8012b1:	50                   	push   %eax
  8012b2:	ff d2                	call   *%edx
  8012b4:	89 c2                	mov    %eax,%edx
  8012b6:	83 c4 10             	add    $0x10,%esp
  8012b9:	eb 09                	jmp    8012c4 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012bb:	89 c2                	mov    %eax,%edx
  8012bd:	eb 05                	jmp    8012c4 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8012bf:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8012c4:	89 d0                	mov    %edx,%eax
  8012c6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012c9:	c9                   	leave  
  8012ca:	c3                   	ret    

008012cb <seek>:

int
seek(int fdnum, off_t offset)
{
  8012cb:	55                   	push   %ebp
  8012cc:	89 e5                	mov    %esp,%ebp
  8012ce:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8012d1:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8012d4:	50                   	push   %eax
  8012d5:	ff 75 08             	pushl  0x8(%ebp)
  8012d8:	e8 22 fc ff ff       	call   800eff <fd_lookup>
  8012dd:	83 c4 08             	add    $0x8,%esp
  8012e0:	85 c0                	test   %eax,%eax
  8012e2:	78 0e                	js     8012f2 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8012e4:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8012e7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012ea:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8012ed:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8012f2:	c9                   	leave  
  8012f3:	c3                   	ret    

008012f4 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8012f4:	55                   	push   %ebp
  8012f5:	89 e5                	mov    %esp,%ebp
  8012f7:	53                   	push   %ebx
  8012f8:	83 ec 14             	sub    $0x14,%esp
  8012fb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012fe:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801301:	50                   	push   %eax
  801302:	53                   	push   %ebx
  801303:	e8 f7 fb ff ff       	call   800eff <fd_lookup>
  801308:	83 c4 08             	add    $0x8,%esp
  80130b:	89 c2                	mov    %eax,%edx
  80130d:	85 c0                	test   %eax,%eax
  80130f:	78 65                	js     801376 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801311:	83 ec 08             	sub    $0x8,%esp
  801314:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801317:	50                   	push   %eax
  801318:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80131b:	ff 30                	pushl  (%eax)
  80131d:	e8 33 fc ff ff       	call   800f55 <dev_lookup>
  801322:	83 c4 10             	add    $0x10,%esp
  801325:	85 c0                	test   %eax,%eax
  801327:	78 44                	js     80136d <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801329:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80132c:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801330:	75 21                	jne    801353 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801332:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801337:	8b 40 48             	mov    0x48(%eax),%eax
  80133a:	83 ec 04             	sub    $0x4,%esp
  80133d:	53                   	push   %ebx
  80133e:	50                   	push   %eax
  80133f:	68 cc 2d 80 00       	push   $0x802dcc
  801344:	e8 24 ef ff ff       	call   80026d <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801349:	83 c4 10             	add    $0x10,%esp
  80134c:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801351:	eb 23                	jmp    801376 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801353:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801356:	8b 52 18             	mov    0x18(%edx),%edx
  801359:	85 d2                	test   %edx,%edx
  80135b:	74 14                	je     801371 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80135d:	83 ec 08             	sub    $0x8,%esp
  801360:	ff 75 0c             	pushl  0xc(%ebp)
  801363:	50                   	push   %eax
  801364:	ff d2                	call   *%edx
  801366:	89 c2                	mov    %eax,%edx
  801368:	83 c4 10             	add    $0x10,%esp
  80136b:	eb 09                	jmp    801376 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80136d:	89 c2                	mov    %eax,%edx
  80136f:	eb 05                	jmp    801376 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801371:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801376:	89 d0                	mov    %edx,%eax
  801378:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80137b:	c9                   	leave  
  80137c:	c3                   	ret    

0080137d <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80137d:	55                   	push   %ebp
  80137e:	89 e5                	mov    %esp,%ebp
  801380:	53                   	push   %ebx
  801381:	83 ec 14             	sub    $0x14,%esp
  801384:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801387:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80138a:	50                   	push   %eax
  80138b:	ff 75 08             	pushl  0x8(%ebp)
  80138e:	e8 6c fb ff ff       	call   800eff <fd_lookup>
  801393:	83 c4 08             	add    $0x8,%esp
  801396:	89 c2                	mov    %eax,%edx
  801398:	85 c0                	test   %eax,%eax
  80139a:	78 58                	js     8013f4 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80139c:	83 ec 08             	sub    $0x8,%esp
  80139f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013a2:	50                   	push   %eax
  8013a3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013a6:	ff 30                	pushl  (%eax)
  8013a8:	e8 a8 fb ff ff       	call   800f55 <dev_lookup>
  8013ad:	83 c4 10             	add    $0x10,%esp
  8013b0:	85 c0                	test   %eax,%eax
  8013b2:	78 37                	js     8013eb <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8013b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013b7:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8013bb:	74 32                	je     8013ef <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8013bd:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8013c0:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8013c7:	00 00 00 
	stat->st_isdir = 0;
  8013ca:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8013d1:	00 00 00 
	stat->st_dev = dev;
  8013d4:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8013da:	83 ec 08             	sub    $0x8,%esp
  8013dd:	53                   	push   %ebx
  8013de:	ff 75 f0             	pushl  -0x10(%ebp)
  8013e1:	ff 50 14             	call   *0x14(%eax)
  8013e4:	89 c2                	mov    %eax,%edx
  8013e6:	83 c4 10             	add    $0x10,%esp
  8013e9:	eb 09                	jmp    8013f4 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013eb:	89 c2                	mov    %eax,%edx
  8013ed:	eb 05                	jmp    8013f4 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8013ef:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8013f4:	89 d0                	mov    %edx,%eax
  8013f6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013f9:	c9                   	leave  
  8013fa:	c3                   	ret    

008013fb <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8013fb:	55                   	push   %ebp
  8013fc:	89 e5                	mov    %esp,%ebp
  8013fe:	56                   	push   %esi
  8013ff:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801400:	83 ec 08             	sub    $0x8,%esp
  801403:	6a 00                	push   $0x0
  801405:	ff 75 08             	pushl  0x8(%ebp)
  801408:	e8 d6 01 00 00       	call   8015e3 <open>
  80140d:	89 c3                	mov    %eax,%ebx
  80140f:	83 c4 10             	add    $0x10,%esp
  801412:	85 c0                	test   %eax,%eax
  801414:	78 1b                	js     801431 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801416:	83 ec 08             	sub    $0x8,%esp
  801419:	ff 75 0c             	pushl  0xc(%ebp)
  80141c:	50                   	push   %eax
  80141d:	e8 5b ff ff ff       	call   80137d <fstat>
  801422:	89 c6                	mov    %eax,%esi
	close(fd);
  801424:	89 1c 24             	mov    %ebx,(%esp)
  801427:	e8 fd fb ff ff       	call   801029 <close>
	return r;
  80142c:	83 c4 10             	add    $0x10,%esp
  80142f:	89 f0                	mov    %esi,%eax
}
  801431:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801434:	5b                   	pop    %ebx
  801435:	5e                   	pop    %esi
  801436:	5d                   	pop    %ebp
  801437:	c3                   	ret    

00801438 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801438:	55                   	push   %ebp
  801439:	89 e5                	mov    %esp,%ebp
  80143b:	56                   	push   %esi
  80143c:	53                   	push   %ebx
  80143d:	89 c6                	mov    %eax,%esi
  80143f:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801441:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801448:	75 12                	jne    80145c <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80144a:	83 ec 0c             	sub    $0xc,%esp
  80144d:	6a 01                	push   $0x1
  80144f:	e8 24 12 00 00       	call   802678 <ipc_find_env>
  801454:	a3 00 40 80 00       	mov    %eax,0x804000
  801459:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80145c:	6a 07                	push   $0x7
  80145e:	68 00 50 80 00       	push   $0x805000
  801463:	56                   	push   %esi
  801464:	ff 35 00 40 80 00    	pushl  0x804000
  80146a:	e8 b5 11 00 00       	call   802624 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80146f:	83 c4 0c             	add    $0xc,%esp
  801472:	6a 00                	push   $0x0
  801474:	53                   	push   %ebx
  801475:	6a 00                	push   $0x0
  801477:	e8 41 11 00 00       	call   8025bd <ipc_recv>
}
  80147c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80147f:	5b                   	pop    %ebx
  801480:	5e                   	pop    %esi
  801481:	5d                   	pop    %ebp
  801482:	c3                   	ret    

00801483 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801483:	55                   	push   %ebp
  801484:	89 e5                	mov    %esp,%ebp
  801486:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801489:	8b 45 08             	mov    0x8(%ebp),%eax
  80148c:	8b 40 0c             	mov    0xc(%eax),%eax
  80148f:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801494:	8b 45 0c             	mov    0xc(%ebp),%eax
  801497:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80149c:	ba 00 00 00 00       	mov    $0x0,%edx
  8014a1:	b8 02 00 00 00       	mov    $0x2,%eax
  8014a6:	e8 8d ff ff ff       	call   801438 <fsipc>
}
  8014ab:	c9                   	leave  
  8014ac:	c3                   	ret    

008014ad <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8014ad:	55                   	push   %ebp
  8014ae:	89 e5                	mov    %esp,%ebp
  8014b0:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8014b3:	8b 45 08             	mov    0x8(%ebp),%eax
  8014b6:	8b 40 0c             	mov    0xc(%eax),%eax
  8014b9:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8014be:	ba 00 00 00 00       	mov    $0x0,%edx
  8014c3:	b8 06 00 00 00       	mov    $0x6,%eax
  8014c8:	e8 6b ff ff ff       	call   801438 <fsipc>
}
  8014cd:	c9                   	leave  
  8014ce:	c3                   	ret    

008014cf <devfile_stat>:

}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8014cf:	55                   	push   %ebp
  8014d0:	89 e5                	mov    %esp,%ebp
  8014d2:	53                   	push   %ebx
  8014d3:	83 ec 04             	sub    $0x4,%esp
  8014d6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8014d9:	8b 45 08             	mov    0x8(%ebp),%eax
  8014dc:	8b 40 0c             	mov    0xc(%eax),%eax
  8014df:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8014e4:	ba 00 00 00 00       	mov    $0x0,%edx
  8014e9:	b8 05 00 00 00       	mov    $0x5,%eax
  8014ee:	e8 45 ff ff ff       	call   801438 <fsipc>
  8014f3:	85 c0                	test   %eax,%eax
  8014f5:	78 2c                	js     801523 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8014f7:	83 ec 08             	sub    $0x8,%esp
  8014fa:	68 00 50 80 00       	push   $0x805000
  8014ff:	53                   	push   %ebx
  801500:	e8 ed f2 ff ff       	call   8007f2 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801505:	a1 80 50 80 00       	mov    0x805080,%eax
  80150a:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801510:	a1 84 50 80 00       	mov    0x805084,%eax
  801515:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80151b:	83 c4 10             	add    $0x10,%esp
  80151e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801523:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801526:	c9                   	leave  
  801527:	c3                   	ret    

00801528 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801528:	55                   	push   %ebp
  801529:	89 e5                	mov    %esp,%ebp
  80152b:	83 ec 0c             	sub    $0xc,%esp
  80152e:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	// panic("devfile_write not implemented");

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801531:	8b 55 08             	mov    0x8(%ebp),%edx
  801534:	8b 52 0c             	mov    0xc(%edx),%edx
  801537:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  80153d:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  801542:	50                   	push   %eax
  801543:	ff 75 0c             	pushl  0xc(%ebp)
  801546:	68 08 50 80 00       	push   $0x805008
  80154b:	e8 34 f4 ff ff       	call   800984 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  801550:	ba 00 00 00 00       	mov    $0x0,%edx
  801555:	b8 04 00 00 00       	mov    $0x4,%eax
  80155a:	e8 d9 fe ff ff       	call   801438 <fsipc>

}
  80155f:	c9                   	leave  
  801560:	c3                   	ret    

00801561 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801561:	55                   	push   %ebp
  801562:	89 e5                	mov    %esp,%ebp
  801564:	56                   	push   %esi
  801565:	53                   	push   %ebx
  801566:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801569:	8b 45 08             	mov    0x8(%ebp),%eax
  80156c:	8b 40 0c             	mov    0xc(%eax),%eax
  80156f:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801574:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80157a:	ba 00 00 00 00       	mov    $0x0,%edx
  80157f:	b8 03 00 00 00       	mov    $0x3,%eax
  801584:	e8 af fe ff ff       	call   801438 <fsipc>
  801589:	89 c3                	mov    %eax,%ebx
  80158b:	85 c0                	test   %eax,%eax
  80158d:	78 4b                	js     8015da <devfile_read+0x79>
		return r;
	assert(r <= n);
  80158f:	39 c6                	cmp    %eax,%esi
  801591:	73 16                	jae    8015a9 <devfile_read+0x48>
  801593:	68 3c 2e 80 00       	push   $0x802e3c
  801598:	68 43 2e 80 00       	push   $0x802e43
  80159d:	6a 7c                	push   $0x7c
  80159f:	68 58 2e 80 00       	push   $0x802e58
  8015a4:	e8 eb eb ff ff       	call   800194 <_panic>
	assert(r <= PGSIZE);
  8015a9:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8015ae:	7e 16                	jle    8015c6 <devfile_read+0x65>
  8015b0:	68 63 2e 80 00       	push   $0x802e63
  8015b5:	68 43 2e 80 00       	push   $0x802e43
  8015ba:	6a 7d                	push   $0x7d
  8015bc:	68 58 2e 80 00       	push   $0x802e58
  8015c1:	e8 ce eb ff ff       	call   800194 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8015c6:	83 ec 04             	sub    $0x4,%esp
  8015c9:	50                   	push   %eax
  8015ca:	68 00 50 80 00       	push   $0x805000
  8015cf:	ff 75 0c             	pushl  0xc(%ebp)
  8015d2:	e8 ad f3 ff ff       	call   800984 <memmove>
	return r;
  8015d7:	83 c4 10             	add    $0x10,%esp
}
  8015da:	89 d8                	mov    %ebx,%eax
  8015dc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015df:	5b                   	pop    %ebx
  8015e0:	5e                   	pop    %esi
  8015e1:	5d                   	pop    %ebp
  8015e2:	c3                   	ret    

008015e3 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8015e3:	55                   	push   %ebp
  8015e4:	89 e5                	mov    %esp,%ebp
  8015e6:	53                   	push   %ebx
  8015e7:	83 ec 20             	sub    $0x20,%esp
  8015ea:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8015ed:	53                   	push   %ebx
  8015ee:	e8 c6 f1 ff ff       	call   8007b9 <strlen>
  8015f3:	83 c4 10             	add    $0x10,%esp
  8015f6:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8015fb:	7f 67                	jg     801664 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8015fd:	83 ec 0c             	sub    $0xc,%esp
  801600:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801603:	50                   	push   %eax
  801604:	e8 a7 f8 ff ff       	call   800eb0 <fd_alloc>
  801609:	83 c4 10             	add    $0x10,%esp
		return r;
  80160c:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80160e:	85 c0                	test   %eax,%eax
  801610:	78 57                	js     801669 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801612:	83 ec 08             	sub    $0x8,%esp
  801615:	53                   	push   %ebx
  801616:	68 00 50 80 00       	push   $0x805000
  80161b:	e8 d2 f1 ff ff       	call   8007f2 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801620:	8b 45 0c             	mov    0xc(%ebp),%eax
  801623:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801628:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80162b:	b8 01 00 00 00       	mov    $0x1,%eax
  801630:	e8 03 fe ff ff       	call   801438 <fsipc>
  801635:	89 c3                	mov    %eax,%ebx
  801637:	83 c4 10             	add    $0x10,%esp
  80163a:	85 c0                	test   %eax,%eax
  80163c:	79 14                	jns    801652 <open+0x6f>
		fd_close(fd, 0);
  80163e:	83 ec 08             	sub    $0x8,%esp
  801641:	6a 00                	push   $0x0
  801643:	ff 75 f4             	pushl  -0xc(%ebp)
  801646:	e8 5d f9 ff ff       	call   800fa8 <fd_close>
		return r;
  80164b:	83 c4 10             	add    $0x10,%esp
  80164e:	89 da                	mov    %ebx,%edx
  801650:	eb 17                	jmp    801669 <open+0x86>
	}

	return fd2num(fd);
  801652:	83 ec 0c             	sub    $0xc,%esp
  801655:	ff 75 f4             	pushl  -0xc(%ebp)
  801658:	e8 2c f8 ff ff       	call   800e89 <fd2num>
  80165d:	89 c2                	mov    %eax,%edx
  80165f:	83 c4 10             	add    $0x10,%esp
  801662:	eb 05                	jmp    801669 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801664:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801669:	89 d0                	mov    %edx,%eax
  80166b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80166e:	c9                   	leave  
  80166f:	c3                   	ret    

00801670 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801670:	55                   	push   %ebp
  801671:	89 e5                	mov    %esp,%ebp
  801673:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801676:	ba 00 00 00 00       	mov    $0x0,%edx
  80167b:	b8 08 00 00 00       	mov    $0x8,%eax
  801680:	e8 b3 fd ff ff       	call   801438 <fsipc>
}
  801685:	c9                   	leave  
  801686:	c3                   	ret    

00801687 <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  801687:	55                   	push   %ebp
  801688:	89 e5                	mov    %esp,%ebp
  80168a:	57                   	push   %edi
  80168b:	56                   	push   %esi
  80168c:	53                   	push   %ebx
  80168d:	81 ec 94 02 00 00    	sub    $0x294,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  801693:	6a 00                	push   $0x0
  801695:	ff 75 08             	pushl  0x8(%ebp)
  801698:	e8 46 ff ff ff       	call   8015e3 <open>
  80169d:	89 c7                	mov    %eax,%edi
  80169f:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  8016a5:	83 c4 10             	add    $0x10,%esp
  8016a8:	85 c0                	test   %eax,%eax
  8016aa:	0f 88 97 04 00 00    	js     801b47 <spawn+0x4c0>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  8016b0:	83 ec 04             	sub    $0x4,%esp
  8016b3:	68 00 02 00 00       	push   $0x200
  8016b8:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  8016be:	50                   	push   %eax
  8016bf:	57                   	push   %edi
  8016c0:	e8 31 fb ff ff       	call   8011f6 <readn>
  8016c5:	83 c4 10             	add    $0x10,%esp
  8016c8:	3d 00 02 00 00       	cmp    $0x200,%eax
  8016cd:	75 0c                	jne    8016db <spawn+0x54>
	    || elf->e_magic != ELF_MAGIC) {
  8016cf:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  8016d6:	45 4c 46 
  8016d9:	74 33                	je     80170e <spawn+0x87>
		close(fd);
  8016db:	83 ec 0c             	sub    $0xc,%esp
  8016de:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  8016e4:	e8 40 f9 ff ff       	call   801029 <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  8016e9:	83 c4 0c             	add    $0xc,%esp
  8016ec:	68 7f 45 4c 46       	push   $0x464c457f
  8016f1:	ff b5 e8 fd ff ff    	pushl  -0x218(%ebp)
  8016f7:	68 6f 2e 80 00       	push   $0x802e6f
  8016fc:	e8 6c eb ff ff       	call   80026d <cprintf>
		return -E_NOT_EXEC;
  801701:	83 c4 10             	add    $0x10,%esp
  801704:	bb f2 ff ff ff       	mov    $0xfffffff2,%ebx
  801709:	e9 ec 04 00 00       	jmp    801bfa <spawn+0x573>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  80170e:	b8 07 00 00 00       	mov    $0x7,%eax
  801713:	cd 30                	int    $0x30
  801715:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
  80171b:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  801721:	85 c0                	test   %eax,%eax
  801723:	0f 88 29 04 00 00    	js     801b52 <spawn+0x4cb>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  801729:	89 c6                	mov    %eax,%esi
  80172b:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  801731:	6b f6 7c             	imul   $0x7c,%esi,%esi
  801734:	81 c6 00 00 c0 ee    	add    $0xeec00000,%esi
  80173a:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  801740:	b9 11 00 00 00       	mov    $0x11,%ecx
  801745:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  801747:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  80174d:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801753:	bb 00 00 00 00       	mov    $0x0,%ebx
	char *string_store;
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
  801758:	be 00 00 00 00       	mov    $0x0,%esi
  80175d:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801760:	eb 13                	jmp    801775 <spawn+0xee>
	for (argc = 0; argv[argc] != 0; argc++)
		string_size += strlen(argv[argc]) + 1;
  801762:	83 ec 0c             	sub    $0xc,%esp
  801765:	50                   	push   %eax
  801766:	e8 4e f0 ff ff       	call   8007b9 <strlen>
  80176b:	8d 74 30 01          	lea    0x1(%eax,%esi,1),%esi
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  80176f:	83 c3 01             	add    $0x1,%ebx
  801772:	83 c4 10             	add    $0x10,%esp
  801775:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
  80177c:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  80177f:	85 c0                	test   %eax,%eax
  801781:	75 df                	jne    801762 <spawn+0xdb>
  801783:	89 9d 88 fd ff ff    	mov    %ebx,-0x278(%ebp)
  801789:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  80178f:	bf 00 10 40 00       	mov    $0x401000,%edi
  801794:	29 f7                	sub    %esi,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  801796:	89 fa                	mov    %edi,%edx
  801798:	83 e2 fc             	and    $0xfffffffc,%edx
  80179b:	8d 04 9d 04 00 00 00 	lea    0x4(,%ebx,4),%eax
  8017a2:	29 c2                	sub    %eax,%edx
  8017a4:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  8017aa:	8d 42 f8             	lea    -0x8(%edx),%eax
  8017ad:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  8017b2:	0f 86 b0 03 00 00    	jbe    801b68 <spawn+0x4e1>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  8017b8:	83 ec 04             	sub    $0x4,%esp
  8017bb:	6a 07                	push   $0x7
  8017bd:	68 00 00 40 00       	push   $0x400000
  8017c2:	6a 00                	push   $0x0
  8017c4:	e8 2c f4 ff ff       	call   800bf5 <sys_page_alloc>
  8017c9:	83 c4 10             	add    $0x10,%esp
  8017cc:	85 c0                	test   %eax,%eax
  8017ce:	0f 88 9e 03 00 00    	js     801b72 <spawn+0x4eb>
  8017d4:	be 00 00 00 00       	mov    $0x0,%esi
  8017d9:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
  8017df:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8017e2:	eb 30                	jmp    801814 <spawn+0x18d>
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
		argv_store[i] = UTEMP2USTACK(string_store);
  8017e4:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  8017ea:	8b 8d 94 fd ff ff    	mov    -0x26c(%ebp),%ecx
  8017f0:	89 04 b1             	mov    %eax,(%ecx,%esi,4)
		strcpy(string_store, argv[i]);
  8017f3:	83 ec 08             	sub    $0x8,%esp
  8017f6:	ff 34 b3             	pushl  (%ebx,%esi,4)
  8017f9:	57                   	push   %edi
  8017fa:	e8 f3 ef ff ff       	call   8007f2 <strcpy>
		string_store += strlen(argv[i]) + 1;
  8017ff:	83 c4 04             	add    $0x4,%esp
  801802:	ff 34 b3             	pushl  (%ebx,%esi,4)
  801805:	e8 af ef ff ff       	call   8007b9 <strlen>
  80180a:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  80180e:	83 c6 01             	add    $0x1,%esi
  801811:	83 c4 10             	add    $0x10,%esp
  801814:	39 b5 90 fd ff ff    	cmp    %esi,-0x270(%ebp)
  80181a:	7f c8                	jg     8017e4 <spawn+0x15d>
		argv_store[i] = UTEMP2USTACK(string_store);
		strcpy(string_store, argv[i]);
		string_store += strlen(argv[i]) + 1;
	}
	argv_store[argc] = 0;
  80181c:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  801822:	8b b5 80 fd ff ff    	mov    -0x280(%ebp),%esi
  801828:	c7 04 30 00 00 00 00 	movl   $0x0,(%eax,%esi,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  80182f:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  801835:	74 19                	je     801850 <spawn+0x1c9>
  801837:	68 fc 2e 80 00       	push   $0x802efc
  80183c:	68 43 2e 80 00       	push   $0x802e43
  801841:	68 f2 00 00 00       	push   $0xf2
  801846:	68 89 2e 80 00       	push   $0x802e89
  80184b:	e8 44 e9 ff ff       	call   800194 <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  801850:	8b bd 94 fd ff ff    	mov    -0x26c(%ebp),%edi
  801856:	89 f8                	mov    %edi,%eax
  801858:	2d 00 30 80 11       	sub    $0x11803000,%eax
  80185d:	89 47 fc             	mov    %eax,-0x4(%edi)
	argv_store[-2] = argc;
  801860:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801866:	89 47 f8             	mov    %eax,-0x8(%edi)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  801869:	8d 87 f8 cf 7f ee    	lea    -0x11803008(%edi),%eax
  80186f:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  801875:	83 ec 0c             	sub    $0xc,%esp
  801878:	6a 07                	push   $0x7
  80187a:	68 00 d0 bf ee       	push   $0xeebfd000
  80187f:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801885:	68 00 00 40 00       	push   $0x400000
  80188a:	6a 00                	push   $0x0
  80188c:	e8 a7 f3 ff ff       	call   800c38 <sys_page_map>
  801891:	89 c3                	mov    %eax,%ebx
  801893:	83 c4 20             	add    $0x20,%esp
  801896:	85 c0                	test   %eax,%eax
  801898:	0f 88 4a 03 00 00    	js     801be8 <spawn+0x561>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  80189e:	83 ec 08             	sub    $0x8,%esp
  8018a1:	68 00 00 40 00       	push   $0x400000
  8018a6:	6a 00                	push   $0x0
  8018a8:	e8 cd f3 ff ff       	call   800c7a <sys_page_unmap>
  8018ad:	89 c3                	mov    %eax,%ebx
  8018af:	83 c4 10             	add    $0x10,%esp
  8018b2:	85 c0                	test   %eax,%eax
  8018b4:	0f 88 2e 03 00 00    	js     801be8 <spawn+0x561>

	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  8018ba:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
  8018c0:	8d 84 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%eax
  8018c7:	89 85 7c fd ff ff    	mov    %eax,-0x284(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  8018cd:	c7 85 78 fd ff ff 00 	movl   $0x0,-0x288(%ebp)
  8018d4:	00 00 00 
  8018d7:	e9 8a 01 00 00       	jmp    801a66 <spawn+0x3df>
		if (ph->p_type != ELF_PROG_LOAD)
  8018dc:	8b 85 7c fd ff ff    	mov    -0x284(%ebp),%eax
  8018e2:	83 38 01             	cmpl   $0x1,(%eax)
  8018e5:	0f 85 6d 01 00 00    	jne    801a58 <spawn+0x3d1>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  8018eb:	89 c7                	mov    %eax,%edi
  8018ed:	8b 40 18             	mov    0x18(%eax),%eax
  8018f0:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  8018f6:	83 e0 02             	and    $0x2,%eax
			perm |= PTE_W;
  8018f9:	83 f8 01             	cmp    $0x1,%eax
  8018fc:	19 c0                	sbb    %eax,%eax
  8018fe:	83 e0 fe             	and    $0xfffffffe,%eax
  801901:	83 c0 07             	add    $0x7,%eax
  801904:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  80190a:	89 f8                	mov    %edi,%eax
  80190c:	8b 7f 04             	mov    0x4(%edi),%edi
  80190f:	89 f9                	mov    %edi,%ecx
  801911:	89 bd 80 fd ff ff    	mov    %edi,-0x280(%ebp)
  801917:	8b 78 10             	mov    0x10(%eax),%edi
  80191a:	8b 70 14             	mov    0x14(%eax),%esi
  80191d:	89 f3                	mov    %esi,%ebx
  80191f:	89 b5 90 fd ff ff    	mov    %esi,-0x270(%ebp)
  801925:	8b 70 08             	mov    0x8(%eax),%esi
	int i, r;
	void *blk;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  801928:	89 f0                	mov    %esi,%eax
  80192a:	25 ff 0f 00 00       	and    $0xfff,%eax
  80192f:	74 14                	je     801945 <spawn+0x2be>
		va -= i;
  801931:	29 c6                	sub    %eax,%esi
		memsz += i;
  801933:	01 c3                	add    %eax,%ebx
  801935:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
		filesz += i;
  80193b:	01 c7                	add    %eax,%edi
		fileoffset -= i;
  80193d:	29 c1                	sub    %eax,%ecx
  80193f:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801945:	bb 00 00 00 00       	mov    $0x0,%ebx
  80194a:	e9 f7 00 00 00       	jmp    801a46 <spawn+0x3bf>
		if (i >= filesz) {
  80194f:	39 df                	cmp    %ebx,%edi
  801951:	77 27                	ja     80197a <spawn+0x2f3>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  801953:	83 ec 04             	sub    $0x4,%esp
  801956:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  80195c:	56                   	push   %esi
  80195d:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  801963:	e8 8d f2 ff ff       	call   800bf5 <sys_page_alloc>
  801968:	83 c4 10             	add    $0x10,%esp
  80196b:	85 c0                	test   %eax,%eax
  80196d:	0f 89 c7 00 00 00    	jns    801a3a <spawn+0x3b3>
  801973:	89 c3                	mov    %eax,%ebx
  801975:	e9 09 02 00 00       	jmp    801b83 <spawn+0x4fc>
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  80197a:	83 ec 04             	sub    $0x4,%esp
  80197d:	6a 07                	push   $0x7
  80197f:	68 00 00 40 00       	push   $0x400000
  801984:	6a 00                	push   $0x0
  801986:	e8 6a f2 ff ff       	call   800bf5 <sys_page_alloc>
  80198b:	83 c4 10             	add    $0x10,%esp
  80198e:	85 c0                	test   %eax,%eax
  801990:	0f 88 e3 01 00 00    	js     801b79 <spawn+0x4f2>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801996:	83 ec 08             	sub    $0x8,%esp
  801999:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  80199f:	03 85 94 fd ff ff    	add    -0x26c(%ebp),%eax
  8019a5:	50                   	push   %eax
  8019a6:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  8019ac:	e8 1a f9 ff ff       	call   8012cb <seek>
  8019b1:	83 c4 10             	add    $0x10,%esp
  8019b4:	85 c0                	test   %eax,%eax
  8019b6:	0f 88 c1 01 00 00    	js     801b7d <spawn+0x4f6>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  8019bc:	83 ec 04             	sub    $0x4,%esp
  8019bf:	89 f8                	mov    %edi,%eax
  8019c1:	2b 85 94 fd ff ff    	sub    -0x26c(%ebp),%eax
  8019c7:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8019cc:	b9 00 10 00 00       	mov    $0x1000,%ecx
  8019d1:	0f 47 c1             	cmova  %ecx,%eax
  8019d4:	50                   	push   %eax
  8019d5:	68 00 00 40 00       	push   $0x400000
  8019da:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  8019e0:	e8 11 f8 ff ff       	call   8011f6 <readn>
  8019e5:	83 c4 10             	add    $0x10,%esp
  8019e8:	85 c0                	test   %eax,%eax
  8019ea:	0f 88 91 01 00 00    	js     801b81 <spawn+0x4fa>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  8019f0:	83 ec 0c             	sub    $0xc,%esp
  8019f3:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  8019f9:	56                   	push   %esi
  8019fa:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  801a00:	68 00 00 40 00       	push   $0x400000
  801a05:	6a 00                	push   $0x0
  801a07:	e8 2c f2 ff ff       	call   800c38 <sys_page_map>
  801a0c:	83 c4 20             	add    $0x20,%esp
  801a0f:	85 c0                	test   %eax,%eax
  801a11:	79 15                	jns    801a28 <spawn+0x3a1>
				panic("spawn: sys_page_map data: %e", r);
  801a13:	50                   	push   %eax
  801a14:	68 95 2e 80 00       	push   $0x802e95
  801a19:	68 25 01 00 00       	push   $0x125
  801a1e:	68 89 2e 80 00       	push   $0x802e89
  801a23:	e8 6c e7 ff ff       	call   800194 <_panic>
			sys_page_unmap(0, UTEMP);
  801a28:	83 ec 08             	sub    $0x8,%esp
  801a2b:	68 00 00 40 00       	push   $0x400000
  801a30:	6a 00                	push   $0x0
  801a32:	e8 43 f2 ff ff       	call   800c7a <sys_page_unmap>
  801a37:	83 c4 10             	add    $0x10,%esp
		memsz += i;
		filesz += i;
		fileoffset -= i;
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801a3a:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801a40:	81 c6 00 10 00 00    	add    $0x1000,%esi
  801a46:	89 9d 94 fd ff ff    	mov    %ebx,-0x26c(%ebp)
  801a4c:	39 9d 90 fd ff ff    	cmp    %ebx,-0x270(%ebp)
  801a52:	0f 87 f7 fe ff ff    	ja     80194f <spawn+0x2c8>
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801a58:	83 85 78 fd ff ff 01 	addl   $0x1,-0x288(%ebp)
  801a5f:	83 85 7c fd ff ff 20 	addl   $0x20,-0x284(%ebp)
  801a66:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  801a6d:	39 85 78 fd ff ff    	cmp    %eax,-0x288(%ebp)
  801a73:	0f 8c 63 fe ff ff    	jl     8018dc <spawn+0x255>
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
	}
	close(fd);
  801a79:	83 ec 0c             	sub    $0xc,%esp
  801a7c:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801a82:	e8 a2 f5 ff ff       	call   801029 <close>
  801a87:	83 c4 10             	add    $0x10,%esp
{
	// LAB 5: Your code here.

	int r;
	uint32_t addr;
	for (uint32_t pn = PGNUM(UTEXT); pn < PGNUM(USTACKTOP); pn++) {
  801a8a:	bb 00 08 00 00       	mov    $0x800,%ebx
  801a8f:	8b b5 84 fd ff ff    	mov    -0x27c(%ebp),%esi

		addr = pn * PGSIZE;
  801a95:	89 d8                	mov    %ebx,%eax
  801a97:	c1 e0 0c             	shl    $0xc,%eax

		// if level-2 page exists
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P) {
  801a9a:	89 c2                	mov    %eax,%edx
  801a9c:	c1 ea 16             	shr    $0x16,%edx
  801a9f:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801aa6:	f6 c2 01             	test   $0x1,%dl
  801aa9:	74 4b                	je     801af6 <spawn+0x46f>
			
			// if real PTE exists
			if ((uvpt[PGNUM(addr)] & PTE_P) == PTE_P) {
  801aab:	89 c2                	mov    %eax,%edx
  801aad:	c1 ea 0c             	shr    $0xc,%edx
  801ab0:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
  801ab7:	f6 c1 01             	test   $0x1,%cl
  801aba:	74 3a                	je     801af6 <spawn+0x46f>

				// For each writable or copy-on-write page
				if ((uvpt[PGNUM(addr)] & PTE_SHARE) != 0) {
  801abc:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801ac3:	f6 c6 04             	test   $0x4,%dh
  801ac6:	74 2e                	je     801af6 <spawn+0x46f>
					r = sys_page_map(thisenv->env_id, (void *)addr, child, (void *)addr, uvpt[pn] & PTE_SYSCALL);
  801ac8:	8b 14 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%edx
  801acf:	8b 0d 08 40 80 00    	mov    0x804008,%ecx
  801ad5:	8b 49 48             	mov    0x48(%ecx),%ecx
  801ad8:	83 ec 0c             	sub    $0xc,%esp
  801adb:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801ae1:	52                   	push   %edx
  801ae2:	50                   	push   %eax
  801ae3:	56                   	push   %esi
  801ae4:	50                   	push   %eax
  801ae5:	51                   	push   %ecx
  801ae6:	e8 4d f1 ff ff       	call   800c38 <sys_page_map>
					if (r < 0)
  801aeb:	83 c4 20             	add    $0x20,%esp
  801aee:	85 c0                	test   %eax,%eax
  801af0:	0f 88 ae 00 00 00    	js     801ba4 <spawn+0x51d>
{
	// LAB 5: Your code here.

	int r;
	uint32_t addr;
	for (uint32_t pn = PGNUM(UTEXT); pn < PGNUM(USTACKTOP); pn++) {
  801af6:	83 c3 01             	add    $0x1,%ebx
  801af9:	81 fb fe eb 0e 00    	cmp    $0xeebfe,%ebx
  801aff:	75 94                	jne    801a95 <spawn+0x40e>
  801b01:	e9 b3 00 00 00       	jmp    801bb9 <spawn+0x532>
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	child_tf.tf_eflags |= FL_IOPL_3;   // devious: see user/faultio.c
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
		panic("sys_env_set_trapframe: %e", r);
  801b06:	50                   	push   %eax
  801b07:	68 b2 2e 80 00       	push   $0x802eb2
  801b0c:	68 86 00 00 00       	push   $0x86
  801b11:	68 89 2e 80 00       	push   $0x802e89
  801b16:	e8 79 e6 ff ff       	call   800194 <_panic>

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  801b1b:	83 ec 08             	sub    $0x8,%esp
  801b1e:	6a 02                	push   $0x2
  801b20:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801b26:	e8 91 f1 ff ff       	call   800cbc <sys_env_set_status>
  801b2b:	83 c4 10             	add    $0x10,%esp
  801b2e:	85 c0                	test   %eax,%eax
  801b30:	79 2b                	jns    801b5d <spawn+0x4d6>
		panic("sys_env_set_status: %e", r);
  801b32:	50                   	push   %eax
  801b33:	68 cc 2e 80 00       	push   $0x802ecc
  801b38:	68 89 00 00 00       	push   $0x89
  801b3d:	68 89 2e 80 00       	push   $0x802e89
  801b42:	e8 4d e6 ff ff       	call   800194 <_panic>
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
		return r;
  801b47:	8b 9d 8c fd ff ff    	mov    -0x274(%ebp),%ebx
  801b4d:	e9 a8 00 00 00       	jmp    801bfa <spawn+0x573>
		return -E_NOT_EXEC;
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
		return r;
  801b52:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  801b58:	e9 9d 00 00 00       	jmp    801bfa <spawn+0x573>
		panic("sys_env_set_trapframe: %e", r);

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
		panic("sys_env_set_status: %e", r);

	return child;
  801b5d:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  801b63:	e9 92 00 00 00       	jmp    801bfa <spawn+0x573>
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
		return -E_NO_MEM;
  801b68:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
  801b6d:	e9 88 00 00 00       	jmp    801bfa <spawn+0x573>

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
		return r;
  801b72:	89 c3                	mov    %eax,%ebx
  801b74:	e9 81 00 00 00       	jmp    801bfa <spawn+0x573>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801b79:	89 c3                	mov    %eax,%ebx
  801b7b:	eb 06                	jmp    801b83 <spawn+0x4fc>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801b7d:	89 c3                	mov    %eax,%ebx
  801b7f:	eb 02                	jmp    801b83 <spawn+0x4fc>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801b81:	89 c3                	mov    %eax,%ebx
		panic("sys_env_set_status: %e", r);

	return child;

error:
	sys_env_destroy(child);
  801b83:	83 ec 0c             	sub    $0xc,%esp
  801b86:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801b8c:	e8 e5 ef ff ff       	call   800b76 <sys_env_destroy>
	close(fd);
  801b91:	83 c4 04             	add    $0x4,%esp
  801b94:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801b9a:	e8 8a f4 ff ff       	call   801029 <close>
	return r;
  801b9f:	83 c4 10             	add    $0x10,%esp
  801ba2:	eb 56                	jmp    801bfa <spawn+0x573>
	close(fd);
	fd = -1;

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);
  801ba4:	50                   	push   %eax
  801ba5:	68 e3 2e 80 00       	push   $0x802ee3
  801baa:	68 82 00 00 00       	push   $0x82
  801baf:	68 89 2e 80 00       	push   $0x802e89
  801bb4:	e8 db e5 ff ff       	call   800194 <_panic>

	child_tf.tf_eflags |= FL_IOPL_3;   // devious: see user/faultio.c
  801bb9:	81 8d dc fd ff ff 00 	orl    $0x3000,-0x224(%ebp)
  801bc0:	30 00 00 
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  801bc3:	83 ec 08             	sub    $0x8,%esp
  801bc6:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  801bcc:	50                   	push   %eax
  801bcd:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801bd3:	e8 26 f1 ff ff       	call   800cfe <sys_env_set_trapframe>
  801bd8:	83 c4 10             	add    $0x10,%esp
  801bdb:	85 c0                	test   %eax,%eax
  801bdd:	0f 89 38 ff ff ff    	jns    801b1b <spawn+0x494>
  801be3:	e9 1e ff ff ff       	jmp    801b06 <spawn+0x47f>
		goto error;

	return 0;

error:
	sys_page_unmap(0, UTEMP);
  801be8:	83 ec 08             	sub    $0x8,%esp
  801beb:	68 00 00 40 00       	push   $0x400000
  801bf0:	6a 00                	push   $0x0
  801bf2:	e8 83 f0 ff ff       	call   800c7a <sys_page_unmap>
  801bf7:	83 c4 10             	add    $0x10,%esp

error:
	sys_env_destroy(child);
	close(fd);
	return r;
}
  801bfa:	89 d8                	mov    %ebx,%eax
  801bfc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bff:	5b                   	pop    %ebx
  801c00:	5e                   	pop    %esi
  801c01:	5f                   	pop    %edi
  801c02:	5d                   	pop    %ebp
  801c03:	c3                   	ret    

00801c04 <spawnl>:
// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
{
  801c04:	55                   	push   %ebp
  801c05:	89 e5                	mov    %esp,%ebp
  801c07:	56                   	push   %esi
  801c08:	53                   	push   %ebx
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801c09:	8d 55 10             	lea    0x10(%ebp),%edx
{
	// We calculate argc by advancing the args until we hit NULL.
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
  801c0c:	b8 00 00 00 00       	mov    $0x0,%eax
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801c11:	eb 03                	jmp    801c16 <spawnl+0x12>
		argc++;
  801c13:	83 c0 01             	add    $0x1,%eax
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801c16:	83 c2 04             	add    $0x4,%edx
  801c19:	83 7a fc 00          	cmpl   $0x0,-0x4(%edx)
  801c1d:	75 f4                	jne    801c13 <spawnl+0xf>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  801c1f:	8d 14 85 1a 00 00 00 	lea    0x1a(,%eax,4),%edx
  801c26:	83 e2 f0             	and    $0xfffffff0,%edx
  801c29:	29 d4                	sub    %edx,%esp
  801c2b:	8d 54 24 03          	lea    0x3(%esp),%edx
  801c2f:	c1 ea 02             	shr    $0x2,%edx
  801c32:	8d 34 95 00 00 00 00 	lea    0x0(,%edx,4),%esi
  801c39:	89 f3                	mov    %esi,%ebx
	argv[0] = arg0;
  801c3b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c3e:	89 0c 95 00 00 00 00 	mov    %ecx,0x0(,%edx,4)
	argv[argc+1] = NULL;
  801c45:	c7 44 86 04 00 00 00 	movl   $0x0,0x4(%esi,%eax,4)
  801c4c:	00 
  801c4d:	89 c2                	mov    %eax,%edx

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  801c4f:	b8 00 00 00 00       	mov    $0x0,%eax
  801c54:	eb 0a                	jmp    801c60 <spawnl+0x5c>
		argv[i+1] = va_arg(vl, const char *);
  801c56:	83 c0 01             	add    $0x1,%eax
  801c59:	8b 4c 85 0c          	mov    0xc(%ebp,%eax,4),%ecx
  801c5d:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  801c60:	39 d0                	cmp    %edx,%eax
  801c62:	75 f2                	jne    801c56 <spawnl+0x52>
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return spawn(prog, argv);
  801c64:	83 ec 08             	sub    $0x8,%esp
  801c67:	56                   	push   %esi
  801c68:	ff 75 08             	pushl  0x8(%ebp)
  801c6b:	e8 17 fa ff ff       	call   801687 <spawn>
}
  801c70:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c73:	5b                   	pop    %ebx
  801c74:	5e                   	pop    %esi
  801c75:	5d                   	pop    %ebp
  801c76:	c3                   	ret    

00801c77 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801c77:	55                   	push   %ebp
  801c78:	89 e5                	mov    %esp,%ebp
  801c7a:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  801c7d:	68 24 2f 80 00       	push   $0x802f24
  801c82:	ff 75 0c             	pushl  0xc(%ebp)
  801c85:	e8 68 eb ff ff       	call   8007f2 <strcpy>
	return 0;
}
  801c8a:	b8 00 00 00 00       	mov    $0x0,%eax
  801c8f:	c9                   	leave  
  801c90:	c3                   	ret    

00801c91 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801c91:	55                   	push   %ebp
  801c92:	89 e5                	mov    %esp,%ebp
  801c94:	53                   	push   %ebx
  801c95:	83 ec 10             	sub    $0x10,%esp
  801c98:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801c9b:	53                   	push   %ebx
  801c9c:	e8 10 0a 00 00       	call   8026b1 <pageref>
  801ca1:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  801ca4:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  801ca9:	83 f8 01             	cmp    $0x1,%eax
  801cac:	75 10                	jne    801cbe <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  801cae:	83 ec 0c             	sub    $0xc,%esp
  801cb1:	ff 73 0c             	pushl  0xc(%ebx)
  801cb4:	e8 c0 02 00 00       	call   801f79 <nsipc_close>
  801cb9:	89 c2                	mov    %eax,%edx
  801cbb:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  801cbe:	89 d0                	mov    %edx,%eax
  801cc0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801cc3:	c9                   	leave  
  801cc4:	c3                   	ret    

00801cc5 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801cc5:	55                   	push   %ebp
  801cc6:	89 e5                	mov    %esp,%ebp
  801cc8:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801ccb:	6a 00                	push   $0x0
  801ccd:	ff 75 10             	pushl  0x10(%ebp)
  801cd0:	ff 75 0c             	pushl  0xc(%ebp)
  801cd3:	8b 45 08             	mov    0x8(%ebp),%eax
  801cd6:	ff 70 0c             	pushl  0xc(%eax)
  801cd9:	e8 78 03 00 00       	call   802056 <nsipc_send>
}
  801cde:	c9                   	leave  
  801cdf:	c3                   	ret    

00801ce0 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801ce0:	55                   	push   %ebp
  801ce1:	89 e5                	mov    %esp,%ebp
  801ce3:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801ce6:	6a 00                	push   $0x0
  801ce8:	ff 75 10             	pushl  0x10(%ebp)
  801ceb:	ff 75 0c             	pushl  0xc(%ebp)
  801cee:	8b 45 08             	mov    0x8(%ebp),%eax
  801cf1:	ff 70 0c             	pushl  0xc(%eax)
  801cf4:	e8 f1 02 00 00       	call   801fea <nsipc_recv>
}
  801cf9:	c9                   	leave  
  801cfa:	c3                   	ret    

00801cfb <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801cfb:	55                   	push   %ebp
  801cfc:	89 e5                	mov    %esp,%ebp
  801cfe:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801d01:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801d04:	52                   	push   %edx
  801d05:	50                   	push   %eax
  801d06:	e8 f4 f1 ff ff       	call   800eff <fd_lookup>
  801d0b:	83 c4 10             	add    $0x10,%esp
  801d0e:	85 c0                	test   %eax,%eax
  801d10:	78 17                	js     801d29 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801d12:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d15:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  801d1b:	39 08                	cmp    %ecx,(%eax)
  801d1d:	75 05                	jne    801d24 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801d1f:	8b 40 0c             	mov    0xc(%eax),%eax
  801d22:	eb 05                	jmp    801d29 <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801d24:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801d29:	c9                   	leave  
  801d2a:	c3                   	ret    

00801d2b <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  801d2b:	55                   	push   %ebp
  801d2c:	89 e5                	mov    %esp,%ebp
  801d2e:	56                   	push   %esi
  801d2f:	53                   	push   %ebx
  801d30:	83 ec 1c             	sub    $0x1c,%esp
  801d33:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801d35:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d38:	50                   	push   %eax
  801d39:	e8 72 f1 ff ff       	call   800eb0 <fd_alloc>
  801d3e:	89 c3                	mov    %eax,%ebx
  801d40:	83 c4 10             	add    $0x10,%esp
  801d43:	85 c0                	test   %eax,%eax
  801d45:	78 1b                	js     801d62 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801d47:	83 ec 04             	sub    $0x4,%esp
  801d4a:	68 07 04 00 00       	push   $0x407
  801d4f:	ff 75 f4             	pushl  -0xc(%ebp)
  801d52:	6a 00                	push   $0x0
  801d54:	e8 9c ee ff ff       	call   800bf5 <sys_page_alloc>
  801d59:	89 c3                	mov    %eax,%ebx
  801d5b:	83 c4 10             	add    $0x10,%esp
  801d5e:	85 c0                	test   %eax,%eax
  801d60:	79 10                	jns    801d72 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  801d62:	83 ec 0c             	sub    $0xc,%esp
  801d65:	56                   	push   %esi
  801d66:	e8 0e 02 00 00       	call   801f79 <nsipc_close>
		return r;
  801d6b:	83 c4 10             	add    $0x10,%esp
  801d6e:	89 d8                	mov    %ebx,%eax
  801d70:	eb 24                	jmp    801d96 <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801d72:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801d78:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d7b:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801d7d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d80:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801d87:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801d8a:	83 ec 0c             	sub    $0xc,%esp
  801d8d:	50                   	push   %eax
  801d8e:	e8 f6 f0 ff ff       	call   800e89 <fd2num>
  801d93:	83 c4 10             	add    $0x10,%esp
}
  801d96:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d99:	5b                   	pop    %ebx
  801d9a:	5e                   	pop    %esi
  801d9b:	5d                   	pop    %ebp
  801d9c:	c3                   	ret    

00801d9d <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801d9d:	55                   	push   %ebp
  801d9e:	89 e5                	mov    %esp,%ebp
  801da0:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801da3:	8b 45 08             	mov    0x8(%ebp),%eax
  801da6:	e8 50 ff ff ff       	call   801cfb <fd2sockid>
		return r;
  801dab:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  801dad:	85 c0                	test   %eax,%eax
  801daf:	78 1f                	js     801dd0 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801db1:	83 ec 04             	sub    $0x4,%esp
  801db4:	ff 75 10             	pushl  0x10(%ebp)
  801db7:	ff 75 0c             	pushl  0xc(%ebp)
  801dba:	50                   	push   %eax
  801dbb:	e8 12 01 00 00       	call   801ed2 <nsipc_accept>
  801dc0:	83 c4 10             	add    $0x10,%esp
		return r;
  801dc3:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801dc5:	85 c0                	test   %eax,%eax
  801dc7:	78 07                	js     801dd0 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  801dc9:	e8 5d ff ff ff       	call   801d2b <alloc_sockfd>
  801dce:	89 c1                	mov    %eax,%ecx
}
  801dd0:	89 c8                	mov    %ecx,%eax
  801dd2:	c9                   	leave  
  801dd3:	c3                   	ret    

00801dd4 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801dd4:	55                   	push   %ebp
  801dd5:	89 e5                	mov    %esp,%ebp
  801dd7:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801dda:	8b 45 08             	mov    0x8(%ebp),%eax
  801ddd:	e8 19 ff ff ff       	call   801cfb <fd2sockid>
  801de2:	85 c0                	test   %eax,%eax
  801de4:	78 12                	js     801df8 <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  801de6:	83 ec 04             	sub    $0x4,%esp
  801de9:	ff 75 10             	pushl  0x10(%ebp)
  801dec:	ff 75 0c             	pushl  0xc(%ebp)
  801def:	50                   	push   %eax
  801df0:	e8 2d 01 00 00       	call   801f22 <nsipc_bind>
  801df5:	83 c4 10             	add    $0x10,%esp
}
  801df8:	c9                   	leave  
  801df9:	c3                   	ret    

00801dfa <shutdown>:

int
shutdown(int s, int how)
{
  801dfa:	55                   	push   %ebp
  801dfb:	89 e5                	mov    %esp,%ebp
  801dfd:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801e00:	8b 45 08             	mov    0x8(%ebp),%eax
  801e03:	e8 f3 fe ff ff       	call   801cfb <fd2sockid>
  801e08:	85 c0                	test   %eax,%eax
  801e0a:	78 0f                	js     801e1b <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801e0c:	83 ec 08             	sub    $0x8,%esp
  801e0f:	ff 75 0c             	pushl  0xc(%ebp)
  801e12:	50                   	push   %eax
  801e13:	e8 3f 01 00 00       	call   801f57 <nsipc_shutdown>
  801e18:	83 c4 10             	add    $0x10,%esp
}
  801e1b:	c9                   	leave  
  801e1c:	c3                   	ret    

00801e1d <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801e1d:	55                   	push   %ebp
  801e1e:	89 e5                	mov    %esp,%ebp
  801e20:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801e23:	8b 45 08             	mov    0x8(%ebp),%eax
  801e26:	e8 d0 fe ff ff       	call   801cfb <fd2sockid>
  801e2b:	85 c0                	test   %eax,%eax
  801e2d:	78 12                	js     801e41 <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  801e2f:	83 ec 04             	sub    $0x4,%esp
  801e32:	ff 75 10             	pushl  0x10(%ebp)
  801e35:	ff 75 0c             	pushl  0xc(%ebp)
  801e38:	50                   	push   %eax
  801e39:	e8 55 01 00 00       	call   801f93 <nsipc_connect>
  801e3e:	83 c4 10             	add    $0x10,%esp
}
  801e41:	c9                   	leave  
  801e42:	c3                   	ret    

00801e43 <listen>:

int
listen(int s, int backlog)
{
  801e43:	55                   	push   %ebp
  801e44:	89 e5                	mov    %esp,%ebp
  801e46:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801e49:	8b 45 08             	mov    0x8(%ebp),%eax
  801e4c:	e8 aa fe ff ff       	call   801cfb <fd2sockid>
  801e51:	85 c0                	test   %eax,%eax
  801e53:	78 0f                	js     801e64 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801e55:	83 ec 08             	sub    $0x8,%esp
  801e58:	ff 75 0c             	pushl  0xc(%ebp)
  801e5b:	50                   	push   %eax
  801e5c:	e8 67 01 00 00       	call   801fc8 <nsipc_listen>
  801e61:	83 c4 10             	add    $0x10,%esp
}
  801e64:	c9                   	leave  
  801e65:	c3                   	ret    

00801e66 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801e66:	55                   	push   %ebp
  801e67:	89 e5                	mov    %esp,%ebp
  801e69:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801e6c:	ff 75 10             	pushl  0x10(%ebp)
  801e6f:	ff 75 0c             	pushl  0xc(%ebp)
  801e72:	ff 75 08             	pushl  0x8(%ebp)
  801e75:	e8 3a 02 00 00       	call   8020b4 <nsipc_socket>
  801e7a:	83 c4 10             	add    $0x10,%esp
  801e7d:	85 c0                	test   %eax,%eax
  801e7f:	78 05                	js     801e86 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  801e81:	e8 a5 fe ff ff       	call   801d2b <alloc_sockfd>
}
  801e86:	c9                   	leave  
  801e87:	c3                   	ret    

00801e88 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801e88:	55                   	push   %ebp
  801e89:	89 e5                	mov    %esp,%ebp
  801e8b:	53                   	push   %ebx
  801e8c:	83 ec 04             	sub    $0x4,%esp
  801e8f:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801e91:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801e98:	75 12                	jne    801eac <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801e9a:	83 ec 0c             	sub    $0xc,%esp
  801e9d:	6a 02                	push   $0x2
  801e9f:	e8 d4 07 00 00       	call   802678 <ipc_find_env>
  801ea4:	a3 04 40 80 00       	mov    %eax,0x804004
  801ea9:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801eac:	6a 07                	push   $0x7
  801eae:	68 00 60 80 00       	push   $0x806000
  801eb3:	53                   	push   %ebx
  801eb4:	ff 35 04 40 80 00    	pushl  0x804004
  801eba:	e8 65 07 00 00       	call   802624 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801ebf:	83 c4 0c             	add    $0xc,%esp
  801ec2:	6a 00                	push   $0x0
  801ec4:	6a 00                	push   $0x0
  801ec6:	6a 00                	push   $0x0
  801ec8:	e8 f0 06 00 00       	call   8025bd <ipc_recv>
}
  801ecd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ed0:	c9                   	leave  
  801ed1:	c3                   	ret    

00801ed2 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801ed2:	55                   	push   %ebp
  801ed3:	89 e5                	mov    %esp,%ebp
  801ed5:	56                   	push   %esi
  801ed6:	53                   	push   %ebx
  801ed7:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801eda:	8b 45 08             	mov    0x8(%ebp),%eax
  801edd:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801ee2:	8b 06                	mov    (%esi),%eax
  801ee4:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801ee9:	b8 01 00 00 00       	mov    $0x1,%eax
  801eee:	e8 95 ff ff ff       	call   801e88 <nsipc>
  801ef3:	89 c3                	mov    %eax,%ebx
  801ef5:	85 c0                	test   %eax,%eax
  801ef7:	78 20                	js     801f19 <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801ef9:	83 ec 04             	sub    $0x4,%esp
  801efc:	ff 35 10 60 80 00    	pushl  0x806010
  801f02:	68 00 60 80 00       	push   $0x806000
  801f07:	ff 75 0c             	pushl  0xc(%ebp)
  801f0a:	e8 75 ea ff ff       	call   800984 <memmove>
		*addrlen = ret->ret_addrlen;
  801f0f:	a1 10 60 80 00       	mov    0x806010,%eax
  801f14:	89 06                	mov    %eax,(%esi)
  801f16:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  801f19:	89 d8                	mov    %ebx,%eax
  801f1b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f1e:	5b                   	pop    %ebx
  801f1f:	5e                   	pop    %esi
  801f20:	5d                   	pop    %ebp
  801f21:	c3                   	ret    

00801f22 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801f22:	55                   	push   %ebp
  801f23:	89 e5                	mov    %esp,%ebp
  801f25:	53                   	push   %ebx
  801f26:	83 ec 08             	sub    $0x8,%esp
  801f29:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801f2c:	8b 45 08             	mov    0x8(%ebp),%eax
  801f2f:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801f34:	53                   	push   %ebx
  801f35:	ff 75 0c             	pushl  0xc(%ebp)
  801f38:	68 04 60 80 00       	push   $0x806004
  801f3d:	e8 42 ea ff ff       	call   800984 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801f42:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801f48:	b8 02 00 00 00       	mov    $0x2,%eax
  801f4d:	e8 36 ff ff ff       	call   801e88 <nsipc>
}
  801f52:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801f55:	c9                   	leave  
  801f56:	c3                   	ret    

00801f57 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801f57:	55                   	push   %ebp
  801f58:	89 e5                	mov    %esp,%ebp
  801f5a:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801f5d:	8b 45 08             	mov    0x8(%ebp),%eax
  801f60:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801f65:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f68:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801f6d:	b8 03 00 00 00       	mov    $0x3,%eax
  801f72:	e8 11 ff ff ff       	call   801e88 <nsipc>
}
  801f77:	c9                   	leave  
  801f78:	c3                   	ret    

00801f79 <nsipc_close>:

int
nsipc_close(int s)
{
  801f79:	55                   	push   %ebp
  801f7a:	89 e5                	mov    %esp,%ebp
  801f7c:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801f7f:	8b 45 08             	mov    0x8(%ebp),%eax
  801f82:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801f87:	b8 04 00 00 00       	mov    $0x4,%eax
  801f8c:	e8 f7 fe ff ff       	call   801e88 <nsipc>
}
  801f91:	c9                   	leave  
  801f92:	c3                   	ret    

00801f93 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801f93:	55                   	push   %ebp
  801f94:	89 e5                	mov    %esp,%ebp
  801f96:	53                   	push   %ebx
  801f97:	83 ec 08             	sub    $0x8,%esp
  801f9a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801f9d:	8b 45 08             	mov    0x8(%ebp),%eax
  801fa0:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801fa5:	53                   	push   %ebx
  801fa6:	ff 75 0c             	pushl  0xc(%ebp)
  801fa9:	68 04 60 80 00       	push   $0x806004
  801fae:	e8 d1 e9 ff ff       	call   800984 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801fb3:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801fb9:	b8 05 00 00 00       	mov    $0x5,%eax
  801fbe:	e8 c5 fe ff ff       	call   801e88 <nsipc>
}
  801fc3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801fc6:	c9                   	leave  
  801fc7:	c3                   	ret    

00801fc8 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801fc8:	55                   	push   %ebp
  801fc9:	89 e5                	mov    %esp,%ebp
  801fcb:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801fce:	8b 45 08             	mov    0x8(%ebp),%eax
  801fd1:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801fd6:	8b 45 0c             	mov    0xc(%ebp),%eax
  801fd9:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801fde:	b8 06 00 00 00       	mov    $0x6,%eax
  801fe3:	e8 a0 fe ff ff       	call   801e88 <nsipc>
}
  801fe8:	c9                   	leave  
  801fe9:	c3                   	ret    

00801fea <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801fea:	55                   	push   %ebp
  801feb:	89 e5                	mov    %esp,%ebp
  801fed:	56                   	push   %esi
  801fee:	53                   	push   %ebx
  801fef:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801ff2:	8b 45 08             	mov    0x8(%ebp),%eax
  801ff5:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801ffa:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  802000:	8b 45 14             	mov    0x14(%ebp),%eax
  802003:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  802008:	b8 07 00 00 00       	mov    $0x7,%eax
  80200d:	e8 76 fe ff ff       	call   801e88 <nsipc>
  802012:	89 c3                	mov    %eax,%ebx
  802014:	85 c0                	test   %eax,%eax
  802016:	78 35                	js     80204d <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  802018:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  80201d:	7f 04                	jg     802023 <nsipc_recv+0x39>
  80201f:	39 c6                	cmp    %eax,%esi
  802021:	7d 16                	jge    802039 <nsipc_recv+0x4f>
  802023:	68 30 2f 80 00       	push   $0x802f30
  802028:	68 43 2e 80 00       	push   $0x802e43
  80202d:	6a 62                	push   $0x62
  80202f:	68 45 2f 80 00       	push   $0x802f45
  802034:	e8 5b e1 ff ff       	call   800194 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  802039:	83 ec 04             	sub    $0x4,%esp
  80203c:	50                   	push   %eax
  80203d:	68 00 60 80 00       	push   $0x806000
  802042:	ff 75 0c             	pushl  0xc(%ebp)
  802045:	e8 3a e9 ff ff       	call   800984 <memmove>
  80204a:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  80204d:	89 d8                	mov    %ebx,%eax
  80204f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802052:	5b                   	pop    %ebx
  802053:	5e                   	pop    %esi
  802054:	5d                   	pop    %ebp
  802055:	c3                   	ret    

00802056 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  802056:	55                   	push   %ebp
  802057:	89 e5                	mov    %esp,%ebp
  802059:	53                   	push   %ebx
  80205a:	83 ec 04             	sub    $0x4,%esp
  80205d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  802060:	8b 45 08             	mov    0x8(%ebp),%eax
  802063:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  802068:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  80206e:	7e 16                	jle    802086 <nsipc_send+0x30>
  802070:	68 51 2f 80 00       	push   $0x802f51
  802075:	68 43 2e 80 00       	push   $0x802e43
  80207a:	6a 6d                	push   $0x6d
  80207c:	68 45 2f 80 00       	push   $0x802f45
  802081:	e8 0e e1 ff ff       	call   800194 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  802086:	83 ec 04             	sub    $0x4,%esp
  802089:	53                   	push   %ebx
  80208a:	ff 75 0c             	pushl  0xc(%ebp)
  80208d:	68 0c 60 80 00       	push   $0x80600c
  802092:	e8 ed e8 ff ff       	call   800984 <memmove>
	nsipcbuf.send.req_size = size;
  802097:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  80209d:	8b 45 14             	mov    0x14(%ebp),%eax
  8020a0:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  8020a5:	b8 08 00 00 00       	mov    $0x8,%eax
  8020aa:	e8 d9 fd ff ff       	call   801e88 <nsipc>
}
  8020af:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8020b2:	c9                   	leave  
  8020b3:	c3                   	ret    

008020b4 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  8020b4:	55                   	push   %ebp
  8020b5:	89 e5                	mov    %esp,%ebp
  8020b7:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  8020ba:	8b 45 08             	mov    0x8(%ebp),%eax
  8020bd:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  8020c2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8020c5:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  8020ca:	8b 45 10             	mov    0x10(%ebp),%eax
  8020cd:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  8020d2:	b8 09 00 00 00       	mov    $0x9,%eax
  8020d7:	e8 ac fd ff ff       	call   801e88 <nsipc>
}
  8020dc:	c9                   	leave  
  8020dd:	c3                   	ret    

008020de <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8020de:	55                   	push   %ebp
  8020df:	89 e5                	mov    %esp,%ebp
  8020e1:	56                   	push   %esi
  8020e2:	53                   	push   %ebx
  8020e3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8020e6:	83 ec 0c             	sub    $0xc,%esp
  8020e9:	ff 75 08             	pushl  0x8(%ebp)
  8020ec:	e8 a8 ed ff ff       	call   800e99 <fd2data>
  8020f1:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8020f3:	83 c4 08             	add    $0x8,%esp
  8020f6:	68 5d 2f 80 00       	push   $0x802f5d
  8020fb:	53                   	push   %ebx
  8020fc:	e8 f1 e6 ff ff       	call   8007f2 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  802101:	8b 46 04             	mov    0x4(%esi),%eax
  802104:	2b 06                	sub    (%esi),%eax
  802106:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80210c:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  802113:	00 00 00 
	stat->st_dev = &devpipe;
  802116:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  80211d:	30 80 00 
	return 0;
}
  802120:	b8 00 00 00 00       	mov    $0x0,%eax
  802125:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802128:	5b                   	pop    %ebx
  802129:	5e                   	pop    %esi
  80212a:	5d                   	pop    %ebp
  80212b:	c3                   	ret    

0080212c <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80212c:	55                   	push   %ebp
  80212d:	89 e5                	mov    %esp,%ebp
  80212f:	53                   	push   %ebx
  802130:	83 ec 0c             	sub    $0xc,%esp
  802133:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  802136:	53                   	push   %ebx
  802137:	6a 00                	push   $0x0
  802139:	e8 3c eb ff ff       	call   800c7a <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  80213e:	89 1c 24             	mov    %ebx,(%esp)
  802141:	e8 53 ed ff ff       	call   800e99 <fd2data>
  802146:	83 c4 08             	add    $0x8,%esp
  802149:	50                   	push   %eax
  80214a:	6a 00                	push   $0x0
  80214c:	e8 29 eb ff ff       	call   800c7a <sys_page_unmap>
}
  802151:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802154:	c9                   	leave  
  802155:	c3                   	ret    

00802156 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  802156:	55                   	push   %ebp
  802157:	89 e5                	mov    %esp,%ebp
  802159:	57                   	push   %edi
  80215a:	56                   	push   %esi
  80215b:	53                   	push   %ebx
  80215c:	83 ec 1c             	sub    $0x1c,%esp
  80215f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  802162:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  802164:	a1 08 40 80 00       	mov    0x804008,%eax
  802169:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  80216c:	83 ec 0c             	sub    $0xc,%esp
  80216f:	ff 75 e0             	pushl  -0x20(%ebp)
  802172:	e8 3a 05 00 00       	call   8026b1 <pageref>
  802177:	89 c3                	mov    %eax,%ebx
  802179:	89 3c 24             	mov    %edi,(%esp)
  80217c:	e8 30 05 00 00       	call   8026b1 <pageref>
  802181:	83 c4 10             	add    $0x10,%esp
  802184:	39 c3                	cmp    %eax,%ebx
  802186:	0f 94 c1             	sete   %cl
  802189:	0f b6 c9             	movzbl %cl,%ecx
  80218c:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  80218f:	8b 15 08 40 80 00    	mov    0x804008,%edx
  802195:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  802198:	39 ce                	cmp    %ecx,%esi
  80219a:	74 1b                	je     8021b7 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  80219c:	39 c3                	cmp    %eax,%ebx
  80219e:	75 c4                	jne    802164 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8021a0:	8b 42 58             	mov    0x58(%edx),%eax
  8021a3:	ff 75 e4             	pushl  -0x1c(%ebp)
  8021a6:	50                   	push   %eax
  8021a7:	56                   	push   %esi
  8021a8:	68 64 2f 80 00       	push   $0x802f64
  8021ad:	e8 bb e0 ff ff       	call   80026d <cprintf>
  8021b2:	83 c4 10             	add    $0x10,%esp
  8021b5:	eb ad                	jmp    802164 <_pipeisclosed+0xe>
	}
}
  8021b7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8021ba:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8021bd:	5b                   	pop    %ebx
  8021be:	5e                   	pop    %esi
  8021bf:	5f                   	pop    %edi
  8021c0:	5d                   	pop    %ebp
  8021c1:	c3                   	ret    

008021c2 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8021c2:	55                   	push   %ebp
  8021c3:	89 e5                	mov    %esp,%ebp
  8021c5:	57                   	push   %edi
  8021c6:	56                   	push   %esi
  8021c7:	53                   	push   %ebx
  8021c8:	83 ec 28             	sub    $0x28,%esp
  8021cb:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8021ce:	56                   	push   %esi
  8021cf:	e8 c5 ec ff ff       	call   800e99 <fd2data>
  8021d4:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8021d6:	83 c4 10             	add    $0x10,%esp
  8021d9:	bf 00 00 00 00       	mov    $0x0,%edi
  8021de:	eb 4b                	jmp    80222b <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8021e0:	89 da                	mov    %ebx,%edx
  8021e2:	89 f0                	mov    %esi,%eax
  8021e4:	e8 6d ff ff ff       	call   802156 <_pipeisclosed>
  8021e9:	85 c0                	test   %eax,%eax
  8021eb:	75 48                	jne    802235 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8021ed:	e8 e4 e9 ff ff       	call   800bd6 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8021f2:	8b 43 04             	mov    0x4(%ebx),%eax
  8021f5:	8b 0b                	mov    (%ebx),%ecx
  8021f7:	8d 51 20             	lea    0x20(%ecx),%edx
  8021fa:	39 d0                	cmp    %edx,%eax
  8021fc:	73 e2                	jae    8021e0 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8021fe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802201:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  802205:	88 4d e7             	mov    %cl,-0x19(%ebp)
  802208:	89 c2                	mov    %eax,%edx
  80220a:	c1 fa 1f             	sar    $0x1f,%edx
  80220d:	89 d1                	mov    %edx,%ecx
  80220f:	c1 e9 1b             	shr    $0x1b,%ecx
  802212:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  802215:	83 e2 1f             	and    $0x1f,%edx
  802218:	29 ca                	sub    %ecx,%edx
  80221a:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  80221e:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  802222:	83 c0 01             	add    $0x1,%eax
  802225:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802228:	83 c7 01             	add    $0x1,%edi
  80222b:	3b 7d 10             	cmp    0x10(%ebp),%edi
  80222e:	75 c2                	jne    8021f2 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  802230:	8b 45 10             	mov    0x10(%ebp),%eax
  802233:	eb 05                	jmp    80223a <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802235:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  80223a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80223d:	5b                   	pop    %ebx
  80223e:	5e                   	pop    %esi
  80223f:	5f                   	pop    %edi
  802240:	5d                   	pop    %ebp
  802241:	c3                   	ret    

00802242 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  802242:	55                   	push   %ebp
  802243:	89 e5                	mov    %esp,%ebp
  802245:	57                   	push   %edi
  802246:	56                   	push   %esi
  802247:	53                   	push   %ebx
  802248:	83 ec 18             	sub    $0x18,%esp
  80224b:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  80224e:	57                   	push   %edi
  80224f:	e8 45 ec ff ff       	call   800e99 <fd2data>
  802254:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802256:	83 c4 10             	add    $0x10,%esp
  802259:	bb 00 00 00 00       	mov    $0x0,%ebx
  80225e:	eb 3d                	jmp    80229d <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  802260:	85 db                	test   %ebx,%ebx
  802262:	74 04                	je     802268 <devpipe_read+0x26>
				return i;
  802264:	89 d8                	mov    %ebx,%eax
  802266:	eb 44                	jmp    8022ac <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  802268:	89 f2                	mov    %esi,%edx
  80226a:	89 f8                	mov    %edi,%eax
  80226c:	e8 e5 fe ff ff       	call   802156 <_pipeisclosed>
  802271:	85 c0                	test   %eax,%eax
  802273:	75 32                	jne    8022a7 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  802275:	e8 5c e9 ff ff       	call   800bd6 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  80227a:	8b 06                	mov    (%esi),%eax
  80227c:	3b 46 04             	cmp    0x4(%esi),%eax
  80227f:	74 df                	je     802260 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  802281:	99                   	cltd   
  802282:	c1 ea 1b             	shr    $0x1b,%edx
  802285:	01 d0                	add    %edx,%eax
  802287:	83 e0 1f             	and    $0x1f,%eax
  80228a:	29 d0                	sub    %edx,%eax
  80228c:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  802291:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802294:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  802297:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80229a:	83 c3 01             	add    $0x1,%ebx
  80229d:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8022a0:	75 d8                	jne    80227a <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8022a2:	8b 45 10             	mov    0x10(%ebp),%eax
  8022a5:	eb 05                	jmp    8022ac <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8022a7:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8022ac:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8022af:	5b                   	pop    %ebx
  8022b0:	5e                   	pop    %esi
  8022b1:	5f                   	pop    %edi
  8022b2:	5d                   	pop    %ebp
  8022b3:	c3                   	ret    

008022b4 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8022b4:	55                   	push   %ebp
  8022b5:	89 e5                	mov    %esp,%ebp
  8022b7:	56                   	push   %esi
  8022b8:	53                   	push   %ebx
  8022b9:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8022bc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8022bf:	50                   	push   %eax
  8022c0:	e8 eb eb ff ff       	call   800eb0 <fd_alloc>
  8022c5:	83 c4 10             	add    $0x10,%esp
  8022c8:	89 c2                	mov    %eax,%edx
  8022ca:	85 c0                	test   %eax,%eax
  8022cc:	0f 88 2c 01 00 00    	js     8023fe <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8022d2:	83 ec 04             	sub    $0x4,%esp
  8022d5:	68 07 04 00 00       	push   $0x407
  8022da:	ff 75 f4             	pushl  -0xc(%ebp)
  8022dd:	6a 00                	push   $0x0
  8022df:	e8 11 e9 ff ff       	call   800bf5 <sys_page_alloc>
  8022e4:	83 c4 10             	add    $0x10,%esp
  8022e7:	89 c2                	mov    %eax,%edx
  8022e9:	85 c0                	test   %eax,%eax
  8022eb:	0f 88 0d 01 00 00    	js     8023fe <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8022f1:	83 ec 0c             	sub    $0xc,%esp
  8022f4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8022f7:	50                   	push   %eax
  8022f8:	e8 b3 eb ff ff       	call   800eb0 <fd_alloc>
  8022fd:	89 c3                	mov    %eax,%ebx
  8022ff:	83 c4 10             	add    $0x10,%esp
  802302:	85 c0                	test   %eax,%eax
  802304:	0f 88 e2 00 00 00    	js     8023ec <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80230a:	83 ec 04             	sub    $0x4,%esp
  80230d:	68 07 04 00 00       	push   $0x407
  802312:	ff 75 f0             	pushl  -0x10(%ebp)
  802315:	6a 00                	push   $0x0
  802317:	e8 d9 e8 ff ff       	call   800bf5 <sys_page_alloc>
  80231c:	89 c3                	mov    %eax,%ebx
  80231e:	83 c4 10             	add    $0x10,%esp
  802321:	85 c0                	test   %eax,%eax
  802323:	0f 88 c3 00 00 00    	js     8023ec <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  802329:	83 ec 0c             	sub    $0xc,%esp
  80232c:	ff 75 f4             	pushl  -0xc(%ebp)
  80232f:	e8 65 eb ff ff       	call   800e99 <fd2data>
  802334:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802336:	83 c4 0c             	add    $0xc,%esp
  802339:	68 07 04 00 00       	push   $0x407
  80233e:	50                   	push   %eax
  80233f:	6a 00                	push   $0x0
  802341:	e8 af e8 ff ff       	call   800bf5 <sys_page_alloc>
  802346:	89 c3                	mov    %eax,%ebx
  802348:	83 c4 10             	add    $0x10,%esp
  80234b:	85 c0                	test   %eax,%eax
  80234d:	0f 88 89 00 00 00    	js     8023dc <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802353:	83 ec 0c             	sub    $0xc,%esp
  802356:	ff 75 f0             	pushl  -0x10(%ebp)
  802359:	e8 3b eb ff ff       	call   800e99 <fd2data>
  80235e:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  802365:	50                   	push   %eax
  802366:	6a 00                	push   $0x0
  802368:	56                   	push   %esi
  802369:	6a 00                	push   $0x0
  80236b:	e8 c8 e8 ff ff       	call   800c38 <sys_page_map>
  802370:	89 c3                	mov    %eax,%ebx
  802372:	83 c4 20             	add    $0x20,%esp
  802375:	85 c0                	test   %eax,%eax
  802377:	78 55                	js     8023ce <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  802379:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80237f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802382:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  802384:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802387:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  80238e:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  802394:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802397:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  802399:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80239c:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8023a3:	83 ec 0c             	sub    $0xc,%esp
  8023a6:	ff 75 f4             	pushl  -0xc(%ebp)
  8023a9:	e8 db ea ff ff       	call   800e89 <fd2num>
  8023ae:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8023b1:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8023b3:	83 c4 04             	add    $0x4,%esp
  8023b6:	ff 75 f0             	pushl  -0x10(%ebp)
  8023b9:	e8 cb ea ff ff       	call   800e89 <fd2num>
  8023be:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8023c1:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8023c4:	83 c4 10             	add    $0x10,%esp
  8023c7:	ba 00 00 00 00       	mov    $0x0,%edx
  8023cc:	eb 30                	jmp    8023fe <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  8023ce:	83 ec 08             	sub    $0x8,%esp
  8023d1:	56                   	push   %esi
  8023d2:	6a 00                	push   $0x0
  8023d4:	e8 a1 e8 ff ff       	call   800c7a <sys_page_unmap>
  8023d9:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  8023dc:	83 ec 08             	sub    $0x8,%esp
  8023df:	ff 75 f0             	pushl  -0x10(%ebp)
  8023e2:	6a 00                	push   $0x0
  8023e4:	e8 91 e8 ff ff       	call   800c7a <sys_page_unmap>
  8023e9:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  8023ec:	83 ec 08             	sub    $0x8,%esp
  8023ef:	ff 75 f4             	pushl  -0xc(%ebp)
  8023f2:	6a 00                	push   $0x0
  8023f4:	e8 81 e8 ff ff       	call   800c7a <sys_page_unmap>
  8023f9:	83 c4 10             	add    $0x10,%esp
  8023fc:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  8023fe:	89 d0                	mov    %edx,%eax
  802400:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802403:	5b                   	pop    %ebx
  802404:	5e                   	pop    %esi
  802405:	5d                   	pop    %ebp
  802406:	c3                   	ret    

00802407 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  802407:	55                   	push   %ebp
  802408:	89 e5                	mov    %esp,%ebp
  80240a:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80240d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802410:	50                   	push   %eax
  802411:	ff 75 08             	pushl  0x8(%ebp)
  802414:	e8 e6 ea ff ff       	call   800eff <fd_lookup>
  802419:	83 c4 10             	add    $0x10,%esp
  80241c:	85 c0                	test   %eax,%eax
  80241e:	78 18                	js     802438 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  802420:	83 ec 0c             	sub    $0xc,%esp
  802423:	ff 75 f4             	pushl  -0xc(%ebp)
  802426:	e8 6e ea ff ff       	call   800e99 <fd2data>
	return _pipeisclosed(fd, p);
  80242b:	89 c2                	mov    %eax,%edx
  80242d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802430:	e8 21 fd ff ff       	call   802156 <_pipeisclosed>
  802435:	83 c4 10             	add    $0x10,%esp
}
  802438:	c9                   	leave  
  802439:	c3                   	ret    

0080243a <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  80243a:	55                   	push   %ebp
  80243b:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  80243d:	b8 00 00 00 00       	mov    $0x0,%eax
  802442:	5d                   	pop    %ebp
  802443:	c3                   	ret    

00802444 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  802444:	55                   	push   %ebp
  802445:	89 e5                	mov    %esp,%ebp
  802447:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  80244a:	68 7c 2f 80 00       	push   $0x802f7c
  80244f:	ff 75 0c             	pushl  0xc(%ebp)
  802452:	e8 9b e3 ff ff       	call   8007f2 <strcpy>
	return 0;
}
  802457:	b8 00 00 00 00       	mov    $0x0,%eax
  80245c:	c9                   	leave  
  80245d:	c3                   	ret    

0080245e <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80245e:	55                   	push   %ebp
  80245f:	89 e5                	mov    %esp,%ebp
  802461:	57                   	push   %edi
  802462:	56                   	push   %esi
  802463:	53                   	push   %ebx
  802464:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80246a:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80246f:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802475:	eb 2d                	jmp    8024a4 <devcons_write+0x46>
		m = n - tot;
  802477:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80247a:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  80247c:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  80247f:	ba 7f 00 00 00       	mov    $0x7f,%edx
  802484:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802487:	83 ec 04             	sub    $0x4,%esp
  80248a:	53                   	push   %ebx
  80248b:	03 45 0c             	add    0xc(%ebp),%eax
  80248e:	50                   	push   %eax
  80248f:	57                   	push   %edi
  802490:	e8 ef e4 ff ff       	call   800984 <memmove>
		sys_cputs(buf, m);
  802495:	83 c4 08             	add    $0x8,%esp
  802498:	53                   	push   %ebx
  802499:	57                   	push   %edi
  80249a:	e8 9a e6 ff ff       	call   800b39 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80249f:	01 de                	add    %ebx,%esi
  8024a1:	83 c4 10             	add    $0x10,%esp
  8024a4:	89 f0                	mov    %esi,%eax
  8024a6:	3b 75 10             	cmp    0x10(%ebp),%esi
  8024a9:	72 cc                	jb     802477 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8024ab:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8024ae:	5b                   	pop    %ebx
  8024af:	5e                   	pop    %esi
  8024b0:	5f                   	pop    %edi
  8024b1:	5d                   	pop    %ebp
  8024b2:	c3                   	ret    

008024b3 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8024b3:	55                   	push   %ebp
  8024b4:	89 e5                	mov    %esp,%ebp
  8024b6:	83 ec 08             	sub    $0x8,%esp
  8024b9:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  8024be:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8024c2:	74 2a                	je     8024ee <devcons_read+0x3b>
  8024c4:	eb 05                	jmp    8024cb <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8024c6:	e8 0b e7 ff ff       	call   800bd6 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8024cb:	e8 87 e6 ff ff       	call   800b57 <sys_cgetc>
  8024d0:	85 c0                	test   %eax,%eax
  8024d2:	74 f2                	je     8024c6 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8024d4:	85 c0                	test   %eax,%eax
  8024d6:	78 16                	js     8024ee <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8024d8:	83 f8 04             	cmp    $0x4,%eax
  8024db:	74 0c                	je     8024e9 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  8024dd:	8b 55 0c             	mov    0xc(%ebp),%edx
  8024e0:	88 02                	mov    %al,(%edx)
	return 1;
  8024e2:	b8 01 00 00 00       	mov    $0x1,%eax
  8024e7:	eb 05                	jmp    8024ee <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8024e9:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8024ee:	c9                   	leave  
  8024ef:	c3                   	ret    

008024f0 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8024f0:	55                   	push   %ebp
  8024f1:	89 e5                	mov    %esp,%ebp
  8024f3:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8024f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8024f9:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8024fc:	6a 01                	push   $0x1
  8024fe:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802501:	50                   	push   %eax
  802502:	e8 32 e6 ff ff       	call   800b39 <sys_cputs>
}
  802507:	83 c4 10             	add    $0x10,%esp
  80250a:	c9                   	leave  
  80250b:	c3                   	ret    

0080250c <getchar>:

int
getchar(void)
{
  80250c:	55                   	push   %ebp
  80250d:	89 e5                	mov    %esp,%ebp
  80250f:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  802512:	6a 01                	push   $0x1
  802514:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802517:	50                   	push   %eax
  802518:	6a 00                	push   $0x0
  80251a:	e8 46 ec ff ff       	call   801165 <read>
	if (r < 0)
  80251f:	83 c4 10             	add    $0x10,%esp
  802522:	85 c0                	test   %eax,%eax
  802524:	78 0f                	js     802535 <getchar+0x29>
		return r;
	if (r < 1)
  802526:	85 c0                	test   %eax,%eax
  802528:	7e 06                	jle    802530 <getchar+0x24>
		return -E_EOF;
	return c;
  80252a:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  80252e:	eb 05                	jmp    802535 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  802530:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  802535:	c9                   	leave  
  802536:	c3                   	ret    

00802537 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  802537:	55                   	push   %ebp
  802538:	89 e5                	mov    %esp,%ebp
  80253a:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80253d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802540:	50                   	push   %eax
  802541:	ff 75 08             	pushl  0x8(%ebp)
  802544:	e8 b6 e9 ff ff       	call   800eff <fd_lookup>
  802549:	83 c4 10             	add    $0x10,%esp
  80254c:	85 c0                	test   %eax,%eax
  80254e:	78 11                	js     802561 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  802550:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802553:	8b 15 58 30 80 00    	mov    0x803058,%edx
  802559:	39 10                	cmp    %edx,(%eax)
  80255b:	0f 94 c0             	sete   %al
  80255e:	0f b6 c0             	movzbl %al,%eax
}
  802561:	c9                   	leave  
  802562:	c3                   	ret    

00802563 <opencons>:

int
opencons(void)
{
  802563:	55                   	push   %ebp
  802564:	89 e5                	mov    %esp,%ebp
  802566:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802569:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80256c:	50                   	push   %eax
  80256d:	e8 3e e9 ff ff       	call   800eb0 <fd_alloc>
  802572:	83 c4 10             	add    $0x10,%esp
		return r;
  802575:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802577:	85 c0                	test   %eax,%eax
  802579:	78 3e                	js     8025b9 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80257b:	83 ec 04             	sub    $0x4,%esp
  80257e:	68 07 04 00 00       	push   $0x407
  802583:	ff 75 f4             	pushl  -0xc(%ebp)
  802586:	6a 00                	push   $0x0
  802588:	e8 68 e6 ff ff       	call   800bf5 <sys_page_alloc>
  80258d:	83 c4 10             	add    $0x10,%esp
		return r;
  802590:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802592:	85 c0                	test   %eax,%eax
  802594:	78 23                	js     8025b9 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  802596:	8b 15 58 30 80 00    	mov    0x803058,%edx
  80259c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80259f:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8025a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8025a4:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8025ab:	83 ec 0c             	sub    $0xc,%esp
  8025ae:	50                   	push   %eax
  8025af:	e8 d5 e8 ff ff       	call   800e89 <fd2num>
  8025b4:	89 c2                	mov    %eax,%edx
  8025b6:	83 c4 10             	add    $0x10,%esp
}
  8025b9:	89 d0                	mov    %edx,%eax
  8025bb:	c9                   	leave  
  8025bc:	c3                   	ret    

008025bd <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8025bd:	55                   	push   %ebp
  8025be:	89 e5                	mov    %esp,%ebp
  8025c0:	56                   	push   %esi
  8025c1:	53                   	push   %ebx
  8025c2:	8b 75 08             	mov    0x8(%ebp),%esi
  8025c5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8025c8:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");

	// don't want to recv page
	if (pg == NULL)
  8025cb:	85 c0                	test   %eax,%eax
		pg = (void *)UTOP;
  8025cd:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  8025d2:	0f 44 c2             	cmove  %edx,%eax

	int err = sys_ipc_recv(pg);
  8025d5:	83 ec 0c             	sub    $0xc,%esp
  8025d8:	50                   	push   %eax
  8025d9:	e8 c7 e7 ff ff       	call   800da5 <sys_ipc_recv>

	if (from_env_store != NULL)
  8025de:	83 c4 10             	add    $0x10,%esp
  8025e1:	85 f6                	test   %esi,%esi
  8025e3:	74 14                	je     8025f9 <ipc_recv+0x3c>
		*from_env_store = err < 0? 0 : thisenv->env_ipc_from;
  8025e5:	ba 00 00 00 00       	mov    $0x0,%edx
  8025ea:	85 c0                	test   %eax,%eax
  8025ec:	78 09                	js     8025f7 <ipc_recv+0x3a>
  8025ee:	8b 15 08 40 80 00    	mov    0x804008,%edx
  8025f4:	8b 52 74             	mov    0x74(%edx),%edx
  8025f7:	89 16                	mov    %edx,(%esi)
	
	if (perm_store != NULL)
  8025f9:	85 db                	test   %ebx,%ebx
  8025fb:	74 14                	je     802611 <ipc_recv+0x54>
		*perm_store = err < 0? 0 : thisenv->env_ipc_perm;
  8025fd:	ba 00 00 00 00       	mov    $0x0,%edx
  802602:	85 c0                	test   %eax,%eax
  802604:	78 09                	js     80260f <ipc_recv+0x52>
  802606:	8b 15 08 40 80 00    	mov    0x804008,%edx
  80260c:	8b 52 78             	mov    0x78(%edx),%edx
  80260f:	89 13                	mov    %edx,(%ebx)

	if (err < 0)
  802611:	85 c0                	test   %eax,%eax
  802613:	78 08                	js     80261d <ipc_recv+0x60>
		return err;
	return thisenv->env_ipc_value;
  802615:	a1 08 40 80 00       	mov    0x804008,%eax
  80261a:	8b 40 70             	mov    0x70(%eax),%eax
}
  80261d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802620:	5b                   	pop    %ebx
  802621:	5e                   	pop    %esi
  802622:	5d                   	pop    %ebp
  802623:	c3                   	ret    

00802624 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802624:	55                   	push   %ebp
  802625:	89 e5                	mov    %esp,%ebp
  802627:	57                   	push   %edi
  802628:	56                   	push   %esi
  802629:	53                   	push   %ebx
  80262a:	83 ec 0c             	sub    $0xc,%esp
  80262d:	8b 7d 08             	mov    0x8(%ebp),%edi
  802630:	8b 75 0c             	mov    0xc(%ebp),%esi
  802633:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");

	// don't want to send page
	if (pg == NULL)
  802636:	85 db                	test   %ebx,%ebx
		pg = (void *)UTOP;
  802638:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  80263d:	0f 44 d8             	cmove  %eax,%ebx
	
	int err = 0;
	
	do {

		err = sys_ipc_try_send(to_env, val, pg, perm);
  802640:	ff 75 14             	pushl  0x14(%ebp)
  802643:	53                   	push   %ebx
  802644:	56                   	push   %esi
  802645:	57                   	push   %edi
  802646:	e8 37 e7 ff ff       	call   800d82 <sys_ipc_try_send>

		if (err < 0) {
  80264b:	83 c4 10             	add    $0x10,%esp
  80264e:	85 c0                	test   %eax,%eax
  802650:	79 1e                	jns    802670 <ipc_send+0x4c>
			if (err == -E_IPC_NOT_RECV)
  802652:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802655:	75 07                	jne    80265e <ipc_send+0x3a>
				sys_yield();
  802657:	e8 7a e5 ff ff       	call   800bd6 <sys_yield>
  80265c:	eb e2                	jmp    802640 <ipc_send+0x1c>
			else 
				panic("ipc_send: %e", err);
  80265e:	50                   	push   %eax
  80265f:	68 88 2f 80 00       	push   $0x802f88
  802664:	6a 49                	push   $0x49
  802666:	68 95 2f 80 00       	push   $0x802f95
  80266b:	e8 24 db ff ff       	call   800194 <_panic>
		}

	} while (err < 0);

}
  802670:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802673:	5b                   	pop    %ebx
  802674:	5e                   	pop    %esi
  802675:	5f                   	pop    %edi
  802676:	5d                   	pop    %ebp
  802677:	c3                   	ret    

00802678 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802678:	55                   	push   %ebp
  802679:	89 e5                	mov    %esp,%ebp
  80267b:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80267e:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802683:	6b d0 7c             	imul   $0x7c,%eax,%edx
  802686:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80268c:	8b 52 50             	mov    0x50(%edx),%edx
  80268f:	39 ca                	cmp    %ecx,%edx
  802691:	75 0d                	jne    8026a0 <ipc_find_env+0x28>
			return envs[i].env_id;
  802693:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802696:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80269b:	8b 40 48             	mov    0x48(%eax),%eax
  80269e:	eb 0f                	jmp    8026af <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8026a0:	83 c0 01             	add    $0x1,%eax
  8026a3:	3d 00 04 00 00       	cmp    $0x400,%eax
  8026a8:	75 d9                	jne    802683 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8026aa:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8026af:	5d                   	pop    %ebp
  8026b0:	c3                   	ret    

008026b1 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8026b1:	55                   	push   %ebp
  8026b2:	89 e5                	mov    %esp,%ebp
  8026b4:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8026b7:	89 d0                	mov    %edx,%eax
  8026b9:	c1 e8 16             	shr    $0x16,%eax
  8026bc:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8026c3:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8026c8:	f6 c1 01             	test   $0x1,%cl
  8026cb:	74 1d                	je     8026ea <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  8026cd:	c1 ea 0c             	shr    $0xc,%edx
  8026d0:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  8026d7:	f6 c2 01             	test   $0x1,%dl
  8026da:	74 0e                	je     8026ea <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8026dc:	c1 ea 0c             	shr    $0xc,%edx
  8026df:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8026e6:	ef 
  8026e7:	0f b7 c0             	movzwl %ax,%eax
}
  8026ea:	5d                   	pop    %ebp
  8026eb:	c3                   	ret    
  8026ec:	66 90                	xchg   %ax,%ax
  8026ee:	66 90                	xchg   %ax,%ax

008026f0 <__udivdi3>:
  8026f0:	55                   	push   %ebp
  8026f1:	57                   	push   %edi
  8026f2:	56                   	push   %esi
  8026f3:	53                   	push   %ebx
  8026f4:	83 ec 1c             	sub    $0x1c,%esp
  8026f7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  8026fb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  8026ff:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802703:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802707:	85 f6                	test   %esi,%esi
  802709:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80270d:	89 ca                	mov    %ecx,%edx
  80270f:	89 f8                	mov    %edi,%eax
  802711:	75 3d                	jne    802750 <__udivdi3+0x60>
  802713:	39 cf                	cmp    %ecx,%edi
  802715:	0f 87 c5 00 00 00    	ja     8027e0 <__udivdi3+0xf0>
  80271b:	85 ff                	test   %edi,%edi
  80271d:	89 fd                	mov    %edi,%ebp
  80271f:	75 0b                	jne    80272c <__udivdi3+0x3c>
  802721:	b8 01 00 00 00       	mov    $0x1,%eax
  802726:	31 d2                	xor    %edx,%edx
  802728:	f7 f7                	div    %edi
  80272a:	89 c5                	mov    %eax,%ebp
  80272c:	89 c8                	mov    %ecx,%eax
  80272e:	31 d2                	xor    %edx,%edx
  802730:	f7 f5                	div    %ebp
  802732:	89 c1                	mov    %eax,%ecx
  802734:	89 d8                	mov    %ebx,%eax
  802736:	89 cf                	mov    %ecx,%edi
  802738:	f7 f5                	div    %ebp
  80273a:	89 c3                	mov    %eax,%ebx
  80273c:	89 d8                	mov    %ebx,%eax
  80273e:	89 fa                	mov    %edi,%edx
  802740:	83 c4 1c             	add    $0x1c,%esp
  802743:	5b                   	pop    %ebx
  802744:	5e                   	pop    %esi
  802745:	5f                   	pop    %edi
  802746:	5d                   	pop    %ebp
  802747:	c3                   	ret    
  802748:	90                   	nop
  802749:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802750:	39 ce                	cmp    %ecx,%esi
  802752:	77 74                	ja     8027c8 <__udivdi3+0xd8>
  802754:	0f bd fe             	bsr    %esi,%edi
  802757:	83 f7 1f             	xor    $0x1f,%edi
  80275a:	0f 84 98 00 00 00    	je     8027f8 <__udivdi3+0x108>
  802760:	bb 20 00 00 00       	mov    $0x20,%ebx
  802765:	89 f9                	mov    %edi,%ecx
  802767:	89 c5                	mov    %eax,%ebp
  802769:	29 fb                	sub    %edi,%ebx
  80276b:	d3 e6                	shl    %cl,%esi
  80276d:	89 d9                	mov    %ebx,%ecx
  80276f:	d3 ed                	shr    %cl,%ebp
  802771:	89 f9                	mov    %edi,%ecx
  802773:	d3 e0                	shl    %cl,%eax
  802775:	09 ee                	or     %ebp,%esi
  802777:	89 d9                	mov    %ebx,%ecx
  802779:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80277d:	89 d5                	mov    %edx,%ebp
  80277f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802783:	d3 ed                	shr    %cl,%ebp
  802785:	89 f9                	mov    %edi,%ecx
  802787:	d3 e2                	shl    %cl,%edx
  802789:	89 d9                	mov    %ebx,%ecx
  80278b:	d3 e8                	shr    %cl,%eax
  80278d:	09 c2                	or     %eax,%edx
  80278f:	89 d0                	mov    %edx,%eax
  802791:	89 ea                	mov    %ebp,%edx
  802793:	f7 f6                	div    %esi
  802795:	89 d5                	mov    %edx,%ebp
  802797:	89 c3                	mov    %eax,%ebx
  802799:	f7 64 24 0c          	mull   0xc(%esp)
  80279d:	39 d5                	cmp    %edx,%ebp
  80279f:	72 10                	jb     8027b1 <__udivdi3+0xc1>
  8027a1:	8b 74 24 08          	mov    0x8(%esp),%esi
  8027a5:	89 f9                	mov    %edi,%ecx
  8027a7:	d3 e6                	shl    %cl,%esi
  8027a9:	39 c6                	cmp    %eax,%esi
  8027ab:	73 07                	jae    8027b4 <__udivdi3+0xc4>
  8027ad:	39 d5                	cmp    %edx,%ebp
  8027af:	75 03                	jne    8027b4 <__udivdi3+0xc4>
  8027b1:	83 eb 01             	sub    $0x1,%ebx
  8027b4:	31 ff                	xor    %edi,%edi
  8027b6:	89 d8                	mov    %ebx,%eax
  8027b8:	89 fa                	mov    %edi,%edx
  8027ba:	83 c4 1c             	add    $0x1c,%esp
  8027bd:	5b                   	pop    %ebx
  8027be:	5e                   	pop    %esi
  8027bf:	5f                   	pop    %edi
  8027c0:	5d                   	pop    %ebp
  8027c1:	c3                   	ret    
  8027c2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8027c8:	31 ff                	xor    %edi,%edi
  8027ca:	31 db                	xor    %ebx,%ebx
  8027cc:	89 d8                	mov    %ebx,%eax
  8027ce:	89 fa                	mov    %edi,%edx
  8027d0:	83 c4 1c             	add    $0x1c,%esp
  8027d3:	5b                   	pop    %ebx
  8027d4:	5e                   	pop    %esi
  8027d5:	5f                   	pop    %edi
  8027d6:	5d                   	pop    %ebp
  8027d7:	c3                   	ret    
  8027d8:	90                   	nop
  8027d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8027e0:	89 d8                	mov    %ebx,%eax
  8027e2:	f7 f7                	div    %edi
  8027e4:	31 ff                	xor    %edi,%edi
  8027e6:	89 c3                	mov    %eax,%ebx
  8027e8:	89 d8                	mov    %ebx,%eax
  8027ea:	89 fa                	mov    %edi,%edx
  8027ec:	83 c4 1c             	add    $0x1c,%esp
  8027ef:	5b                   	pop    %ebx
  8027f0:	5e                   	pop    %esi
  8027f1:	5f                   	pop    %edi
  8027f2:	5d                   	pop    %ebp
  8027f3:	c3                   	ret    
  8027f4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8027f8:	39 ce                	cmp    %ecx,%esi
  8027fa:	72 0c                	jb     802808 <__udivdi3+0x118>
  8027fc:	31 db                	xor    %ebx,%ebx
  8027fe:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802802:	0f 87 34 ff ff ff    	ja     80273c <__udivdi3+0x4c>
  802808:	bb 01 00 00 00       	mov    $0x1,%ebx
  80280d:	e9 2a ff ff ff       	jmp    80273c <__udivdi3+0x4c>
  802812:	66 90                	xchg   %ax,%ax
  802814:	66 90                	xchg   %ax,%ax
  802816:	66 90                	xchg   %ax,%ax
  802818:	66 90                	xchg   %ax,%ax
  80281a:	66 90                	xchg   %ax,%ax
  80281c:	66 90                	xchg   %ax,%ax
  80281e:	66 90                	xchg   %ax,%ax

00802820 <__umoddi3>:
  802820:	55                   	push   %ebp
  802821:	57                   	push   %edi
  802822:	56                   	push   %esi
  802823:	53                   	push   %ebx
  802824:	83 ec 1c             	sub    $0x1c,%esp
  802827:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80282b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80282f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802833:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802837:	85 d2                	test   %edx,%edx
  802839:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80283d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802841:	89 f3                	mov    %esi,%ebx
  802843:	89 3c 24             	mov    %edi,(%esp)
  802846:	89 74 24 04          	mov    %esi,0x4(%esp)
  80284a:	75 1c                	jne    802868 <__umoddi3+0x48>
  80284c:	39 f7                	cmp    %esi,%edi
  80284e:	76 50                	jbe    8028a0 <__umoddi3+0x80>
  802850:	89 c8                	mov    %ecx,%eax
  802852:	89 f2                	mov    %esi,%edx
  802854:	f7 f7                	div    %edi
  802856:	89 d0                	mov    %edx,%eax
  802858:	31 d2                	xor    %edx,%edx
  80285a:	83 c4 1c             	add    $0x1c,%esp
  80285d:	5b                   	pop    %ebx
  80285e:	5e                   	pop    %esi
  80285f:	5f                   	pop    %edi
  802860:	5d                   	pop    %ebp
  802861:	c3                   	ret    
  802862:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802868:	39 f2                	cmp    %esi,%edx
  80286a:	89 d0                	mov    %edx,%eax
  80286c:	77 52                	ja     8028c0 <__umoddi3+0xa0>
  80286e:	0f bd ea             	bsr    %edx,%ebp
  802871:	83 f5 1f             	xor    $0x1f,%ebp
  802874:	75 5a                	jne    8028d0 <__umoddi3+0xb0>
  802876:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80287a:	0f 82 e0 00 00 00    	jb     802960 <__umoddi3+0x140>
  802880:	39 0c 24             	cmp    %ecx,(%esp)
  802883:	0f 86 d7 00 00 00    	jbe    802960 <__umoddi3+0x140>
  802889:	8b 44 24 08          	mov    0x8(%esp),%eax
  80288d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802891:	83 c4 1c             	add    $0x1c,%esp
  802894:	5b                   	pop    %ebx
  802895:	5e                   	pop    %esi
  802896:	5f                   	pop    %edi
  802897:	5d                   	pop    %ebp
  802898:	c3                   	ret    
  802899:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8028a0:	85 ff                	test   %edi,%edi
  8028a2:	89 fd                	mov    %edi,%ebp
  8028a4:	75 0b                	jne    8028b1 <__umoddi3+0x91>
  8028a6:	b8 01 00 00 00       	mov    $0x1,%eax
  8028ab:	31 d2                	xor    %edx,%edx
  8028ad:	f7 f7                	div    %edi
  8028af:	89 c5                	mov    %eax,%ebp
  8028b1:	89 f0                	mov    %esi,%eax
  8028b3:	31 d2                	xor    %edx,%edx
  8028b5:	f7 f5                	div    %ebp
  8028b7:	89 c8                	mov    %ecx,%eax
  8028b9:	f7 f5                	div    %ebp
  8028bb:	89 d0                	mov    %edx,%eax
  8028bd:	eb 99                	jmp    802858 <__umoddi3+0x38>
  8028bf:	90                   	nop
  8028c0:	89 c8                	mov    %ecx,%eax
  8028c2:	89 f2                	mov    %esi,%edx
  8028c4:	83 c4 1c             	add    $0x1c,%esp
  8028c7:	5b                   	pop    %ebx
  8028c8:	5e                   	pop    %esi
  8028c9:	5f                   	pop    %edi
  8028ca:	5d                   	pop    %ebp
  8028cb:	c3                   	ret    
  8028cc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8028d0:	8b 34 24             	mov    (%esp),%esi
  8028d3:	bf 20 00 00 00       	mov    $0x20,%edi
  8028d8:	89 e9                	mov    %ebp,%ecx
  8028da:	29 ef                	sub    %ebp,%edi
  8028dc:	d3 e0                	shl    %cl,%eax
  8028de:	89 f9                	mov    %edi,%ecx
  8028e0:	89 f2                	mov    %esi,%edx
  8028e2:	d3 ea                	shr    %cl,%edx
  8028e4:	89 e9                	mov    %ebp,%ecx
  8028e6:	09 c2                	or     %eax,%edx
  8028e8:	89 d8                	mov    %ebx,%eax
  8028ea:	89 14 24             	mov    %edx,(%esp)
  8028ed:	89 f2                	mov    %esi,%edx
  8028ef:	d3 e2                	shl    %cl,%edx
  8028f1:	89 f9                	mov    %edi,%ecx
  8028f3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8028f7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8028fb:	d3 e8                	shr    %cl,%eax
  8028fd:	89 e9                	mov    %ebp,%ecx
  8028ff:	89 c6                	mov    %eax,%esi
  802901:	d3 e3                	shl    %cl,%ebx
  802903:	89 f9                	mov    %edi,%ecx
  802905:	89 d0                	mov    %edx,%eax
  802907:	d3 e8                	shr    %cl,%eax
  802909:	89 e9                	mov    %ebp,%ecx
  80290b:	09 d8                	or     %ebx,%eax
  80290d:	89 d3                	mov    %edx,%ebx
  80290f:	89 f2                	mov    %esi,%edx
  802911:	f7 34 24             	divl   (%esp)
  802914:	89 d6                	mov    %edx,%esi
  802916:	d3 e3                	shl    %cl,%ebx
  802918:	f7 64 24 04          	mull   0x4(%esp)
  80291c:	39 d6                	cmp    %edx,%esi
  80291e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802922:	89 d1                	mov    %edx,%ecx
  802924:	89 c3                	mov    %eax,%ebx
  802926:	72 08                	jb     802930 <__umoddi3+0x110>
  802928:	75 11                	jne    80293b <__umoddi3+0x11b>
  80292a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80292e:	73 0b                	jae    80293b <__umoddi3+0x11b>
  802930:	2b 44 24 04          	sub    0x4(%esp),%eax
  802934:	1b 14 24             	sbb    (%esp),%edx
  802937:	89 d1                	mov    %edx,%ecx
  802939:	89 c3                	mov    %eax,%ebx
  80293b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80293f:	29 da                	sub    %ebx,%edx
  802941:	19 ce                	sbb    %ecx,%esi
  802943:	89 f9                	mov    %edi,%ecx
  802945:	89 f0                	mov    %esi,%eax
  802947:	d3 e0                	shl    %cl,%eax
  802949:	89 e9                	mov    %ebp,%ecx
  80294b:	d3 ea                	shr    %cl,%edx
  80294d:	89 e9                	mov    %ebp,%ecx
  80294f:	d3 ee                	shr    %cl,%esi
  802951:	09 d0                	or     %edx,%eax
  802953:	89 f2                	mov    %esi,%edx
  802955:	83 c4 1c             	add    $0x1c,%esp
  802958:	5b                   	pop    %ebx
  802959:	5e                   	pop    %esi
  80295a:	5f                   	pop    %edi
  80295b:	5d                   	pop    %ebp
  80295c:	c3                   	ret    
  80295d:	8d 76 00             	lea    0x0(%esi),%esi
  802960:	29 f9                	sub    %edi,%ecx
  802962:	19 d6                	sbb    %edx,%esi
  802964:	89 74 24 04          	mov    %esi,0x4(%esp)
  802968:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80296c:	e9 18 ff ff ff       	jmp    802889 <__umoddi3+0x69>
