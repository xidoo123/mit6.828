
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
  80003e:	c7 05 00 30 80 00 c0 	movl   $0x8023c0,0x803000
  800045:	23 80 00 

	cprintf("icode startup\n");
  800048:	68 c6 23 80 00       	push   $0x8023c6
  80004d:	e8 1b 02 00 00       	call   80026d <cprintf>

	cprintf("icode: open /motd\n");
  800052:	c7 04 24 d5 23 80 00 	movl   $0x8023d5,(%esp)
  800059:	e8 0f 02 00 00       	call   80026d <cprintf>
	if ((fd = open("/motd", O_RDONLY)) < 0)
  80005e:	83 c4 08             	add    $0x8,%esp
  800061:	6a 00                	push   $0x0
  800063:	68 e8 23 80 00       	push   $0x8023e8
  800068:	e8 b4 14 00 00       	call   801521 <open>
  80006d:	89 c6                	mov    %eax,%esi
  80006f:	83 c4 10             	add    $0x10,%esp
  800072:	85 c0                	test   %eax,%eax
  800074:	79 12                	jns    800088 <umain+0x55>
		panic("icode: open /motd: %e", fd);
  800076:	50                   	push   %eax
  800077:	68 ee 23 80 00       	push   $0x8023ee
  80007c:	6a 0f                	push   $0xf
  80007e:	68 04 24 80 00       	push   $0x802404
  800083:	e8 0c 01 00 00       	call   800194 <_panic>

	cprintf("icode: read /motd\n");
  800088:	83 ec 0c             	sub    $0xc,%esp
  80008b:	68 11 24 80 00       	push   $0x802411
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
  8000b7:	e8 06 10 00 00       	call   8010c2 <read>
  8000bc:	83 c4 10             	add    $0x10,%esp
  8000bf:	85 c0                	test   %eax,%eax
  8000c1:	7f dd                	jg     8000a0 <umain+0x6d>
		sys_cputs(buf, n);

	cprintf("icode: close /motd\n");
  8000c3:	83 ec 0c             	sub    $0xc,%esp
  8000c6:	68 24 24 80 00       	push   $0x802424
  8000cb:	e8 9d 01 00 00       	call   80026d <cprintf>
	close(fd);
  8000d0:	89 34 24             	mov    %esi,(%esp)
  8000d3:	e8 ae 0e 00 00       	call   800f86 <close>

	cprintf("icode: spawn /init\n");
  8000d8:	c7 04 24 38 24 80 00 	movl   $0x802438,(%esp)
  8000df:	e8 89 01 00 00       	call   80026d <cprintf>
	if ((r = spawnl("/init", "init", "initarg1", "initarg2", (char*)0)) < 0)
  8000e4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000eb:	68 4c 24 80 00       	push   $0x80244c
  8000f0:	68 55 24 80 00       	push   $0x802455
  8000f5:	68 5f 24 80 00       	push   $0x80245f
  8000fa:	68 5e 24 80 00       	push   $0x80245e
  8000ff:	e8 8e 19 00 00       	call   801a92 <spawnl>
  800104:	83 c4 20             	add    $0x20,%esp
  800107:	85 c0                	test   %eax,%eax
  800109:	79 12                	jns    80011d <umain+0xea>
		panic("icode: spawn /init: %e", r);
  80010b:	50                   	push   %eax
  80010c:	68 64 24 80 00       	push   $0x802464
  800111:	6a 1a                	push   $0x1a
  800113:	68 04 24 80 00       	push   $0x802404
  800118:	e8 77 00 00 00       	call   800194 <_panic>

	cprintf("icode: exiting\n");
  80011d:	83 ec 0c             	sub    $0xc,%esp
  800120:	68 7b 24 80 00       	push   $0x80247b
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
  800151:	a3 04 40 80 00       	mov    %eax,0x804004

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
  800180:	e8 2c 0e 00 00       	call   800fb1 <close_all>
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
  8001b2:	68 98 24 80 00       	push   $0x802498
  8001b7:	e8 b1 00 00 00       	call   80026d <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001bc:	83 c4 18             	add    $0x18,%esp
  8001bf:	53                   	push   %ebx
  8001c0:	ff 75 10             	pushl  0x10(%ebp)
  8001c3:	e8 54 00 00 00       	call   80021c <vcprintf>
	cprintf("\n");
  8001c8:	c7 04 24 80 29 80 00 	movl   $0x802980,(%esp)
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
  8002d0:	e8 4b 1e 00 00       	call   802120 <__udivdi3>
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
  800313:	e8 38 1f 00 00       	call   802250 <__umoddi3>
  800318:	83 c4 14             	add    $0x14,%esp
  80031b:	0f be 80 bb 24 80 00 	movsbl 0x8024bb(%eax),%eax
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
  800417:	ff 24 85 00 26 80 00 	jmp    *0x802600(,%eax,4)
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
  8004db:	8b 14 85 60 27 80 00 	mov    0x802760(,%eax,4),%edx
  8004e2:	85 d2                	test   %edx,%edx
  8004e4:	75 18                	jne    8004fe <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8004e6:	50                   	push   %eax
  8004e7:	68 d3 24 80 00       	push   $0x8024d3
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
  8004ff:	68 ba 28 80 00       	push   $0x8028ba
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
  800523:	b8 cc 24 80 00       	mov    $0x8024cc,%eax
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
  800b9e:	68 bf 27 80 00       	push   $0x8027bf
  800ba3:	6a 23                	push   $0x23
  800ba5:	68 dc 27 80 00       	push   $0x8027dc
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
  800c1f:	68 bf 27 80 00       	push   $0x8027bf
  800c24:	6a 23                	push   $0x23
  800c26:	68 dc 27 80 00       	push   $0x8027dc
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
  800c61:	68 bf 27 80 00       	push   $0x8027bf
  800c66:	6a 23                	push   $0x23
  800c68:	68 dc 27 80 00       	push   $0x8027dc
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
  800ca3:	68 bf 27 80 00       	push   $0x8027bf
  800ca8:	6a 23                	push   $0x23
  800caa:	68 dc 27 80 00       	push   $0x8027dc
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
  800ce5:	68 bf 27 80 00       	push   $0x8027bf
  800cea:	6a 23                	push   $0x23
  800cec:	68 dc 27 80 00       	push   $0x8027dc
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
  800d27:	68 bf 27 80 00       	push   $0x8027bf
  800d2c:	6a 23                	push   $0x23
  800d2e:	68 dc 27 80 00       	push   $0x8027dc
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
  800d69:	68 bf 27 80 00       	push   $0x8027bf
  800d6e:	6a 23                	push   $0x23
  800d70:	68 dc 27 80 00       	push   $0x8027dc
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
  800dcd:	68 bf 27 80 00       	push   $0x8027bf
  800dd2:	6a 23                	push   $0x23
  800dd4:	68 dc 27 80 00       	push   $0x8027dc
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

00800de6 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800de6:	55                   	push   %ebp
  800de7:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800de9:	8b 45 08             	mov    0x8(%ebp),%eax
  800dec:	05 00 00 00 30       	add    $0x30000000,%eax
  800df1:	c1 e8 0c             	shr    $0xc,%eax
}
  800df4:	5d                   	pop    %ebp
  800df5:	c3                   	ret    

00800df6 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800df6:	55                   	push   %ebp
  800df7:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800df9:	8b 45 08             	mov    0x8(%ebp),%eax
  800dfc:	05 00 00 00 30       	add    $0x30000000,%eax
  800e01:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800e06:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800e0b:	5d                   	pop    %ebp
  800e0c:	c3                   	ret    

00800e0d <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800e0d:	55                   	push   %ebp
  800e0e:	89 e5                	mov    %esp,%ebp
  800e10:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e13:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800e18:	89 c2                	mov    %eax,%edx
  800e1a:	c1 ea 16             	shr    $0x16,%edx
  800e1d:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e24:	f6 c2 01             	test   $0x1,%dl
  800e27:	74 11                	je     800e3a <fd_alloc+0x2d>
  800e29:	89 c2                	mov    %eax,%edx
  800e2b:	c1 ea 0c             	shr    $0xc,%edx
  800e2e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e35:	f6 c2 01             	test   $0x1,%dl
  800e38:	75 09                	jne    800e43 <fd_alloc+0x36>
			*fd_store = fd;
  800e3a:	89 01                	mov    %eax,(%ecx)
			return 0;
  800e3c:	b8 00 00 00 00       	mov    $0x0,%eax
  800e41:	eb 17                	jmp    800e5a <fd_alloc+0x4d>
  800e43:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800e48:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800e4d:	75 c9                	jne    800e18 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800e4f:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800e55:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800e5a:	5d                   	pop    %ebp
  800e5b:	c3                   	ret    

00800e5c <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800e5c:	55                   	push   %ebp
  800e5d:	89 e5                	mov    %esp,%ebp
  800e5f:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800e62:	83 f8 1f             	cmp    $0x1f,%eax
  800e65:	77 36                	ja     800e9d <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800e67:	c1 e0 0c             	shl    $0xc,%eax
  800e6a:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800e6f:	89 c2                	mov    %eax,%edx
  800e71:	c1 ea 16             	shr    $0x16,%edx
  800e74:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e7b:	f6 c2 01             	test   $0x1,%dl
  800e7e:	74 24                	je     800ea4 <fd_lookup+0x48>
  800e80:	89 c2                	mov    %eax,%edx
  800e82:	c1 ea 0c             	shr    $0xc,%edx
  800e85:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e8c:	f6 c2 01             	test   $0x1,%dl
  800e8f:	74 1a                	je     800eab <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800e91:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e94:	89 02                	mov    %eax,(%edx)
	return 0;
  800e96:	b8 00 00 00 00       	mov    $0x0,%eax
  800e9b:	eb 13                	jmp    800eb0 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800e9d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800ea2:	eb 0c                	jmp    800eb0 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800ea4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800ea9:	eb 05                	jmp    800eb0 <fd_lookup+0x54>
  800eab:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800eb0:	5d                   	pop    %ebp
  800eb1:	c3                   	ret    

00800eb2 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800eb2:	55                   	push   %ebp
  800eb3:	89 e5                	mov    %esp,%ebp
  800eb5:	83 ec 08             	sub    $0x8,%esp
  800eb8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ebb:	ba 68 28 80 00       	mov    $0x802868,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800ec0:	eb 13                	jmp    800ed5 <dev_lookup+0x23>
  800ec2:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800ec5:	39 08                	cmp    %ecx,(%eax)
  800ec7:	75 0c                	jne    800ed5 <dev_lookup+0x23>
			*dev = devtab[i];
  800ec9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ecc:	89 01                	mov    %eax,(%ecx)
			return 0;
  800ece:	b8 00 00 00 00       	mov    $0x0,%eax
  800ed3:	eb 2e                	jmp    800f03 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800ed5:	8b 02                	mov    (%edx),%eax
  800ed7:	85 c0                	test   %eax,%eax
  800ed9:	75 e7                	jne    800ec2 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800edb:	a1 04 40 80 00       	mov    0x804004,%eax
  800ee0:	8b 40 48             	mov    0x48(%eax),%eax
  800ee3:	83 ec 04             	sub    $0x4,%esp
  800ee6:	51                   	push   %ecx
  800ee7:	50                   	push   %eax
  800ee8:	68 ec 27 80 00       	push   $0x8027ec
  800eed:	e8 7b f3 ff ff       	call   80026d <cprintf>
	*dev = 0;
  800ef2:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ef5:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800efb:	83 c4 10             	add    $0x10,%esp
  800efe:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800f03:	c9                   	leave  
  800f04:	c3                   	ret    

00800f05 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800f05:	55                   	push   %ebp
  800f06:	89 e5                	mov    %esp,%ebp
  800f08:	56                   	push   %esi
  800f09:	53                   	push   %ebx
  800f0a:	83 ec 10             	sub    $0x10,%esp
  800f0d:	8b 75 08             	mov    0x8(%ebp),%esi
  800f10:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800f13:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f16:	50                   	push   %eax
  800f17:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800f1d:	c1 e8 0c             	shr    $0xc,%eax
  800f20:	50                   	push   %eax
  800f21:	e8 36 ff ff ff       	call   800e5c <fd_lookup>
  800f26:	83 c4 08             	add    $0x8,%esp
  800f29:	85 c0                	test   %eax,%eax
  800f2b:	78 05                	js     800f32 <fd_close+0x2d>
	    || fd != fd2)
  800f2d:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800f30:	74 0c                	je     800f3e <fd_close+0x39>
		return (must_exist ? r : 0);
  800f32:	84 db                	test   %bl,%bl
  800f34:	ba 00 00 00 00       	mov    $0x0,%edx
  800f39:	0f 44 c2             	cmove  %edx,%eax
  800f3c:	eb 41                	jmp    800f7f <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800f3e:	83 ec 08             	sub    $0x8,%esp
  800f41:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800f44:	50                   	push   %eax
  800f45:	ff 36                	pushl  (%esi)
  800f47:	e8 66 ff ff ff       	call   800eb2 <dev_lookup>
  800f4c:	89 c3                	mov    %eax,%ebx
  800f4e:	83 c4 10             	add    $0x10,%esp
  800f51:	85 c0                	test   %eax,%eax
  800f53:	78 1a                	js     800f6f <fd_close+0x6a>
		if (dev->dev_close)
  800f55:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f58:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800f5b:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800f60:	85 c0                	test   %eax,%eax
  800f62:	74 0b                	je     800f6f <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800f64:	83 ec 0c             	sub    $0xc,%esp
  800f67:	56                   	push   %esi
  800f68:	ff d0                	call   *%eax
  800f6a:	89 c3                	mov    %eax,%ebx
  800f6c:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800f6f:	83 ec 08             	sub    $0x8,%esp
  800f72:	56                   	push   %esi
  800f73:	6a 00                	push   $0x0
  800f75:	e8 00 fd ff ff       	call   800c7a <sys_page_unmap>
	return r;
  800f7a:	83 c4 10             	add    $0x10,%esp
  800f7d:	89 d8                	mov    %ebx,%eax
}
  800f7f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f82:	5b                   	pop    %ebx
  800f83:	5e                   	pop    %esi
  800f84:	5d                   	pop    %ebp
  800f85:	c3                   	ret    

