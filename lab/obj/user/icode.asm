
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
  80003e:	c7 05 00 30 80 00 80 	movl   $0x802480,0x803000
  800045:	24 80 00 

	cprintf("icode startup\n");
  800048:	68 86 24 80 00       	push   $0x802486
  80004d:	e8 1b 02 00 00       	call   80026d <cprintf>

	cprintf("icode: open /motd\n");
  800052:	c7 04 24 95 24 80 00 	movl   $0x802495,(%esp)
  800059:	e8 0f 02 00 00       	call   80026d <cprintf>
	if ((fd = open("/motd", O_RDONLY)) < 0)
  80005e:	83 c4 08             	add    $0x8,%esp
  800061:	6a 00                	push   $0x0
  800063:	68 a8 24 80 00       	push   $0x8024a8
  800068:	e8 d3 14 00 00       	call   801540 <open>
  80006d:	89 c6                	mov    %eax,%esi
  80006f:	83 c4 10             	add    $0x10,%esp
  800072:	85 c0                	test   %eax,%eax
  800074:	79 12                	jns    800088 <umain+0x55>
		panic("icode: open /motd: %e", fd);
  800076:	50                   	push   %eax
  800077:	68 ae 24 80 00       	push   $0x8024ae
  80007c:	6a 0f                	push   $0xf
  80007e:	68 c4 24 80 00       	push   $0x8024c4
  800083:	e8 0c 01 00 00       	call   800194 <_panic>

	cprintf("icode: read /motd\n");
  800088:	83 ec 0c             	sub    $0xc,%esp
  80008b:	68 d1 24 80 00       	push   $0x8024d1
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
  8000c6:	68 e4 24 80 00       	push   $0x8024e4
  8000cb:	e8 9d 01 00 00       	call   80026d <cprintf>
	close(fd);
  8000d0:	89 34 24             	mov    %esi,(%esp)
  8000d3:	e8 ae 0e 00 00       	call   800f86 <close>

	cprintf("icode: spawn /init\n");
  8000d8:	c7 04 24 f8 24 80 00 	movl   $0x8024f8,(%esp)
  8000df:	e8 89 01 00 00       	call   80026d <cprintf>
	if ((r = spawnl("/init", "init", "initarg1", "initarg2", (char*)0)) < 0)
  8000e4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000eb:	68 0c 25 80 00       	push   $0x80250c
  8000f0:	68 15 25 80 00       	push   $0x802515
  8000f5:	68 1f 25 80 00       	push   $0x80251f
  8000fa:	68 1e 25 80 00       	push   $0x80251e
  8000ff:	e8 5d 1a 00 00       	call   801b61 <spawnl>
  800104:	83 c4 20             	add    $0x20,%esp
  800107:	85 c0                	test   %eax,%eax
  800109:	79 12                	jns    80011d <umain+0xea>
		panic("icode: spawn /init: %e", r);
  80010b:	50                   	push   %eax
  80010c:	68 24 25 80 00       	push   $0x802524
  800111:	6a 1a                	push   $0x1a
  800113:	68 c4 24 80 00       	push   $0x8024c4
  800118:	e8 77 00 00 00       	call   800194 <_panic>

	cprintf("icode: exiting\n");
  80011d:	83 ec 0c             	sub    $0xc,%esp
  800120:	68 3b 25 80 00       	push   $0x80253b
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
  8001b2:	68 58 25 80 00       	push   $0x802558
  8001b7:	e8 b1 00 00 00       	call   80026d <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001bc:	83 c4 18             	add    $0x18,%esp
  8001bf:	53                   	push   %ebx
  8001c0:	ff 75 10             	pushl  0x10(%ebp)
  8001c3:	e8 54 00 00 00       	call   80021c <vcprintf>
	cprintf("\n");
  8001c8:	c7 04 24 38 2a 80 00 	movl   $0x802a38,(%esp)
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
  8002d0:	e8 1b 1f 00 00       	call   8021f0 <__udivdi3>
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
  800313:	e8 08 20 00 00       	call   802320 <__umoddi3>
  800318:	83 c4 14             	add    $0x14,%esp
  80031b:	0f be 80 7b 25 80 00 	movsbl 0x80257b(%eax),%eax
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
  800417:	ff 24 85 c0 26 80 00 	jmp    *0x8026c0(,%eax,4)
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
  8004db:	8b 14 85 20 28 80 00 	mov    0x802820(,%eax,4),%edx
  8004e2:	85 d2                	test   %edx,%edx
  8004e4:	75 18                	jne    8004fe <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8004e6:	50                   	push   %eax
  8004e7:	68 93 25 80 00       	push   $0x802593
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
  8004ff:	68 51 29 80 00       	push   $0x802951
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
  800523:	b8 8c 25 80 00       	mov    $0x80258c,%eax
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
  800b9e:	68 7f 28 80 00       	push   $0x80287f
  800ba3:	6a 23                	push   $0x23
  800ba5:	68 9c 28 80 00       	push   $0x80289c
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
  800c1f:	68 7f 28 80 00       	push   $0x80287f
  800c24:	6a 23                	push   $0x23
  800c26:	68 9c 28 80 00       	push   $0x80289c
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
  800c61:	68 7f 28 80 00       	push   $0x80287f
  800c66:	6a 23                	push   $0x23
  800c68:	68 9c 28 80 00       	push   $0x80289c
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
  800ca3:	68 7f 28 80 00       	push   $0x80287f
  800ca8:	6a 23                	push   $0x23
  800caa:	68 9c 28 80 00       	push   $0x80289c
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
  800ce5:	68 7f 28 80 00       	push   $0x80287f
  800cea:	6a 23                	push   $0x23
  800cec:	68 9c 28 80 00       	push   $0x80289c
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
  800d27:	68 7f 28 80 00       	push   $0x80287f
  800d2c:	6a 23                	push   $0x23
  800d2e:	68 9c 28 80 00       	push   $0x80289c
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
  800d69:	68 7f 28 80 00       	push   $0x80287f
  800d6e:	6a 23                	push   $0x23
  800d70:	68 9c 28 80 00       	push   $0x80289c
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
  800dcd:	68 7f 28 80 00       	push   $0x80287f
  800dd2:	6a 23                	push   $0x23
  800dd4:	68 9c 28 80 00       	push   $0x80289c
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
  800ebb:	ba 28 29 80 00       	mov    $0x802928,%edx
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
  800ee8:	68 ac 28 80 00       	push   $0x8028ac
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
  801112:	68 ed 28 80 00       	push   $0x8028ed
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
  8011e7:	68 09 29 80 00       	push   $0x802909
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
  80129c:	68 cc 28 80 00       	push   $0x8028cc
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
  801365:	e8 d6 01 00 00       	call   801540 <open>
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
  8013ac:	e8 bd 0d 00 00       	call   80216e <ipc_find_env>
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
  8013c7:	e8 4e 0d 00 00       	call   80211a <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8013cc:	83 c4 0c             	add    $0xc,%esp
  8013cf:	6a 00                	push   $0x0
  8013d1:	53                   	push   %ebx
  8013d2:	6a 00                	push   $0x0
  8013d4:	e8 da 0c 00 00       	call   8020b3 <ipc_recv>
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
  80148b:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	// panic("devfile_write not implemented");

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  80148e:	8b 55 08             	mov    0x8(%ebp),%edx
  801491:	8b 52 0c             	mov    0xc(%edx),%edx
  801494:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  80149a:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  80149f:	50                   	push   %eax
  8014a0:	ff 75 0c             	pushl  0xc(%ebp)
  8014a3:	68 08 50 80 00       	push   $0x805008
  8014a8:	e8 d7 f4 ff ff       	call   800984 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  8014ad:	ba 00 00 00 00       	mov    $0x0,%edx
  8014b2:	b8 04 00 00 00       	mov    $0x4,%eax
  8014b7:	e8 d9 fe ff ff       	call   801395 <fsipc>

}
  8014bc:	c9                   	leave  
  8014bd:	c3                   	ret    

008014be <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8014be:	55                   	push   %ebp
  8014bf:	89 e5                	mov    %esp,%ebp
  8014c1:	56                   	push   %esi
  8014c2:	53                   	push   %ebx
  8014c3:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8014c6:	8b 45 08             	mov    0x8(%ebp),%eax
  8014c9:	8b 40 0c             	mov    0xc(%eax),%eax
  8014cc:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8014d1:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8014d7:	ba 00 00 00 00       	mov    $0x0,%edx
  8014dc:	b8 03 00 00 00       	mov    $0x3,%eax
  8014e1:	e8 af fe ff ff       	call   801395 <fsipc>
  8014e6:	89 c3                	mov    %eax,%ebx
  8014e8:	85 c0                	test   %eax,%eax
  8014ea:	78 4b                	js     801537 <devfile_read+0x79>
		return r;
	assert(r <= n);
  8014ec:	39 c6                	cmp    %eax,%esi
  8014ee:	73 16                	jae    801506 <devfile_read+0x48>
  8014f0:	68 38 29 80 00       	push   $0x802938
  8014f5:	68 3f 29 80 00       	push   $0x80293f
  8014fa:	6a 7c                	push   $0x7c
  8014fc:	68 54 29 80 00       	push   $0x802954
  801501:	e8 8e ec ff ff       	call   800194 <_panic>
	assert(r <= PGSIZE);
  801506:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80150b:	7e 16                	jle    801523 <devfile_read+0x65>
  80150d:	68 5f 29 80 00       	push   $0x80295f
  801512:	68 3f 29 80 00       	push   $0x80293f
  801517:	6a 7d                	push   $0x7d
  801519:	68 54 29 80 00       	push   $0x802954
  80151e:	e8 71 ec ff ff       	call   800194 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801523:	83 ec 04             	sub    $0x4,%esp
  801526:	50                   	push   %eax
  801527:	68 00 50 80 00       	push   $0x805000
  80152c:	ff 75 0c             	pushl  0xc(%ebp)
  80152f:	e8 50 f4 ff ff       	call   800984 <memmove>
	return r;
  801534:	83 c4 10             	add    $0x10,%esp
}
  801537:	89 d8                	mov    %ebx,%eax
  801539:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80153c:	5b                   	pop    %ebx
  80153d:	5e                   	pop    %esi
  80153e:	5d                   	pop    %ebp
  80153f:	c3                   	ret    