00800f86 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800f86:	55                   	push   %ebp
  800f87:	89 e5                	mov    %esp,%ebp
  800f89:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800f8c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f8f:	50                   	push   %eax
  800f90:	ff 75 08             	pushl  0x8(%ebp)
  800f93:	e8 c4 fe ff ff       	call   800e5c <fd_lookup>
  800f98:	83 c4 08             	add    $0x8,%esp
  800f9b:	85 c0                	test   %eax,%eax
  800f9d:	78 10                	js     800faf <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800f9f:	83 ec 08             	sub    $0x8,%esp
  800fa2:	6a 01                	push   $0x1
  800fa4:	ff 75 f4             	pushl  -0xc(%ebp)
  800fa7:	e8 59 ff ff ff       	call   800f05 <fd_close>
  800fac:	83 c4 10             	add    $0x10,%esp
}
  800faf:	c9                   	leave  
  800fb0:	c3                   	ret    

00800fb1 <close_all>:

void
close_all(void)
{
  800fb1:	55                   	push   %ebp
  800fb2:	89 e5                	mov    %esp,%ebp
  800fb4:	53                   	push   %ebx
  800fb5:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800fb8:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800fbd:	83 ec 0c             	sub    $0xc,%esp
  800fc0:	53                   	push   %ebx
  800fc1:	e8 c0 ff ff ff       	call   800f86 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800fc6:	83 c3 01             	add    $0x1,%ebx
  800fc9:	83 c4 10             	add    $0x10,%esp
  800fcc:	83 fb 20             	cmp    $0x20,%ebx
  800fcf:	75 ec                	jne    800fbd <close_all+0xc>
		close(i);
}
  800fd1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800fd4:	c9                   	leave  
  800fd5:	c3                   	ret    

00800fd6 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800fd6:	55                   	push   %ebp
  800fd7:	89 e5                	mov    %esp,%ebp
  800fd9:	57                   	push   %edi
  800fda:	56                   	push   %esi
  800fdb:	53                   	push   %ebx
  800fdc:	83 ec 2c             	sub    $0x2c,%esp
  800fdf:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800fe2:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800fe5:	50                   	push   %eax
  800fe6:	ff 75 08             	pushl  0x8(%ebp)
  800fe9:	e8 6e fe ff ff       	call   800e5c <fd_lookup>
  800fee:	83 c4 08             	add    $0x8,%esp
  800ff1:	85 c0                	test   %eax,%eax
  800ff3:	0f 88 c1 00 00 00    	js     8010ba <dup+0xe4>
		return r;
	close(newfdnum);
  800ff9:	83 ec 0c             	sub    $0xc,%esp
  800ffc:	56                   	push   %esi
  800ffd:	e8 84 ff ff ff       	call   800f86 <close>

	newfd = INDEX2FD(newfdnum);
  801002:	89 f3                	mov    %esi,%ebx
  801004:	c1 e3 0c             	shl    $0xc,%ebx
  801007:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  80100d:	83 c4 04             	add    $0x4,%esp
  801010:	ff 75 e4             	pushl  -0x1c(%ebp)
  801013:	e8 de fd ff ff       	call   800df6 <fd2data>
  801018:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  80101a:	89 1c 24             	mov    %ebx,(%esp)
  80101d:	e8 d4 fd ff ff       	call   800df6 <fd2data>
  801022:	83 c4 10             	add    $0x10,%esp
  801025:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801028:	89 f8                	mov    %edi,%eax
  80102a:	c1 e8 16             	shr    $0x16,%eax
  80102d:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801034:	a8 01                	test   $0x1,%al
  801036:	74 37                	je     80106f <dup+0x99>
  801038:	89 f8                	mov    %edi,%eax
  80103a:	c1 e8 0c             	shr    $0xc,%eax
  80103d:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801044:	f6 c2 01             	test   $0x1,%dl
  801047:	74 26                	je     80106f <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801049:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801050:	83 ec 0c             	sub    $0xc,%esp
  801053:	25 07 0e 00 00       	and    $0xe07,%eax
  801058:	50                   	push   %eax
  801059:	ff 75 d4             	pushl  -0x2c(%ebp)
  80105c:	6a 00                	push   $0x0
  80105e:	57                   	push   %edi
  80105f:	6a 00                	push   $0x0
  801061:	e8 d2 fb ff ff       	call   800c38 <sys_page_map>
  801066:	89 c7                	mov    %eax,%edi
  801068:	83 c4 20             	add    $0x20,%esp
  80106b:	85 c0                	test   %eax,%eax
  80106d:	78 2e                	js     80109d <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80106f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801072:	89 d0                	mov    %edx,%eax
  801074:	c1 e8 0c             	shr    $0xc,%eax
  801077:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80107e:	83 ec 0c             	sub    $0xc,%esp
  801081:	25 07 0e 00 00       	and    $0xe07,%eax
  801086:	50                   	push   %eax
  801087:	53                   	push   %ebx
  801088:	6a 00                	push   $0x0
  80108a:	52                   	push   %edx
  80108b:	6a 00                	push   $0x0
  80108d:	e8 a6 fb ff ff       	call   800c38 <sys_page_map>
  801092:	89 c7                	mov    %eax,%edi
  801094:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801097:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801099:	85 ff                	test   %edi,%edi
  80109b:	79 1d                	jns    8010ba <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80109d:	83 ec 08             	sub    $0x8,%esp
  8010a0:	53                   	push   %ebx
  8010a1:	6a 00                	push   $0x0
  8010a3:	e8 d2 fb ff ff       	call   800c7a <sys_page_unmap>
	sys_page_unmap(0, nva);
  8010a8:	83 c4 08             	add    $0x8,%esp
  8010ab:	ff 75 d4             	pushl  -0x2c(%ebp)
  8010ae:	6a 00                	push   $0x0
  8010b0:	e8 c5 fb ff ff       	call   800c7a <sys_page_unmap>
	return r;
  8010b5:	83 c4 10             	add    $0x10,%esp
  8010b8:	89 f8                	mov    %edi,%eax
}
  8010ba:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010bd:	5b                   	pop    %ebx
  8010be:	5e                   	pop    %esi
  8010bf:	5f                   	pop    %edi
  8010c0:	5d                   	pop    %ebp
  8010c1:	c3                   	ret    

008010c2 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8010c2:	55                   	push   %ebp
  8010c3:	89 e5                	mov    %esp,%ebp
  8010c5:	53                   	push   %ebx
  8010c6:	83 ec 14             	sub    $0x14,%esp
  8010c9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8010cc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8010cf:	50                   	push   %eax
  8010d0:	53                   	push   %ebx
  8010d1:	e8 86 fd ff ff       	call   800e5c <fd_lookup>
  8010d6:	83 c4 08             	add    $0x8,%esp
  8010d9:	89 c2                	mov    %eax,%edx
  8010db:	85 c0                	test   %eax,%eax
  8010dd:	78 6d                	js     80114c <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8010df:	83 ec 08             	sub    $0x8,%esp
  8010e2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010e5:	50                   	push   %eax
  8010e6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8010e9:	ff 30                	pushl  (%eax)
  8010eb:	e8 c2 fd ff ff       	call   800eb2 <dev_lookup>
  8010f0:	83 c4 10             	add    $0x10,%esp
  8010f3:	85 c0                	test   %eax,%eax
  8010f5:	78 4c                	js     801143 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8010f7:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8010fa:	8b 42 08             	mov    0x8(%edx),%eax
  8010fd:	83 e0 03             	and    $0x3,%eax
  801100:	83 f8 01             	cmp    $0x1,%eax
  801103:	75 21                	jne    801126 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801105:	a1 04 40 80 00       	mov    0x804004,%eax
  80110a:	8b 40 48             	mov    0x48(%eax),%eax
  80110d:	83 ec 04             	sub    $0x4,%esp
  801110:	53                   	push   %ebx
  801111:	50                   	push   %eax
  801112:	68 2d 28 80 00       	push   $0x80282d
  801117:	e8 51 f1 ff ff       	call   80026d <cprintf>
		return -E_INVAL;
  80111c:	83 c4 10             	add    $0x10,%esp
  80111f:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801124:	eb 26                	jmp    80114c <read+0x8a>
	}
	if (!dev->dev_read)
  801126:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801129:	8b 40 08             	mov    0x8(%eax),%eax
  80112c:	85 c0                	test   %eax,%eax
  80112e:	74 17                	je     801147 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801130:	83 ec 04             	sub    $0x4,%esp
  801133:	ff 75 10             	pushl  0x10(%ebp)
  801136:	ff 75 0c             	pushl  0xc(%ebp)
  801139:	52                   	push   %edx
  80113a:	ff d0                	call   *%eax
  80113c:	89 c2                	mov    %eax,%edx
  80113e:	83 c4 10             	add    $0x10,%esp
  801141:	eb 09                	jmp    80114c <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801143:	89 c2                	mov    %eax,%edx
  801145:	eb 05                	jmp    80114c <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801147:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  80114c:	89 d0                	mov    %edx,%eax
  80114e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801151:	c9                   	leave  
  801152:	c3                   	ret    

00801153 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801153:	55                   	push   %ebp
  801154:	89 e5                	mov    %esp,%ebp
  801156:	57                   	push   %edi
  801157:	56                   	push   %esi
  801158:	53                   	push   %ebx
  801159:	83 ec 0c             	sub    $0xc,%esp
  80115c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80115f:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801162:	bb 00 00 00 00       	mov    $0x0,%ebx
  801167:	eb 21                	jmp    80118a <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801169:	83 ec 04             	sub    $0x4,%esp
  80116c:	89 f0                	mov    %esi,%eax
  80116e:	29 d8                	sub    %ebx,%eax
  801170:	50                   	push   %eax
  801171:	89 d8                	mov    %ebx,%eax
  801173:	03 45 0c             	add    0xc(%ebp),%eax
  801176:	50                   	push   %eax
  801177:	57                   	push   %edi
  801178:	e8 45 ff ff ff       	call   8010c2 <read>
		if (m < 0)
  80117d:	83 c4 10             	add    $0x10,%esp
  801180:	85 c0                	test   %eax,%eax
  801182:	78 10                	js     801194 <readn+0x41>
			return m;
		if (m == 0)
  801184:	85 c0                	test   %eax,%eax
  801186:	74 0a                	je     801192 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801188:	01 c3                	add    %eax,%ebx
  80118a:	39 f3                	cmp    %esi,%ebx
  80118c:	72 db                	jb     801169 <readn+0x16>
  80118e:	89 d8                	mov    %ebx,%eax
  801190:	eb 02                	jmp    801194 <readn+0x41>
  801192:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801194:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801197:	5b                   	pop    %ebx
  801198:	5e                   	pop    %esi
  801199:	5f                   	pop    %edi
  80119a:	5d                   	pop    %ebp
  80119b:	c3                   	ret    

0080119c <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80119c:	55                   	push   %ebp
  80119d:	89 e5                	mov    %esp,%ebp
  80119f:	53                   	push   %ebx
  8011a0:	83 ec 14             	sub    $0x14,%esp
  8011a3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011a6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011a9:	50                   	push   %eax
  8011aa:	53                   	push   %ebx
  8011ab:	e8 ac fc ff ff       	call   800e5c <fd_lookup>
  8011b0:	83 c4 08             	add    $0x8,%esp
  8011b3:	89 c2                	mov    %eax,%edx
  8011b5:	85 c0                	test   %eax,%eax
  8011b7:	78 68                	js     801221 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011b9:	83 ec 08             	sub    $0x8,%esp
  8011bc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011bf:	50                   	push   %eax
  8011c0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011c3:	ff 30                	pushl  (%eax)
  8011c5:	e8 e8 fc ff ff       	call   800eb2 <dev_lookup>
  8011ca:	83 c4 10             	add    $0x10,%esp
  8011cd:	85 c0                	test   %eax,%eax
  8011cf:	78 47                	js     801218 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8011d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011d4:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8011d8:	75 21                	jne    8011fb <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8011da:	a1 04 40 80 00       	mov    0x804004,%eax
  8011df:	8b 40 48             	mov    0x48(%eax),%eax
  8011e2:	83 ec 04             	sub    $0x4,%esp
  8011e5:	53                   	push   %ebx
  8011e6:	50                   	push   %eax
  8011e7:	68 49 28 80 00       	push   $0x802849
  8011ec:	e8 7c f0 ff ff       	call   80026d <cprintf>
		return -E_INVAL;
  8011f1:	83 c4 10             	add    $0x10,%esp
  8011f4:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8011f9:	eb 26                	jmp    801221 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8011fb:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8011fe:	8b 52 0c             	mov    0xc(%edx),%edx
  801201:	85 d2                	test   %edx,%edx
  801203:	74 17                	je     80121c <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801205:	83 ec 04             	sub    $0x4,%esp
  801208:	ff 75 10             	pushl  0x10(%ebp)
  80120b:	ff 75 0c             	pushl  0xc(%ebp)
  80120e:	50                   	push   %eax
  80120f:	ff d2                	call   *%edx
  801211:	89 c2                	mov    %eax,%edx
  801213:	83 c4 10             	add    $0x10,%esp
  801216:	eb 09                	jmp    801221 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801218:	89 c2                	mov    %eax,%edx
  80121a:	eb 05                	jmp    801221 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80121c:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801221:	89 d0                	mov    %edx,%eax
  801223:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801226:	c9                   	leave  
  801227:	c3                   	ret    

00801228 <seek>:

int
seek(int fdnum, off_t offset)
{
  801228:	55                   	push   %ebp
  801229:	89 e5                	mov    %esp,%ebp
  80122b:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80122e:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801231:	50                   	push   %eax
  801232:	ff 75 08             	pushl  0x8(%ebp)
  801235:	e8 22 fc ff ff       	call   800e5c <fd_lookup>
  80123a:	83 c4 08             	add    $0x8,%esp
  80123d:	85 c0                	test   %eax,%eax
  80123f:	78 0e                	js     80124f <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801241:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801244:	8b 55 0c             	mov    0xc(%ebp),%edx
  801247:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80124a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80124f:	c9                   	leave  
  801250:	c3                   	ret    

00801251 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801251:	55                   	push   %ebp
  801252:	89 e5                	mov    %esp,%ebp
  801254:	53                   	push   %ebx
  801255:	83 ec 14             	sub    $0x14,%esp
  801258:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80125b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80125e:	50                   	push   %eax
  80125f:	53                   	push   %ebx
  801260:	e8 f7 fb ff ff       	call   800e5c <fd_lookup>
  801265:	83 c4 08             	add    $0x8,%esp
  801268:	89 c2                	mov    %eax,%edx
  80126a:	85 c0                	test   %eax,%eax
  80126c:	78 65                	js     8012d3 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80126e:	83 ec 08             	sub    $0x8,%esp
  801271:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801274:	50                   	push   %eax
  801275:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801278:	ff 30                	pushl  (%eax)
  80127a:	e8 33 fc ff ff       	call   800eb2 <dev_lookup>
  80127f:	83 c4 10             	add    $0x10,%esp
  801282:	85 c0                	test   %eax,%eax
  801284:	78 44                	js     8012ca <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801286:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801289:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80128d:	75 21                	jne    8012b0 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80128f:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801294:	8b 40 48             	mov    0x48(%eax),%eax
  801297:	83 ec 04             	sub    $0x4,%esp
  80129a:	53                   	push   %ebx
  80129b:	50                   	push   %eax
  80129c:	68 0c 28 80 00       	push   $0x80280c
  8012a1:	e8 c7 ef ff ff       	call   80026d <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8012a6:	83 c4 10             	add    $0x10,%esp
  8012a9:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8012ae:	eb 23                	jmp    8012d3 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8012b0:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8012b3:	8b 52 18             	mov    0x18(%edx),%edx
  8012b6:	85 d2                	test   %edx,%edx
  8012b8:	74 14                	je     8012ce <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8012ba:	83 ec 08             	sub    $0x8,%esp
  8012bd:	ff 75 0c             	pushl  0xc(%ebp)
  8012c0:	50                   	push   %eax
  8012c1:	ff d2                	call   *%edx
  8012c3:	89 c2                	mov    %eax,%edx
  8012c5:	83 c4 10             	add    $0x10,%esp
  8012c8:	eb 09                	jmp    8012d3 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012ca:	89 c2                	mov    %eax,%edx
  8012cc:	eb 05                	jmp    8012d3 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8012ce:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8012d3:	89 d0                	mov    %edx,%eax
  8012d5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012d8:	c9                   	leave  
  8012d9:	c3                   	ret    

008012da <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8012da:	55                   	push   %ebp
  8012db:	89 e5                	mov    %esp,%ebp
  8012dd:	53                   	push   %ebx
  8012de:	83 ec 14             	sub    $0x14,%esp
  8012e1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012e4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012e7:	50                   	push   %eax
  8012e8:	ff 75 08             	pushl  0x8(%ebp)
  8012eb:	e8 6c fb ff ff       	call   800e5c <fd_lookup>
  8012f0:	83 c4 08             	add    $0x8,%esp
  8012f3:	89 c2                	mov    %eax,%edx
  8012f5:	85 c0                	test   %eax,%eax
  8012f7:	78 58                	js     801351 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012f9:	83 ec 08             	sub    $0x8,%esp
  8012fc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012ff:	50                   	push   %eax
  801300:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801303:	ff 30                	pushl  (%eax)
  801305:	e8 a8 fb ff ff       	call   800eb2 <dev_lookup>
  80130a:	83 c4 10             	add    $0x10,%esp
  80130d:	85 c0                	test   %eax,%eax
  80130f:	78 37                	js     801348 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801311:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801314:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801318:	74 32                	je     80134c <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80131a:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80131d:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801324:	00 00 00 
	stat->st_isdir = 0;
  801327:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80132e:	00 00 00 
	stat->st_dev = dev;
  801331:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801337:	83 ec 08             	sub    $0x8,%esp
  80133a:	53                   	push   %ebx
  80133b:	ff 75 f0             	pushl  -0x10(%ebp)
  80133e:	ff 50 14             	call   *0x14(%eax)
  801341:	89 c2                	mov    %eax,%edx
  801343:	83 c4 10             	add    $0x10,%esp
  801346:	eb 09                	jmp    801351 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801348:	89 c2                	mov    %eax,%edx
  80134a:	eb 05                	jmp    801351 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80134c:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801351:	89 d0                	mov    %edx,%eax
  801353:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801356:	c9                   	leave  
  801357:	c3                   	ret    

00801358 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801358:	55                   	push   %ebp
  801359:	89 e5                	mov    %esp,%ebp
  80135b:	56                   	push   %esi
  80135c:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80135d:	83 ec 08             	sub    $0x8,%esp
  801360:	6a 00                	push   $0x0
  801362:	ff 75 08             	pushl  0x8(%ebp)
  801365:	e8 b7 01 00 00       	call   801521 <open>
  80136a:	89 c3                	mov    %eax,%ebx
  80136c:	83 c4 10             	add    $0x10,%esp
  80136f:	85 c0                	test   %eax,%eax
  801371:	78 1b                	js     80138e <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801373:	83 ec 08             	sub    $0x8,%esp
  801376:	ff 75 0c             	pushl  0xc(%ebp)
  801379:	50                   	push   %eax
  80137a:	e8 5b ff ff ff       	call   8012da <fstat>
  80137f:	89 c6                	mov    %eax,%esi
	close(fd);
  801381:	89 1c 24             	mov    %ebx,(%esp)
  801384:	e8 fd fb ff ff       	call   800f86 <close>
	return r;
  801389:	83 c4 10             	add    $0x10,%esp
  80138c:	89 f0                	mov    %esi,%eax
}
  80138e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801391:	5b                   	pop    %ebx
  801392:	5e                   	pop    %esi
  801393:	5d                   	pop    %ebp
  801394:	c3                   	ret    

00801395 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801395:	55                   	push   %ebp
  801396:	89 e5                	mov    %esp,%ebp
  801398:	56                   	push   %esi
  801399:	53                   	push   %ebx
  80139a:	89 c6                	mov    %eax,%esi
  80139c:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80139e:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8013a5:	75 12                	jne    8013b9 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8013a7:	83 ec 0c             	sub    $0xc,%esp
  8013aa:	6a 01                	push   $0x1
  8013ac:	e8 ee 0c 00 00       	call   80209f <ipc_find_env>
  8013b1:	a3 00 40 80 00       	mov    %eax,0x804000
  8013b6:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8013b9:	6a 07                	push   $0x7
  8013bb:	68 00 50 80 00       	push   $0x805000
  8013c0:	56                   	push   %esi
  8013c1:	ff 35 00 40 80 00    	pushl  0x804000
  8013c7:	e8 7f 0c 00 00       	call   80204b <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8013cc:	83 c4 0c             	add    $0xc,%esp
  8013cf:	6a 00                	push   $0x0
  8013d1:	53                   	push   %ebx
  8013d2:	6a 00                	push   $0x0
  8013d4:	e8 0b 0c 00 00       	call   801fe4 <ipc_recv>
}
  8013d9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013dc:	5b                   	pop    %ebx
  8013dd:	5e                   	pop    %esi
  8013de:	5d                   	pop    %ebp
  8013df:	c3                   	ret    

008013e0 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8013e0:	55                   	push   %ebp
  8013e1:	89 e5                	mov    %esp,%ebp
  8013e3:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8013e6:	8b 45 08             	mov    0x8(%ebp),%eax
  8013e9:	8b 40 0c             	mov    0xc(%eax),%eax
  8013ec:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8013f1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013f4:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8013f9:	ba 00 00 00 00       	mov    $0x0,%edx
  8013fe:	b8 02 00 00 00       	mov    $0x2,%eax
  801403:	e8 8d ff ff ff       	call   801395 <fsipc>
}
  801408:	c9                   	leave  
  801409:	c3                   	ret    

0080140a <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80140a:	55                   	push   %ebp
  80140b:	89 e5                	mov    %esp,%ebp
  80140d:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801410:	8b 45 08             	mov    0x8(%ebp),%eax
  801413:	8b 40 0c             	mov    0xc(%eax),%eax
  801416:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80141b:	ba 00 00 00 00       	mov    $0x0,%edx
  801420:	b8 06 00 00 00       	mov    $0x6,%eax
  801425:	e8 6b ff ff ff       	call   801395 <fsipc>
}
  80142a:	c9                   	leave  
  80142b:	c3                   	ret    

0080142c <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80142c:	55                   	push   %ebp
  80142d:	89 e5                	mov    %esp,%ebp
  80142f:	53                   	push   %ebx
  801430:	83 ec 04             	sub    $0x4,%esp
  801433:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801436:	8b 45 08             	mov    0x8(%ebp),%eax
  801439:	8b 40 0c             	mov    0xc(%eax),%eax
  80143c:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801441:	ba 00 00 00 00       	mov    $0x0,%edx
  801446:	b8 05 00 00 00       	mov    $0x5,%eax
  80144b:	e8 45 ff ff ff       	call   801395 <fsipc>
  801450:	85 c0                	test   %eax,%eax
  801452:	78 2c                	js     801480 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801454:	83 ec 08             	sub    $0x8,%esp
  801457:	68 00 50 80 00       	push   $0x805000
  80145c:	53                   	push   %ebx
  80145d:	e8 90 f3 ff ff       	call   8007f2 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801462:	a1 80 50 80 00       	mov    0x805080,%eax
  801467:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80146d:	a1 84 50 80 00       	mov    0x805084,%eax
  801472:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801478:	83 c4 10             	add    $0x10,%esp
  80147b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801480:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801483:	c9                   	leave  
  801484:	c3                   	ret    

00801485 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801485:	55                   	push   %ebp
  801486:	89 e5                	mov    %esp,%ebp
  801488:	83 ec 0c             	sub    $0xc,%esp
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	panic("devfile_write not implemented");
  80148b:	68 78 28 80 00       	push   $0x802878
  801490:	68 90 00 00 00       	push   $0x90
  801495:	68 96 28 80 00       	push   $0x802896
  80149a:	e8 f5 ec ff ff       	call   800194 <_panic>

0080149f <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80149f:	55                   	push   %ebp
  8014a0:	89 e5                	mov    %esp,%ebp
  8014a2:	56                   	push   %esi
  8014a3:	53                   	push   %ebx
  8014a4:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8014a7:	8b 45 08             	mov    0x8(%ebp),%eax
  8014aa:	8b 40 0c             	mov    0xc(%eax),%eax
  8014ad:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8014b2:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8014b8:	ba 00 00 00 00       	mov    $0x0,%edx
  8014bd:	b8 03 00 00 00       	mov    $0x3,%eax
  8014c2:	e8 ce fe ff ff       	call   801395 <fsipc>
  8014c7:	89 c3                	mov    %eax,%ebx
  8014c9:	85 c0                	test   %eax,%eax
  8014cb:	78 4b                	js     801518 <devfile_read+0x79>
		return r;
	assert(r <= n);
  8014cd:	39 c6                	cmp    %eax,%esi
  8014cf:	73 16                	jae    8014e7 <devfile_read+0x48>
  8014d1:	68 a1 28 80 00       	push   $0x8028a1
  8014d6:	68 a8 28 80 00       	push   $0x8028a8
  8014db:	6a 7c                	push   $0x7c
  8014dd:	68 96 28 80 00       	push   $0x802896
  8014e2:	e8 ad ec ff ff       	call   800194 <_panic>
	assert(r <= PGSIZE);
  8014e7:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8014ec:	7e 16                	jle    801504 <devfile_read+0x65>
  8014ee:	68 bd 28 80 00       	push   $0x8028bd
  8014f3:	68 a8 28 80 00       	push   $0x8028a8
  8014f8:	6a 7d                	push   $0x7d
  8014fa:	68 96 28 80 00       	push   $0x802896
  8014ff:	e8 90 ec ff ff       	call   800194 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801504:	83 ec 04             	sub    $0x4,%esp
  801507:	50                   	push   %eax
  801508:	68 00 50 80 00       	push   $0x805000
  80150d:	ff 75 0c             	pushl  0xc(%ebp)
  801510:	e8 6f f4 ff ff       	call   800984 <memmove>
	return r;
  801515:	83 c4 10             	add    $0x10,%esp
}
  801518:	89 d8                	mov    %ebx,%eax
  80151a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80151d:	5b                   	pop    %ebx
  80151e:	5e                   	pop    %esi
  80151f:	5d                   	pop    %ebp
  801520:	c3                   	ret    