00801540 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801540:	55                   	push   %ebp
  801541:	89 e5                	mov    %esp,%ebp
  801543:	53                   	push   %ebx
  801544:	83 ec 20             	sub    $0x20,%esp
  801547:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  80154a:	53                   	push   %ebx
  80154b:	e8 69 f2 ff ff       	call   8007b9 <strlen>
  801550:	83 c4 10             	add    $0x10,%esp
  801553:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801558:	7f 67                	jg     8015c1 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80155a:	83 ec 0c             	sub    $0xc,%esp
  80155d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801560:	50                   	push   %eax
  801561:	e8 a7 f8 ff ff       	call   800e0d <fd_alloc>
  801566:	83 c4 10             	add    $0x10,%esp
		return r;
  801569:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80156b:	85 c0                	test   %eax,%eax
  80156d:	78 57                	js     8015c6 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  80156f:	83 ec 08             	sub    $0x8,%esp
  801572:	53                   	push   %ebx
  801573:	68 00 50 80 00       	push   $0x805000
  801578:	e8 75 f2 ff ff       	call   8007f2 <strcpy>
	fsipcbuf.open.req_omode = mode;
  80157d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801580:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801585:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801588:	b8 01 00 00 00       	mov    $0x1,%eax
  80158d:	e8 03 fe ff ff       	call   801395 <fsipc>
  801592:	89 c3                	mov    %eax,%ebx
  801594:	83 c4 10             	add    $0x10,%esp
  801597:	85 c0                	test   %eax,%eax
  801599:	79 14                	jns    8015af <open+0x6f>
		fd_close(fd, 0);
  80159b:	83 ec 08             	sub    $0x8,%esp
  80159e:	6a 00                	push   $0x0
  8015a0:	ff 75 f4             	pushl  -0xc(%ebp)
  8015a3:	e8 5d f9 ff ff       	call   800f05 <fd_close>
		return r;
  8015a8:	83 c4 10             	add    $0x10,%esp
  8015ab:	89 da                	mov    %ebx,%edx
  8015ad:	eb 17                	jmp    8015c6 <open+0x86>
	}

	return fd2num(fd);
  8015af:	83 ec 0c             	sub    $0xc,%esp
  8015b2:	ff 75 f4             	pushl  -0xc(%ebp)
  8015b5:	e8 2c f8 ff ff       	call   800de6 <fd2num>
  8015ba:	89 c2                	mov    %eax,%edx
  8015bc:	83 c4 10             	add    $0x10,%esp
  8015bf:	eb 05                	jmp    8015c6 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8015c1:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8015c6:	89 d0                	mov    %edx,%eax
  8015c8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015cb:	c9                   	leave  
  8015cc:	c3                   	ret    

008015cd <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8015cd:	55                   	push   %ebp
  8015ce:	89 e5                	mov    %esp,%ebp
  8015d0:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8015d3:	ba 00 00 00 00       	mov    $0x0,%edx
  8015d8:	b8 08 00 00 00       	mov    $0x8,%eax
  8015dd:	e8 b3 fd ff ff       	call   801395 <fsipc>
}
  8015e2:	c9                   	leave  
  8015e3:	c3                   	ret    