00801521 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801521:	55                   	push   %ebp
  801522:	89 e5                	mov    %esp,%ebp
  801524:	53                   	push   %ebx
  801525:	83 ec 20             	sub    $0x20,%esp
  801528:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  80152b:	53                   	push   %ebx
  80152c:	e8 88 f2 ff ff       	call   8007b9 <strlen>
  801531:	83 c4 10             	add    $0x10,%esp
  801534:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801539:	7f 67                	jg     8015a2 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80153b:	83 ec 0c             	sub    $0xc,%esp
  80153e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801541:	50                   	push   %eax
  801542:	e8 c6 f8 ff ff       	call   800e0d <fd_alloc>
  801547:	83 c4 10             	add    $0x10,%esp
		return r;
  80154a:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80154c:	85 c0                	test   %eax,%eax
  80154e:	78 57                	js     8015a7 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801550:	83 ec 08             	sub    $0x8,%esp
  801553:	53                   	push   %ebx
  801554:	68 00 50 80 00       	push   $0x805000
  801559:	e8 94 f2 ff ff       	call   8007f2 <strcpy>
	fsipcbuf.open.req_omode = mode;
  80155e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801561:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801566:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801569:	b8 01 00 00 00       	mov    $0x1,%eax
  80156e:	e8 22 fe ff ff       	call   801395 <fsipc>
  801573:	89 c3                	mov    %eax,%ebx
  801575:	83 c4 10             	add    $0x10,%esp
  801578:	85 c0                	test   %eax,%eax
  80157a:	79 14                	jns    801590 <open+0x6f>
		fd_close(fd, 0);
  80157c:	83 ec 08             	sub    $0x8,%esp
  80157f:	6a 00                	push   $0x0
  801581:	ff 75 f4             	pushl  -0xc(%ebp)
  801584:	e8 7c f9 ff ff       	call   800f05 <fd_close>
		return r;
  801589:	83 c4 10             	add    $0x10,%esp
  80158c:	89 da                	mov    %ebx,%edx
  80158e:	eb 17                	jmp    8015a7 <open+0x86>
	}

	return fd2num(fd);
  801590:	83 ec 0c             	sub    $0xc,%esp
  801593:	ff 75 f4             	pushl  -0xc(%ebp)
  801596:	e8 4b f8 ff ff       	call   800de6 <fd2num>
  80159b:	89 c2                	mov    %eax,%edx
  80159d:	83 c4 10             	add    $0x10,%esp
  8015a0:	eb 05                	jmp    8015a7 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8015a2:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8015a7:	89 d0                	mov    %edx,%eax
  8015a9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015ac:	c9                   	leave  
  8015ad:	c3                   	ret    

008015ae <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8015ae:	55                   	push   %ebp
  8015af:	89 e5                	mov    %esp,%ebp
  8015b1:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8015b4:	ba 00 00 00 00       	mov    $0x0,%edx
  8015b9:	b8 08 00 00 00       	mov    $0x8,%eax
  8015be:	e8 d2 fd ff ff       	call   801395 <fsipc>
}
  8015c3:	c9                   	leave  
  8015c4:	c3                   	ret    