008015e4 <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  8015e4:	55                   	push   %ebp
  8015e5:	89 e5                	mov    %esp,%ebp
  8015e7:	57                   	push   %edi
  8015e8:	56                   	push   %esi
  8015e9:	53                   	push   %ebx
  8015ea:	81 ec 94 02 00 00    	sub    $0x294,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  8015f0:	6a 00                	push   $0x0
  8015f2:	ff 75 08             	pushl  0x8(%ebp)
  8015f5:	e8 46 ff ff ff       	call   801540 <open>
  8015fa:	89 c7                	mov    %eax,%edi
  8015fc:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  801602:	83 c4 10             	add    $0x10,%esp
  801605:	85 c0                	test   %eax,%eax
  801607:	0f 88 97 04 00 00    	js     801aa4 <spawn+0x4c0>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  80160d:	83 ec 04             	sub    $0x4,%esp
  801610:	68 00 02 00 00       	push   $0x200
  801615:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  80161b:	50                   	push   %eax
  80161c:	57                   	push   %edi
  80161d:	e8 31 fb ff ff       	call   801153 <readn>
  801622:	83 c4 10             	add    $0x10,%esp
  801625:	3d 00 02 00 00       	cmp    $0x200,%eax
  80162a:	75 0c                	jne    801638 <spawn+0x54>
	    || elf->e_magic != ELF_MAGIC) {
  80162c:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  801633:	45 4c 46 
  801636:	74 33                	je     80166b <spawn+0x87>
		close(fd);
  801638:	83 ec 0c             	sub    $0xc,%esp
  80163b:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801641:	e8 40 f9 ff ff       	call   800f86 <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  801646:	83 c4 0c             	add    $0xc,%esp
  801649:	68 7f 45 4c 46       	push   $0x464c457f
  80164e:	ff b5 e8 fd ff ff    	pushl  -0x218(%ebp)
  801654:	68 6b 29 80 00       	push   $0x80296b
  801659:	e8 0f ec ff ff       	call   80026d <cprintf>
		return -E_NOT_EXEC;
  80165e:	83 c4 10             	add    $0x10,%esp
  801661:	bb f2 ff ff ff       	mov    $0xfffffff2,%ebx
  801666:	e9 ec 04 00 00       	jmp    801b57 <spawn+0x573>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  80166b:	b8 07 00 00 00       	mov    $0x7,%eax
  801670:	cd 30                	int    $0x30
  801672:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
  801678:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  80167e:	85 c0                	test   %eax,%eax
  801680:	0f 88 29 04 00 00    	js     801aaf <spawn+0x4cb>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  801686:	89 c6                	mov    %eax,%esi
  801688:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  80168e:	6b f6 7c             	imul   $0x7c,%esi,%esi
  801691:	81 c6 00 00 c0 ee    	add    $0xeec00000,%esi
  801697:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  80169d:	b9 11 00 00 00       	mov    $0x11,%ecx
  8016a2:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  8016a4:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  8016aa:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  8016b0:	bb 00 00 00 00       	mov    $0x0,%ebx
	char *string_store;
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
  8016b5:	be 00 00 00 00       	mov    $0x0,%esi
  8016ba:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8016bd:	eb 13                	jmp    8016d2 <spawn+0xee>
	for (argc = 0; argv[argc] != 0; argc++)
		string_size += strlen(argv[argc]) + 1;
  8016bf:	83 ec 0c             	sub    $0xc,%esp
  8016c2:	50                   	push   %eax
  8016c3:	e8 f1 f0 ff ff       	call   8007b9 <strlen>
  8016c8:	8d 74 30 01          	lea    0x1(%eax,%esi,1),%esi
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  8016cc:	83 c3 01             	add    $0x1,%ebx
  8016cf:	83 c4 10             	add    $0x10,%esp
  8016d2:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
  8016d9:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  8016dc:	85 c0                	test   %eax,%eax
  8016de:	75 df                	jne    8016bf <spawn+0xdb>
  8016e0:	89 9d 88 fd ff ff    	mov    %ebx,-0x278(%ebp)
  8016e6:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  8016ec:	bf 00 10 40 00       	mov    $0x401000,%edi
  8016f1:	29 f7                	sub    %esi,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  8016f3:	89 fa                	mov    %edi,%edx
  8016f5:	83 e2 fc             	and    $0xfffffffc,%edx
  8016f8:	8d 04 9d 04 00 00 00 	lea    0x4(,%ebx,4),%eax
  8016ff:	29 c2                	sub    %eax,%edx
  801701:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  801707:	8d 42 f8             	lea    -0x8(%edx),%eax
  80170a:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  80170f:	0f 86 b0 03 00 00    	jbe    801ac5 <spawn+0x4e1>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801715:	83 ec 04             	sub    $0x4,%esp
  801718:	6a 07                	push   $0x7
  80171a:	68 00 00 40 00       	push   $0x400000
  80171f:	6a 00                	push   $0x0
  801721:	e8 cf f4 ff ff       	call   800bf5 <sys_page_alloc>
  801726:	83 c4 10             	add    $0x10,%esp
  801729:	85 c0                	test   %eax,%eax
  80172b:	0f 88 9e 03 00 00    	js     801acf <spawn+0x4eb>
  801731:	be 00 00 00 00       	mov    $0x0,%esi
  801736:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
  80173c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80173f:	eb 30                	jmp    801771 <spawn+0x18d>
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
		argv_store[i] = UTEMP2USTACK(string_store);
  801741:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  801747:	8b 8d 94 fd ff ff    	mov    -0x26c(%ebp),%ecx
  80174d:	89 04 b1             	mov    %eax,(%ecx,%esi,4)
		strcpy(string_store, argv[i]);
  801750:	83 ec 08             	sub    $0x8,%esp
  801753:	ff 34 b3             	pushl  (%ebx,%esi,4)
  801756:	57                   	push   %edi
  801757:	e8 96 f0 ff ff       	call   8007f2 <strcpy>
		string_store += strlen(argv[i]) + 1;
  80175c:	83 c4 04             	add    $0x4,%esp
  80175f:	ff 34 b3             	pushl  (%ebx,%esi,4)
  801762:	e8 52 f0 ff ff       	call   8007b9 <strlen>
  801767:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  80176b:	83 c6 01             	add    $0x1,%esi
  80176e:	83 c4 10             	add    $0x10,%esp
  801771:	39 b5 90 fd ff ff    	cmp    %esi,-0x270(%ebp)
  801777:	7f c8                	jg     801741 <spawn+0x15d>
		argv_store[i] = UTEMP2USTACK(string_store);
		strcpy(string_store, argv[i]);
		string_store += strlen(argv[i]) + 1;
	}
	argv_store[argc] = 0;
  801779:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  80177f:	8b b5 80 fd ff ff    	mov    -0x280(%ebp),%esi
  801785:	c7 04 30 00 00 00 00 	movl   $0x0,(%eax,%esi,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  80178c:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  801792:	74 19                	je     8017ad <spawn+0x1c9>
  801794:	68 f8 29 80 00       	push   $0x8029f8
  801799:	68 3f 29 80 00       	push   $0x80293f
  80179e:	68 f2 00 00 00       	push   $0xf2
  8017a3:	68 85 29 80 00       	push   $0x802985
  8017a8:	e8 e7 e9 ff ff       	call   800194 <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  8017ad:	8b bd 94 fd ff ff    	mov    -0x26c(%ebp),%edi
  8017b3:	89 f8                	mov    %edi,%eax
  8017b5:	2d 00 30 80 11       	sub    $0x11803000,%eax
  8017ba:	89 47 fc             	mov    %eax,-0x4(%edi)
	argv_store[-2] = argc;
  8017bd:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  8017c3:	89 47 f8             	mov    %eax,-0x8(%edi)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  8017c6:	8d 87 f8 cf 7f ee    	lea    -0x11803008(%edi),%eax
  8017cc:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  8017d2:	83 ec 0c             	sub    $0xc,%esp
  8017d5:	6a 07                	push   $0x7
  8017d7:	68 00 d0 bf ee       	push   $0xeebfd000
  8017dc:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  8017e2:	68 00 00 40 00       	push   $0x400000
  8017e7:	6a 00                	push   $0x0
  8017e9:	e8 4a f4 ff ff       	call   800c38 <sys_page_map>
  8017ee:	89 c3                	mov    %eax,%ebx
  8017f0:	83 c4 20             	add    $0x20,%esp
  8017f3:	85 c0                	test   %eax,%eax
  8017f5:	0f 88 4a 03 00 00    	js     801b45 <spawn+0x561>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  8017fb:	83 ec 08             	sub    $0x8,%esp
  8017fe:	68 00 00 40 00       	push   $0x400000
  801803:	6a 00                	push   $0x0
  801805:	e8 70 f4 ff ff       	call   800c7a <sys_page_unmap>
  80180a:	89 c3                	mov    %eax,%ebx
  80180c:	83 c4 10             	add    $0x10,%esp
  80180f:	85 c0                	test   %eax,%eax
  801811:	0f 88 2e 03 00 00    	js     801b45 <spawn+0x561>

	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  801817:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
  80181d:	8d 84 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%eax
  801824:	89 85 7c fd ff ff    	mov    %eax,-0x284(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  80182a:	c7 85 78 fd ff ff 00 	movl   $0x0,-0x288(%ebp)
  801831:	00 00 00 
  801834:	e9 8a 01 00 00       	jmp    8019c3 <spawn+0x3df>
		if (ph->p_type != ELF_PROG_LOAD)
  801839:	8b 85 7c fd ff ff    	mov    -0x284(%ebp),%eax
  80183f:	83 38 01             	cmpl   $0x1,(%eax)
  801842:	0f 85 6d 01 00 00    	jne    8019b5 <spawn+0x3d1>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  801848:	89 c7                	mov    %eax,%edi
  80184a:	8b 40 18             	mov    0x18(%eax),%eax
  80184d:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  801853:	83 e0 02             	and    $0x2,%eax
			perm |= PTE_W;
  801856:	83 f8 01             	cmp    $0x1,%eax
  801859:	19 c0                	sbb    %eax,%eax
  80185b:	83 e0 fe             	and    $0xfffffffe,%eax
  80185e:	83 c0 07             	add    $0x7,%eax
  801861:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  801867:	89 f8                	mov    %edi,%eax
  801869:	8b 7f 04             	mov    0x4(%edi),%edi
  80186c:	89 f9                	mov    %edi,%ecx
  80186e:	89 bd 80 fd ff ff    	mov    %edi,-0x280(%ebp)
  801874:	8b 78 10             	mov    0x10(%eax),%edi
  801877:	8b 70 14             	mov    0x14(%eax),%esi
  80187a:	89 f3                	mov    %esi,%ebx
  80187c:	89 b5 90 fd ff ff    	mov    %esi,-0x270(%ebp)
  801882:	8b 70 08             	mov    0x8(%eax),%esi
	int i, r;
	void *blk;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  801885:	89 f0                	mov    %esi,%eax
  801887:	25 ff 0f 00 00       	and    $0xfff,%eax
  80188c:	74 14                	je     8018a2 <spawn+0x2be>
		va -= i;
  80188e:	29 c6                	sub    %eax,%esi
		memsz += i;
  801890:	01 c3                	add    %eax,%ebx
  801892:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
		filesz += i;
  801898:	01 c7                	add    %eax,%edi
		fileoffset -= i;
  80189a:	29 c1                	sub    %eax,%ecx
  80189c:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  8018a2:	bb 00 00 00 00       	mov    $0x0,%ebx
  8018a7:	e9 f7 00 00 00       	jmp    8019a3 <spawn+0x3bf>
		if (i >= filesz) {
  8018ac:	39 df                	cmp    %ebx,%edi
  8018ae:	77 27                	ja     8018d7 <spawn+0x2f3>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  8018b0:	83 ec 04             	sub    $0x4,%esp
  8018b3:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  8018b9:	56                   	push   %esi
  8018ba:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  8018c0:	e8 30 f3 ff ff       	call   800bf5 <sys_page_alloc>
  8018c5:	83 c4 10             	add    $0x10,%esp
  8018c8:	85 c0                	test   %eax,%eax
  8018ca:	0f 89 c7 00 00 00    	jns    801997 <spawn+0x3b3>
  8018d0:	89 c3                	mov    %eax,%ebx
  8018d2:	e9 09 02 00 00       	jmp    801ae0 <spawn+0x4fc>
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  8018d7:	83 ec 04             	sub    $0x4,%esp
  8018da:	6a 07                	push   $0x7
  8018dc:	68 00 00 40 00       	push   $0x400000
  8018e1:	6a 00                	push   $0x0
  8018e3:	e8 0d f3 ff ff       	call   800bf5 <sys_page_alloc>
  8018e8:	83 c4 10             	add    $0x10,%esp
  8018eb:	85 c0                	test   %eax,%eax
  8018ed:	0f 88 e3 01 00 00    	js     801ad6 <spawn+0x4f2>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  8018f3:	83 ec 08             	sub    $0x8,%esp
  8018f6:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  8018fc:	03 85 94 fd ff ff    	add    -0x26c(%ebp),%eax
  801902:	50                   	push   %eax
  801903:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801909:	e8 1a f9 ff ff       	call   801228 <seek>
  80190e:	83 c4 10             	add    $0x10,%esp
  801911:	85 c0                	test   %eax,%eax
  801913:	0f 88 c1 01 00 00    	js     801ada <spawn+0x4f6>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801919:	83 ec 04             	sub    $0x4,%esp
  80191c:	89 f8                	mov    %edi,%eax
  80191e:	2b 85 94 fd ff ff    	sub    -0x26c(%ebp),%eax
  801924:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801929:	b9 00 10 00 00       	mov    $0x1000,%ecx
  80192e:	0f 47 c1             	cmova  %ecx,%eax
  801931:	50                   	push   %eax
  801932:	68 00 00 40 00       	push   $0x400000
  801937:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  80193d:	e8 11 f8 ff ff       	call   801153 <readn>
  801942:	83 c4 10             	add    $0x10,%esp
  801945:	85 c0                	test   %eax,%eax
  801947:	0f 88 91 01 00 00    	js     801ade <spawn+0x4fa>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  80194d:	83 ec 0c             	sub    $0xc,%esp
  801950:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  801956:	56                   	push   %esi
  801957:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  80195d:	68 00 00 40 00       	push   $0x400000
  801962:	6a 00                	push   $0x0
  801964:	e8 cf f2 ff ff       	call   800c38 <sys_page_map>
  801969:	83 c4 20             	add    $0x20,%esp
  80196c:	85 c0                	test   %eax,%eax
  80196e:	79 15                	jns    801985 <spawn+0x3a1>
				panic("spawn: sys_page_map data: %e", r);
  801970:	50                   	push   %eax
  801971:	68 91 29 80 00       	push   $0x802991
  801976:	68 25 01 00 00       	push   $0x125
  80197b:	68 85 29 80 00       	push   $0x802985
  801980:	e8 0f e8 ff ff       	call   800194 <_panic>
			sys_page_unmap(0, UTEMP);
  801985:	83 ec 08             	sub    $0x8,%esp
  801988:	68 00 00 40 00       	push   $0x400000
  80198d:	6a 00                	push   $0x0
  80198f:	e8 e6 f2 ff ff       	call   800c7a <sys_page_unmap>
  801994:	83 c4 10             	add    $0x10,%esp
		memsz += i;
		filesz += i;
		fileoffset -= i;
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801997:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  80199d:	81 c6 00 10 00 00    	add    $0x1000,%esi
  8019a3:	89 9d 94 fd ff ff    	mov    %ebx,-0x26c(%ebp)
  8019a9:	39 9d 90 fd ff ff    	cmp    %ebx,-0x270(%ebp)
  8019af:	0f 87 f7 fe ff ff    	ja     8018ac <spawn+0x2c8>
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  8019b5:	83 85 78 fd ff ff 01 	addl   $0x1,-0x288(%ebp)
  8019bc:	83 85 7c fd ff ff 20 	addl   $0x20,-0x284(%ebp)
  8019c3:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  8019ca:	39 85 78 fd ff ff    	cmp    %eax,-0x288(%ebp)
  8019d0:	0f 8c 63 fe ff ff    	jl     801839 <spawn+0x255>
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
	}
	close(fd);
  8019d6:	83 ec 0c             	sub    $0xc,%esp
  8019d9:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  8019df:	e8 a2 f5 ff ff       	call   800f86 <close>
  8019e4:	83 c4 10             	add    $0x10,%esp
{
	// LAB 5: Your code here.

	int r;
	uint32_t addr;
	for (uint32_t pn = PGNUM(UTEXT); pn < PGNUM(USTACKTOP); pn++) {
  8019e7:	bb 00 08 00 00       	mov    $0x800,%ebx
  8019ec:	8b b5 84 fd ff ff    	mov    -0x27c(%ebp),%esi

		addr = pn * PGSIZE;
  8019f2:	89 d8                	mov    %ebx,%eax
  8019f4:	c1 e0 0c             	shl    $0xc,%eax

		// if level-2 page exists
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P) {
  8019f7:	89 c2                	mov    %eax,%edx
  8019f9:	c1 ea 16             	shr    $0x16,%edx
  8019fc:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801a03:	f6 c2 01             	test   $0x1,%dl
  801a06:	74 4b                	je     801a53 <spawn+0x46f>
			
			// if real PTE exists
			if ((uvpt[PGNUM(addr)] & PTE_P) == PTE_P) {
  801a08:	89 c2                	mov    %eax,%edx
  801a0a:	c1 ea 0c             	shr    $0xc,%edx
  801a0d:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
  801a14:	f6 c1 01             	test   $0x1,%cl
  801a17:	74 3a                	je     801a53 <spawn+0x46f>

				// For each writable or copy-on-write page
				if ((uvpt[PGNUM(addr)] & PTE_SHARE) != 0) {
  801a19:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801a20:	f6 c6 04             	test   $0x4,%dh
  801a23:	74 2e                	je     801a53 <spawn+0x46f>
					r = sys_page_map(thisenv->env_id, (void *)addr, child, (void *)addr, uvpt[pn] & PTE_SYSCALL);
  801a25:	8b 14 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%edx
  801a2c:	8b 0d 04 40 80 00    	mov    0x804004,%ecx
  801a32:	8b 49 48             	mov    0x48(%ecx),%ecx
  801a35:	83 ec 0c             	sub    $0xc,%esp
  801a38:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801a3e:	52                   	push   %edx
  801a3f:	50                   	push   %eax
  801a40:	56                   	push   %esi
  801a41:	50                   	push   %eax
  801a42:	51                   	push   %ecx
  801a43:	e8 f0 f1 ff ff       	call   800c38 <sys_page_map>
					if (r < 0)
  801a48:	83 c4 20             	add    $0x20,%esp
  801a4b:	85 c0                	test   %eax,%eax
  801a4d:	0f 88 ae 00 00 00    	js     801b01 <spawn+0x51d>
{
	// LAB 5: Your code here.

	int r;
	uint32_t addr;
	for (uint32_t pn = PGNUM(UTEXT); pn < PGNUM(USTACKTOP); pn++) {
  801a53:	83 c3 01             	add    $0x1,%ebx
  801a56:	81 fb fe eb 0e 00    	cmp    $0xeebfe,%ebx
  801a5c:	75 94                	jne    8019f2 <spawn+0x40e>
  801a5e:	e9 b3 00 00 00       	jmp    801b16 <spawn+0x532>
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	child_tf.tf_eflags |= FL_IOPL_3;   // devious: see user/faultio.c
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
		panic("sys_env_set_trapframe: %e", r);
  801a63:	50                   	push   %eax
  801a64:	68 ae 29 80 00       	push   $0x8029ae
  801a69:	68 86 00 00 00       	push   $0x86
  801a6e:	68 85 29 80 00       	push   $0x802985
  801a73:	e8 1c e7 ff ff       	call   800194 <_panic>

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  801a78:	83 ec 08             	sub    $0x8,%esp
  801a7b:	6a 02                	push   $0x2
  801a7d:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801a83:	e8 34 f2 ff ff       	call   800cbc <sys_env_set_status>
  801a88:	83 c4 10             	add    $0x10,%esp
  801a8b:	85 c0                	test   %eax,%eax
  801a8d:	79 2b                	jns    801aba <spawn+0x4d6>
		panic("sys_env_set_status: %e", r);
  801a8f:	50                   	push   %eax
  801a90:	68 c8 29 80 00       	push   $0x8029c8
  801a95:	68 89 00 00 00       	push   $0x89
  801a9a:	68 85 29 80 00       	push   $0x802985
  801a9f:	e8 f0 e6 ff ff       	call   800194 <_panic>
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
		return r;
  801aa4:	8b 9d 8c fd ff ff    	mov    -0x274(%ebp),%ebx
  801aaa:	e9 a8 00 00 00       	jmp    801b57 <spawn+0x573>
		return -E_NOT_EXEC;
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
		return r;
  801aaf:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  801ab5:	e9 9d 00 00 00       	jmp    801b57 <spawn+0x573>
		panic("sys_env_set_trapframe: %e", r);

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
		panic("sys_env_set_status: %e", r);

	return child;
  801aba:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  801ac0:	e9 92 00 00 00       	jmp    801b57 <spawn+0x573>
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
		return -E_NO_MEM;
  801ac5:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
  801aca:	e9 88 00 00 00       	jmp    801b57 <spawn+0x573>

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
		return r;
  801acf:	89 c3                	mov    %eax,%ebx
  801ad1:	e9 81 00 00 00       	jmp    801b57 <spawn+0x573>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801ad6:	89 c3                	mov    %eax,%ebx
  801ad8:	eb 06                	jmp    801ae0 <spawn+0x4fc>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801ada:	89 c3                	mov    %eax,%ebx
  801adc:	eb 02                	jmp    801ae0 <spawn+0x4fc>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801ade:	89 c3                	mov    %eax,%ebx
		panic("sys_env_set_status: %e", r);

	return child;

error:
	sys_env_destroy(child);
  801ae0:	83 ec 0c             	sub    $0xc,%esp
  801ae3:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801ae9:	e8 88 f0 ff ff       	call   800b76 <sys_env_destroy>
	close(fd);
  801aee:	83 c4 04             	add    $0x4,%esp
  801af1:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801af7:	e8 8a f4 ff ff       	call   800f86 <close>
	return r;
  801afc:	83 c4 10             	add    $0x10,%esp
  801aff:	eb 56                	jmp    801b57 <spawn+0x573>
	close(fd);
	fd = -1;

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);
  801b01:	50                   	push   %eax
  801b02:	68 df 29 80 00       	push   $0x8029df
  801b07:	68 82 00 00 00       	push   $0x82
  801b0c:	68 85 29 80 00       	push   $0x802985
  801b11:	e8 7e e6 ff ff       	call   800194 <_panic>

	child_tf.tf_eflags |= FL_IOPL_3;   // devious: see user/faultio.c
  801b16:	81 8d dc fd ff ff 00 	orl    $0x3000,-0x224(%ebp)
  801b1d:	30 00 00 
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  801b20:	83 ec 08             	sub    $0x8,%esp
  801b23:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  801b29:	50                   	push   %eax
  801b2a:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801b30:	e8 c9 f1 ff ff       	call   800cfe <sys_env_set_trapframe>
  801b35:	83 c4 10             	add    $0x10,%esp
  801b38:	85 c0                	test   %eax,%eax
  801b3a:	0f 89 38 ff ff ff    	jns    801a78 <spawn+0x494>
  801b40:	e9 1e ff ff ff       	jmp    801a63 <spawn+0x47f>
		goto error;

	return 0;

error:
	sys_page_unmap(0, UTEMP);
  801b45:	83 ec 08             	sub    $0x8,%esp
  801b48:	68 00 00 40 00       	push   $0x400000
  801b4d:	6a 00                	push   $0x0
  801b4f:	e8 26 f1 ff ff       	call   800c7a <sys_page_unmap>
  801b54:	83 c4 10             	add    $0x10,%esp

error:
	sys_env_destroy(child);
	close(fd);
	return r;
}
  801b57:	89 d8                	mov    %ebx,%eax
  801b59:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b5c:	5b                   	pop    %ebx
  801b5d:	5e                   	pop    %esi
  801b5e:	5f                   	pop    %edi
  801b5f:	5d                   	pop    %ebp
  801b60:	c3                   	ret    

00801b61 <spawnl>:
// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
{
  801b61:	55                   	push   %ebp
  801b62:	89 e5                	mov    %esp,%ebp
  801b64:	56                   	push   %esi
  801b65:	53                   	push   %ebx
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801b66:	8d 55 10             	lea    0x10(%ebp),%edx
{
	// We calculate argc by advancing the args until we hit NULL.
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
  801b69:	b8 00 00 00 00       	mov    $0x0,%eax
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801b6e:	eb 03                	jmp    801b73 <spawnl+0x12>
		argc++;
  801b70:	83 c0 01             	add    $0x1,%eax
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801b73:	83 c2 04             	add    $0x4,%edx
  801b76:	83 7a fc 00          	cmpl   $0x0,-0x4(%edx)
  801b7a:	75 f4                	jne    801b70 <spawnl+0xf>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  801b7c:	8d 14 85 1a 00 00 00 	lea    0x1a(,%eax,4),%edx
  801b83:	83 e2 f0             	and    $0xfffffff0,%edx
  801b86:	29 d4                	sub    %edx,%esp
  801b88:	8d 54 24 03          	lea    0x3(%esp),%edx
  801b8c:	c1 ea 02             	shr    $0x2,%edx
  801b8f:	8d 34 95 00 00 00 00 	lea    0x0(,%edx,4),%esi
  801b96:	89 f3                	mov    %esi,%ebx
	argv[0] = arg0;
  801b98:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b9b:	89 0c 95 00 00 00 00 	mov    %ecx,0x0(,%edx,4)
	argv[argc+1] = NULL;
  801ba2:	c7 44 86 04 00 00 00 	movl   $0x0,0x4(%esi,%eax,4)
  801ba9:	00 
  801baa:	89 c2                	mov    %eax,%edx

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  801bac:	b8 00 00 00 00       	mov    $0x0,%eax
  801bb1:	eb 0a                	jmp    801bbd <spawnl+0x5c>
		argv[i+1] = va_arg(vl, const char *);
  801bb3:	83 c0 01             	add    $0x1,%eax
  801bb6:	8b 4c 85 0c          	mov    0xc(%ebp,%eax,4),%ecx
  801bba:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  801bbd:	39 d0                	cmp    %edx,%eax
  801bbf:	75 f2                	jne    801bb3 <spawnl+0x52>
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return spawn(prog, argv);
  801bc1:	83 ec 08             	sub    $0x8,%esp
  801bc4:	56                   	push   %esi
  801bc5:	ff 75 08             	pushl  0x8(%ebp)
  801bc8:	e8 17 fa ff ff       	call   8015e4 <spawn>
}
  801bcd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801bd0:	5b                   	pop    %ebx
  801bd1:	5e                   	pop    %esi
  801bd2:	5d                   	pop    %ebp
  801bd3:	c3                   	ret    

00801bd4 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801bd4:	55                   	push   %ebp
  801bd5:	89 e5                	mov    %esp,%ebp
  801bd7:	56                   	push   %esi
  801bd8:	53                   	push   %ebx
  801bd9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801bdc:	83 ec 0c             	sub    $0xc,%esp
  801bdf:	ff 75 08             	pushl  0x8(%ebp)
  801be2:	e8 0f f2 ff ff       	call   800df6 <fd2data>
  801be7:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801be9:	83 c4 08             	add    $0x8,%esp
  801bec:	68 20 2a 80 00       	push   $0x802a20
  801bf1:	53                   	push   %ebx
  801bf2:	e8 fb eb ff ff       	call   8007f2 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801bf7:	8b 46 04             	mov    0x4(%esi),%eax
  801bfa:	2b 06                	sub    (%esi),%eax
  801bfc:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801c02:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801c09:	00 00 00 
	stat->st_dev = &devpipe;
  801c0c:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801c13:	30 80 00 
	return 0;
}
  801c16:	b8 00 00 00 00       	mov    $0x0,%eax
  801c1b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c1e:	5b                   	pop    %ebx
  801c1f:	5e                   	pop    %esi
  801c20:	5d                   	pop    %ebp
  801c21:	c3                   	ret    

00801c22 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801c22:	55                   	push   %ebp
  801c23:	89 e5                	mov    %esp,%ebp
  801c25:	53                   	push   %ebx
  801c26:	83 ec 0c             	sub    $0xc,%esp
  801c29:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801c2c:	53                   	push   %ebx
  801c2d:	6a 00                	push   $0x0
  801c2f:	e8 46 f0 ff ff       	call   800c7a <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801c34:	89 1c 24             	mov    %ebx,(%esp)
  801c37:	e8 ba f1 ff ff       	call   800df6 <fd2data>
  801c3c:	83 c4 08             	add    $0x8,%esp
  801c3f:	50                   	push   %eax
  801c40:	6a 00                	push   $0x0
  801c42:	e8 33 f0 ff ff       	call   800c7a <sys_page_unmap>
}
  801c47:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c4a:	c9                   	leave  
  801c4b:	c3                   	ret    

00801c4c <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801c4c:	55                   	push   %ebp
  801c4d:	89 e5                	mov    %esp,%ebp
  801c4f:	57                   	push   %edi
  801c50:	56                   	push   %esi
  801c51:	53                   	push   %ebx
  801c52:	83 ec 1c             	sub    $0x1c,%esp
  801c55:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801c58:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801c5a:	a1 04 40 80 00       	mov    0x804004,%eax
  801c5f:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801c62:	83 ec 0c             	sub    $0xc,%esp
  801c65:	ff 75 e0             	pushl  -0x20(%ebp)
  801c68:	e8 3a 05 00 00       	call   8021a7 <pageref>
  801c6d:	89 c3                	mov    %eax,%ebx
  801c6f:	89 3c 24             	mov    %edi,(%esp)
  801c72:	e8 30 05 00 00       	call   8021a7 <pageref>
  801c77:	83 c4 10             	add    $0x10,%esp
  801c7a:	39 c3                	cmp    %eax,%ebx
  801c7c:	0f 94 c1             	sete   %cl
  801c7f:	0f b6 c9             	movzbl %cl,%ecx
  801c82:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801c85:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801c8b:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801c8e:	39 ce                	cmp    %ecx,%esi
  801c90:	74 1b                	je     801cad <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801c92:	39 c3                	cmp    %eax,%ebx
  801c94:	75 c4                	jne    801c5a <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801c96:	8b 42 58             	mov    0x58(%edx),%eax
  801c99:	ff 75 e4             	pushl  -0x1c(%ebp)
  801c9c:	50                   	push   %eax
  801c9d:	56                   	push   %esi
  801c9e:	68 27 2a 80 00       	push   $0x802a27
  801ca3:	e8 c5 e5 ff ff       	call   80026d <cprintf>
  801ca8:	83 c4 10             	add    $0x10,%esp
  801cab:	eb ad                	jmp    801c5a <_pipeisclosed+0xe>
	}
}
  801cad:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801cb0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801cb3:	5b                   	pop    %ebx
  801cb4:	5e                   	pop    %esi
  801cb5:	5f                   	pop    %edi
  801cb6:	5d                   	pop    %ebp
  801cb7:	c3                   	ret    

00801cb8 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801cb8:	55                   	push   %ebp
  801cb9:	89 e5                	mov    %esp,%ebp
  801cbb:	57                   	push   %edi
  801cbc:	56                   	push   %esi
  801cbd:	53                   	push   %ebx
  801cbe:	83 ec 28             	sub    $0x28,%esp
  801cc1:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801cc4:	56                   	push   %esi
  801cc5:	e8 2c f1 ff ff       	call   800df6 <fd2data>
  801cca:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ccc:	83 c4 10             	add    $0x10,%esp
  801ccf:	bf 00 00 00 00       	mov    $0x0,%edi
  801cd4:	eb 4b                	jmp    801d21 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801cd6:	89 da                	mov    %ebx,%edx
  801cd8:	89 f0                	mov    %esi,%eax
  801cda:	e8 6d ff ff ff       	call   801c4c <_pipeisclosed>
  801cdf:	85 c0                	test   %eax,%eax
  801ce1:	75 48                	jne    801d2b <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801ce3:	e8 ee ee ff ff       	call   800bd6 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801ce8:	8b 43 04             	mov    0x4(%ebx),%eax
  801ceb:	8b 0b                	mov    (%ebx),%ecx
  801ced:	8d 51 20             	lea    0x20(%ecx),%edx
  801cf0:	39 d0                	cmp    %edx,%eax
  801cf2:	73 e2                	jae    801cd6 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801cf4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801cf7:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801cfb:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801cfe:	89 c2                	mov    %eax,%edx
  801d00:	c1 fa 1f             	sar    $0x1f,%edx
  801d03:	89 d1                	mov    %edx,%ecx
  801d05:	c1 e9 1b             	shr    $0x1b,%ecx
  801d08:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801d0b:	83 e2 1f             	and    $0x1f,%edx
  801d0e:	29 ca                	sub    %ecx,%edx
  801d10:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801d14:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801d18:	83 c0 01             	add    $0x1,%eax
  801d1b:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d1e:	83 c7 01             	add    $0x1,%edi
  801d21:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801d24:	75 c2                	jne    801ce8 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801d26:	8b 45 10             	mov    0x10(%ebp),%eax
  801d29:	eb 05                	jmp    801d30 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801d2b:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801d30:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d33:	5b                   	pop    %ebx
  801d34:	5e                   	pop    %esi
  801d35:	5f                   	pop    %edi
  801d36:	5d                   	pop    %ebp
  801d37:	c3                   	ret    

00801d38 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801d38:	55                   	push   %ebp
  801d39:	89 e5                	mov    %esp,%ebp
  801d3b:	57                   	push   %edi
  801d3c:	56                   	push   %esi
  801d3d:	53                   	push   %ebx
  801d3e:	83 ec 18             	sub    $0x18,%esp
  801d41:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801d44:	57                   	push   %edi
  801d45:	e8 ac f0 ff ff       	call   800df6 <fd2data>
  801d4a:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d4c:	83 c4 10             	add    $0x10,%esp
  801d4f:	bb 00 00 00 00       	mov    $0x0,%ebx
  801d54:	eb 3d                	jmp    801d93 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801d56:	85 db                	test   %ebx,%ebx
  801d58:	74 04                	je     801d5e <devpipe_read+0x26>
				return i;
  801d5a:	89 d8                	mov    %ebx,%eax
  801d5c:	eb 44                	jmp    801da2 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801d5e:	89 f2                	mov    %esi,%edx
  801d60:	89 f8                	mov    %edi,%eax
  801d62:	e8 e5 fe ff ff       	call   801c4c <_pipeisclosed>
  801d67:	85 c0                	test   %eax,%eax
  801d69:	75 32                	jne    801d9d <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801d6b:	e8 66 ee ff ff       	call   800bd6 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801d70:	8b 06                	mov    (%esi),%eax
  801d72:	3b 46 04             	cmp    0x4(%esi),%eax
  801d75:	74 df                	je     801d56 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801d77:	99                   	cltd   
  801d78:	c1 ea 1b             	shr    $0x1b,%edx
  801d7b:	01 d0                	add    %edx,%eax
  801d7d:	83 e0 1f             	and    $0x1f,%eax
  801d80:	29 d0                	sub    %edx,%eax
  801d82:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801d87:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801d8a:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801d8d:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d90:	83 c3 01             	add    $0x1,%ebx
  801d93:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801d96:	75 d8                	jne    801d70 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801d98:	8b 45 10             	mov    0x10(%ebp),%eax
  801d9b:	eb 05                	jmp    801da2 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801d9d:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801da2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801da5:	5b                   	pop    %ebx
  801da6:	5e                   	pop    %esi
  801da7:	5f                   	pop    %edi
  801da8:	5d                   	pop    %ebp
  801da9:	c3                   	ret    

00801daa <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801daa:	55                   	push   %ebp
  801dab:	89 e5                	mov    %esp,%ebp
  801dad:	56                   	push   %esi
  801dae:	53                   	push   %ebx
  801daf:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801db2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801db5:	50                   	push   %eax
  801db6:	e8 52 f0 ff ff       	call   800e0d <fd_alloc>
  801dbb:	83 c4 10             	add    $0x10,%esp
  801dbe:	89 c2                	mov    %eax,%edx
  801dc0:	85 c0                	test   %eax,%eax
  801dc2:	0f 88 2c 01 00 00    	js     801ef4 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801dc8:	83 ec 04             	sub    $0x4,%esp
  801dcb:	68 07 04 00 00       	push   $0x407
  801dd0:	ff 75 f4             	pushl  -0xc(%ebp)
  801dd3:	6a 00                	push   $0x0
  801dd5:	e8 1b ee ff ff       	call   800bf5 <sys_page_alloc>
  801dda:	83 c4 10             	add    $0x10,%esp
  801ddd:	89 c2                	mov    %eax,%edx
  801ddf:	85 c0                	test   %eax,%eax
  801de1:	0f 88 0d 01 00 00    	js     801ef4 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801de7:	83 ec 0c             	sub    $0xc,%esp
  801dea:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801ded:	50                   	push   %eax
  801dee:	e8 1a f0 ff ff       	call   800e0d <fd_alloc>
  801df3:	89 c3                	mov    %eax,%ebx
  801df5:	83 c4 10             	add    $0x10,%esp
  801df8:	85 c0                	test   %eax,%eax
  801dfa:	0f 88 e2 00 00 00    	js     801ee2 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e00:	83 ec 04             	sub    $0x4,%esp
  801e03:	68 07 04 00 00       	push   $0x407
  801e08:	ff 75 f0             	pushl  -0x10(%ebp)
  801e0b:	6a 00                	push   $0x0
  801e0d:	e8 e3 ed ff ff       	call   800bf5 <sys_page_alloc>
  801e12:	89 c3                	mov    %eax,%ebx
  801e14:	83 c4 10             	add    $0x10,%esp
  801e17:	85 c0                	test   %eax,%eax
  801e19:	0f 88 c3 00 00 00    	js     801ee2 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801e1f:	83 ec 0c             	sub    $0xc,%esp
  801e22:	ff 75 f4             	pushl  -0xc(%ebp)
  801e25:	e8 cc ef ff ff       	call   800df6 <fd2data>
  801e2a:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e2c:	83 c4 0c             	add    $0xc,%esp
  801e2f:	68 07 04 00 00       	push   $0x407
  801e34:	50                   	push   %eax
  801e35:	6a 00                	push   $0x0
  801e37:	e8 b9 ed ff ff       	call   800bf5 <sys_page_alloc>
  801e3c:	89 c3                	mov    %eax,%ebx
  801e3e:	83 c4 10             	add    $0x10,%esp
  801e41:	85 c0                	test   %eax,%eax
  801e43:	0f 88 89 00 00 00    	js     801ed2 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e49:	83 ec 0c             	sub    $0xc,%esp
  801e4c:	ff 75 f0             	pushl  -0x10(%ebp)
  801e4f:	e8 a2 ef ff ff       	call   800df6 <fd2data>
  801e54:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801e5b:	50                   	push   %eax
  801e5c:	6a 00                	push   $0x0
  801e5e:	56                   	push   %esi
  801e5f:	6a 00                	push   $0x0
  801e61:	e8 d2 ed ff ff       	call   800c38 <sys_page_map>
  801e66:	89 c3                	mov    %eax,%ebx
  801e68:	83 c4 20             	add    $0x20,%esp
  801e6b:	85 c0                	test   %eax,%eax
  801e6d:	78 55                	js     801ec4 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801e6f:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801e75:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e78:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801e7a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e7d:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801e84:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801e8a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801e8d:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801e8f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801e92:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801e99:	83 ec 0c             	sub    $0xc,%esp
  801e9c:	ff 75 f4             	pushl  -0xc(%ebp)
  801e9f:	e8 42 ef ff ff       	call   800de6 <fd2num>
  801ea4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801ea7:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801ea9:	83 c4 04             	add    $0x4,%esp
  801eac:	ff 75 f0             	pushl  -0x10(%ebp)
  801eaf:	e8 32 ef ff ff       	call   800de6 <fd2num>
  801eb4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801eb7:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801eba:	83 c4 10             	add    $0x10,%esp
  801ebd:	ba 00 00 00 00       	mov    $0x0,%edx
  801ec2:	eb 30                	jmp    801ef4 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801ec4:	83 ec 08             	sub    $0x8,%esp
  801ec7:	56                   	push   %esi
  801ec8:	6a 00                	push   $0x0
  801eca:	e8 ab ed ff ff       	call   800c7a <sys_page_unmap>
  801ecf:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801ed2:	83 ec 08             	sub    $0x8,%esp
  801ed5:	ff 75 f0             	pushl  -0x10(%ebp)
  801ed8:	6a 00                	push   $0x0
  801eda:	e8 9b ed ff ff       	call   800c7a <sys_page_unmap>
  801edf:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801ee2:	83 ec 08             	sub    $0x8,%esp
  801ee5:	ff 75 f4             	pushl  -0xc(%ebp)
  801ee8:	6a 00                	push   $0x0
  801eea:	e8 8b ed ff ff       	call   800c7a <sys_page_unmap>
  801eef:	83 c4 10             	add    $0x10,%esp
  801ef2:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801ef4:	89 d0                	mov    %edx,%eax
  801ef6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ef9:	5b                   	pop    %ebx
  801efa:	5e                   	pop    %esi
  801efb:	5d                   	pop    %ebp
  801efc:	c3                   	ret    

00801efd <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801efd:	55                   	push   %ebp
  801efe:	89 e5                	mov    %esp,%ebp
  801f00:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801f03:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f06:	50                   	push   %eax
  801f07:	ff 75 08             	pushl  0x8(%ebp)
  801f0a:	e8 4d ef ff ff       	call   800e5c <fd_lookup>
  801f0f:	83 c4 10             	add    $0x10,%esp
  801f12:	85 c0                	test   %eax,%eax
  801f14:	78 18                	js     801f2e <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801f16:	83 ec 0c             	sub    $0xc,%esp
  801f19:	ff 75 f4             	pushl  -0xc(%ebp)
  801f1c:	e8 d5 ee ff ff       	call   800df6 <fd2data>
	return _pipeisclosed(fd, p);
  801f21:	89 c2                	mov    %eax,%edx
  801f23:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f26:	e8 21 fd ff ff       	call   801c4c <_pipeisclosed>
  801f2b:	83 c4 10             	add    $0x10,%esp
}
  801f2e:	c9                   	leave  
  801f2f:	c3                   	ret    

00801f30 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801f30:	55                   	push   %ebp
  801f31:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801f33:	b8 00 00 00 00       	mov    $0x0,%eax
  801f38:	5d                   	pop    %ebp
  801f39:	c3                   	ret    

00801f3a <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801f3a:	55                   	push   %ebp
  801f3b:	89 e5                	mov    %esp,%ebp
  801f3d:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801f40:	68 3f 2a 80 00       	push   $0x802a3f
  801f45:	ff 75 0c             	pushl  0xc(%ebp)
  801f48:	e8 a5 e8 ff ff       	call   8007f2 <strcpy>
	return 0;
}
  801f4d:	b8 00 00 00 00       	mov    $0x0,%eax
  801f52:	c9                   	leave  
  801f53:	c3                   	ret    

00801f54 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801f54:	55                   	push   %ebp
  801f55:	89 e5                	mov    %esp,%ebp
  801f57:	57                   	push   %edi
  801f58:	56                   	push   %esi
  801f59:	53                   	push   %ebx
  801f5a:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801f60:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801f65:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801f6b:	eb 2d                	jmp    801f9a <devcons_write+0x46>
		m = n - tot;
  801f6d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801f70:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801f72:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801f75:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801f7a:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801f7d:	83 ec 04             	sub    $0x4,%esp
  801f80:	53                   	push   %ebx
  801f81:	03 45 0c             	add    0xc(%ebp),%eax
  801f84:	50                   	push   %eax
  801f85:	57                   	push   %edi
  801f86:	e8 f9 e9 ff ff       	call   800984 <memmove>
		sys_cputs(buf, m);
  801f8b:	83 c4 08             	add    $0x8,%esp
  801f8e:	53                   	push   %ebx
  801f8f:	57                   	push   %edi
  801f90:	e8 a4 eb ff ff       	call   800b39 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801f95:	01 de                	add    %ebx,%esi
  801f97:	83 c4 10             	add    $0x10,%esp
  801f9a:	89 f0                	mov    %esi,%eax
  801f9c:	3b 75 10             	cmp    0x10(%ebp),%esi
  801f9f:	72 cc                	jb     801f6d <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801fa1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801fa4:	5b                   	pop    %ebx
  801fa5:	5e                   	pop    %esi
  801fa6:	5f                   	pop    %edi
  801fa7:	5d                   	pop    %ebp
  801fa8:	c3                   	ret    

00801fa9 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801fa9:	55                   	push   %ebp
  801faa:	89 e5                	mov    %esp,%ebp
  801fac:	83 ec 08             	sub    $0x8,%esp
  801faf:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801fb4:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801fb8:	74 2a                	je     801fe4 <devcons_read+0x3b>
  801fba:	eb 05                	jmp    801fc1 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801fbc:	e8 15 ec ff ff       	call   800bd6 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801fc1:	e8 91 eb ff ff       	call   800b57 <sys_cgetc>
  801fc6:	85 c0                	test   %eax,%eax
  801fc8:	74 f2                	je     801fbc <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801fca:	85 c0                	test   %eax,%eax
  801fcc:	78 16                	js     801fe4 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801fce:	83 f8 04             	cmp    $0x4,%eax
  801fd1:	74 0c                	je     801fdf <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801fd3:	8b 55 0c             	mov    0xc(%ebp),%edx
  801fd6:	88 02                	mov    %al,(%edx)
	return 1;
  801fd8:	b8 01 00 00 00       	mov    $0x1,%eax
  801fdd:	eb 05                	jmp    801fe4 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801fdf:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801fe4:	c9                   	leave  
  801fe5:	c3                   	ret    

00801fe6 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801fe6:	55                   	push   %ebp
  801fe7:	89 e5                	mov    %esp,%ebp
  801fe9:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801fec:	8b 45 08             	mov    0x8(%ebp),%eax
  801fef:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801ff2:	6a 01                	push   $0x1
  801ff4:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801ff7:	50                   	push   %eax
  801ff8:	e8 3c eb ff ff       	call   800b39 <sys_cputs>
}
  801ffd:	83 c4 10             	add    $0x10,%esp
  802000:	c9                   	leave  
  802001:	c3                   	ret    

00802002 <getchar>:

int
getchar(void)
{
  802002:	55                   	push   %ebp
  802003:	89 e5                	mov    %esp,%ebp
  802005:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  802008:	6a 01                	push   $0x1
  80200a:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80200d:	50                   	push   %eax
  80200e:	6a 00                	push   $0x0
  802010:	e8 ad f0 ff ff       	call   8010c2 <read>
	if (r < 0)
  802015:	83 c4 10             	add    $0x10,%esp
  802018:	85 c0                	test   %eax,%eax
  80201a:	78 0f                	js     80202b <getchar+0x29>
		return r;
	if (r < 1)
  80201c:	85 c0                	test   %eax,%eax
  80201e:	7e 06                	jle    802026 <getchar+0x24>
		return -E_EOF;
	return c;
  802020:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  802024:	eb 05                	jmp    80202b <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  802026:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80202b:	c9                   	leave  
  80202c:	c3                   	ret    

0080202d <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  80202d:	55                   	push   %ebp
  80202e:	89 e5                	mov    %esp,%ebp
  802030:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802033:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802036:	50                   	push   %eax
  802037:	ff 75 08             	pushl  0x8(%ebp)
  80203a:	e8 1d ee ff ff       	call   800e5c <fd_lookup>
  80203f:	83 c4 10             	add    $0x10,%esp
  802042:	85 c0                	test   %eax,%eax
  802044:	78 11                	js     802057 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  802046:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802049:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80204f:	39 10                	cmp    %edx,(%eax)
  802051:	0f 94 c0             	sete   %al
  802054:	0f b6 c0             	movzbl %al,%eax
}
  802057:	c9                   	leave  
  802058:	c3                   	ret    