008015c5 <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  8015c5:	55                   	push   %ebp
  8015c6:	89 e5                	mov    %esp,%ebp
  8015c8:	57                   	push   %edi
  8015c9:	56                   	push   %esi
  8015ca:	53                   	push   %ebx
  8015cb:	81 ec 94 02 00 00    	sub    $0x294,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  8015d1:	6a 00                	push   $0x0
  8015d3:	ff 75 08             	pushl  0x8(%ebp)
  8015d6:	e8 46 ff ff ff       	call   801521 <open>
  8015db:	89 c7                	mov    %eax,%edi
  8015dd:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  8015e3:	83 c4 10             	add    $0x10,%esp
  8015e6:	85 c0                	test   %eax,%eax
  8015e8:	0f 88 3a 04 00 00    	js     801a28 <spawn+0x463>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  8015ee:	83 ec 04             	sub    $0x4,%esp
  8015f1:	68 00 02 00 00       	push   $0x200
  8015f6:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  8015fc:	50                   	push   %eax
  8015fd:	57                   	push   %edi
  8015fe:	e8 50 fb ff ff       	call   801153 <readn>
  801603:	83 c4 10             	add    $0x10,%esp
  801606:	3d 00 02 00 00       	cmp    $0x200,%eax
  80160b:	75 0c                	jne    801619 <spawn+0x54>
	    || elf->e_magic != ELF_MAGIC) {
  80160d:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  801614:	45 4c 46 
  801617:	74 33                	je     80164c <spawn+0x87>
		close(fd);
  801619:	83 ec 0c             	sub    $0xc,%esp
  80161c:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801622:	e8 5f f9 ff ff       	call   800f86 <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  801627:	83 c4 0c             	add    $0xc,%esp
  80162a:	68 7f 45 4c 46       	push   $0x464c457f
  80162f:	ff b5 e8 fd ff ff    	pushl  -0x218(%ebp)
  801635:	68 c9 28 80 00       	push   $0x8028c9
  80163a:	e8 2e ec ff ff       	call   80026d <cprintf>
		return -E_NOT_EXEC;
  80163f:	83 c4 10             	add    $0x10,%esp
  801642:	bb f2 ff ff ff       	mov    $0xfffffff2,%ebx
  801647:	e9 3c 04 00 00       	jmp    801a88 <spawn+0x4c3>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  80164c:	b8 07 00 00 00       	mov    $0x7,%eax
  801651:	cd 30                	int    $0x30
  801653:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
  801659:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  80165f:	85 c0                	test   %eax,%eax
  801661:	0f 88 c9 03 00 00    	js     801a30 <spawn+0x46b>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  801667:	89 c6                	mov    %eax,%esi
  801669:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  80166f:	6b f6 7c             	imul   $0x7c,%esi,%esi
  801672:	81 c6 00 00 c0 ee    	add    $0xeec00000,%esi
  801678:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  80167e:	b9 11 00 00 00       	mov    $0x11,%ecx
  801683:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  801685:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  80168b:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801691:	bb 00 00 00 00       	mov    $0x0,%ebx
	char *string_store;
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
  801696:	be 00 00 00 00       	mov    $0x0,%esi
  80169b:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80169e:	eb 13                	jmp    8016b3 <spawn+0xee>
	for (argc = 0; argv[argc] != 0; argc++)
		string_size += strlen(argv[argc]) + 1;
  8016a0:	83 ec 0c             	sub    $0xc,%esp
  8016a3:	50                   	push   %eax
  8016a4:	e8 10 f1 ff ff       	call   8007b9 <strlen>
  8016a9:	8d 74 30 01          	lea    0x1(%eax,%esi,1),%esi
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  8016ad:	83 c3 01             	add    $0x1,%ebx
  8016b0:	83 c4 10             	add    $0x10,%esp
  8016b3:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
  8016ba:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  8016bd:	85 c0                	test   %eax,%eax
  8016bf:	75 df                	jne    8016a0 <spawn+0xdb>
  8016c1:	89 9d 88 fd ff ff    	mov    %ebx,-0x278(%ebp)
  8016c7:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  8016cd:	bf 00 10 40 00       	mov    $0x401000,%edi
  8016d2:	29 f7                	sub    %esi,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  8016d4:	89 fa                	mov    %edi,%edx
  8016d6:	83 e2 fc             	and    $0xfffffffc,%edx
  8016d9:	8d 04 9d 04 00 00 00 	lea    0x4(,%ebx,4),%eax
  8016e0:	29 c2                	sub    %eax,%edx
  8016e2:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  8016e8:	8d 42 f8             	lea    -0x8(%edx),%eax
  8016eb:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  8016f0:	0f 86 4a 03 00 00    	jbe    801a40 <spawn+0x47b>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  8016f6:	83 ec 04             	sub    $0x4,%esp
  8016f9:	6a 07                	push   $0x7
  8016fb:	68 00 00 40 00       	push   $0x400000
  801700:	6a 00                	push   $0x0
  801702:	e8 ee f4 ff ff       	call   800bf5 <sys_page_alloc>
  801707:	83 c4 10             	add    $0x10,%esp
  80170a:	85 c0                	test   %eax,%eax
  80170c:	0f 88 35 03 00 00    	js     801a47 <spawn+0x482>
  801712:	be 00 00 00 00       	mov    $0x0,%esi
  801717:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
  80171d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801720:	eb 30                	jmp    801752 <spawn+0x18d>
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
		argv_store[i] = UTEMP2USTACK(string_store);
  801722:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  801728:	8b 8d 94 fd ff ff    	mov    -0x26c(%ebp),%ecx
  80172e:	89 04 b1             	mov    %eax,(%ecx,%esi,4)
		strcpy(string_store, argv[i]);
  801731:	83 ec 08             	sub    $0x8,%esp
  801734:	ff 34 b3             	pushl  (%ebx,%esi,4)
  801737:	57                   	push   %edi
  801738:	e8 b5 f0 ff ff       	call   8007f2 <strcpy>
		string_store += strlen(argv[i]) + 1;
  80173d:	83 c4 04             	add    $0x4,%esp
  801740:	ff 34 b3             	pushl  (%ebx,%esi,4)
  801743:	e8 71 f0 ff ff       	call   8007b9 <strlen>
  801748:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  80174c:	83 c6 01             	add    $0x1,%esi
  80174f:	83 c4 10             	add    $0x10,%esp
  801752:	39 b5 90 fd ff ff    	cmp    %esi,-0x270(%ebp)
  801758:	7f c8                	jg     801722 <spawn+0x15d>
		argv_store[i] = UTEMP2USTACK(string_store);
		strcpy(string_store, argv[i]);
		string_store += strlen(argv[i]) + 1;
	}
	argv_store[argc] = 0;
  80175a:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  801760:	8b 8d 80 fd ff ff    	mov    -0x280(%ebp),%ecx
  801766:	c7 04 08 00 00 00 00 	movl   $0x0,(%eax,%ecx,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  80176d:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  801773:	74 19                	je     80178e <spawn+0x1c9>
  801775:	68 40 29 80 00       	push   $0x802940
  80177a:	68 a8 28 80 00       	push   $0x8028a8
  80177f:	68 f2 00 00 00       	push   $0xf2
  801784:	68 e3 28 80 00       	push   $0x8028e3
  801789:	e8 06 ea ff ff       	call   800194 <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  80178e:	8b 8d 94 fd ff ff    	mov    -0x26c(%ebp),%ecx
  801794:	89 c8                	mov    %ecx,%eax
  801796:	2d 00 30 80 11       	sub    $0x11803000,%eax
  80179b:	89 41 fc             	mov    %eax,-0x4(%ecx)
	argv_store[-2] = argc;
  80179e:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  8017a4:	89 41 f8             	mov    %eax,-0x8(%ecx)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  8017a7:	8d 81 f8 cf 7f ee    	lea    -0x11803008(%ecx),%eax
  8017ad:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  8017b3:	83 ec 0c             	sub    $0xc,%esp
  8017b6:	6a 07                	push   $0x7
  8017b8:	68 00 d0 bf ee       	push   $0xeebfd000
  8017bd:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  8017c3:	68 00 00 40 00       	push   $0x400000
  8017c8:	6a 00                	push   $0x0
  8017ca:	e8 69 f4 ff ff       	call   800c38 <sys_page_map>
  8017cf:	89 c3                	mov    %eax,%ebx
  8017d1:	83 c4 20             	add    $0x20,%esp
  8017d4:	85 c0                	test   %eax,%eax
  8017d6:	0f 88 9a 02 00 00    	js     801a76 <spawn+0x4b1>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  8017dc:	83 ec 08             	sub    $0x8,%esp
  8017df:	68 00 00 40 00       	push   $0x400000
  8017e4:	6a 00                	push   $0x0
  8017e6:	e8 8f f4 ff ff       	call   800c7a <sys_page_unmap>
  8017eb:	89 c3                	mov    %eax,%ebx
  8017ed:	83 c4 10             	add    $0x10,%esp
  8017f0:	85 c0                	test   %eax,%eax
  8017f2:	0f 88 7e 02 00 00    	js     801a76 <spawn+0x4b1>

	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  8017f8:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
  8017fe:	8d 84 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%eax
  801805:	89 85 7c fd ff ff    	mov    %eax,-0x284(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  80180b:	c7 85 78 fd ff ff 00 	movl   $0x0,-0x288(%ebp)
  801812:	00 00 00 
  801815:	e9 86 01 00 00       	jmp    8019a0 <spawn+0x3db>
		if (ph->p_type != ELF_PROG_LOAD)
  80181a:	8b 85 7c fd ff ff    	mov    -0x284(%ebp),%eax
  801820:	83 38 01             	cmpl   $0x1,(%eax)
  801823:	0f 85 69 01 00 00    	jne    801992 <spawn+0x3cd>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  801829:	89 c1                	mov    %eax,%ecx
  80182b:	8b 40 18             	mov    0x18(%eax),%eax
  80182e:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  801834:	83 e0 02             	and    $0x2,%eax
			perm |= PTE_W;
  801837:	83 f8 01             	cmp    $0x1,%eax
  80183a:	19 c0                	sbb    %eax,%eax
  80183c:	83 e0 fe             	and    $0xfffffffe,%eax
  80183f:	83 c0 07             	add    $0x7,%eax
  801842:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  801848:	89 c8                	mov    %ecx,%eax
  80184a:	8b 49 04             	mov    0x4(%ecx),%ecx
  80184d:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
  801853:	8b 78 10             	mov    0x10(%eax),%edi
  801856:	8b 50 14             	mov    0x14(%eax),%edx
  801859:	89 95 90 fd ff ff    	mov    %edx,-0x270(%ebp)
  80185f:	8b 70 08             	mov    0x8(%eax),%esi
	int i, r;
	void *blk;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  801862:	89 f0                	mov    %esi,%eax
  801864:	25 ff 0f 00 00       	and    $0xfff,%eax
  801869:	74 14                	je     80187f <spawn+0x2ba>
		va -= i;
  80186b:	29 c6                	sub    %eax,%esi
		memsz += i;
  80186d:	01 c2                	add    %eax,%edx
  80186f:	89 95 90 fd ff ff    	mov    %edx,-0x270(%ebp)
		filesz += i;
  801875:	01 c7                	add    %eax,%edi
		fileoffset -= i;
  801877:	29 c1                	sub    %eax,%ecx
  801879:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  80187f:	bb 00 00 00 00       	mov    $0x0,%ebx
  801884:	e9 f7 00 00 00       	jmp    801980 <spawn+0x3bb>
		if (i >= filesz) {
  801889:	39 df                	cmp    %ebx,%edi
  80188b:	77 27                	ja     8018b4 <spawn+0x2ef>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  80188d:	83 ec 04             	sub    $0x4,%esp
  801890:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  801896:	56                   	push   %esi
  801897:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  80189d:	e8 53 f3 ff ff       	call   800bf5 <sys_page_alloc>
  8018a2:	83 c4 10             	add    $0x10,%esp
  8018a5:	85 c0                	test   %eax,%eax
  8018a7:	0f 89 c7 00 00 00    	jns    801974 <spawn+0x3af>
  8018ad:	89 c3                	mov    %eax,%ebx
  8018af:	e9 a1 01 00 00       	jmp    801a55 <spawn+0x490>
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  8018b4:	83 ec 04             	sub    $0x4,%esp
  8018b7:	6a 07                	push   $0x7
  8018b9:	68 00 00 40 00       	push   $0x400000
  8018be:	6a 00                	push   $0x0
  8018c0:	e8 30 f3 ff ff       	call   800bf5 <sys_page_alloc>
  8018c5:	83 c4 10             	add    $0x10,%esp
  8018c8:	85 c0                	test   %eax,%eax
  8018ca:	0f 88 7b 01 00 00    	js     801a4b <spawn+0x486>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  8018d0:	83 ec 08             	sub    $0x8,%esp
  8018d3:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  8018d9:	03 85 94 fd ff ff    	add    -0x26c(%ebp),%eax
  8018df:	50                   	push   %eax
  8018e0:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  8018e6:	e8 3d f9 ff ff       	call   801228 <seek>
  8018eb:	83 c4 10             	add    $0x10,%esp
  8018ee:	85 c0                	test   %eax,%eax
  8018f0:	0f 88 59 01 00 00    	js     801a4f <spawn+0x48a>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  8018f6:	83 ec 04             	sub    $0x4,%esp
  8018f9:	89 f8                	mov    %edi,%eax
  8018fb:	2b 85 94 fd ff ff    	sub    -0x26c(%ebp),%eax
  801901:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801906:	b9 00 10 00 00       	mov    $0x1000,%ecx
  80190b:	0f 47 c1             	cmova  %ecx,%eax
  80190e:	50                   	push   %eax
  80190f:	68 00 00 40 00       	push   $0x400000
  801914:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  80191a:	e8 34 f8 ff ff       	call   801153 <readn>
  80191f:	83 c4 10             	add    $0x10,%esp
  801922:	85 c0                	test   %eax,%eax
  801924:	0f 88 29 01 00 00    	js     801a53 <spawn+0x48e>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  80192a:	83 ec 0c             	sub    $0xc,%esp
  80192d:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  801933:	56                   	push   %esi
  801934:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  80193a:	68 00 00 40 00       	push   $0x400000
  80193f:	6a 00                	push   $0x0
  801941:	e8 f2 f2 ff ff       	call   800c38 <sys_page_map>
  801946:	83 c4 20             	add    $0x20,%esp
  801949:	85 c0                	test   %eax,%eax
  80194b:	79 15                	jns    801962 <spawn+0x39d>
				panic("spawn: sys_page_map data: %e", r);
  80194d:	50                   	push   %eax
  80194e:	68 ef 28 80 00       	push   $0x8028ef
  801953:	68 25 01 00 00       	push   $0x125
  801958:	68 e3 28 80 00       	push   $0x8028e3
  80195d:	e8 32 e8 ff ff       	call   800194 <_panic>
			sys_page_unmap(0, UTEMP);
  801962:	83 ec 08             	sub    $0x8,%esp
  801965:	68 00 00 40 00       	push   $0x400000
  80196a:	6a 00                	push   $0x0
  80196c:	e8 09 f3 ff ff       	call   800c7a <sys_page_unmap>
  801971:	83 c4 10             	add    $0x10,%esp
		memsz += i;
		filesz += i;
		fileoffset -= i;
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801974:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  80197a:	81 c6 00 10 00 00    	add    $0x1000,%esi
  801980:	89 9d 94 fd ff ff    	mov    %ebx,-0x26c(%ebp)
  801986:	39 9d 90 fd ff ff    	cmp    %ebx,-0x270(%ebp)
  80198c:	0f 87 f7 fe ff ff    	ja     801889 <spawn+0x2c4>
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801992:	83 85 78 fd ff ff 01 	addl   $0x1,-0x288(%ebp)
  801999:	83 85 7c fd ff ff 20 	addl   $0x20,-0x284(%ebp)
  8019a0:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  8019a7:	39 85 78 fd ff ff    	cmp    %eax,-0x288(%ebp)
  8019ad:	0f 8c 67 fe ff ff    	jl     80181a <spawn+0x255>
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
	}
	close(fd);
  8019b3:	83 ec 0c             	sub    $0xc,%esp
  8019b6:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  8019bc:	e8 c5 f5 ff ff       	call   800f86 <close>

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	child_tf.tf_eflags |= FL_IOPL_3;   // devious: see user/faultio.c
  8019c1:	81 8d dc fd ff ff 00 	orl    $0x3000,-0x224(%ebp)
  8019c8:	30 00 00 
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  8019cb:	83 c4 08             	add    $0x8,%esp
  8019ce:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  8019d4:	50                   	push   %eax
  8019d5:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  8019db:	e8 1e f3 ff ff       	call   800cfe <sys_env_set_trapframe>
  8019e0:	83 c4 10             	add    $0x10,%esp
  8019e3:	85 c0                	test   %eax,%eax
  8019e5:	79 15                	jns    8019fc <spawn+0x437>
		panic("sys_env_set_trapframe: %e", r);
  8019e7:	50                   	push   %eax
  8019e8:	68 0c 29 80 00       	push   $0x80290c
  8019ed:	68 86 00 00 00       	push   $0x86
  8019f2:	68 e3 28 80 00       	push   $0x8028e3
  8019f7:	e8 98 e7 ff ff       	call   800194 <_panic>

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  8019fc:	83 ec 08             	sub    $0x8,%esp
  8019ff:	6a 02                	push   $0x2
  801a01:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801a07:	e8 b0 f2 ff ff       	call   800cbc <sys_env_set_status>
  801a0c:	83 c4 10             	add    $0x10,%esp
  801a0f:	85 c0                	test   %eax,%eax
  801a11:	79 25                	jns    801a38 <spawn+0x473>
		panic("sys_env_set_status: %e", r);
  801a13:	50                   	push   %eax
  801a14:	68 26 29 80 00       	push   $0x802926
  801a19:	68 89 00 00 00       	push   $0x89
  801a1e:	68 e3 28 80 00       	push   $0x8028e3
  801a23:	e8 6c e7 ff ff       	call   800194 <_panic>
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
		return r;
  801a28:	8b 9d 8c fd ff ff    	mov    -0x274(%ebp),%ebx
  801a2e:	eb 58                	jmp    801a88 <spawn+0x4c3>
		return -E_NOT_EXEC;
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
		return r;
  801a30:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  801a36:	eb 50                	jmp    801a88 <spawn+0x4c3>
		panic("sys_env_set_trapframe: %e", r);

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
		panic("sys_env_set_status: %e", r);

	return child;
  801a38:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  801a3e:	eb 48                	jmp    801a88 <spawn+0x4c3>
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
		return -E_NO_MEM;
  801a40:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
  801a45:	eb 41                	jmp    801a88 <spawn+0x4c3>

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
		return r;
  801a47:	89 c3                	mov    %eax,%ebx
  801a49:	eb 3d                	jmp    801a88 <spawn+0x4c3>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801a4b:	89 c3                	mov    %eax,%ebx
  801a4d:	eb 06                	jmp    801a55 <spawn+0x490>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801a4f:	89 c3                	mov    %eax,%ebx
  801a51:	eb 02                	jmp    801a55 <spawn+0x490>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801a53:	89 c3                	mov    %eax,%ebx
		panic("sys_env_set_status: %e", r);

	return child;

error:
	sys_env_destroy(child);
  801a55:	83 ec 0c             	sub    $0xc,%esp
  801a58:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801a5e:	e8 13 f1 ff ff       	call   800b76 <sys_env_destroy>
	close(fd);
  801a63:	83 c4 04             	add    $0x4,%esp
  801a66:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801a6c:	e8 15 f5 ff ff       	call   800f86 <close>
	return r;
  801a71:	83 c4 10             	add    $0x10,%esp
  801a74:	eb 12                	jmp    801a88 <spawn+0x4c3>
		goto error;

	return 0;

error:
	sys_page_unmap(0, UTEMP);
  801a76:	83 ec 08             	sub    $0x8,%esp
  801a79:	68 00 00 40 00       	push   $0x400000
  801a7e:	6a 00                	push   $0x0
  801a80:	e8 f5 f1 ff ff       	call   800c7a <sys_page_unmap>
  801a85:	83 c4 10             	add    $0x10,%esp

error:
	sys_env_destroy(child);
	close(fd);
	return r;
}
  801a88:	89 d8                	mov    %ebx,%eax
  801a8a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a8d:	5b                   	pop    %ebx
  801a8e:	5e                   	pop    %esi
  801a8f:	5f                   	pop    %edi
  801a90:	5d                   	pop    %ebp
  801a91:	c3                   	ret    

00801a92 <spawnl>:
// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
{
  801a92:	55                   	push   %ebp
  801a93:	89 e5                	mov    %esp,%ebp
  801a95:	56                   	push   %esi
  801a96:	53                   	push   %ebx
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801a97:	8d 55 10             	lea    0x10(%ebp),%edx
{
	// We calculate argc by advancing the args until we hit NULL.
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
  801a9a:	b8 00 00 00 00       	mov    $0x0,%eax
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801a9f:	eb 03                	jmp    801aa4 <spawnl+0x12>
		argc++;
  801aa1:	83 c0 01             	add    $0x1,%eax
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801aa4:	83 c2 04             	add    $0x4,%edx
  801aa7:	83 7a fc 00          	cmpl   $0x0,-0x4(%edx)
  801aab:	75 f4                	jne    801aa1 <spawnl+0xf>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  801aad:	8d 14 85 1a 00 00 00 	lea    0x1a(,%eax,4),%edx
  801ab4:	83 e2 f0             	and    $0xfffffff0,%edx
  801ab7:	29 d4                	sub    %edx,%esp
  801ab9:	8d 54 24 03          	lea    0x3(%esp),%edx
  801abd:	c1 ea 02             	shr    $0x2,%edx
  801ac0:	8d 34 95 00 00 00 00 	lea    0x0(,%edx,4),%esi
  801ac7:	89 f3                	mov    %esi,%ebx
	argv[0] = arg0;
  801ac9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801acc:	89 0c 95 00 00 00 00 	mov    %ecx,0x0(,%edx,4)
	argv[argc+1] = NULL;
  801ad3:	c7 44 86 04 00 00 00 	movl   $0x0,0x4(%esi,%eax,4)
  801ada:	00 
  801adb:	89 c2                	mov    %eax,%edx

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  801add:	b8 00 00 00 00       	mov    $0x0,%eax
  801ae2:	eb 0a                	jmp    801aee <spawnl+0x5c>
		argv[i+1] = va_arg(vl, const char *);
  801ae4:	83 c0 01             	add    $0x1,%eax
  801ae7:	8b 4c 85 0c          	mov    0xc(%ebp,%eax,4),%ecx
  801aeb:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  801aee:	39 d0                	cmp    %edx,%eax
  801af0:	75 f2                	jne    801ae4 <spawnl+0x52>
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return spawn(prog, argv);
  801af2:	83 ec 08             	sub    $0x8,%esp
  801af5:	56                   	push   %esi
  801af6:	ff 75 08             	pushl  0x8(%ebp)
  801af9:	e8 c7 fa ff ff       	call   8015c5 <spawn>
}
  801afe:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b01:	5b                   	pop    %ebx
  801b02:	5e                   	pop    %esi
  801b03:	5d                   	pop    %ebp
  801b04:	c3                   	ret    

00801b05 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801b05:	55                   	push   %ebp
  801b06:	89 e5                	mov    %esp,%ebp
  801b08:	56                   	push   %esi
  801b09:	53                   	push   %ebx
  801b0a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801b0d:	83 ec 0c             	sub    $0xc,%esp
  801b10:	ff 75 08             	pushl  0x8(%ebp)
  801b13:	e8 de f2 ff ff       	call   800df6 <fd2data>
  801b18:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801b1a:	83 c4 08             	add    $0x8,%esp
  801b1d:	68 68 29 80 00       	push   $0x802968
  801b22:	53                   	push   %ebx
  801b23:	e8 ca ec ff ff       	call   8007f2 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801b28:	8b 46 04             	mov    0x4(%esi),%eax
  801b2b:	2b 06                	sub    (%esi),%eax
  801b2d:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801b33:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801b3a:	00 00 00 
	stat->st_dev = &devpipe;
  801b3d:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801b44:	30 80 00 
	return 0;
}
  801b47:	b8 00 00 00 00       	mov    $0x0,%eax
  801b4c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b4f:	5b                   	pop    %ebx
  801b50:	5e                   	pop    %esi
  801b51:	5d                   	pop    %ebp
  801b52:	c3                   	ret    

00801b53 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801b53:	55                   	push   %ebp
  801b54:	89 e5                	mov    %esp,%ebp
  801b56:	53                   	push   %ebx
  801b57:	83 ec 0c             	sub    $0xc,%esp
  801b5a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801b5d:	53                   	push   %ebx
  801b5e:	6a 00                	push   $0x0
  801b60:	e8 15 f1 ff ff       	call   800c7a <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801b65:	89 1c 24             	mov    %ebx,(%esp)
  801b68:	e8 89 f2 ff ff       	call   800df6 <fd2data>
  801b6d:	83 c4 08             	add    $0x8,%esp
  801b70:	50                   	push   %eax
  801b71:	6a 00                	push   $0x0
  801b73:	e8 02 f1 ff ff       	call   800c7a <sys_page_unmap>
}
  801b78:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b7b:	c9                   	leave  
  801b7c:	c3                   	ret    