00802059 <opencons>:

int
opencons(void)
{
  802059:	55                   	push   %ebp
  80205a:	89 e5                	mov    %esp,%ebp
  80205c:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80205f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802062:	50                   	push   %eax
  802063:	e8 a5 ed ff ff       	call   800e0d <fd_alloc>
  802068:	83 c4 10             	add    $0x10,%esp
		return r;
  80206b:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80206d:	85 c0                	test   %eax,%eax
  80206f:	78 3e                	js     8020af <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802071:	83 ec 04             	sub    $0x4,%esp
  802074:	68 07 04 00 00       	push   $0x407
  802079:	ff 75 f4             	pushl  -0xc(%ebp)
  80207c:	6a 00                	push   $0x0
  80207e:	e8 72 eb ff ff       	call   800bf5 <sys_page_alloc>
  802083:	83 c4 10             	add    $0x10,%esp
		return r;
  802086:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802088:	85 c0                	test   %eax,%eax
  80208a:	78 23                	js     8020af <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  80208c:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  802092:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802095:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  802097:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80209a:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8020a1:	83 ec 0c             	sub    $0xc,%esp
  8020a4:	50                   	push   %eax
  8020a5:	e8 3c ed ff ff       	call   800de6 <fd2num>
  8020aa:	89 c2                	mov    %eax,%edx
  8020ac:	83 c4 10             	add    $0x10,%esp
}
  8020af:	89 d0                	mov    %edx,%eax
  8020b1:	c9                   	leave  
  8020b2:	c3                   	ret    

008020b3 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8020b3:	55                   	push   %ebp
  8020b4:	89 e5                	mov    %esp,%ebp
  8020b6:	56                   	push   %esi
  8020b7:	53                   	push   %ebx
  8020b8:	8b 75 08             	mov    0x8(%ebp),%esi
  8020bb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8020be:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");

	// don't want to recv page
	if (pg == NULL)
  8020c1:	85 c0                	test   %eax,%eax
		pg = (void *)UTOP;
  8020c3:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  8020c8:	0f 44 c2             	cmove  %edx,%eax

	int err = sys_ipc_recv(pg);
  8020cb:	83 ec 0c             	sub    $0xc,%esp
  8020ce:	50                   	push   %eax
  8020cf:	e8 d1 ec ff ff       	call   800da5 <sys_ipc_recv>

	if (from_env_store != NULL)
  8020d4:	83 c4 10             	add    $0x10,%esp
  8020d7:	85 f6                	test   %esi,%esi
  8020d9:	74 14                	je     8020ef <ipc_recv+0x3c>
		*from_env_store = err < 0? 0 : thisenv->env_ipc_from;
  8020db:	ba 00 00 00 00       	mov    $0x0,%edx
  8020e0:	85 c0                	test   %eax,%eax
  8020e2:	78 09                	js     8020ed <ipc_recv+0x3a>
  8020e4:	8b 15 04 40 80 00    	mov    0x804004,%edx
  8020ea:	8b 52 74             	mov    0x74(%edx),%edx
  8020ed:	89 16                	mov    %edx,(%esi)
	
	if (perm_store != NULL)
  8020ef:	85 db                	test   %ebx,%ebx
  8020f1:	74 14                	je     802107 <ipc_recv+0x54>
		*perm_store = err < 0? 0 : thisenv->env_ipc_perm;
  8020f3:	ba 00 00 00 00       	mov    $0x0,%edx
  8020f8:	85 c0                	test   %eax,%eax
  8020fa:	78 09                	js     802105 <ipc_recv+0x52>
  8020fc:	8b 15 04 40 80 00    	mov    0x804004,%edx
  802102:	8b 52 78             	mov    0x78(%edx),%edx
  802105:	89 13                	mov    %edx,(%ebx)

	if (err < 0)
  802107:	85 c0                	test   %eax,%eax
  802109:	78 08                	js     802113 <ipc_recv+0x60>
		return err;
	return thisenv->env_ipc_value;
  80210b:	a1 04 40 80 00       	mov    0x804004,%eax
  802110:	8b 40 70             	mov    0x70(%eax),%eax
}
  802113:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802116:	5b                   	pop    %ebx
  802117:	5e                   	pop    %esi
  802118:	5d                   	pop    %ebp
  802119:	c3                   	ret    