00801b7d <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801b7d:	55                   	push   %ebp
  801b7e:	89 e5                	mov    %esp,%ebp
  801b80:	57                   	push   %edi
  801b81:	56                   	push   %esi
  801b82:	53                   	push   %ebx
  801b83:	83 ec 1c             	sub    $0x1c,%esp
  801b86:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801b89:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801b8b:	a1 04 40 80 00       	mov    0x804004,%eax
  801b90:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801b93:	83 ec 0c             	sub    $0xc,%esp
  801b96:	ff 75 e0             	pushl  -0x20(%ebp)
  801b99:	e8 3a 05 00 00       	call   8020d8 <pageref>
  801b9e:	89 c3                	mov    %eax,%ebx
  801ba0:	89 3c 24             	mov    %edi,(%esp)
  801ba3:	e8 30 05 00 00       	call   8020d8 <pageref>
  801ba8:	83 c4 10             	add    $0x10,%esp
  801bab:	39 c3                	cmp    %eax,%ebx
  801bad:	0f 94 c1             	sete   %cl
  801bb0:	0f b6 c9             	movzbl %cl,%ecx
  801bb3:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801bb6:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801bbc:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801bbf:	39 ce                	cmp    %ecx,%esi
  801bc1:	74 1b                	je     801bde <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801bc3:	39 c3                	cmp    %eax,%ebx
  801bc5:	75 c4                	jne    801b8b <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801bc7:	8b 42 58             	mov    0x58(%edx),%eax
  801bca:	ff 75 e4             	pushl  -0x1c(%ebp)
  801bcd:	50                   	push   %eax
  801bce:	56                   	push   %esi
  801bcf:	68 6f 29 80 00       	push   $0x80296f
  801bd4:	e8 94 e6 ff ff       	call   80026d <cprintf>
  801bd9:	83 c4 10             	add    $0x10,%esp
  801bdc:	eb ad                	jmp    801b8b <_pipeisclosed+0xe>
	}
}
  801bde:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801be1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801be4:	5b                   	pop    %ebx
  801be5:	5e                   	pop    %esi
  801be6:	5f                   	pop    %edi
  801be7:	5d                   	pop    %ebp
  801be8:	c3                   	ret    

00801be9 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801be9:	55                   	push   %ebp
  801bea:	89 e5                	mov    %esp,%ebp
  801bec:	57                   	push   %edi
  801bed:	56                   	push   %esi
  801bee:	53                   	push   %ebx
  801bef:	83 ec 28             	sub    $0x28,%esp
  801bf2:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801bf5:	56                   	push   %esi
  801bf6:	e8 fb f1 ff ff       	call   800df6 <fd2data>
  801bfb:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801bfd:	83 c4 10             	add    $0x10,%esp
  801c00:	bf 00 00 00 00       	mov    $0x0,%edi
  801c05:	eb 4b                	jmp    801c52 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801c07:	89 da                	mov    %ebx,%edx
  801c09:	89 f0                	mov    %esi,%eax
  801c0b:	e8 6d ff ff ff       	call   801b7d <_pipeisclosed>
  801c10:	85 c0                	test   %eax,%eax
  801c12:	75 48                	jne    801c5c <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801c14:	e8 bd ef ff ff       	call   800bd6 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801c19:	8b 43 04             	mov    0x4(%ebx),%eax
  801c1c:	8b 0b                	mov    (%ebx),%ecx
  801c1e:	8d 51 20             	lea    0x20(%ecx),%edx
  801c21:	39 d0                	cmp    %edx,%eax
  801c23:	73 e2                	jae    801c07 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801c25:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c28:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801c2c:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801c2f:	89 c2                	mov    %eax,%edx
  801c31:	c1 fa 1f             	sar    $0x1f,%edx
  801c34:	89 d1                	mov    %edx,%ecx
  801c36:	c1 e9 1b             	shr    $0x1b,%ecx
  801c39:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801c3c:	83 e2 1f             	and    $0x1f,%edx
  801c3f:	29 ca                	sub    %ecx,%edx
  801c41:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801c45:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801c49:	83 c0 01             	add    $0x1,%eax
  801c4c:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c4f:	83 c7 01             	add    $0x1,%edi
  801c52:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801c55:	75 c2                	jne    801c19 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801c57:	8b 45 10             	mov    0x10(%ebp),%eax
  801c5a:	eb 05                	jmp    801c61 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801c5c:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801c61:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c64:	5b                   	pop    %ebx
  801c65:	5e                   	pop    %esi
  801c66:	5f                   	pop    %edi
  801c67:	5d                   	pop    %ebp
  801c68:	c3                   	ret    

00801c69 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801c69:	55                   	push   %ebp
  801c6a:	89 e5                	mov    %esp,%ebp
  801c6c:	57                   	push   %edi
  801c6d:	56                   	push   %esi
  801c6e:	53                   	push   %ebx
  801c6f:	83 ec 18             	sub    $0x18,%esp
  801c72:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801c75:	57                   	push   %edi
  801c76:	e8 7b f1 ff ff       	call   800df6 <fd2data>
  801c7b:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c7d:	83 c4 10             	add    $0x10,%esp
  801c80:	bb 00 00 00 00       	mov    $0x0,%ebx
  801c85:	eb 3d                	jmp    801cc4 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801c87:	85 db                	test   %ebx,%ebx
  801c89:	74 04                	je     801c8f <devpipe_read+0x26>
				return i;
  801c8b:	89 d8                	mov    %ebx,%eax
  801c8d:	eb 44                	jmp    801cd3 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801c8f:	89 f2                	mov    %esi,%edx
  801c91:	89 f8                	mov    %edi,%eax
  801c93:	e8 e5 fe ff ff       	call   801b7d <_pipeisclosed>
  801c98:	85 c0                	test   %eax,%eax
  801c9a:	75 32                	jne    801cce <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801c9c:	e8 35 ef ff ff       	call   800bd6 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801ca1:	8b 06                	mov    (%esi),%eax
  801ca3:	3b 46 04             	cmp    0x4(%esi),%eax
  801ca6:	74 df                	je     801c87 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801ca8:	99                   	cltd   
  801ca9:	c1 ea 1b             	shr    $0x1b,%edx
  801cac:	01 d0                	add    %edx,%eax
  801cae:	83 e0 1f             	and    $0x1f,%eax
  801cb1:	29 d0                	sub    %edx,%eax
  801cb3:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801cb8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801cbb:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801cbe:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801cc1:	83 c3 01             	add    $0x1,%ebx
  801cc4:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801cc7:	75 d8                	jne    801ca1 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801cc9:	8b 45 10             	mov    0x10(%ebp),%eax
  801ccc:	eb 05                	jmp    801cd3 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801cce:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801cd3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801cd6:	5b                   	pop    %ebx
  801cd7:	5e                   	pop    %esi
  801cd8:	5f                   	pop    %edi
  801cd9:	5d                   	pop    %ebp
  801cda:	c3                   	ret    

00801cdb <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801cdb:	55                   	push   %ebp
  801cdc:	89 e5                	mov    %esp,%ebp
  801cde:	56                   	push   %esi
  801cdf:	53                   	push   %ebx
  801ce0:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801ce3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ce6:	50                   	push   %eax
  801ce7:	e8 21 f1 ff ff       	call   800e0d <fd_alloc>
  801cec:	83 c4 10             	add    $0x10,%esp
  801cef:	89 c2                	mov    %eax,%edx
  801cf1:	85 c0                	test   %eax,%eax
  801cf3:	0f 88 2c 01 00 00    	js     801e25 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801cf9:	83 ec 04             	sub    $0x4,%esp
  801cfc:	68 07 04 00 00       	push   $0x407
  801d01:	ff 75 f4             	pushl  -0xc(%ebp)
  801d04:	6a 00                	push   $0x0
  801d06:	e8 ea ee ff ff       	call   800bf5 <sys_page_alloc>
  801d0b:	83 c4 10             	add    $0x10,%esp
  801d0e:	89 c2                	mov    %eax,%edx
  801d10:	85 c0                	test   %eax,%eax
  801d12:	0f 88 0d 01 00 00    	js     801e25 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801d18:	83 ec 0c             	sub    $0xc,%esp
  801d1b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801d1e:	50                   	push   %eax
  801d1f:	e8 e9 f0 ff ff       	call   800e0d <fd_alloc>
  801d24:	89 c3                	mov    %eax,%ebx
  801d26:	83 c4 10             	add    $0x10,%esp
  801d29:	85 c0                	test   %eax,%eax
  801d2b:	0f 88 e2 00 00 00    	js     801e13 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d31:	83 ec 04             	sub    $0x4,%esp
  801d34:	68 07 04 00 00       	push   $0x407
  801d39:	ff 75 f0             	pushl  -0x10(%ebp)
  801d3c:	6a 00                	push   $0x0
  801d3e:	e8 b2 ee ff ff       	call   800bf5 <sys_page_alloc>
  801d43:	89 c3                	mov    %eax,%ebx
  801d45:	83 c4 10             	add    $0x10,%esp
  801d48:	85 c0                	test   %eax,%eax
  801d4a:	0f 88 c3 00 00 00    	js     801e13 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801d50:	83 ec 0c             	sub    $0xc,%esp
  801d53:	ff 75 f4             	pushl  -0xc(%ebp)
  801d56:	e8 9b f0 ff ff       	call   800df6 <fd2data>
  801d5b:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d5d:	83 c4 0c             	add    $0xc,%esp
  801d60:	68 07 04 00 00       	push   $0x407
  801d65:	50                   	push   %eax
  801d66:	6a 00                	push   $0x0
  801d68:	e8 88 ee ff ff       	call   800bf5 <sys_page_alloc>
  801d6d:	89 c3                	mov    %eax,%ebx
  801d6f:	83 c4 10             	add    $0x10,%esp
  801d72:	85 c0                	test   %eax,%eax
  801d74:	0f 88 89 00 00 00    	js     801e03 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d7a:	83 ec 0c             	sub    $0xc,%esp
  801d7d:	ff 75 f0             	pushl  -0x10(%ebp)
  801d80:	e8 71 f0 ff ff       	call   800df6 <fd2data>
  801d85:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801d8c:	50                   	push   %eax
  801d8d:	6a 00                	push   $0x0
  801d8f:	56                   	push   %esi
  801d90:	6a 00                	push   $0x0
  801d92:	e8 a1 ee ff ff       	call   800c38 <sys_page_map>
  801d97:	89 c3                	mov    %eax,%ebx
  801d99:	83 c4 20             	add    $0x20,%esp
  801d9c:	85 c0                	test   %eax,%eax
  801d9e:	78 55                	js     801df5 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801da0:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801da6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801da9:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801dab:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801dae:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801db5:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801dbb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801dbe:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801dc0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801dc3:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801dca:	83 ec 0c             	sub    $0xc,%esp
  801dcd:	ff 75 f4             	pushl  -0xc(%ebp)
  801dd0:	e8 11 f0 ff ff       	call   800de6 <fd2num>
  801dd5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801dd8:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801dda:	83 c4 04             	add    $0x4,%esp
  801ddd:	ff 75 f0             	pushl  -0x10(%ebp)
  801de0:	e8 01 f0 ff ff       	call   800de6 <fd2num>
  801de5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801de8:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801deb:	83 c4 10             	add    $0x10,%esp
  801dee:	ba 00 00 00 00       	mov    $0x0,%edx
  801df3:	eb 30                	jmp    801e25 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801df5:	83 ec 08             	sub    $0x8,%esp
  801df8:	56                   	push   %esi
  801df9:	6a 00                	push   $0x0
  801dfb:	e8 7a ee ff ff       	call   800c7a <sys_page_unmap>
  801e00:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801e03:	83 ec 08             	sub    $0x8,%esp
  801e06:	ff 75 f0             	pushl  -0x10(%ebp)
  801e09:	6a 00                	push   $0x0
  801e0b:	e8 6a ee ff ff       	call   800c7a <sys_page_unmap>
  801e10:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801e13:	83 ec 08             	sub    $0x8,%esp
  801e16:	ff 75 f4             	pushl  -0xc(%ebp)
  801e19:	6a 00                	push   $0x0
  801e1b:	e8 5a ee ff ff       	call   800c7a <sys_page_unmap>
  801e20:	83 c4 10             	add    $0x10,%esp
  801e23:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801e25:	89 d0                	mov    %edx,%eax
  801e27:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e2a:	5b                   	pop    %ebx
  801e2b:	5e                   	pop    %esi
  801e2c:	5d                   	pop    %ebp
  801e2d:	c3                   	ret    

00801e2e <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801e2e:	55                   	push   %ebp
  801e2f:	89 e5                	mov    %esp,%ebp
  801e31:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e34:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e37:	50                   	push   %eax
  801e38:	ff 75 08             	pushl  0x8(%ebp)
  801e3b:	e8 1c f0 ff ff       	call   800e5c <fd_lookup>
  801e40:	83 c4 10             	add    $0x10,%esp
  801e43:	85 c0                	test   %eax,%eax
  801e45:	78 18                	js     801e5f <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801e47:	83 ec 0c             	sub    $0xc,%esp
  801e4a:	ff 75 f4             	pushl  -0xc(%ebp)
  801e4d:	e8 a4 ef ff ff       	call   800df6 <fd2data>
	return _pipeisclosed(fd, p);
  801e52:	89 c2                	mov    %eax,%edx
  801e54:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e57:	e8 21 fd ff ff       	call   801b7d <_pipeisclosed>
  801e5c:	83 c4 10             	add    $0x10,%esp
}
  801e5f:	c9                   	leave  
  801e60:	c3                   	ret    

00801e61 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801e61:	55                   	push   %ebp
  801e62:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801e64:	b8 00 00 00 00       	mov    $0x0,%eax
  801e69:	5d                   	pop    %ebp
  801e6a:	c3                   	ret    

00801e6b <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801e6b:	55                   	push   %ebp
  801e6c:	89 e5                	mov    %esp,%ebp
  801e6e:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801e71:	68 87 29 80 00       	push   $0x802987
  801e76:	ff 75 0c             	pushl  0xc(%ebp)
  801e79:	e8 74 e9 ff ff       	call   8007f2 <strcpy>
	return 0;
}
  801e7e:	b8 00 00 00 00       	mov    $0x0,%eax
  801e83:	c9                   	leave  
  801e84:	c3                   	ret    