0080211a <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80211a:	55                   	push   %ebp
  80211b:	89 e5                	mov    %esp,%ebp
  80211d:	57                   	push   %edi
  80211e:	56                   	push   %esi
  80211f:	53                   	push   %ebx
  802120:	83 ec 0c             	sub    $0xc,%esp
  802123:	8b 7d 08             	mov    0x8(%ebp),%edi
  802126:	8b 75 0c             	mov    0xc(%ebp),%esi
  802129:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");

	// don't want to send page
	if (pg == NULL)
  80212c:	85 db                	test   %ebx,%ebx
		pg = (void *)UTOP;
  80212e:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  802133:	0f 44 d8             	cmove  %eax,%ebx
	
	int err = 0;
	
	do {

		err = sys_ipc_try_send(to_env, val, pg, perm);
  802136:	ff 75 14             	pushl  0x14(%ebp)
  802139:	53                   	push   %ebx
  80213a:	56                   	push   %esi
  80213b:	57                   	push   %edi
  80213c:	e8 41 ec ff ff       	call   800d82 <sys_ipc_try_send>

		if (err < 0) {
  802141:	83 c4 10             	add    $0x10,%esp
  802144:	85 c0                	test   %eax,%eax
  802146:	79 1e                	jns    802166 <ipc_send+0x4c>
			if (err == -E_IPC_NOT_RECV)
  802148:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80214b:	75 07                	jne    802154 <ipc_send+0x3a>
				sys_yield();
  80214d:	e8 84 ea ff ff       	call   800bd6 <sys_yield>
  802152:	eb e2                	jmp    802136 <ipc_send+0x1c>
			else 
				panic("ipc_send: %e", err);
  802154:	50                   	push   %eax
  802155:	68 4b 2a 80 00       	push   $0x802a4b
  80215a:	6a 49                	push   $0x49
  80215c:	68 58 2a 80 00       	push   $0x802a58
  802161:	e8 2e e0 ff ff       	call   800194 <_panic>
		}

	} while (err < 0);

}
  802166:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802169:	5b                   	pop    %ebx
  80216a:	5e                   	pop    %esi
  80216b:	5f                   	pop    %edi
  80216c:	5d                   	pop    %ebp
  80216d:	c3                   	ret    

0080216e <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80216e:	55                   	push   %ebp
  80216f:	89 e5                	mov    %esp,%ebp
  802171:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802174:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802179:	6b d0 7c             	imul   $0x7c,%eax,%edx
  80217c:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802182:	8b 52 50             	mov    0x50(%edx),%edx
  802185:	39 ca                	cmp    %ecx,%edx
  802187:	75 0d                	jne    802196 <ipc_find_env+0x28>
			return envs[i].env_id;
  802189:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80218c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802191:	8b 40 48             	mov    0x48(%eax),%eax
  802194:	eb 0f                	jmp    8021a5 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802196:	83 c0 01             	add    $0x1,%eax
  802199:	3d 00 04 00 00       	cmp    $0x400,%eax
  80219e:	75 d9                	jne    802179 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8021a0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8021a5:	5d                   	pop    %ebp
  8021a6:	c3                   	ret    

008021a7 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8021a7:	55                   	push   %ebp
  8021a8:	89 e5                	mov    %esp,%ebp
  8021aa:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8021ad:	89 d0                	mov    %edx,%eax
  8021af:	c1 e8 16             	shr    $0x16,%eax
  8021b2:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8021b9:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8021be:	f6 c1 01             	test   $0x1,%cl
  8021c1:	74 1d                	je     8021e0 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  8021c3:	c1 ea 0c             	shr    $0xc,%edx
  8021c6:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  8021cd:	f6 c2 01             	test   $0x1,%dl
  8021d0:	74 0e                	je     8021e0 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8021d2:	c1 ea 0c             	shr    $0xc,%edx
  8021d5:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8021dc:	ef 
  8021dd:	0f b7 c0             	movzwl %ax,%eax
}
  8021e0:	5d                   	pop    %ebp
  8021e1:	c3                   	ret    
  8021e2:	66 90                	xchg   %ax,%ax
  8021e4:	66 90                	xchg   %ax,%ax
  8021e6:	66 90                	xchg   %ax,%ax
  8021e8:	66 90                	xchg   %ax,%ax
  8021ea:	66 90                	xchg   %ax,%ax
  8021ec:	66 90                	xchg   %ax,%ax
  8021ee:	66 90                	xchg   %ax,%ax

008021f0 <__udivdi3>:
  8021f0:	55                   	push   %ebp
  8021f1:	57                   	push   %edi
  8021f2:	56                   	push   %esi
  8021f3:	53                   	push   %ebx
  8021f4:	83 ec 1c             	sub    $0x1c,%esp
  8021f7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  8021fb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  8021ff:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802203:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802207:	85 f6                	test   %esi,%esi
  802209:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80220d:	89 ca                	mov    %ecx,%edx
  80220f:	89 f8                	mov    %edi,%eax
  802211:	75 3d                	jne    802250 <__udivdi3+0x60>
  802213:	39 cf                	cmp    %ecx,%edi
  802215:	0f 87 c5 00 00 00    	ja     8022e0 <__udivdi3+0xf0>
  80221b:	85 ff                	test   %edi,%edi
  80221d:	89 fd                	mov    %edi,%ebp
  80221f:	75 0b                	jne    80222c <__udivdi3+0x3c>
  802221:	b8 01 00 00 00       	mov    $0x1,%eax
  802226:	31 d2                	xor    %edx,%edx
  802228:	f7 f7                	div    %edi
  80222a:	89 c5                	mov    %eax,%ebp
  80222c:	89 c8                	mov    %ecx,%eax
  80222e:	31 d2                	xor    %edx,%edx
  802230:	f7 f5                	div    %ebp
  802232:	89 c1                	mov    %eax,%ecx
  802234:	89 d8                	mov    %ebx,%eax
  802236:	89 cf                	mov    %ecx,%edi
  802238:	f7 f5                	div    %ebp
  80223a:	89 c3                	mov    %eax,%ebx
  80223c:	89 d8                	mov    %ebx,%eax
  80223e:	89 fa                	mov    %edi,%edx
  802240:	83 c4 1c             	add    $0x1c,%esp
  802243:	5b                   	pop    %ebx
  802244:	5e                   	pop    %esi
  802245:	5f                   	pop    %edi
  802246:	5d                   	pop    %ebp
  802247:	c3                   	ret    
  802248:	90                   	nop
  802249:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802250:	39 ce                	cmp    %ecx,%esi
  802252:	77 74                	ja     8022c8 <__udivdi3+0xd8>
  802254:	0f bd fe             	bsr    %esi,%edi
  802257:	83 f7 1f             	xor    $0x1f,%edi
  80225a:	0f 84 98 00 00 00    	je     8022f8 <__udivdi3+0x108>
  802260:	bb 20 00 00 00       	mov    $0x20,%ebx
  802265:	89 f9                	mov    %edi,%ecx
  802267:	89 c5                	mov    %eax,%ebp
  802269:	29 fb                	sub    %edi,%ebx
  80226b:	d3 e6                	shl    %cl,%esi
  80226d:	89 d9                	mov    %ebx,%ecx
  80226f:	d3 ed                	shr    %cl,%ebp
  802271:	89 f9                	mov    %edi,%ecx
  802273:	d3 e0                	shl    %cl,%eax
  802275:	09 ee                	or     %ebp,%esi
  802277:	89 d9                	mov    %ebx,%ecx
  802279:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80227d:	89 d5                	mov    %edx,%ebp
  80227f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802283:	d3 ed                	shr    %cl,%ebp
  802285:	89 f9                	mov    %edi,%ecx
  802287:	d3 e2                	shl    %cl,%edx
  802289:	89 d9                	mov    %ebx,%ecx
  80228b:	d3 e8                	shr    %cl,%eax
  80228d:	09 c2                	or     %eax,%edx
  80228f:	89 d0                	mov    %edx,%eax
  802291:	89 ea                	mov    %ebp,%edx
  802293:	f7 f6                	div    %esi
  802295:	89 d5                	mov    %edx,%ebp
  802297:	89 c3                	mov    %eax,%ebx
  802299:	f7 64 24 0c          	mull   0xc(%esp)
  80229d:	39 d5                	cmp    %edx,%ebp
  80229f:	72 10                	jb     8022b1 <__udivdi3+0xc1>
  8022a1:	8b 74 24 08          	mov    0x8(%esp),%esi
  8022a5:	89 f9                	mov    %edi,%ecx
  8022a7:	d3 e6                	shl    %cl,%esi
  8022a9:	39 c6                	cmp    %eax,%esi
  8022ab:	73 07                	jae    8022b4 <__udivdi3+0xc4>
  8022ad:	39 d5                	cmp    %edx,%ebp
  8022af:	75 03                	jne    8022b4 <__udivdi3+0xc4>
  8022b1:	83 eb 01             	sub    $0x1,%ebx
  8022b4:	31 ff                	xor    %edi,%edi
  8022b6:	89 d8                	mov    %ebx,%eax
  8022b8:	89 fa                	mov    %edi,%edx
  8022ba:	83 c4 1c             	add    $0x1c,%esp
  8022bd:	5b                   	pop    %ebx
  8022be:	5e                   	pop    %esi
  8022bf:	5f                   	pop    %edi
  8022c0:	5d                   	pop    %ebp
  8022c1:	c3                   	ret    
  8022c2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8022c8:	31 ff                	xor    %edi,%edi
  8022ca:	31 db                	xor    %ebx,%ebx
  8022cc:	89 d8                	mov    %ebx,%eax
  8022ce:	89 fa                	mov    %edi,%edx
  8022d0:	83 c4 1c             	add    $0x1c,%esp
  8022d3:	5b                   	pop    %ebx
  8022d4:	5e                   	pop    %esi
  8022d5:	5f                   	pop    %edi
  8022d6:	5d                   	pop    %ebp
  8022d7:	c3                   	ret    
  8022d8:	90                   	nop
  8022d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8022e0:	89 d8                	mov    %ebx,%eax
  8022e2:	f7 f7                	div    %edi
  8022e4:	31 ff                	xor    %edi,%edi
  8022e6:	89 c3                	mov    %eax,%ebx
  8022e8:	89 d8                	mov    %ebx,%eax
  8022ea:	89 fa                	mov    %edi,%edx
  8022ec:	83 c4 1c             	add    $0x1c,%esp
  8022ef:	5b                   	pop    %ebx
  8022f0:	5e                   	pop    %esi
  8022f1:	5f                   	pop    %edi
  8022f2:	5d                   	pop    %ebp
  8022f3:	c3                   	ret    
  8022f4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8022f8:	39 ce                	cmp    %ecx,%esi
  8022fa:	72 0c                	jb     802308 <__udivdi3+0x118>
  8022fc:	31 db                	xor    %ebx,%ebx
  8022fe:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802302:	0f 87 34 ff ff ff    	ja     80223c <__udivdi3+0x4c>
  802308:	bb 01 00 00 00       	mov    $0x1,%ebx
  80230d:	e9 2a ff ff ff       	jmp    80223c <__udivdi3+0x4c>
  802312:	66 90                	xchg   %ax,%ax
  802314:	66 90                	xchg   %ax,%ax
  802316:	66 90                	xchg   %ax,%ax
  802318:	66 90                	xchg   %ax,%ax
  80231a:	66 90                	xchg   %ax,%ax
  80231c:	66 90                	xchg   %ax,%ax
  80231e:	66 90                	xchg   %ax,%ax