00801e85 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801e85:	55                   	push   %ebp
  801e86:	89 e5                	mov    %esp,%ebp
  801e88:	57                   	push   %edi
  801e89:	56                   	push   %esi
  801e8a:	53                   	push   %ebx
  801e8b:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801e91:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801e96:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801e9c:	eb 2d                	jmp    801ecb <devcons_write+0x46>
		m = n - tot;
  801e9e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801ea1:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801ea3:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801ea6:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801eab:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801eae:	83 ec 04             	sub    $0x4,%esp
  801eb1:	53                   	push   %ebx
  801eb2:	03 45 0c             	add    0xc(%ebp),%eax
  801eb5:	50                   	push   %eax
  801eb6:	57                   	push   %edi
  801eb7:	e8 c8 ea ff ff       	call   800984 <memmove>
		sys_cputs(buf, m);
  801ebc:	83 c4 08             	add    $0x8,%esp
  801ebf:	53                   	push   %ebx
  801ec0:	57                   	push   %edi
  801ec1:	e8 73 ec ff ff       	call   800b39 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801ec6:	01 de                	add    %ebx,%esi
  801ec8:	83 c4 10             	add    $0x10,%esp
  801ecb:	89 f0                	mov    %esi,%eax
  801ecd:	3b 75 10             	cmp    0x10(%ebp),%esi
  801ed0:	72 cc                	jb     801e9e <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801ed2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ed5:	5b                   	pop    %ebx
  801ed6:	5e                   	pop    %esi
  801ed7:	5f                   	pop    %edi
  801ed8:	5d                   	pop    %ebp
  801ed9:	c3                   	ret    

00801eda <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801eda:	55                   	push   %ebp
  801edb:	89 e5                	mov    %esp,%ebp
  801edd:	83 ec 08             	sub    $0x8,%esp
  801ee0:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801ee5:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801ee9:	74 2a                	je     801f15 <devcons_read+0x3b>
  801eeb:	eb 05                	jmp    801ef2 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801eed:	e8 e4 ec ff ff       	call   800bd6 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801ef2:	e8 60 ec ff ff       	call   800b57 <sys_cgetc>
  801ef7:	85 c0                	test   %eax,%eax
  801ef9:	74 f2                	je     801eed <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801efb:	85 c0                	test   %eax,%eax
  801efd:	78 16                	js     801f15 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801eff:	83 f8 04             	cmp    $0x4,%eax
  801f02:	74 0c                	je     801f10 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801f04:	8b 55 0c             	mov    0xc(%ebp),%edx
  801f07:	88 02                	mov    %al,(%edx)
	return 1;
  801f09:	b8 01 00 00 00       	mov    $0x1,%eax
  801f0e:	eb 05                	jmp    801f15 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801f10:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801f15:	c9                   	leave  
  801f16:	c3                   	ret    

00801f17 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801f17:	55                   	push   %ebp
  801f18:	89 e5                	mov    %esp,%ebp
  801f1a:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801f1d:	8b 45 08             	mov    0x8(%ebp),%eax
  801f20:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801f23:	6a 01                	push   $0x1
  801f25:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801f28:	50                   	push   %eax
  801f29:	e8 0b ec ff ff       	call   800b39 <sys_cputs>
}
  801f2e:	83 c4 10             	add    $0x10,%esp
  801f31:	c9                   	leave  
  801f32:	c3                   	ret    

00801f33 <getchar>:

int
getchar(void)
{
  801f33:	55                   	push   %ebp
  801f34:	89 e5                	mov    %esp,%ebp
  801f36:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801f39:	6a 01                	push   $0x1
  801f3b:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801f3e:	50                   	push   %eax
  801f3f:	6a 00                	push   $0x0
  801f41:	e8 7c f1 ff ff       	call   8010c2 <read>
	if (r < 0)
  801f46:	83 c4 10             	add    $0x10,%esp
  801f49:	85 c0                	test   %eax,%eax
  801f4b:	78 0f                	js     801f5c <getchar+0x29>
		return r;
	if (r < 1)
  801f4d:	85 c0                	test   %eax,%eax
  801f4f:	7e 06                	jle    801f57 <getchar+0x24>
		return -E_EOF;
	return c;
  801f51:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801f55:	eb 05                	jmp    801f5c <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801f57:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801f5c:	c9                   	leave  
  801f5d:	c3                   	ret    

00801f5e <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801f5e:	55                   	push   %ebp
  801f5f:	89 e5                	mov    %esp,%ebp
  801f61:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801f64:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f67:	50                   	push   %eax
  801f68:	ff 75 08             	pushl  0x8(%ebp)
  801f6b:	e8 ec ee ff ff       	call   800e5c <fd_lookup>
  801f70:	83 c4 10             	add    $0x10,%esp
  801f73:	85 c0                	test   %eax,%eax
  801f75:	78 11                	js     801f88 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801f77:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f7a:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801f80:	39 10                	cmp    %edx,(%eax)
  801f82:	0f 94 c0             	sete   %al
  801f85:	0f b6 c0             	movzbl %al,%eax
}
  801f88:	c9                   	leave  
  801f89:	c3                   	ret    

00801f8a <opencons>:

int
opencons(void)
{
  801f8a:	55                   	push   %ebp
  801f8b:	89 e5                	mov    %esp,%ebp
  801f8d:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801f90:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f93:	50                   	push   %eax
  801f94:	e8 74 ee ff ff       	call   800e0d <fd_alloc>
  801f99:	83 c4 10             	add    $0x10,%esp
		return r;
  801f9c:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801f9e:	85 c0                	test   %eax,%eax
  801fa0:	78 3e                	js     801fe0 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801fa2:	83 ec 04             	sub    $0x4,%esp
  801fa5:	68 07 04 00 00       	push   $0x407
  801faa:	ff 75 f4             	pushl  -0xc(%ebp)
  801fad:	6a 00                	push   $0x0
  801faf:	e8 41 ec ff ff       	call   800bf5 <sys_page_alloc>
  801fb4:	83 c4 10             	add    $0x10,%esp
		return r;
  801fb7:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801fb9:	85 c0                	test   %eax,%eax
  801fbb:	78 23                	js     801fe0 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801fbd:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801fc3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fc6:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801fc8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fcb:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801fd2:	83 ec 0c             	sub    $0xc,%esp
  801fd5:	50                   	push   %eax
  801fd6:	e8 0b ee ff ff       	call   800de6 <fd2num>
  801fdb:	89 c2                	mov    %eax,%edx
  801fdd:	83 c4 10             	add    $0x10,%esp
}
  801fe0:	89 d0                	mov    %edx,%eax
  801fe2:	c9                   	leave  
  801fe3:	c3                   	ret    

00801fe4 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801fe4:	55                   	push   %ebp
  801fe5:	89 e5                	mov    %esp,%ebp
  801fe7:	56                   	push   %esi
  801fe8:	53                   	push   %ebx
  801fe9:	8b 75 08             	mov    0x8(%ebp),%esi
  801fec:	8b 45 0c             	mov    0xc(%ebp),%eax
  801fef:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");

	// don't want to recv page
	if (pg == NULL)
  801ff2:	85 c0                	test   %eax,%eax
		pg = (void *)UTOP;
  801ff4:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801ff9:	0f 44 c2             	cmove  %edx,%eax

	int err = sys_ipc_recv(pg);
  801ffc:	83 ec 0c             	sub    $0xc,%esp
  801fff:	50                   	push   %eax
  802000:	e8 a0 ed ff ff       	call   800da5 <sys_ipc_recv>

	if (from_env_store != NULL)
  802005:	83 c4 10             	add    $0x10,%esp
  802008:	85 f6                	test   %esi,%esi
  80200a:	74 14                	je     802020 <ipc_recv+0x3c>
		*from_env_store = err < 0? 0 : thisenv->env_ipc_from;
  80200c:	ba 00 00 00 00       	mov    $0x0,%edx
  802011:	85 c0                	test   %eax,%eax
  802013:	78 09                	js     80201e <ipc_recv+0x3a>
  802015:	8b 15 04 40 80 00    	mov    0x804004,%edx
  80201b:	8b 52 74             	mov    0x74(%edx),%edx
  80201e:	89 16                	mov    %edx,(%esi)
	
	if (perm_store != NULL)
  802020:	85 db                	test   %ebx,%ebx
  802022:	74 14                	je     802038 <ipc_recv+0x54>
		*perm_store = err < 0? 0 : thisenv->env_ipc_perm;
  802024:	ba 00 00 00 00       	mov    $0x0,%edx
  802029:	85 c0                	test   %eax,%eax
  80202b:	78 09                	js     802036 <ipc_recv+0x52>
  80202d:	8b 15 04 40 80 00    	mov    0x804004,%edx
  802033:	8b 52 78             	mov    0x78(%edx),%edx
  802036:	89 13                	mov    %edx,(%ebx)

	if (err < 0)
  802038:	85 c0                	test   %eax,%eax
  80203a:	78 08                	js     802044 <ipc_recv+0x60>
		return err;
	return thisenv->env_ipc_value;
  80203c:	a1 04 40 80 00       	mov    0x804004,%eax
  802041:	8b 40 70             	mov    0x70(%eax),%eax
}
  802044:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802047:	5b                   	pop    %ebx
  802048:	5e                   	pop    %esi
  802049:	5d                   	pop    %ebp
  80204a:	c3                   	ret    

0080204b <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80204b:	55                   	push   %ebp
  80204c:	89 e5                	mov    %esp,%ebp
  80204e:	57                   	push   %edi
  80204f:	56                   	push   %esi
  802050:	53                   	push   %ebx
  802051:	83 ec 0c             	sub    $0xc,%esp
  802054:	8b 7d 08             	mov    0x8(%ebp),%edi
  802057:	8b 75 0c             	mov    0xc(%ebp),%esi
  80205a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");

	// don't want to send page
	if (pg == NULL)
  80205d:	85 db                	test   %ebx,%ebx
		pg = (void *)UTOP;
  80205f:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  802064:	0f 44 d8             	cmove  %eax,%ebx
	
	int err = 0;
	
	do {

		err = sys_ipc_try_send(to_env, val, pg, perm);
  802067:	ff 75 14             	pushl  0x14(%ebp)
  80206a:	53                   	push   %ebx
  80206b:	56                   	push   %esi
  80206c:	57                   	push   %edi
  80206d:	e8 10 ed ff ff       	call   800d82 <sys_ipc_try_send>

		if (err < 0) {
  802072:	83 c4 10             	add    $0x10,%esp
  802075:	85 c0                	test   %eax,%eax
  802077:	79 1e                	jns    802097 <ipc_send+0x4c>
			if (err == -E_IPC_NOT_RECV)
  802079:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80207c:	75 07                	jne    802085 <ipc_send+0x3a>
				sys_yield();
  80207e:	e8 53 eb ff ff       	call   800bd6 <sys_yield>
  802083:	eb e2                	jmp    802067 <ipc_send+0x1c>
			else 
				panic("ipc_send: %e", err);
  802085:	50                   	push   %eax
  802086:	68 93 29 80 00       	push   $0x802993
  80208b:	6a 49                	push   $0x49
  80208d:	68 a0 29 80 00       	push   $0x8029a0
  802092:	e8 fd e0 ff ff       	call   800194 <_panic>
		}

	} while (err < 0);

}
  802097:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80209a:	5b                   	pop    %ebx
  80209b:	5e                   	pop    %esi
  80209c:	5f                   	pop    %edi
  80209d:	5d                   	pop    %ebp
  80209e:	c3                   	ret    

0080209f <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80209f:	55                   	push   %ebp
  8020a0:	89 e5                	mov    %esp,%ebp
  8020a2:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8020a5:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8020aa:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8020ad:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8020b3:	8b 52 50             	mov    0x50(%edx),%edx
  8020b6:	39 ca                	cmp    %ecx,%edx
  8020b8:	75 0d                	jne    8020c7 <ipc_find_env+0x28>
			return envs[i].env_id;
  8020ba:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8020bd:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8020c2:	8b 40 48             	mov    0x48(%eax),%eax
  8020c5:	eb 0f                	jmp    8020d6 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8020c7:	83 c0 01             	add    $0x1,%eax
  8020ca:	3d 00 04 00 00       	cmp    $0x400,%eax
  8020cf:	75 d9                	jne    8020aa <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8020d1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8020d6:	5d                   	pop    %ebp
  8020d7:	c3                   	ret    

008020d8 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8020d8:	55                   	push   %ebp
  8020d9:	89 e5                	mov    %esp,%ebp
  8020db:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8020de:	89 d0                	mov    %edx,%eax
  8020e0:	c1 e8 16             	shr    $0x16,%eax
  8020e3:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8020ea:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8020ef:	f6 c1 01             	test   $0x1,%cl
  8020f2:	74 1d                	je     802111 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  8020f4:	c1 ea 0c             	shr    $0xc,%edx
  8020f7:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  8020fe:	f6 c2 01             	test   $0x1,%dl
  802101:	74 0e                	je     802111 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802103:	c1 ea 0c             	shr    $0xc,%edx
  802106:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  80210d:	ef 
  80210e:	0f b7 c0             	movzwl %ax,%eax
}
  802111:	5d                   	pop    %ebp
  802112:	c3                   	ret    
  802113:	66 90                	xchg   %ax,%ax
  802115:	66 90                	xchg   %ax,%ax
  802117:	66 90                	xchg   %ax,%ax
  802119:	66 90                	xchg   %ax,%ax
  80211b:	66 90                	xchg   %ax,%ax
  80211d:	66 90                	xchg   %ax,%ax
  80211f:	90                   	nop