00802320 <__umoddi3>:
  802320:	55                   	push   %ebp
  802321:	57                   	push   %edi
  802322:	56                   	push   %esi
  802323:	53                   	push   %ebx
  802324:	83 ec 1c             	sub    $0x1c,%esp
  802327:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80232b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80232f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802333:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802337:	85 d2                	test   %edx,%edx
  802339:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80233d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802341:	89 f3                	mov    %esi,%ebx
  802343:	89 3c 24             	mov    %edi,(%esp)
  802346:	89 74 24 04          	mov    %esi,0x4(%esp)
  80234a:	75 1c                	jne    802368 <__umoddi3+0x48>
  80234c:	39 f7                	cmp    %esi,%edi
  80234e:	76 50                	jbe    8023a0 <__umoddi3+0x80>
  802350:	89 c8                	mov    %ecx,%eax
  802352:	89 f2                	mov    %esi,%edx
  802354:	f7 f7                	div    %edi
  802356:	89 d0                	mov    %edx,%eax
  802358:	31 d2                	xor    %edx,%edx
  80235a:	83 c4 1c             	add    $0x1c,%esp
  80235d:	5b                   	pop    %ebx
  80235e:	5e                   	pop    %esi
  80235f:	5f                   	pop    %edi
  802360:	5d                   	pop    %ebp
  802361:	c3                   	ret    
  802362:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802368:	39 f2                	cmp    %esi,%edx
  80236a:	89 d0                	mov    %edx,%eax
  80236c:	77 52                	ja     8023c0 <__umoddi3+0xa0>
  80236e:	0f bd ea             	bsr    %edx,%ebp
  802371:	83 f5 1f             	xor    $0x1f,%ebp
  802374:	75 5a                	jne    8023d0 <__umoddi3+0xb0>
  802376:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80237a:	0f 82 e0 00 00 00    	jb     802460 <__umoddi3+0x140>
  802380:	39 0c 24             	cmp    %ecx,(%esp)
  802383:	0f 86 d7 00 00 00    	jbe    802460 <__umoddi3+0x140>
  802389:	8b 44 24 08          	mov    0x8(%esp),%eax
  80238d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802391:	83 c4 1c             	add    $0x1c,%esp
  802394:	5b                   	pop    %ebx
  802395:	5e                   	pop    %esi
  802396:	5f                   	pop    %edi
  802397:	5d                   	pop    %ebp
  802398:	c3                   	ret    
  802399:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8023a0:	85 ff                	test   %edi,%edi
  8023a2:	89 fd                	mov    %edi,%ebp
  8023a4:	75 0b                	jne    8023b1 <__umoddi3+0x91>
  8023a6:	b8 01 00 00 00       	mov    $0x1,%eax
  8023ab:	31 d2                	xor    %edx,%edx
  8023ad:	f7 f7                	div    %edi
  8023af:	89 c5                	mov    %eax,%ebp
  8023b1:	89 f0                	mov    %esi,%eax
  8023b3:	31 d2                	xor    %edx,%edx
  8023b5:	f7 f5                	div    %ebp
  8023b7:	89 c8                	mov    %ecx,%eax
  8023b9:	f7 f5                	div    %ebp
  8023bb:	89 d0                	mov    %edx,%eax
  8023bd:	eb 99                	jmp    802358 <__umoddi3+0x38>
  8023bf:	90                   	nop
  8023c0:	89 c8                	mov    %ecx,%eax
  8023c2:	89 f2                	mov    %esi,%edx
  8023c4:	83 c4 1c             	add    $0x1c,%esp
  8023c7:	5b                   	pop    %ebx
  8023c8:	5e                   	pop    %esi
  8023c9:	5f                   	pop    %edi
  8023ca:	5d                   	pop    %ebp
  8023cb:	c3                   	ret    
  8023cc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8023d0:	8b 34 24             	mov    (%esp),%esi
  8023d3:	bf 20 00 00 00       	mov    $0x20,%edi
  8023d8:	89 e9                	mov    %ebp,%ecx
  8023da:	29 ef                	sub    %ebp,%edi
  8023dc:	d3 e0                	shl    %cl,%eax
  8023de:	89 f9                	mov    %edi,%ecx
  8023e0:	89 f2                	mov    %esi,%edx
  8023e2:	d3 ea                	shr    %cl,%edx
  8023e4:	89 e9                	mov    %ebp,%ecx
  8023e6:	09 c2                	or     %eax,%edx
  8023e8:	89 d8                	mov    %ebx,%eax
  8023ea:	89 14 24             	mov    %edx,(%esp)
  8023ed:	89 f2                	mov    %esi,%edx
  8023ef:	d3 e2                	shl    %cl,%edx
  8023f1:	89 f9                	mov    %edi,%ecx
  8023f3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8023f7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8023fb:	d3 e8                	shr    %cl,%eax
  8023fd:	89 e9                	mov    %ebp,%ecx
  8023ff:	89 c6                	mov    %eax,%esi
  802401:	d3 e3                	shl    %cl,%ebx
  802403:	89 f9                	mov    %edi,%ecx
  802405:	89 d0                	mov    %edx,%eax
  802407:	d3 e8                	shr    %cl,%eax
  802409:	89 e9                	mov    %ebp,%ecx
  80240b:	09 d8                	or     %ebx,%eax
  80240d:	89 d3                	mov    %edx,%ebx
  80240f:	89 f2                	mov    %esi,%edx
  802411:	f7 34 24             	divl   (%esp)
  802414:	89 d6                	mov    %edx,%esi
  802416:	d3 e3                	shl    %cl,%ebx
  802418:	f7 64 24 04          	mull   0x4(%esp)
  80241c:	39 d6                	cmp    %edx,%esi
  80241e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802422:	89 d1                	mov    %edx,%ecx
  802424:	89 c3                	mov    %eax,%ebx
  802426:	72 08                	jb     802430 <__umoddi3+0x110>
  802428:	75 11                	jne    80243b <__umoddi3+0x11b>
  80242a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80242e:	73 0b                	jae    80243b <__umoddi3+0x11b>
  802430:	2b 44 24 04          	sub    0x4(%esp),%eax
  802434:	1b 14 24             	sbb    (%esp),%edx
  802437:	89 d1                	mov    %edx,%ecx
  802439:	89 c3                	mov    %eax,%ebx
  80243b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80243f:	29 da                	sub    %ebx,%edx
  802441:	19 ce                	sbb    %ecx,%esi
  802443:	89 f9                	mov    %edi,%ecx
  802445:	89 f0                	mov    %esi,%eax
  802447:	d3 e0                	shl    %cl,%eax
  802449:	89 e9                	mov    %ebp,%ecx
  80244b:	d3 ea                	shr    %cl,%edx
  80244d:	89 e9                	mov    %ebp,%ecx
  80244f:	d3 ee                	shr    %cl,%esi
  802451:	09 d0                	or     %edx,%eax
  802453:	89 f2                	mov    %esi,%edx
  802455:	83 c4 1c             	add    $0x1c,%esp
  802458:	5b                   	pop    %ebx
  802459:	5e                   	pop    %esi
  80245a:	5f                   	pop    %edi
  80245b:	5d                   	pop    %ebp
  80245c:	c3                   	ret    
  80245d:	8d 76 00             	lea    0x0(%esi),%esi
  802460:	29 f9                	sub    %edi,%ecx
  802462:	19 d6                	sbb    %edx,%esi
  802464:	89 74 24 04          	mov    %esi,0x4(%esp)
  802468:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80246c:	e9 18 ff ff ff       	jmp    802389 <__umoddi3+0x69>