00802120 <__udivdi3>:
  802120:	55                   	push   %ebp
  802121:	57                   	push   %edi
  802122:	56                   	push   %esi
  802123:	53                   	push   %ebx
  802124:	83 ec 1c             	sub    $0x1c,%esp
  802127:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80212b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80212f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802133:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802137:	85 f6                	test   %esi,%esi
  802139:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80213d:	89 ca                	mov    %ecx,%edx
  80213f:	89 f8                	mov    %edi,%eax
  802141:	75 3d                	jne    802180 <__udivdi3+0x60>
  802143:	39 cf                	cmp    %ecx,%edi
  802145:	0f 87 c5 00 00 00    	ja     802210 <__udivdi3+0xf0>
  80214b:	85 ff                	test   %edi,%edi
  80214d:	89 fd                	mov    %edi,%ebp
  80214f:	75 0b                	jne    80215c <__udivdi3+0x3c>
  802151:	b8 01 00 00 00       	mov    $0x1,%eax
  802156:	31 d2                	xor    %edx,%edx
  802158:	f7 f7                	div    %edi
  80215a:	89 c5                	mov    %eax,%ebp
  80215c:	89 c8                	mov    %ecx,%eax
  80215e:	31 d2                	xor    %edx,%edx
  802160:	f7 f5                	div    %ebp
  802162:	89 c1                	mov    %eax,%ecx
  802164:	89 d8                	mov    %ebx,%eax
  802166:	89 cf                	mov    %ecx,%edi
  802168:	f7 f5                	div    %ebp
  80216a:	89 c3                	mov    %eax,%ebx
  80216c:	89 d8                	mov    %ebx,%eax
  80216e:	89 fa                	mov    %edi,%edx
  802170:	83 c4 1c             	add    $0x1c,%esp
  802173:	5b                   	pop    %ebx
  802174:	5e                   	pop    %esi
  802175:	5f                   	pop    %edi
  802176:	5d                   	pop    %ebp
  802177:	c3                   	ret    
  802178:	90                   	nop
  802179:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802180:	39 ce                	cmp    %ecx,%esi
  802182:	77 74                	ja     8021f8 <__udivdi3+0xd8>
  802184:	0f bd fe             	bsr    %esi,%edi
  802187:	83 f7 1f             	xor    $0x1f,%edi
  80218a:	0f 84 98 00 00 00    	je     802228 <__udivdi3+0x108>
  802190:	bb 20 00 00 00       	mov    $0x20,%ebx
  802195:	89 f9                	mov    %edi,%ecx
  802197:	89 c5                	mov    %eax,%ebp
  802199:	29 fb                	sub    %edi,%ebx
  80219b:	d3 e6                	shl    %cl,%esi
  80219d:	89 d9                	mov    %ebx,%ecx
  80219f:	d3 ed                	shr    %cl,%ebp
  8021a1:	89 f9                	mov    %edi,%ecx
  8021a3:	d3 e0                	shl    %cl,%eax
  8021a5:	09 ee                	or     %ebp,%esi
  8021a7:	89 d9                	mov    %ebx,%ecx
  8021a9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8021ad:	89 d5                	mov    %edx,%ebp
  8021af:	8b 44 24 08          	mov    0x8(%esp),%eax
  8021b3:	d3 ed                	shr    %cl,%ebp
  8021b5:	89 f9                	mov    %edi,%ecx
  8021b7:	d3 e2                	shl    %cl,%edx
  8021b9:	89 d9                	mov    %ebx,%ecx
  8021bb:	d3 e8                	shr    %cl,%eax
  8021bd:	09 c2                	or     %eax,%edx
  8021bf:	89 d0                	mov    %edx,%eax
  8021c1:	89 ea                	mov    %ebp,%edx
  8021c3:	f7 f6                	div    %esi
  8021c5:	89 d5                	mov    %edx,%ebp
  8021c7:	89 c3                	mov    %eax,%ebx
  8021c9:	f7 64 24 0c          	mull   0xc(%esp)
  8021cd:	39 d5                	cmp    %edx,%ebp
  8021cf:	72 10                	jb     8021e1 <__udivdi3+0xc1>
  8021d1:	8b 74 24 08          	mov    0x8(%esp),%esi
  8021d5:	89 f9                	mov    %edi,%ecx
  8021d7:	d3 e6                	shl    %cl,%esi
  8021d9:	39 c6                	cmp    %eax,%esi
  8021db:	73 07                	jae    8021e4 <__udivdi3+0xc4>
  8021dd:	39 d5                	cmp    %edx,%ebp
  8021df:	75 03                	jne    8021e4 <__udivdi3+0xc4>
  8021e1:	83 eb 01             	sub    $0x1,%ebx
  8021e4:	31 ff                	xor    %edi,%edi
  8021e6:	89 d8                	mov    %ebx,%eax
  8021e8:	89 fa                	mov    %edi,%edx
  8021ea:	83 c4 1c             	add    $0x1c,%esp
  8021ed:	5b                   	pop    %ebx
  8021ee:	5e                   	pop    %esi
  8021ef:	5f                   	pop    %edi
  8021f0:	5d                   	pop    %ebp
  8021f1:	c3                   	ret    
  8021f2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8021f8:	31 ff                	xor    %edi,%edi
  8021fa:	31 db                	xor    %ebx,%ebx
  8021fc:	89 d8                	mov    %ebx,%eax
  8021fe:	89 fa                	mov    %edi,%edx
  802200:	83 c4 1c             	add    $0x1c,%esp
  802203:	5b                   	pop    %ebx
  802204:	5e                   	pop    %esi
  802205:	5f                   	pop    %edi
  802206:	5d                   	pop    %ebp
  802207:	c3                   	ret    
  802208:	90                   	nop
  802209:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802210:	89 d8                	mov    %ebx,%eax
  802212:	f7 f7                	div    %edi
  802214:	31 ff                	xor    %edi,%edi
  802216:	89 c3                	mov    %eax,%ebx
  802218:	89 d8                	mov    %ebx,%eax
  80221a:	89 fa                	mov    %edi,%edx
  80221c:	83 c4 1c             	add    $0x1c,%esp
  80221f:	5b                   	pop    %ebx
  802220:	5e                   	pop    %esi
  802221:	5f                   	pop    %edi
  802222:	5d                   	pop    %ebp
  802223:	c3                   	ret    
  802224:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802228:	39 ce                	cmp    %ecx,%esi
  80222a:	72 0c                	jb     802238 <__udivdi3+0x118>
  80222c:	31 db                	xor    %ebx,%ebx
  80222e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802232:	0f 87 34 ff ff ff    	ja     80216c <__udivdi3+0x4c>
  802238:	bb 01 00 00 00       	mov    $0x1,%ebx
  80223d:	e9 2a ff ff ff       	jmp    80216c <__udivdi3+0x4c>
  802242:	66 90                	xchg   %ax,%ax
  802244:	66 90                	xchg   %ax,%ax
  802246:	66 90                	xchg   %ax,%ax
  802248:	66 90                	xchg   %ax,%ax
  80224a:	66 90                	xchg   %ax,%ax
  80224c:	66 90                	xchg   %ax,%ax
  80224e:	66 90                	xchg   %ax,%ax

00802250 <__umoddi3>:
  802250:	55                   	push   %ebp
  802251:	57                   	push   %edi
  802252:	56                   	push   %esi
  802253:	53                   	push   %ebx
  802254:	83 ec 1c             	sub    $0x1c,%esp
  802257:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80225b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80225f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802263:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802267:	85 d2                	test   %edx,%edx
  802269:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80226d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802271:	89 f3                	mov    %esi,%ebx
  802273:	89 3c 24             	mov    %edi,(%esp)
  802276:	89 74 24 04          	mov    %esi,0x4(%esp)
  80227a:	75 1c                	jne    802298 <__umoddi3+0x48>
  80227c:	39 f7                	cmp    %esi,%edi
  80227e:	76 50                	jbe    8022d0 <__umoddi3+0x80>
  802280:	89 c8                	mov    %ecx,%eax
  802282:	89 f2                	mov    %esi,%edx
  802284:	f7 f7                	div    %edi
  802286:	89 d0                	mov    %edx,%eax
  802288:	31 d2                	xor    %edx,%edx
  80228a:	83 c4 1c             	add    $0x1c,%esp
  80228d:	5b                   	pop    %ebx
  80228e:	5e                   	pop    %esi
  80228f:	5f                   	pop    %edi
  802290:	5d                   	pop    %ebp
  802291:	c3                   	ret    
  802292:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802298:	39 f2                	cmp    %esi,%edx
  80229a:	89 d0                	mov    %edx,%eax
  80229c:	77 52                	ja     8022f0 <__umoddi3+0xa0>
  80229e:	0f bd ea             	bsr    %edx,%ebp
  8022a1:	83 f5 1f             	xor    $0x1f,%ebp
  8022a4:	75 5a                	jne    802300 <__umoddi3+0xb0>
  8022a6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8022aa:	0f 82 e0 00 00 00    	jb     802390 <__umoddi3+0x140>
  8022b0:	39 0c 24             	cmp    %ecx,(%esp)
  8022b3:	0f 86 d7 00 00 00    	jbe    802390 <__umoddi3+0x140>
  8022b9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8022bd:	8b 54 24 04          	mov    0x4(%esp),%edx
  8022c1:	83 c4 1c             	add    $0x1c,%esp
  8022c4:	5b                   	pop    %ebx
  8022c5:	5e                   	pop    %esi
  8022c6:	5f                   	pop    %edi
  8022c7:	5d                   	pop    %ebp
  8022c8:	c3                   	ret    
  8022c9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8022d0:	85 ff                	test   %edi,%edi
  8022d2:	89 fd                	mov    %edi,%ebp
  8022d4:	75 0b                	jne    8022e1 <__umoddi3+0x91>
  8022d6:	b8 01 00 00 00       	mov    $0x1,%eax
  8022db:	31 d2                	xor    %edx,%edx
  8022dd:	f7 f7                	div    %edi
  8022df:	89 c5                	mov    %eax,%ebp
  8022e1:	89 f0                	mov    %esi,%eax
  8022e3:	31 d2                	xor    %edx,%edx
  8022e5:	f7 f5                	div    %ebp
  8022e7:	89 c8                	mov    %ecx,%eax
  8022e9:	f7 f5                	div    %ebp
  8022eb:	89 d0                	mov    %edx,%eax
  8022ed:	eb 99                	jmp    802288 <__umoddi3+0x38>
  8022ef:	90                   	nop
  8022f0:	89 c8                	mov    %ecx,%eax
  8022f2:	89 f2                	mov    %esi,%edx
  8022f4:	83 c4 1c             	add    $0x1c,%esp
  8022f7:	5b                   	pop    %ebx
  8022f8:	5e                   	pop    %esi
  8022f9:	5f                   	pop    %edi
  8022fa:	5d                   	pop    %ebp
  8022fb:	c3                   	ret    
  8022fc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802300:	8b 34 24             	mov    (%esp),%esi
  802303:	bf 20 00 00 00       	mov    $0x20,%edi
  802308:	89 e9                	mov    %ebp,%ecx
  80230a:	29 ef                	sub    %ebp,%edi
  80230c:	d3 e0                	shl    %cl,%eax
  80230e:	89 f9                	mov    %edi,%ecx
  802310:	89 f2                	mov    %esi,%edx
  802312:	d3 ea                	shr    %cl,%edx
  802314:	89 e9                	mov    %ebp,%ecx
  802316:	09 c2                	or     %eax,%edx
  802318:	89 d8                	mov    %ebx,%eax
  80231a:	89 14 24             	mov    %edx,(%esp)
  80231d:	89 f2                	mov    %esi,%edx
  80231f:	d3 e2                	shl    %cl,%edx
  802321:	89 f9                	mov    %edi,%ecx
  802323:	89 54 24 04          	mov    %edx,0x4(%esp)
  802327:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80232b:	d3 e8                	shr    %cl,%eax
  80232d:	89 e9                	mov    %ebp,%ecx
  80232f:	89 c6                	mov    %eax,%esi
  802331:	d3 e3                	shl    %cl,%ebx
  802333:	89 f9                	mov    %edi,%ecx
  802335:	89 d0                	mov    %edx,%eax
  802337:	d3 e8                	shr    %cl,%eax
  802339:	89 e9                	mov    %ebp,%ecx
  80233b:	09 d8                	or     %ebx,%eax
  80233d:	89 d3                	mov    %edx,%ebx
  80233f:	89 f2                	mov    %esi,%edx
  802341:	f7 34 24             	divl   (%esp)
  802344:	89 d6                	mov    %edx,%esi
  802346:	d3 e3                	shl    %cl,%ebx
  802348:	f7 64 24 04          	mull   0x4(%esp)
  80234c:	39 d6                	cmp    %edx,%esi
  80234e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802352:	89 d1                	mov    %edx,%ecx
  802354:	89 c3                	mov    %eax,%ebx
  802356:	72 08                	jb     802360 <__umoddi3+0x110>
  802358:	75 11                	jne    80236b <__umoddi3+0x11b>
  80235a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80235e:	73 0b                	jae    80236b <__umoddi3+0x11b>
  802360:	2b 44 24 04          	sub    0x4(%esp),%eax
  802364:	1b 14 24             	sbb    (%esp),%edx
  802367:	89 d1                	mov    %edx,%ecx
  802369:	89 c3                	mov    %eax,%ebx
  80236b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80236f:	29 da                	sub    %ebx,%edx
  802371:	19 ce                	sbb    %ecx,%esi
  802373:	89 f9                	mov    %edi,%ecx
  802375:	89 f0                	mov    %esi,%eax
  802377:	d3 e0                	shl    %cl,%eax
  802379:	89 e9                	mov    %ebp,%ecx
  80237b:	d3 ea                	shr    %cl,%edx
  80237d:	89 e9                	mov    %ebp,%ecx
  80237f:	d3 ee                	shr    %cl,%esi
  802381:	09 d0                	or     %edx,%eax
  802383:	89 f2                	mov    %esi,%edx
  802385:	83 c4 1c             	add    $0x1c,%esp
  802388:	5b                   	pop    %ebx
  802389:	5e                   	pop    %esi
  80238a:	5f                   	pop    %edi
  80238b:	5d                   	pop    %ebp
  80238c:	c3                   	ret    
  80238d:	8d 76 00             	lea    0x0(%esi),%esi
  802390:	29 f9                	sub    %edi,%ecx
  802392:	19 d6                	sbb    %edx,%esi
  802394:	89 74 24 04          	mov    %esi,0x4(%esp)
  802398:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80239c:	e9 18 ff ff ff       	jmp    8022b9 <__umoddi3+0x69>
