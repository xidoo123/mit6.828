
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
  80003e:	c7 05 00 30 80 00 40 	movl   $0x802940,0x803000
  800045:	29 80 00 

	cprintf("icode startup\n");
  800048:	68 46 29 80 00       	push   $0x802946
  80004d:	e8 1b 02 00 00       	call   80026d <cprintf>

	cprintf("icode: open /motd\n");
  800052:	c7 04 24 55 29 80 00 	movl   $0x802955,(%esp)
  800059:	e8 0f 02 00 00       	call   80026d <cprintf>
	if ((fd = open("/motd", O_RDONLY)) < 0)
  80005e:	83 c4 08             	add    $0x8,%esp
  800061:	6a 00                	push   $0x0
  800063:	68 68 29 80 00       	push   $0x802968
  800068:	e8 34 15 00 00       	call   8015a1 <open>
  80006d:	89 c6                	mov    %eax,%esi
  80006f:	83 c4 10             	add    $0x10,%esp
  800072:	85 c0                	test   %eax,%eax
  800074:	79 12                	jns    800088 <umain+0x55>
		panic("icode: open /motd: %e", fd);
  800076:	50                   	push   %eax
  800077:	68 6e 29 80 00       	push   $0x80296e
  80007c:	6a 0f                	push   $0xf
  80007e:	68 84 29 80 00       	push   $0x802984
  800083:	e8 0c 01 00 00       	call   800194 <_panic>

	cprintf("icode: read /motd\n");
  800088:	83 ec 0c             	sub    $0xc,%esp
  80008b:	68 91 29 80 00       	push   $0x802991
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
  8000b7:	e8 67 10 00 00       	call   801123 <read>
  8000bc:	83 c4 10             	add    $0x10,%esp
  8000bf:	85 c0                	test   %eax,%eax
  8000c1:	7f dd                	jg     8000a0 <umain+0x6d>
		sys_cputs(buf, n);

	cprintf("icode: close /motd\n");
  8000c3:	83 ec 0c             	sub    $0xc,%esp
  8000c6:	68 a4 29 80 00       	push   $0x8029a4
  8000cb:	e8 9d 01 00 00       	call   80026d <cprintf>
	close(fd);
  8000d0:	89 34 24             	mov    %esi,(%esp)
  8000d3:	e8 0f 0f 00 00       	call   800fe7 <close>

	cprintf("icode: spawn /init\n");
  8000d8:	c7 04 24 b8 29 80 00 	movl   $0x8029b8,(%esp)
  8000df:	e8 89 01 00 00       	call   80026d <cprintf>
	if ((r = spawnl("/init", "init", "initarg1", "initarg2", (char*)0)) < 0)
  8000e4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000eb:	68 cc 29 80 00       	push   $0x8029cc
  8000f0:	68 d5 29 80 00       	push   $0x8029d5
  8000f5:	68 df 29 80 00       	push   $0x8029df
  8000fa:	68 de 29 80 00       	push   $0x8029de
  8000ff:	e8 be 1a 00 00       	call   801bc2 <spawnl>
  800104:	83 c4 20             	add    $0x20,%esp
  800107:	85 c0                	test   %eax,%eax
  800109:	79 12                	jns    80011d <umain+0xea>
		panic("icode: spawn /init: %e", r);
  80010b:	50                   	push   %eax
  80010c:	68 e4 29 80 00       	push   $0x8029e4
  800111:	6a 1a                	push   $0x1a
  800113:	68 84 29 80 00       	push   $0x802984
  800118:	e8 77 00 00 00       	call   800194 <_panic>

	cprintf("icode: exiting\n");
  80011d:	83 ec 0c             	sub    $0xc,%esp
  800120:	68 fb 29 80 00       	push   $0x8029fb
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
  800180:	e8 8d 0e 00 00       	call   801012 <close_all>
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
  8001b2:	68 18 2a 80 00       	push   $0x802a18
  8001b7:	e8 b1 00 00 00       	call   80026d <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001bc:	83 c4 18             	add    $0x18,%esp
  8001bf:	53                   	push   %ebx
  8001c0:	ff 75 10             	pushl  0x10(%ebp)
  8001c3:	e8 54 00 00 00       	call   80021c <vcprintf>
	cprintf("\n");
  8001c8:	c7 04 24 35 2f 80 00 	movl   $0x802f35,(%esp)
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
  8002d0:	e8 db 23 00 00       	call   8026b0 <__udivdi3>
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
  800313:	e8 c8 24 00 00       	call   8027e0 <__umoddi3>
  800318:	83 c4 14             	add    $0x14,%esp
  80031b:	0f be 80 3b 2a 80 00 	movsbl 0x802a3b(%eax),%eax
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
  800417:	ff 24 85 80 2b 80 00 	jmp    *0x802b80(,%eax,4)
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
  8004db:	8b 14 85 e0 2c 80 00 	mov    0x802ce0(,%eax,4),%edx
  8004e2:	85 d2                	test   %edx,%edx
  8004e4:	75 18                	jne    8004fe <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8004e6:	50                   	push   %eax
  8004e7:	68 53 2a 80 00       	push   $0x802a53
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
  8004ff:	68 15 2e 80 00       	push   $0x802e15
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
  800523:	b8 4c 2a 80 00       	mov    $0x802a4c,%eax
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
  800b9e:	68 3f 2d 80 00       	push   $0x802d3f
  800ba3:	6a 23                	push   $0x23
  800ba5:	68 5c 2d 80 00       	push   $0x802d5c
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
  800c1f:	68 3f 2d 80 00       	push   $0x802d3f
  800c24:	6a 23                	push   $0x23
  800c26:	68 5c 2d 80 00       	push   $0x802d5c
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
  800c61:	68 3f 2d 80 00       	push   $0x802d3f
  800c66:	6a 23                	push   $0x23
  800c68:	68 5c 2d 80 00       	push   $0x802d5c
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
  800ca3:	68 3f 2d 80 00       	push   $0x802d3f
  800ca8:	6a 23                	push   $0x23
  800caa:	68 5c 2d 80 00       	push   $0x802d5c
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
  800ce5:	68 3f 2d 80 00       	push   $0x802d3f
  800cea:	6a 23                	push   $0x23
  800cec:	68 5c 2d 80 00       	push   $0x802d5c
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
  800d27:	68 3f 2d 80 00       	push   $0x802d3f
  800d2c:	6a 23                	push   $0x23
  800d2e:	68 5c 2d 80 00       	push   $0x802d5c
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
  800d69:	68 3f 2d 80 00       	push   $0x802d3f
  800d6e:	6a 23                	push   $0x23
  800d70:	68 5c 2d 80 00       	push   $0x802d5c
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
  800dcd:	68 3f 2d 80 00       	push   $0x802d3f
  800dd2:	6a 23                	push   $0x23
  800dd4:	68 5c 2d 80 00       	push   $0x802d5c
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
  800e2e:	68 3f 2d 80 00       	push   $0x802d3f
  800e33:	6a 23                	push   $0x23
  800e35:	68 5c 2d 80 00       	push   $0x802d5c
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

00800e47 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800e47:	55                   	push   %ebp
  800e48:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800e4a:	8b 45 08             	mov    0x8(%ebp),%eax
  800e4d:	05 00 00 00 30       	add    $0x30000000,%eax
  800e52:	c1 e8 0c             	shr    $0xc,%eax
}
  800e55:	5d                   	pop    %ebp
  800e56:	c3                   	ret    

00800e57 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800e57:	55                   	push   %ebp
  800e58:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800e5a:	8b 45 08             	mov    0x8(%ebp),%eax
  800e5d:	05 00 00 00 30       	add    $0x30000000,%eax
  800e62:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800e67:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800e6c:	5d                   	pop    %ebp
  800e6d:	c3                   	ret    

00800e6e <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800e6e:	55                   	push   %ebp
  800e6f:	89 e5                	mov    %esp,%ebp
  800e71:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e74:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800e79:	89 c2                	mov    %eax,%edx
  800e7b:	c1 ea 16             	shr    $0x16,%edx
  800e7e:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e85:	f6 c2 01             	test   $0x1,%dl
  800e88:	74 11                	je     800e9b <fd_alloc+0x2d>
  800e8a:	89 c2                	mov    %eax,%edx
  800e8c:	c1 ea 0c             	shr    $0xc,%edx
  800e8f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e96:	f6 c2 01             	test   $0x1,%dl
  800e99:	75 09                	jne    800ea4 <fd_alloc+0x36>
			*fd_store = fd;
  800e9b:	89 01                	mov    %eax,(%ecx)
			return 0;
  800e9d:	b8 00 00 00 00       	mov    $0x0,%eax
  800ea2:	eb 17                	jmp    800ebb <fd_alloc+0x4d>
  800ea4:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800ea9:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800eae:	75 c9                	jne    800e79 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800eb0:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800eb6:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800ebb:	5d                   	pop    %ebp
  800ebc:	c3                   	ret    

00800ebd <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800ebd:	55                   	push   %ebp
  800ebe:	89 e5                	mov    %esp,%ebp
  800ec0:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800ec3:	83 f8 1f             	cmp    $0x1f,%eax
  800ec6:	77 36                	ja     800efe <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800ec8:	c1 e0 0c             	shl    $0xc,%eax
  800ecb:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800ed0:	89 c2                	mov    %eax,%edx
  800ed2:	c1 ea 16             	shr    $0x16,%edx
  800ed5:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800edc:	f6 c2 01             	test   $0x1,%dl
  800edf:	74 24                	je     800f05 <fd_lookup+0x48>
  800ee1:	89 c2                	mov    %eax,%edx
  800ee3:	c1 ea 0c             	shr    $0xc,%edx
  800ee6:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800eed:	f6 c2 01             	test   $0x1,%dl
  800ef0:	74 1a                	je     800f0c <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800ef2:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ef5:	89 02                	mov    %eax,(%edx)
	return 0;
  800ef7:	b8 00 00 00 00       	mov    $0x0,%eax
  800efc:	eb 13                	jmp    800f11 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800efe:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f03:	eb 0c                	jmp    800f11 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800f05:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f0a:	eb 05                	jmp    800f11 <fd_lookup+0x54>
  800f0c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800f11:	5d                   	pop    %ebp
  800f12:	c3                   	ret    

00800f13 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800f13:	55                   	push   %ebp
  800f14:	89 e5                	mov    %esp,%ebp
  800f16:	83 ec 08             	sub    $0x8,%esp
  800f19:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f1c:	ba e8 2d 80 00       	mov    $0x802de8,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800f21:	eb 13                	jmp    800f36 <dev_lookup+0x23>
  800f23:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800f26:	39 08                	cmp    %ecx,(%eax)
  800f28:	75 0c                	jne    800f36 <dev_lookup+0x23>
			*dev = devtab[i];
  800f2a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f2d:	89 01                	mov    %eax,(%ecx)
			return 0;
  800f2f:	b8 00 00 00 00       	mov    $0x0,%eax
  800f34:	eb 2e                	jmp    800f64 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800f36:	8b 02                	mov    (%edx),%eax
  800f38:	85 c0                	test   %eax,%eax
  800f3a:	75 e7                	jne    800f23 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800f3c:	a1 08 40 80 00       	mov    0x804008,%eax
  800f41:	8b 40 48             	mov    0x48(%eax),%eax
  800f44:	83 ec 04             	sub    $0x4,%esp
  800f47:	51                   	push   %ecx
  800f48:	50                   	push   %eax
  800f49:	68 6c 2d 80 00       	push   $0x802d6c
  800f4e:	e8 1a f3 ff ff       	call   80026d <cprintf>
	*dev = 0;
  800f53:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f56:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800f5c:	83 c4 10             	add    $0x10,%esp
  800f5f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800f64:	c9                   	leave  
  800f65:	c3                   	ret    

00800f66 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800f66:	55                   	push   %ebp
  800f67:	89 e5                	mov    %esp,%ebp
  800f69:	56                   	push   %esi
  800f6a:	53                   	push   %ebx
  800f6b:	83 ec 10             	sub    $0x10,%esp
  800f6e:	8b 75 08             	mov    0x8(%ebp),%esi
  800f71:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800f74:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f77:	50                   	push   %eax
  800f78:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800f7e:	c1 e8 0c             	shr    $0xc,%eax
  800f81:	50                   	push   %eax
  800f82:	e8 36 ff ff ff       	call   800ebd <fd_lookup>
  800f87:	83 c4 08             	add    $0x8,%esp
  800f8a:	85 c0                	test   %eax,%eax
  800f8c:	78 05                	js     800f93 <fd_close+0x2d>
	    || fd != fd2)
  800f8e:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800f91:	74 0c                	je     800f9f <fd_close+0x39>
		return (must_exist ? r : 0);
  800f93:	84 db                	test   %bl,%bl
  800f95:	ba 00 00 00 00       	mov    $0x0,%edx
  800f9a:	0f 44 c2             	cmove  %edx,%eax
  800f9d:	eb 41                	jmp    800fe0 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800f9f:	83 ec 08             	sub    $0x8,%esp
  800fa2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800fa5:	50                   	push   %eax
  800fa6:	ff 36                	pushl  (%esi)
  800fa8:	e8 66 ff ff ff       	call   800f13 <dev_lookup>
  800fad:	89 c3                	mov    %eax,%ebx
  800faf:	83 c4 10             	add    $0x10,%esp
  800fb2:	85 c0                	test   %eax,%eax
  800fb4:	78 1a                	js     800fd0 <fd_close+0x6a>
		if (dev->dev_close)
  800fb6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800fb9:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800fbc:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800fc1:	85 c0                	test   %eax,%eax
  800fc3:	74 0b                	je     800fd0 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800fc5:	83 ec 0c             	sub    $0xc,%esp
  800fc8:	56                   	push   %esi
  800fc9:	ff d0                	call   *%eax
  800fcb:	89 c3                	mov    %eax,%ebx
  800fcd:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800fd0:	83 ec 08             	sub    $0x8,%esp
  800fd3:	56                   	push   %esi
  800fd4:	6a 00                	push   $0x0
  800fd6:	e8 9f fc ff ff       	call   800c7a <sys_page_unmap>
	return r;
  800fdb:	83 c4 10             	add    $0x10,%esp
  800fde:	89 d8                	mov    %ebx,%eax
}
  800fe0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800fe3:	5b                   	pop    %ebx
  800fe4:	5e                   	pop    %esi
  800fe5:	5d                   	pop    %ebp
  800fe6:	c3                   	ret    

00800fe7 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800fe7:	55                   	push   %ebp
  800fe8:	89 e5                	mov    %esp,%ebp
  800fea:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800fed:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ff0:	50                   	push   %eax
  800ff1:	ff 75 08             	pushl  0x8(%ebp)
  800ff4:	e8 c4 fe ff ff       	call   800ebd <fd_lookup>
  800ff9:	83 c4 08             	add    $0x8,%esp
  800ffc:	85 c0                	test   %eax,%eax
  800ffe:	78 10                	js     801010 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801000:	83 ec 08             	sub    $0x8,%esp
  801003:	6a 01                	push   $0x1
  801005:	ff 75 f4             	pushl  -0xc(%ebp)
  801008:	e8 59 ff ff ff       	call   800f66 <fd_close>
  80100d:	83 c4 10             	add    $0x10,%esp
}
  801010:	c9                   	leave  
  801011:	c3                   	ret    

00801012 <close_all>:

void
close_all(void)
{
  801012:	55                   	push   %ebp
  801013:	89 e5                	mov    %esp,%ebp
  801015:	53                   	push   %ebx
  801016:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801019:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80101e:	83 ec 0c             	sub    $0xc,%esp
  801021:	53                   	push   %ebx
  801022:	e8 c0 ff ff ff       	call   800fe7 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801027:	83 c3 01             	add    $0x1,%ebx
  80102a:	83 c4 10             	add    $0x10,%esp
  80102d:	83 fb 20             	cmp    $0x20,%ebx
  801030:	75 ec                	jne    80101e <close_all+0xc>
		close(i);
}
  801032:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801035:	c9                   	leave  
  801036:	c3                   	ret    

00801037 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801037:	55                   	push   %ebp
  801038:	89 e5                	mov    %esp,%ebp
  80103a:	57                   	push   %edi
  80103b:	56                   	push   %esi
  80103c:	53                   	push   %ebx
  80103d:	83 ec 2c             	sub    $0x2c,%esp
  801040:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801043:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801046:	50                   	push   %eax
  801047:	ff 75 08             	pushl  0x8(%ebp)
  80104a:	e8 6e fe ff ff       	call   800ebd <fd_lookup>
  80104f:	83 c4 08             	add    $0x8,%esp
  801052:	85 c0                	test   %eax,%eax
  801054:	0f 88 c1 00 00 00    	js     80111b <dup+0xe4>
		return r;
	close(newfdnum);
  80105a:	83 ec 0c             	sub    $0xc,%esp
  80105d:	56                   	push   %esi
  80105e:	e8 84 ff ff ff       	call   800fe7 <close>

	newfd = INDEX2FD(newfdnum);
  801063:	89 f3                	mov    %esi,%ebx
  801065:	c1 e3 0c             	shl    $0xc,%ebx
  801068:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  80106e:	83 c4 04             	add    $0x4,%esp
  801071:	ff 75 e4             	pushl  -0x1c(%ebp)
  801074:	e8 de fd ff ff       	call   800e57 <fd2data>
  801079:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  80107b:	89 1c 24             	mov    %ebx,(%esp)
  80107e:	e8 d4 fd ff ff       	call   800e57 <fd2data>
  801083:	83 c4 10             	add    $0x10,%esp
  801086:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801089:	89 f8                	mov    %edi,%eax
  80108b:	c1 e8 16             	shr    $0x16,%eax
  80108e:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801095:	a8 01                	test   $0x1,%al
  801097:	74 37                	je     8010d0 <dup+0x99>
  801099:	89 f8                	mov    %edi,%eax
  80109b:	c1 e8 0c             	shr    $0xc,%eax
  80109e:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8010a5:	f6 c2 01             	test   $0x1,%dl
  8010a8:	74 26                	je     8010d0 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8010aa:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8010b1:	83 ec 0c             	sub    $0xc,%esp
  8010b4:	25 07 0e 00 00       	and    $0xe07,%eax
  8010b9:	50                   	push   %eax
  8010ba:	ff 75 d4             	pushl  -0x2c(%ebp)
  8010bd:	6a 00                	push   $0x0
  8010bf:	57                   	push   %edi
  8010c0:	6a 00                	push   $0x0
  8010c2:	e8 71 fb ff ff       	call   800c38 <sys_page_map>
  8010c7:	89 c7                	mov    %eax,%edi
  8010c9:	83 c4 20             	add    $0x20,%esp
  8010cc:	85 c0                	test   %eax,%eax
  8010ce:	78 2e                	js     8010fe <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8010d0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8010d3:	89 d0                	mov    %edx,%eax
  8010d5:	c1 e8 0c             	shr    $0xc,%eax
  8010d8:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8010df:	83 ec 0c             	sub    $0xc,%esp
  8010e2:	25 07 0e 00 00       	and    $0xe07,%eax
  8010e7:	50                   	push   %eax
  8010e8:	53                   	push   %ebx
  8010e9:	6a 00                	push   $0x0
  8010eb:	52                   	push   %edx
  8010ec:	6a 00                	push   $0x0
  8010ee:	e8 45 fb ff ff       	call   800c38 <sys_page_map>
  8010f3:	89 c7                	mov    %eax,%edi
  8010f5:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8010f8:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8010fa:	85 ff                	test   %edi,%edi
  8010fc:	79 1d                	jns    80111b <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8010fe:	83 ec 08             	sub    $0x8,%esp
  801101:	53                   	push   %ebx
  801102:	6a 00                	push   $0x0
  801104:	e8 71 fb ff ff       	call   800c7a <sys_page_unmap>
	sys_page_unmap(0, nva);
  801109:	83 c4 08             	add    $0x8,%esp
  80110c:	ff 75 d4             	pushl  -0x2c(%ebp)
  80110f:	6a 00                	push   $0x0
  801111:	e8 64 fb ff ff       	call   800c7a <sys_page_unmap>
	return r;
  801116:	83 c4 10             	add    $0x10,%esp
  801119:	89 f8                	mov    %edi,%eax
}
  80111b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80111e:	5b                   	pop    %ebx
  80111f:	5e                   	pop    %esi
  801120:	5f                   	pop    %edi
  801121:	5d                   	pop    %ebp
  801122:	c3                   	ret    

00801123 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801123:	55                   	push   %ebp
  801124:	89 e5                	mov    %esp,%ebp
  801126:	53                   	push   %ebx
  801127:	83 ec 14             	sub    $0x14,%esp
  80112a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80112d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801130:	50                   	push   %eax
  801131:	53                   	push   %ebx
  801132:	e8 86 fd ff ff       	call   800ebd <fd_lookup>
  801137:	83 c4 08             	add    $0x8,%esp
  80113a:	89 c2                	mov    %eax,%edx
  80113c:	85 c0                	test   %eax,%eax
  80113e:	78 6d                	js     8011ad <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801140:	83 ec 08             	sub    $0x8,%esp
  801143:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801146:	50                   	push   %eax
  801147:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80114a:	ff 30                	pushl  (%eax)
  80114c:	e8 c2 fd ff ff       	call   800f13 <dev_lookup>
  801151:	83 c4 10             	add    $0x10,%esp
  801154:	85 c0                	test   %eax,%eax
  801156:	78 4c                	js     8011a4 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801158:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80115b:	8b 42 08             	mov    0x8(%edx),%eax
  80115e:	83 e0 03             	and    $0x3,%eax
  801161:	83 f8 01             	cmp    $0x1,%eax
  801164:	75 21                	jne    801187 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801166:	a1 08 40 80 00       	mov    0x804008,%eax
  80116b:	8b 40 48             	mov    0x48(%eax),%eax
  80116e:	83 ec 04             	sub    $0x4,%esp
  801171:	53                   	push   %ebx
  801172:	50                   	push   %eax
  801173:	68 ad 2d 80 00       	push   $0x802dad
  801178:	e8 f0 f0 ff ff       	call   80026d <cprintf>
		return -E_INVAL;
  80117d:	83 c4 10             	add    $0x10,%esp
  801180:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801185:	eb 26                	jmp    8011ad <read+0x8a>
	}
	if (!dev->dev_read)
  801187:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80118a:	8b 40 08             	mov    0x8(%eax),%eax
  80118d:	85 c0                	test   %eax,%eax
  80118f:	74 17                	je     8011a8 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801191:	83 ec 04             	sub    $0x4,%esp
  801194:	ff 75 10             	pushl  0x10(%ebp)
  801197:	ff 75 0c             	pushl  0xc(%ebp)
  80119a:	52                   	push   %edx
  80119b:	ff d0                	call   *%eax
  80119d:	89 c2                	mov    %eax,%edx
  80119f:	83 c4 10             	add    $0x10,%esp
  8011a2:	eb 09                	jmp    8011ad <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011a4:	89 c2                	mov    %eax,%edx
  8011a6:	eb 05                	jmp    8011ad <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8011a8:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8011ad:	89 d0                	mov    %edx,%eax
  8011af:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011b2:	c9                   	leave  
  8011b3:	c3                   	ret    

008011b4 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8011b4:	55                   	push   %ebp
  8011b5:	89 e5                	mov    %esp,%ebp
  8011b7:	57                   	push   %edi
  8011b8:	56                   	push   %esi
  8011b9:	53                   	push   %ebx
  8011ba:	83 ec 0c             	sub    $0xc,%esp
  8011bd:	8b 7d 08             	mov    0x8(%ebp),%edi
  8011c0:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8011c3:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011c8:	eb 21                	jmp    8011eb <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8011ca:	83 ec 04             	sub    $0x4,%esp
  8011cd:	89 f0                	mov    %esi,%eax
  8011cf:	29 d8                	sub    %ebx,%eax
  8011d1:	50                   	push   %eax
  8011d2:	89 d8                	mov    %ebx,%eax
  8011d4:	03 45 0c             	add    0xc(%ebp),%eax
  8011d7:	50                   	push   %eax
  8011d8:	57                   	push   %edi
  8011d9:	e8 45 ff ff ff       	call   801123 <read>
		if (m < 0)
  8011de:	83 c4 10             	add    $0x10,%esp
  8011e1:	85 c0                	test   %eax,%eax
  8011e3:	78 10                	js     8011f5 <readn+0x41>
			return m;
		if (m == 0)
  8011e5:	85 c0                	test   %eax,%eax
  8011e7:	74 0a                	je     8011f3 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8011e9:	01 c3                	add    %eax,%ebx
  8011eb:	39 f3                	cmp    %esi,%ebx
  8011ed:	72 db                	jb     8011ca <readn+0x16>
  8011ef:	89 d8                	mov    %ebx,%eax
  8011f1:	eb 02                	jmp    8011f5 <readn+0x41>
  8011f3:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8011f5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011f8:	5b                   	pop    %ebx
  8011f9:	5e                   	pop    %esi
  8011fa:	5f                   	pop    %edi
  8011fb:	5d                   	pop    %ebp
  8011fc:	c3                   	ret    

008011fd <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8011fd:	55                   	push   %ebp
  8011fe:	89 e5                	mov    %esp,%ebp
  801200:	53                   	push   %ebx
  801201:	83 ec 14             	sub    $0x14,%esp
  801204:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801207:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80120a:	50                   	push   %eax
  80120b:	53                   	push   %ebx
  80120c:	e8 ac fc ff ff       	call   800ebd <fd_lookup>
  801211:	83 c4 08             	add    $0x8,%esp
  801214:	89 c2                	mov    %eax,%edx
  801216:	85 c0                	test   %eax,%eax
  801218:	78 68                	js     801282 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80121a:	83 ec 08             	sub    $0x8,%esp
  80121d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801220:	50                   	push   %eax
  801221:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801224:	ff 30                	pushl  (%eax)
  801226:	e8 e8 fc ff ff       	call   800f13 <dev_lookup>
  80122b:	83 c4 10             	add    $0x10,%esp
  80122e:	85 c0                	test   %eax,%eax
  801230:	78 47                	js     801279 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801232:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801235:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801239:	75 21                	jne    80125c <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80123b:	a1 08 40 80 00       	mov    0x804008,%eax
  801240:	8b 40 48             	mov    0x48(%eax),%eax
  801243:	83 ec 04             	sub    $0x4,%esp
  801246:	53                   	push   %ebx
  801247:	50                   	push   %eax
  801248:	68 c9 2d 80 00       	push   $0x802dc9
  80124d:	e8 1b f0 ff ff       	call   80026d <cprintf>
		return -E_INVAL;
  801252:	83 c4 10             	add    $0x10,%esp
  801255:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80125a:	eb 26                	jmp    801282 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80125c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80125f:	8b 52 0c             	mov    0xc(%edx),%edx
  801262:	85 d2                	test   %edx,%edx
  801264:	74 17                	je     80127d <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801266:	83 ec 04             	sub    $0x4,%esp
  801269:	ff 75 10             	pushl  0x10(%ebp)
  80126c:	ff 75 0c             	pushl  0xc(%ebp)
  80126f:	50                   	push   %eax
  801270:	ff d2                	call   *%edx
  801272:	89 c2                	mov    %eax,%edx
  801274:	83 c4 10             	add    $0x10,%esp
  801277:	eb 09                	jmp    801282 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801279:	89 c2                	mov    %eax,%edx
  80127b:	eb 05                	jmp    801282 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80127d:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801282:	89 d0                	mov    %edx,%eax
  801284:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801287:	c9                   	leave  
  801288:	c3                   	ret    

00801289 <seek>:

int
seek(int fdnum, off_t offset)
{
  801289:	55                   	push   %ebp
  80128a:	89 e5                	mov    %esp,%ebp
  80128c:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80128f:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801292:	50                   	push   %eax
  801293:	ff 75 08             	pushl  0x8(%ebp)
  801296:	e8 22 fc ff ff       	call   800ebd <fd_lookup>
  80129b:	83 c4 08             	add    $0x8,%esp
  80129e:	85 c0                	test   %eax,%eax
  8012a0:	78 0e                	js     8012b0 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8012a2:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8012a5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012a8:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8012ab:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8012b0:	c9                   	leave  
  8012b1:	c3                   	ret    

008012b2 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8012b2:	55                   	push   %ebp
  8012b3:	89 e5                	mov    %esp,%ebp
  8012b5:	53                   	push   %ebx
  8012b6:	83 ec 14             	sub    $0x14,%esp
  8012b9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012bc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012bf:	50                   	push   %eax
  8012c0:	53                   	push   %ebx
  8012c1:	e8 f7 fb ff ff       	call   800ebd <fd_lookup>
  8012c6:	83 c4 08             	add    $0x8,%esp
  8012c9:	89 c2                	mov    %eax,%edx
  8012cb:	85 c0                	test   %eax,%eax
  8012cd:	78 65                	js     801334 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012cf:	83 ec 08             	sub    $0x8,%esp
  8012d2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012d5:	50                   	push   %eax
  8012d6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012d9:	ff 30                	pushl  (%eax)
  8012db:	e8 33 fc ff ff       	call   800f13 <dev_lookup>
  8012e0:	83 c4 10             	add    $0x10,%esp
  8012e3:	85 c0                	test   %eax,%eax
  8012e5:	78 44                	js     80132b <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8012e7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012ea:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8012ee:	75 21                	jne    801311 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8012f0:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8012f5:	8b 40 48             	mov    0x48(%eax),%eax
  8012f8:	83 ec 04             	sub    $0x4,%esp
  8012fb:	53                   	push   %ebx
  8012fc:	50                   	push   %eax
  8012fd:	68 8c 2d 80 00       	push   $0x802d8c
  801302:	e8 66 ef ff ff       	call   80026d <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801307:	83 c4 10             	add    $0x10,%esp
  80130a:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80130f:	eb 23                	jmp    801334 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801311:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801314:	8b 52 18             	mov    0x18(%edx),%edx
  801317:	85 d2                	test   %edx,%edx
  801319:	74 14                	je     80132f <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80131b:	83 ec 08             	sub    $0x8,%esp
  80131e:	ff 75 0c             	pushl  0xc(%ebp)
  801321:	50                   	push   %eax
  801322:	ff d2                	call   *%edx
  801324:	89 c2                	mov    %eax,%edx
  801326:	83 c4 10             	add    $0x10,%esp
  801329:	eb 09                	jmp    801334 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80132b:	89 c2                	mov    %eax,%edx
  80132d:	eb 05                	jmp    801334 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80132f:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801334:	89 d0                	mov    %edx,%eax
  801336:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801339:	c9                   	leave  
  80133a:	c3                   	ret    

0080133b <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80133b:	55                   	push   %ebp
  80133c:	89 e5                	mov    %esp,%ebp
  80133e:	53                   	push   %ebx
  80133f:	83 ec 14             	sub    $0x14,%esp
  801342:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801345:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801348:	50                   	push   %eax
  801349:	ff 75 08             	pushl  0x8(%ebp)
  80134c:	e8 6c fb ff ff       	call   800ebd <fd_lookup>
  801351:	83 c4 08             	add    $0x8,%esp
  801354:	89 c2                	mov    %eax,%edx
  801356:	85 c0                	test   %eax,%eax
  801358:	78 58                	js     8013b2 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80135a:	83 ec 08             	sub    $0x8,%esp
  80135d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801360:	50                   	push   %eax
  801361:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801364:	ff 30                	pushl  (%eax)
  801366:	e8 a8 fb ff ff       	call   800f13 <dev_lookup>
  80136b:	83 c4 10             	add    $0x10,%esp
  80136e:	85 c0                	test   %eax,%eax
  801370:	78 37                	js     8013a9 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801372:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801375:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801379:	74 32                	je     8013ad <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80137b:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80137e:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801385:	00 00 00 
	stat->st_isdir = 0;
  801388:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80138f:	00 00 00 
	stat->st_dev = dev;
  801392:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801398:	83 ec 08             	sub    $0x8,%esp
  80139b:	53                   	push   %ebx
  80139c:	ff 75 f0             	pushl  -0x10(%ebp)
  80139f:	ff 50 14             	call   *0x14(%eax)
  8013a2:	89 c2                	mov    %eax,%edx
  8013a4:	83 c4 10             	add    $0x10,%esp
  8013a7:	eb 09                	jmp    8013b2 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013a9:	89 c2                	mov    %eax,%edx
  8013ab:	eb 05                	jmp    8013b2 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8013ad:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8013b2:	89 d0                	mov    %edx,%eax
  8013b4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013b7:	c9                   	leave  
  8013b8:	c3                   	ret    

008013b9 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8013b9:	55                   	push   %ebp
  8013ba:	89 e5                	mov    %esp,%ebp
  8013bc:	56                   	push   %esi
  8013bd:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8013be:	83 ec 08             	sub    $0x8,%esp
  8013c1:	6a 00                	push   $0x0
  8013c3:	ff 75 08             	pushl  0x8(%ebp)
  8013c6:	e8 d6 01 00 00       	call   8015a1 <open>
  8013cb:	89 c3                	mov    %eax,%ebx
  8013cd:	83 c4 10             	add    $0x10,%esp
  8013d0:	85 c0                	test   %eax,%eax
  8013d2:	78 1b                	js     8013ef <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8013d4:	83 ec 08             	sub    $0x8,%esp
  8013d7:	ff 75 0c             	pushl  0xc(%ebp)
  8013da:	50                   	push   %eax
  8013db:	e8 5b ff ff ff       	call   80133b <fstat>
  8013e0:	89 c6                	mov    %eax,%esi
	close(fd);
  8013e2:	89 1c 24             	mov    %ebx,(%esp)
  8013e5:	e8 fd fb ff ff       	call   800fe7 <close>
	return r;
  8013ea:	83 c4 10             	add    $0x10,%esp
  8013ed:	89 f0                	mov    %esi,%eax
}
  8013ef:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013f2:	5b                   	pop    %ebx
  8013f3:	5e                   	pop    %esi
  8013f4:	5d                   	pop    %ebp
  8013f5:	c3                   	ret    

008013f6 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8013f6:	55                   	push   %ebp
  8013f7:	89 e5                	mov    %esp,%ebp
  8013f9:	56                   	push   %esi
  8013fa:	53                   	push   %ebx
  8013fb:	89 c6                	mov    %eax,%esi
  8013fd:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8013ff:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801406:	75 12                	jne    80141a <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801408:	83 ec 0c             	sub    $0xc,%esp
  80140b:	6a 01                	push   $0x1
  80140d:	e8 24 12 00 00       	call   802636 <ipc_find_env>
  801412:	a3 00 40 80 00       	mov    %eax,0x804000
  801417:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80141a:	6a 07                	push   $0x7
  80141c:	68 00 50 80 00       	push   $0x805000
  801421:	56                   	push   %esi
  801422:	ff 35 00 40 80 00    	pushl  0x804000
  801428:	e8 b5 11 00 00       	call   8025e2 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80142d:	83 c4 0c             	add    $0xc,%esp
  801430:	6a 00                	push   $0x0
  801432:	53                   	push   %ebx
  801433:	6a 00                	push   $0x0
  801435:	e8 41 11 00 00       	call   80257b <ipc_recv>
}
  80143a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80143d:	5b                   	pop    %ebx
  80143e:	5e                   	pop    %esi
  80143f:	5d                   	pop    %ebp
  801440:	c3                   	ret    

00801441 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801441:	55                   	push   %ebp
  801442:	89 e5                	mov    %esp,%ebp
  801444:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801447:	8b 45 08             	mov    0x8(%ebp),%eax
  80144a:	8b 40 0c             	mov    0xc(%eax),%eax
  80144d:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801452:	8b 45 0c             	mov    0xc(%ebp),%eax
  801455:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80145a:	ba 00 00 00 00       	mov    $0x0,%edx
  80145f:	b8 02 00 00 00       	mov    $0x2,%eax
  801464:	e8 8d ff ff ff       	call   8013f6 <fsipc>
}
  801469:	c9                   	leave  
  80146a:	c3                   	ret    

0080146b <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80146b:	55                   	push   %ebp
  80146c:	89 e5                	mov    %esp,%ebp
  80146e:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801471:	8b 45 08             	mov    0x8(%ebp),%eax
  801474:	8b 40 0c             	mov    0xc(%eax),%eax
  801477:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80147c:	ba 00 00 00 00       	mov    $0x0,%edx
  801481:	b8 06 00 00 00       	mov    $0x6,%eax
  801486:	e8 6b ff ff ff       	call   8013f6 <fsipc>
}
  80148b:	c9                   	leave  
  80148c:	c3                   	ret    

0080148d <devfile_stat>:

}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80148d:	55                   	push   %ebp
  80148e:	89 e5                	mov    %esp,%ebp
  801490:	53                   	push   %ebx
  801491:	83 ec 04             	sub    $0x4,%esp
  801494:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801497:	8b 45 08             	mov    0x8(%ebp),%eax
  80149a:	8b 40 0c             	mov    0xc(%eax),%eax
  80149d:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8014a2:	ba 00 00 00 00       	mov    $0x0,%edx
  8014a7:	b8 05 00 00 00       	mov    $0x5,%eax
  8014ac:	e8 45 ff ff ff       	call   8013f6 <fsipc>
  8014b1:	85 c0                	test   %eax,%eax
  8014b3:	78 2c                	js     8014e1 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8014b5:	83 ec 08             	sub    $0x8,%esp
  8014b8:	68 00 50 80 00       	push   $0x805000
  8014bd:	53                   	push   %ebx
  8014be:	e8 2f f3 ff ff       	call   8007f2 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8014c3:	a1 80 50 80 00       	mov    0x805080,%eax
  8014c8:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8014ce:	a1 84 50 80 00       	mov    0x805084,%eax
  8014d3:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8014d9:	83 c4 10             	add    $0x10,%esp
  8014dc:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8014e1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014e4:	c9                   	leave  
  8014e5:	c3                   	ret    

008014e6 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8014e6:	55                   	push   %ebp
  8014e7:	89 e5                	mov    %esp,%ebp
  8014e9:	83 ec 0c             	sub    $0xc,%esp
  8014ec:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	// panic("devfile_write not implemented");

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8014ef:	8b 55 08             	mov    0x8(%ebp),%edx
  8014f2:	8b 52 0c             	mov    0xc(%edx),%edx
  8014f5:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  8014fb:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  801500:	50                   	push   %eax
  801501:	ff 75 0c             	pushl  0xc(%ebp)
  801504:	68 08 50 80 00       	push   $0x805008
  801509:	e8 76 f4 ff ff       	call   800984 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  80150e:	ba 00 00 00 00       	mov    $0x0,%edx
  801513:	b8 04 00 00 00       	mov    $0x4,%eax
  801518:	e8 d9 fe ff ff       	call   8013f6 <fsipc>

}
  80151d:	c9                   	leave  
  80151e:	c3                   	ret    

0080151f <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80151f:	55                   	push   %ebp
  801520:	89 e5                	mov    %esp,%ebp
  801522:	56                   	push   %esi
  801523:	53                   	push   %ebx
  801524:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801527:	8b 45 08             	mov    0x8(%ebp),%eax
  80152a:	8b 40 0c             	mov    0xc(%eax),%eax
  80152d:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801532:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801538:	ba 00 00 00 00       	mov    $0x0,%edx
  80153d:	b8 03 00 00 00       	mov    $0x3,%eax
  801542:	e8 af fe ff ff       	call   8013f6 <fsipc>
  801547:	89 c3                	mov    %eax,%ebx
  801549:	85 c0                	test   %eax,%eax
  80154b:	78 4b                	js     801598 <devfile_read+0x79>
		return r;
	assert(r <= n);
  80154d:	39 c6                	cmp    %eax,%esi
  80154f:	73 16                	jae    801567 <devfile_read+0x48>
  801551:	68 fc 2d 80 00       	push   $0x802dfc
  801556:	68 03 2e 80 00       	push   $0x802e03
  80155b:	6a 7c                	push   $0x7c
  80155d:	68 18 2e 80 00       	push   $0x802e18
  801562:	e8 2d ec ff ff       	call   800194 <_panic>
	assert(r <= PGSIZE);
  801567:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80156c:	7e 16                	jle    801584 <devfile_read+0x65>
  80156e:	68 23 2e 80 00       	push   $0x802e23
  801573:	68 03 2e 80 00       	push   $0x802e03
  801578:	6a 7d                	push   $0x7d
  80157a:	68 18 2e 80 00       	push   $0x802e18
  80157f:	e8 10 ec ff ff       	call   800194 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801584:	83 ec 04             	sub    $0x4,%esp
  801587:	50                   	push   %eax
  801588:	68 00 50 80 00       	push   $0x805000
  80158d:	ff 75 0c             	pushl  0xc(%ebp)
  801590:	e8 ef f3 ff ff       	call   800984 <memmove>
	return r;
  801595:	83 c4 10             	add    $0x10,%esp
}
  801598:	89 d8                	mov    %ebx,%eax
  80159a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80159d:	5b                   	pop    %ebx
  80159e:	5e                   	pop    %esi
  80159f:	5d                   	pop    %ebp
  8015a0:	c3                   	ret    

008015a1 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8015a1:	55                   	push   %ebp
  8015a2:	89 e5                	mov    %esp,%ebp
  8015a4:	53                   	push   %ebx
  8015a5:	83 ec 20             	sub    $0x20,%esp
  8015a8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8015ab:	53                   	push   %ebx
  8015ac:	e8 08 f2 ff ff       	call   8007b9 <strlen>
  8015b1:	83 c4 10             	add    $0x10,%esp
  8015b4:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8015b9:	7f 67                	jg     801622 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8015bb:	83 ec 0c             	sub    $0xc,%esp
  8015be:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015c1:	50                   	push   %eax
  8015c2:	e8 a7 f8 ff ff       	call   800e6e <fd_alloc>
  8015c7:	83 c4 10             	add    $0x10,%esp
		return r;
  8015ca:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8015cc:	85 c0                	test   %eax,%eax
  8015ce:	78 57                	js     801627 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8015d0:	83 ec 08             	sub    $0x8,%esp
  8015d3:	53                   	push   %ebx
  8015d4:	68 00 50 80 00       	push   $0x805000
  8015d9:	e8 14 f2 ff ff       	call   8007f2 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8015de:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015e1:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8015e6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015e9:	b8 01 00 00 00       	mov    $0x1,%eax
  8015ee:	e8 03 fe ff ff       	call   8013f6 <fsipc>
  8015f3:	89 c3                	mov    %eax,%ebx
  8015f5:	83 c4 10             	add    $0x10,%esp
  8015f8:	85 c0                	test   %eax,%eax
  8015fa:	79 14                	jns    801610 <open+0x6f>
		fd_close(fd, 0);
  8015fc:	83 ec 08             	sub    $0x8,%esp
  8015ff:	6a 00                	push   $0x0
  801601:	ff 75 f4             	pushl  -0xc(%ebp)
  801604:	e8 5d f9 ff ff       	call   800f66 <fd_close>
		return r;
  801609:	83 c4 10             	add    $0x10,%esp
  80160c:	89 da                	mov    %ebx,%edx
  80160e:	eb 17                	jmp    801627 <open+0x86>
	}

	return fd2num(fd);
  801610:	83 ec 0c             	sub    $0xc,%esp
  801613:	ff 75 f4             	pushl  -0xc(%ebp)
  801616:	e8 2c f8 ff ff       	call   800e47 <fd2num>
  80161b:	89 c2                	mov    %eax,%edx
  80161d:	83 c4 10             	add    $0x10,%esp
  801620:	eb 05                	jmp    801627 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801622:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801627:	89 d0                	mov    %edx,%eax
  801629:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80162c:	c9                   	leave  
  80162d:	c3                   	ret    

0080162e <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80162e:	55                   	push   %ebp
  80162f:	89 e5                	mov    %esp,%ebp
  801631:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801634:	ba 00 00 00 00       	mov    $0x0,%edx
  801639:	b8 08 00 00 00       	mov    $0x8,%eax
  80163e:	e8 b3 fd ff ff       	call   8013f6 <fsipc>
}
  801643:	c9                   	leave  
  801644:	c3                   	ret    

00801645 <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  801645:	55                   	push   %ebp
  801646:	89 e5                	mov    %esp,%ebp
  801648:	57                   	push   %edi
  801649:	56                   	push   %esi
  80164a:	53                   	push   %ebx
  80164b:	81 ec 94 02 00 00    	sub    $0x294,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  801651:	6a 00                	push   $0x0
  801653:	ff 75 08             	pushl  0x8(%ebp)
  801656:	e8 46 ff ff ff       	call   8015a1 <open>
  80165b:	89 c7                	mov    %eax,%edi
  80165d:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  801663:	83 c4 10             	add    $0x10,%esp
  801666:	85 c0                	test   %eax,%eax
  801668:	0f 88 97 04 00 00    	js     801b05 <spawn+0x4c0>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  80166e:	83 ec 04             	sub    $0x4,%esp
  801671:	68 00 02 00 00       	push   $0x200
  801676:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  80167c:	50                   	push   %eax
  80167d:	57                   	push   %edi
  80167e:	e8 31 fb ff ff       	call   8011b4 <readn>
  801683:	83 c4 10             	add    $0x10,%esp
  801686:	3d 00 02 00 00       	cmp    $0x200,%eax
  80168b:	75 0c                	jne    801699 <spawn+0x54>
	    || elf->e_magic != ELF_MAGIC) {
  80168d:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  801694:	45 4c 46 
  801697:	74 33                	je     8016cc <spawn+0x87>
		close(fd);
  801699:	83 ec 0c             	sub    $0xc,%esp
  80169c:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  8016a2:	e8 40 f9 ff ff       	call   800fe7 <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  8016a7:	83 c4 0c             	add    $0xc,%esp
  8016aa:	68 7f 45 4c 46       	push   $0x464c457f
  8016af:	ff b5 e8 fd ff ff    	pushl  -0x218(%ebp)
  8016b5:	68 2f 2e 80 00       	push   $0x802e2f
  8016ba:	e8 ae eb ff ff       	call   80026d <cprintf>
		return -E_NOT_EXEC;
  8016bf:	83 c4 10             	add    $0x10,%esp
  8016c2:	bb f2 ff ff ff       	mov    $0xfffffff2,%ebx
  8016c7:	e9 ec 04 00 00       	jmp    801bb8 <spawn+0x573>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  8016cc:	b8 07 00 00 00       	mov    $0x7,%eax
  8016d1:	cd 30                	int    $0x30
  8016d3:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
  8016d9:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  8016df:	85 c0                	test   %eax,%eax
  8016e1:	0f 88 29 04 00 00    	js     801b10 <spawn+0x4cb>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  8016e7:	89 c6                	mov    %eax,%esi
  8016e9:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  8016ef:	6b f6 7c             	imul   $0x7c,%esi,%esi
  8016f2:	81 c6 00 00 c0 ee    	add    $0xeec00000,%esi
  8016f8:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  8016fe:	b9 11 00 00 00       	mov    $0x11,%ecx
  801703:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  801705:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  80170b:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801711:	bb 00 00 00 00       	mov    $0x0,%ebx
	char *string_store;
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
  801716:	be 00 00 00 00       	mov    $0x0,%esi
  80171b:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80171e:	eb 13                	jmp    801733 <spawn+0xee>
	for (argc = 0; argv[argc] != 0; argc++)
		string_size += strlen(argv[argc]) + 1;
  801720:	83 ec 0c             	sub    $0xc,%esp
  801723:	50                   	push   %eax
  801724:	e8 90 f0 ff ff       	call   8007b9 <strlen>
  801729:	8d 74 30 01          	lea    0x1(%eax,%esi,1),%esi
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  80172d:	83 c3 01             	add    $0x1,%ebx
  801730:	83 c4 10             	add    $0x10,%esp
  801733:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
  80173a:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  80173d:	85 c0                	test   %eax,%eax
  80173f:	75 df                	jne    801720 <spawn+0xdb>
  801741:	89 9d 88 fd ff ff    	mov    %ebx,-0x278(%ebp)
  801747:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  80174d:	bf 00 10 40 00       	mov    $0x401000,%edi
  801752:	29 f7                	sub    %esi,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  801754:	89 fa                	mov    %edi,%edx
  801756:	83 e2 fc             	and    $0xfffffffc,%edx
  801759:	8d 04 9d 04 00 00 00 	lea    0x4(,%ebx,4),%eax
  801760:	29 c2                	sub    %eax,%edx
  801762:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  801768:	8d 42 f8             	lea    -0x8(%edx),%eax
  80176b:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  801770:	0f 86 b0 03 00 00    	jbe    801b26 <spawn+0x4e1>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801776:	83 ec 04             	sub    $0x4,%esp
  801779:	6a 07                	push   $0x7
  80177b:	68 00 00 40 00       	push   $0x400000
  801780:	6a 00                	push   $0x0
  801782:	e8 6e f4 ff ff       	call   800bf5 <sys_page_alloc>
  801787:	83 c4 10             	add    $0x10,%esp
  80178a:	85 c0                	test   %eax,%eax
  80178c:	0f 88 9e 03 00 00    	js     801b30 <spawn+0x4eb>
  801792:	be 00 00 00 00       	mov    $0x0,%esi
  801797:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
  80179d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8017a0:	eb 30                	jmp    8017d2 <spawn+0x18d>
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
		argv_store[i] = UTEMP2USTACK(string_store);
  8017a2:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  8017a8:	8b 8d 94 fd ff ff    	mov    -0x26c(%ebp),%ecx
  8017ae:	89 04 b1             	mov    %eax,(%ecx,%esi,4)
		strcpy(string_store, argv[i]);
  8017b1:	83 ec 08             	sub    $0x8,%esp
  8017b4:	ff 34 b3             	pushl  (%ebx,%esi,4)
  8017b7:	57                   	push   %edi
  8017b8:	e8 35 f0 ff ff       	call   8007f2 <strcpy>
		string_store += strlen(argv[i]) + 1;
  8017bd:	83 c4 04             	add    $0x4,%esp
  8017c0:	ff 34 b3             	pushl  (%ebx,%esi,4)
  8017c3:	e8 f1 ef ff ff       	call   8007b9 <strlen>
  8017c8:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  8017cc:	83 c6 01             	add    $0x1,%esi
  8017cf:	83 c4 10             	add    $0x10,%esp
  8017d2:	39 b5 90 fd ff ff    	cmp    %esi,-0x270(%ebp)
  8017d8:	7f c8                	jg     8017a2 <spawn+0x15d>
		argv_store[i] = UTEMP2USTACK(string_store);
		strcpy(string_store, argv[i]);
		string_store += strlen(argv[i]) + 1;
	}
	argv_store[argc] = 0;
  8017da:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  8017e0:	8b b5 80 fd ff ff    	mov    -0x280(%ebp),%esi
  8017e6:	c7 04 30 00 00 00 00 	movl   $0x0,(%eax,%esi,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  8017ed:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  8017f3:	74 19                	je     80180e <spawn+0x1c9>
  8017f5:	68 bc 2e 80 00       	push   $0x802ebc
  8017fa:	68 03 2e 80 00       	push   $0x802e03
  8017ff:	68 f2 00 00 00       	push   $0xf2
  801804:	68 49 2e 80 00       	push   $0x802e49
  801809:	e8 86 e9 ff ff       	call   800194 <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  80180e:	8b bd 94 fd ff ff    	mov    -0x26c(%ebp),%edi
  801814:	89 f8                	mov    %edi,%eax
  801816:	2d 00 30 80 11       	sub    $0x11803000,%eax
  80181b:	89 47 fc             	mov    %eax,-0x4(%edi)
	argv_store[-2] = argc;
  80181e:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801824:	89 47 f8             	mov    %eax,-0x8(%edi)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  801827:	8d 87 f8 cf 7f ee    	lea    -0x11803008(%edi),%eax
  80182d:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  801833:	83 ec 0c             	sub    $0xc,%esp
  801836:	6a 07                	push   $0x7
  801838:	68 00 d0 bf ee       	push   $0xeebfd000
  80183d:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801843:	68 00 00 40 00       	push   $0x400000
  801848:	6a 00                	push   $0x0
  80184a:	e8 e9 f3 ff ff       	call   800c38 <sys_page_map>
  80184f:	89 c3                	mov    %eax,%ebx
  801851:	83 c4 20             	add    $0x20,%esp
  801854:	85 c0                	test   %eax,%eax
  801856:	0f 88 4a 03 00 00    	js     801ba6 <spawn+0x561>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  80185c:	83 ec 08             	sub    $0x8,%esp
  80185f:	68 00 00 40 00       	push   $0x400000
  801864:	6a 00                	push   $0x0
  801866:	e8 0f f4 ff ff       	call   800c7a <sys_page_unmap>
  80186b:	89 c3                	mov    %eax,%ebx
  80186d:	83 c4 10             	add    $0x10,%esp
  801870:	85 c0                	test   %eax,%eax
  801872:	0f 88 2e 03 00 00    	js     801ba6 <spawn+0x561>

	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  801878:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
  80187e:	8d 84 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%eax
  801885:	89 85 7c fd ff ff    	mov    %eax,-0x284(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  80188b:	c7 85 78 fd ff ff 00 	movl   $0x0,-0x288(%ebp)
  801892:	00 00 00 
  801895:	e9 8a 01 00 00       	jmp    801a24 <spawn+0x3df>
		if (ph->p_type != ELF_PROG_LOAD)
  80189a:	8b 85 7c fd ff ff    	mov    -0x284(%ebp),%eax
  8018a0:	83 38 01             	cmpl   $0x1,(%eax)
  8018a3:	0f 85 6d 01 00 00    	jne    801a16 <spawn+0x3d1>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  8018a9:	89 c7                	mov    %eax,%edi
  8018ab:	8b 40 18             	mov    0x18(%eax),%eax
  8018ae:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  8018b4:	83 e0 02             	and    $0x2,%eax
			perm |= PTE_W;
  8018b7:	83 f8 01             	cmp    $0x1,%eax
  8018ba:	19 c0                	sbb    %eax,%eax
  8018bc:	83 e0 fe             	and    $0xfffffffe,%eax
  8018bf:	83 c0 07             	add    $0x7,%eax
  8018c2:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  8018c8:	89 f8                	mov    %edi,%eax
  8018ca:	8b 7f 04             	mov    0x4(%edi),%edi
  8018cd:	89 f9                	mov    %edi,%ecx
  8018cf:	89 bd 80 fd ff ff    	mov    %edi,-0x280(%ebp)
  8018d5:	8b 78 10             	mov    0x10(%eax),%edi
  8018d8:	8b 70 14             	mov    0x14(%eax),%esi
  8018db:	89 f3                	mov    %esi,%ebx
  8018dd:	89 b5 90 fd ff ff    	mov    %esi,-0x270(%ebp)
  8018e3:	8b 70 08             	mov    0x8(%eax),%esi
	int i, r;
	void *blk;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  8018e6:	89 f0                	mov    %esi,%eax
  8018e8:	25 ff 0f 00 00       	and    $0xfff,%eax
  8018ed:	74 14                	je     801903 <spawn+0x2be>
		va -= i;
  8018ef:	29 c6                	sub    %eax,%esi
		memsz += i;
  8018f1:	01 c3                	add    %eax,%ebx
  8018f3:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
		filesz += i;
  8018f9:	01 c7                	add    %eax,%edi
		fileoffset -= i;
  8018fb:	29 c1                	sub    %eax,%ecx
  8018fd:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801903:	bb 00 00 00 00       	mov    $0x0,%ebx
  801908:	e9 f7 00 00 00       	jmp    801a04 <spawn+0x3bf>
		if (i >= filesz) {
  80190d:	39 df                	cmp    %ebx,%edi
  80190f:	77 27                	ja     801938 <spawn+0x2f3>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  801911:	83 ec 04             	sub    $0x4,%esp
  801914:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  80191a:	56                   	push   %esi
  80191b:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  801921:	e8 cf f2 ff ff       	call   800bf5 <sys_page_alloc>
  801926:	83 c4 10             	add    $0x10,%esp
  801929:	85 c0                	test   %eax,%eax
  80192b:	0f 89 c7 00 00 00    	jns    8019f8 <spawn+0x3b3>
  801931:	89 c3                	mov    %eax,%ebx
  801933:	e9 09 02 00 00       	jmp    801b41 <spawn+0x4fc>
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801938:	83 ec 04             	sub    $0x4,%esp
  80193b:	6a 07                	push   $0x7
  80193d:	68 00 00 40 00       	push   $0x400000
  801942:	6a 00                	push   $0x0
  801944:	e8 ac f2 ff ff       	call   800bf5 <sys_page_alloc>
  801949:	83 c4 10             	add    $0x10,%esp
  80194c:	85 c0                	test   %eax,%eax
  80194e:	0f 88 e3 01 00 00    	js     801b37 <spawn+0x4f2>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801954:	83 ec 08             	sub    $0x8,%esp
  801957:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  80195d:	03 85 94 fd ff ff    	add    -0x26c(%ebp),%eax
  801963:	50                   	push   %eax
  801964:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  80196a:	e8 1a f9 ff ff       	call   801289 <seek>
  80196f:	83 c4 10             	add    $0x10,%esp
  801972:	85 c0                	test   %eax,%eax
  801974:	0f 88 c1 01 00 00    	js     801b3b <spawn+0x4f6>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  80197a:	83 ec 04             	sub    $0x4,%esp
  80197d:	89 f8                	mov    %edi,%eax
  80197f:	2b 85 94 fd ff ff    	sub    -0x26c(%ebp),%eax
  801985:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80198a:	b9 00 10 00 00       	mov    $0x1000,%ecx
  80198f:	0f 47 c1             	cmova  %ecx,%eax
  801992:	50                   	push   %eax
  801993:	68 00 00 40 00       	push   $0x400000
  801998:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  80199e:	e8 11 f8 ff ff       	call   8011b4 <readn>
  8019a3:	83 c4 10             	add    $0x10,%esp
  8019a6:	85 c0                	test   %eax,%eax
  8019a8:	0f 88 91 01 00 00    	js     801b3f <spawn+0x4fa>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  8019ae:	83 ec 0c             	sub    $0xc,%esp
  8019b1:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  8019b7:	56                   	push   %esi
  8019b8:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  8019be:	68 00 00 40 00       	push   $0x400000
  8019c3:	6a 00                	push   $0x0
  8019c5:	e8 6e f2 ff ff       	call   800c38 <sys_page_map>
  8019ca:	83 c4 20             	add    $0x20,%esp
  8019cd:	85 c0                	test   %eax,%eax
  8019cf:	79 15                	jns    8019e6 <spawn+0x3a1>
				panic("spawn: sys_page_map data: %e", r);
  8019d1:	50                   	push   %eax
  8019d2:	68 55 2e 80 00       	push   $0x802e55
  8019d7:	68 25 01 00 00       	push   $0x125
  8019dc:	68 49 2e 80 00       	push   $0x802e49
  8019e1:	e8 ae e7 ff ff       	call   800194 <_panic>
			sys_page_unmap(0, UTEMP);
  8019e6:	83 ec 08             	sub    $0x8,%esp
  8019e9:	68 00 00 40 00       	push   $0x400000
  8019ee:	6a 00                	push   $0x0
  8019f0:	e8 85 f2 ff ff       	call   800c7a <sys_page_unmap>
  8019f5:	83 c4 10             	add    $0x10,%esp
		memsz += i;
		filesz += i;
		fileoffset -= i;
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  8019f8:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8019fe:	81 c6 00 10 00 00    	add    $0x1000,%esi
  801a04:	89 9d 94 fd ff ff    	mov    %ebx,-0x26c(%ebp)
  801a0a:	39 9d 90 fd ff ff    	cmp    %ebx,-0x270(%ebp)
  801a10:	0f 87 f7 fe ff ff    	ja     80190d <spawn+0x2c8>
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801a16:	83 85 78 fd ff ff 01 	addl   $0x1,-0x288(%ebp)
  801a1d:	83 85 7c fd ff ff 20 	addl   $0x20,-0x284(%ebp)
  801a24:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  801a2b:	39 85 78 fd ff ff    	cmp    %eax,-0x288(%ebp)
  801a31:	0f 8c 63 fe ff ff    	jl     80189a <spawn+0x255>
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
	}
	close(fd);
  801a37:	83 ec 0c             	sub    $0xc,%esp
  801a3a:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801a40:	e8 a2 f5 ff ff       	call   800fe7 <close>
  801a45:	83 c4 10             	add    $0x10,%esp
{
	// LAB 5: Your code here.

	int r;
	uint32_t addr;
	for (uint32_t pn = PGNUM(UTEXT); pn < PGNUM(USTACKTOP); pn++) {
  801a48:	bb 00 08 00 00       	mov    $0x800,%ebx
  801a4d:	8b b5 84 fd ff ff    	mov    -0x27c(%ebp),%esi

		addr = pn * PGSIZE;
  801a53:	89 d8                	mov    %ebx,%eax
  801a55:	c1 e0 0c             	shl    $0xc,%eax

		// if level-2 page exists
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P) {
  801a58:	89 c2                	mov    %eax,%edx
  801a5a:	c1 ea 16             	shr    $0x16,%edx
  801a5d:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801a64:	f6 c2 01             	test   $0x1,%dl
  801a67:	74 4b                	je     801ab4 <spawn+0x46f>
			
			// if real PTE exists
			if ((uvpt[PGNUM(addr)] & PTE_P) == PTE_P) {
  801a69:	89 c2                	mov    %eax,%edx
  801a6b:	c1 ea 0c             	shr    $0xc,%edx
  801a6e:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
  801a75:	f6 c1 01             	test   $0x1,%cl
  801a78:	74 3a                	je     801ab4 <spawn+0x46f>

				// For each writable or copy-on-write page
				if ((uvpt[PGNUM(addr)] & PTE_SHARE) != 0) {
  801a7a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801a81:	f6 c6 04             	test   $0x4,%dh
  801a84:	74 2e                	je     801ab4 <spawn+0x46f>
					r = sys_page_map(thisenv->env_id, (void *)addr, child, (void *)addr, uvpt[pn] & PTE_SYSCALL);
  801a86:	8b 14 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%edx
  801a8d:	8b 0d 08 40 80 00    	mov    0x804008,%ecx
  801a93:	8b 49 48             	mov    0x48(%ecx),%ecx
  801a96:	83 ec 0c             	sub    $0xc,%esp
  801a99:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801a9f:	52                   	push   %edx
  801aa0:	50                   	push   %eax
  801aa1:	56                   	push   %esi
  801aa2:	50                   	push   %eax
  801aa3:	51                   	push   %ecx
  801aa4:	e8 8f f1 ff ff       	call   800c38 <sys_page_map>
					if (r < 0)
  801aa9:	83 c4 20             	add    $0x20,%esp
  801aac:	85 c0                	test   %eax,%eax
  801aae:	0f 88 ae 00 00 00    	js     801b62 <spawn+0x51d>
{
	// LAB 5: Your code here.

	int r;
	uint32_t addr;
	for (uint32_t pn = PGNUM(UTEXT); pn < PGNUM(USTACKTOP); pn++) {
  801ab4:	83 c3 01             	add    $0x1,%ebx
  801ab7:	81 fb fe eb 0e 00    	cmp    $0xeebfe,%ebx
  801abd:	75 94                	jne    801a53 <spawn+0x40e>
  801abf:	e9 b3 00 00 00       	jmp    801b77 <spawn+0x532>
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	child_tf.tf_eflags |= FL_IOPL_3;   // devious: see user/faultio.c
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
		panic("sys_env_set_trapframe: %e", r);
  801ac4:	50                   	push   %eax
  801ac5:	68 72 2e 80 00       	push   $0x802e72
  801aca:	68 86 00 00 00       	push   $0x86
  801acf:	68 49 2e 80 00       	push   $0x802e49
  801ad4:	e8 bb e6 ff ff       	call   800194 <_panic>

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  801ad9:	83 ec 08             	sub    $0x8,%esp
  801adc:	6a 02                	push   $0x2
  801ade:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801ae4:	e8 d3 f1 ff ff       	call   800cbc <sys_env_set_status>
  801ae9:	83 c4 10             	add    $0x10,%esp
  801aec:	85 c0                	test   %eax,%eax
  801aee:	79 2b                	jns    801b1b <spawn+0x4d6>
		panic("sys_env_set_status: %e", r);
  801af0:	50                   	push   %eax
  801af1:	68 8c 2e 80 00       	push   $0x802e8c
  801af6:	68 89 00 00 00       	push   $0x89
  801afb:	68 49 2e 80 00       	push   $0x802e49
  801b00:	e8 8f e6 ff ff       	call   800194 <_panic>
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
		return r;
  801b05:	8b 9d 8c fd ff ff    	mov    -0x274(%ebp),%ebx
  801b0b:	e9 a8 00 00 00       	jmp    801bb8 <spawn+0x573>
		return -E_NOT_EXEC;
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
		return r;
  801b10:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  801b16:	e9 9d 00 00 00       	jmp    801bb8 <spawn+0x573>
		panic("sys_env_set_trapframe: %e", r);

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
		panic("sys_env_set_status: %e", r);

	return child;
  801b1b:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  801b21:	e9 92 00 00 00       	jmp    801bb8 <spawn+0x573>
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
		return -E_NO_MEM;
  801b26:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
  801b2b:	e9 88 00 00 00       	jmp    801bb8 <spawn+0x573>

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
		return r;
  801b30:	89 c3                	mov    %eax,%ebx
  801b32:	e9 81 00 00 00       	jmp    801bb8 <spawn+0x573>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801b37:	89 c3                	mov    %eax,%ebx
  801b39:	eb 06                	jmp    801b41 <spawn+0x4fc>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801b3b:	89 c3                	mov    %eax,%ebx
  801b3d:	eb 02                	jmp    801b41 <spawn+0x4fc>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801b3f:	89 c3                	mov    %eax,%ebx
		panic("sys_env_set_status: %e", r);

	return child;

error:
	sys_env_destroy(child);
  801b41:	83 ec 0c             	sub    $0xc,%esp
  801b44:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801b4a:	e8 27 f0 ff ff       	call   800b76 <sys_env_destroy>
	close(fd);
  801b4f:	83 c4 04             	add    $0x4,%esp
  801b52:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801b58:	e8 8a f4 ff ff       	call   800fe7 <close>
	return r;
  801b5d:	83 c4 10             	add    $0x10,%esp
  801b60:	eb 56                	jmp    801bb8 <spawn+0x573>
	close(fd);
	fd = -1;

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);
  801b62:	50                   	push   %eax
  801b63:	68 a3 2e 80 00       	push   $0x802ea3
  801b68:	68 82 00 00 00       	push   $0x82
  801b6d:	68 49 2e 80 00       	push   $0x802e49
  801b72:	e8 1d e6 ff ff       	call   800194 <_panic>

	child_tf.tf_eflags |= FL_IOPL_3;   // devious: see user/faultio.c
  801b77:	81 8d dc fd ff ff 00 	orl    $0x3000,-0x224(%ebp)
  801b7e:	30 00 00 
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  801b81:	83 ec 08             	sub    $0x8,%esp
  801b84:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  801b8a:	50                   	push   %eax
  801b8b:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801b91:	e8 68 f1 ff ff       	call   800cfe <sys_env_set_trapframe>
  801b96:	83 c4 10             	add    $0x10,%esp
  801b99:	85 c0                	test   %eax,%eax
  801b9b:	0f 89 38 ff ff ff    	jns    801ad9 <spawn+0x494>
  801ba1:	e9 1e ff ff ff       	jmp    801ac4 <spawn+0x47f>
		goto error;

	return 0;

error:
	sys_page_unmap(0, UTEMP);
  801ba6:	83 ec 08             	sub    $0x8,%esp
  801ba9:	68 00 00 40 00       	push   $0x400000
  801bae:	6a 00                	push   $0x0
  801bb0:	e8 c5 f0 ff ff       	call   800c7a <sys_page_unmap>
  801bb5:	83 c4 10             	add    $0x10,%esp

error:
	sys_env_destroy(child);
	close(fd);
	return r;
}
  801bb8:	89 d8                	mov    %ebx,%eax
  801bba:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bbd:	5b                   	pop    %ebx
  801bbe:	5e                   	pop    %esi
  801bbf:	5f                   	pop    %edi
  801bc0:	5d                   	pop    %ebp
  801bc1:	c3                   	ret    

00801bc2 <spawnl>:
// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
{
  801bc2:	55                   	push   %ebp
  801bc3:	89 e5                	mov    %esp,%ebp
  801bc5:	56                   	push   %esi
  801bc6:	53                   	push   %ebx
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801bc7:	8d 55 10             	lea    0x10(%ebp),%edx
{
	// We calculate argc by advancing the args until we hit NULL.
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
  801bca:	b8 00 00 00 00       	mov    $0x0,%eax
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801bcf:	eb 03                	jmp    801bd4 <spawnl+0x12>
		argc++;
  801bd1:	83 c0 01             	add    $0x1,%eax
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801bd4:	83 c2 04             	add    $0x4,%edx
  801bd7:	83 7a fc 00          	cmpl   $0x0,-0x4(%edx)
  801bdb:	75 f4                	jne    801bd1 <spawnl+0xf>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  801bdd:	8d 14 85 1a 00 00 00 	lea    0x1a(,%eax,4),%edx
  801be4:	83 e2 f0             	and    $0xfffffff0,%edx
  801be7:	29 d4                	sub    %edx,%esp
  801be9:	8d 54 24 03          	lea    0x3(%esp),%edx
  801bed:	c1 ea 02             	shr    $0x2,%edx
  801bf0:	8d 34 95 00 00 00 00 	lea    0x0(,%edx,4),%esi
  801bf7:	89 f3                	mov    %esi,%ebx
	argv[0] = arg0;
  801bf9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801bfc:	89 0c 95 00 00 00 00 	mov    %ecx,0x0(,%edx,4)
	argv[argc+1] = NULL;
  801c03:	c7 44 86 04 00 00 00 	movl   $0x0,0x4(%esi,%eax,4)
  801c0a:	00 
  801c0b:	89 c2                	mov    %eax,%edx

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  801c0d:	b8 00 00 00 00       	mov    $0x0,%eax
  801c12:	eb 0a                	jmp    801c1e <spawnl+0x5c>
		argv[i+1] = va_arg(vl, const char *);
  801c14:	83 c0 01             	add    $0x1,%eax
  801c17:	8b 4c 85 0c          	mov    0xc(%ebp,%eax,4),%ecx
  801c1b:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  801c1e:	39 d0                	cmp    %edx,%eax
  801c20:	75 f2                	jne    801c14 <spawnl+0x52>
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return spawn(prog, argv);
  801c22:	83 ec 08             	sub    $0x8,%esp
  801c25:	56                   	push   %esi
  801c26:	ff 75 08             	pushl  0x8(%ebp)
  801c29:	e8 17 fa ff ff       	call   801645 <spawn>
}
  801c2e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c31:	5b                   	pop    %ebx
  801c32:	5e                   	pop    %esi
  801c33:	5d                   	pop    %ebp
  801c34:	c3                   	ret    

00801c35 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801c35:	55                   	push   %ebp
  801c36:	89 e5                	mov    %esp,%ebp
  801c38:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  801c3b:	68 e4 2e 80 00       	push   $0x802ee4
  801c40:	ff 75 0c             	pushl  0xc(%ebp)
  801c43:	e8 aa eb ff ff       	call   8007f2 <strcpy>
	return 0;
}
  801c48:	b8 00 00 00 00       	mov    $0x0,%eax
  801c4d:	c9                   	leave  
  801c4e:	c3                   	ret    

00801c4f <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801c4f:	55                   	push   %ebp
  801c50:	89 e5                	mov    %esp,%ebp
  801c52:	53                   	push   %ebx
  801c53:	83 ec 10             	sub    $0x10,%esp
  801c56:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801c59:	53                   	push   %ebx
  801c5a:	e8 10 0a 00 00       	call   80266f <pageref>
  801c5f:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  801c62:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  801c67:	83 f8 01             	cmp    $0x1,%eax
  801c6a:	75 10                	jne    801c7c <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  801c6c:	83 ec 0c             	sub    $0xc,%esp
  801c6f:	ff 73 0c             	pushl  0xc(%ebx)
  801c72:	e8 c0 02 00 00       	call   801f37 <nsipc_close>
  801c77:	89 c2                	mov    %eax,%edx
  801c79:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  801c7c:	89 d0                	mov    %edx,%eax
  801c7e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c81:	c9                   	leave  
  801c82:	c3                   	ret    

00801c83 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801c83:	55                   	push   %ebp
  801c84:	89 e5                	mov    %esp,%ebp
  801c86:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801c89:	6a 00                	push   $0x0
  801c8b:	ff 75 10             	pushl  0x10(%ebp)
  801c8e:	ff 75 0c             	pushl  0xc(%ebp)
  801c91:	8b 45 08             	mov    0x8(%ebp),%eax
  801c94:	ff 70 0c             	pushl  0xc(%eax)
  801c97:	e8 78 03 00 00       	call   802014 <nsipc_send>
}
  801c9c:	c9                   	leave  
  801c9d:	c3                   	ret    

00801c9e <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801c9e:	55                   	push   %ebp
  801c9f:	89 e5                	mov    %esp,%ebp
  801ca1:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801ca4:	6a 00                	push   $0x0
  801ca6:	ff 75 10             	pushl  0x10(%ebp)
  801ca9:	ff 75 0c             	pushl  0xc(%ebp)
  801cac:	8b 45 08             	mov    0x8(%ebp),%eax
  801caf:	ff 70 0c             	pushl  0xc(%eax)
  801cb2:	e8 f1 02 00 00       	call   801fa8 <nsipc_recv>
}
  801cb7:	c9                   	leave  
  801cb8:	c3                   	ret    

00801cb9 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801cb9:	55                   	push   %ebp
  801cba:	89 e5                	mov    %esp,%ebp
  801cbc:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801cbf:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801cc2:	52                   	push   %edx
  801cc3:	50                   	push   %eax
  801cc4:	e8 f4 f1 ff ff       	call   800ebd <fd_lookup>
  801cc9:	83 c4 10             	add    $0x10,%esp
  801ccc:	85 c0                	test   %eax,%eax
  801cce:	78 17                	js     801ce7 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801cd0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cd3:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  801cd9:	39 08                	cmp    %ecx,(%eax)
  801cdb:	75 05                	jne    801ce2 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801cdd:	8b 40 0c             	mov    0xc(%eax),%eax
  801ce0:	eb 05                	jmp    801ce7 <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801ce2:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801ce7:	c9                   	leave  
  801ce8:	c3                   	ret    

00801ce9 <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  801ce9:	55                   	push   %ebp
  801cea:	89 e5                	mov    %esp,%ebp
  801cec:	56                   	push   %esi
  801ced:	53                   	push   %ebx
  801cee:	83 ec 1c             	sub    $0x1c,%esp
  801cf1:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801cf3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801cf6:	50                   	push   %eax
  801cf7:	e8 72 f1 ff ff       	call   800e6e <fd_alloc>
  801cfc:	89 c3                	mov    %eax,%ebx
  801cfe:	83 c4 10             	add    $0x10,%esp
  801d01:	85 c0                	test   %eax,%eax
  801d03:	78 1b                	js     801d20 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801d05:	83 ec 04             	sub    $0x4,%esp
  801d08:	68 07 04 00 00       	push   $0x407
  801d0d:	ff 75 f4             	pushl  -0xc(%ebp)
  801d10:	6a 00                	push   $0x0
  801d12:	e8 de ee ff ff       	call   800bf5 <sys_page_alloc>
  801d17:	89 c3                	mov    %eax,%ebx
  801d19:	83 c4 10             	add    $0x10,%esp
  801d1c:	85 c0                	test   %eax,%eax
  801d1e:	79 10                	jns    801d30 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  801d20:	83 ec 0c             	sub    $0xc,%esp
  801d23:	56                   	push   %esi
  801d24:	e8 0e 02 00 00       	call   801f37 <nsipc_close>
		return r;
  801d29:	83 c4 10             	add    $0x10,%esp
  801d2c:	89 d8                	mov    %ebx,%eax
  801d2e:	eb 24                	jmp    801d54 <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801d30:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801d36:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d39:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801d3b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d3e:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801d45:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801d48:	83 ec 0c             	sub    $0xc,%esp
  801d4b:	50                   	push   %eax
  801d4c:	e8 f6 f0 ff ff       	call   800e47 <fd2num>
  801d51:	83 c4 10             	add    $0x10,%esp
}
  801d54:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d57:	5b                   	pop    %ebx
  801d58:	5e                   	pop    %esi
  801d59:	5d                   	pop    %ebp
  801d5a:	c3                   	ret    

00801d5b <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801d5b:	55                   	push   %ebp
  801d5c:	89 e5                	mov    %esp,%ebp
  801d5e:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801d61:	8b 45 08             	mov    0x8(%ebp),%eax
  801d64:	e8 50 ff ff ff       	call   801cb9 <fd2sockid>
		return r;
  801d69:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  801d6b:	85 c0                	test   %eax,%eax
  801d6d:	78 1f                	js     801d8e <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801d6f:	83 ec 04             	sub    $0x4,%esp
  801d72:	ff 75 10             	pushl  0x10(%ebp)
  801d75:	ff 75 0c             	pushl  0xc(%ebp)
  801d78:	50                   	push   %eax
  801d79:	e8 12 01 00 00       	call   801e90 <nsipc_accept>
  801d7e:	83 c4 10             	add    $0x10,%esp
		return r;
  801d81:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801d83:	85 c0                	test   %eax,%eax
  801d85:	78 07                	js     801d8e <accept+0x33>
		return r;
	return alloc_sockfd(r);
  801d87:	e8 5d ff ff ff       	call   801ce9 <alloc_sockfd>
  801d8c:	89 c1                	mov    %eax,%ecx
}
  801d8e:	89 c8                	mov    %ecx,%eax
  801d90:	c9                   	leave  
  801d91:	c3                   	ret    

00801d92 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801d92:	55                   	push   %ebp
  801d93:	89 e5                	mov    %esp,%ebp
  801d95:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801d98:	8b 45 08             	mov    0x8(%ebp),%eax
  801d9b:	e8 19 ff ff ff       	call   801cb9 <fd2sockid>
  801da0:	85 c0                	test   %eax,%eax
  801da2:	78 12                	js     801db6 <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  801da4:	83 ec 04             	sub    $0x4,%esp
  801da7:	ff 75 10             	pushl  0x10(%ebp)
  801daa:	ff 75 0c             	pushl  0xc(%ebp)
  801dad:	50                   	push   %eax
  801dae:	e8 2d 01 00 00       	call   801ee0 <nsipc_bind>
  801db3:	83 c4 10             	add    $0x10,%esp
}
  801db6:	c9                   	leave  
  801db7:	c3                   	ret    

00801db8 <shutdown>:

int
shutdown(int s, int how)
{
  801db8:	55                   	push   %ebp
  801db9:	89 e5                	mov    %esp,%ebp
  801dbb:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801dbe:	8b 45 08             	mov    0x8(%ebp),%eax
  801dc1:	e8 f3 fe ff ff       	call   801cb9 <fd2sockid>
  801dc6:	85 c0                	test   %eax,%eax
  801dc8:	78 0f                	js     801dd9 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801dca:	83 ec 08             	sub    $0x8,%esp
  801dcd:	ff 75 0c             	pushl  0xc(%ebp)
  801dd0:	50                   	push   %eax
  801dd1:	e8 3f 01 00 00       	call   801f15 <nsipc_shutdown>
  801dd6:	83 c4 10             	add    $0x10,%esp
}
  801dd9:	c9                   	leave  
  801dda:	c3                   	ret    

00801ddb <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801ddb:	55                   	push   %ebp
  801ddc:	89 e5                	mov    %esp,%ebp
  801dde:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801de1:	8b 45 08             	mov    0x8(%ebp),%eax
  801de4:	e8 d0 fe ff ff       	call   801cb9 <fd2sockid>
  801de9:	85 c0                	test   %eax,%eax
  801deb:	78 12                	js     801dff <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  801ded:	83 ec 04             	sub    $0x4,%esp
  801df0:	ff 75 10             	pushl  0x10(%ebp)
  801df3:	ff 75 0c             	pushl  0xc(%ebp)
  801df6:	50                   	push   %eax
  801df7:	e8 55 01 00 00       	call   801f51 <nsipc_connect>
  801dfc:	83 c4 10             	add    $0x10,%esp
}
  801dff:	c9                   	leave  
  801e00:	c3                   	ret    

00801e01 <listen>:

int
listen(int s, int backlog)
{
  801e01:	55                   	push   %ebp
  801e02:	89 e5                	mov    %esp,%ebp
  801e04:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801e07:	8b 45 08             	mov    0x8(%ebp),%eax
  801e0a:	e8 aa fe ff ff       	call   801cb9 <fd2sockid>
  801e0f:	85 c0                	test   %eax,%eax
  801e11:	78 0f                	js     801e22 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801e13:	83 ec 08             	sub    $0x8,%esp
  801e16:	ff 75 0c             	pushl  0xc(%ebp)
  801e19:	50                   	push   %eax
  801e1a:	e8 67 01 00 00       	call   801f86 <nsipc_listen>
  801e1f:	83 c4 10             	add    $0x10,%esp
}
  801e22:	c9                   	leave  
  801e23:	c3                   	ret    

00801e24 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801e24:	55                   	push   %ebp
  801e25:	89 e5                	mov    %esp,%ebp
  801e27:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801e2a:	ff 75 10             	pushl  0x10(%ebp)
  801e2d:	ff 75 0c             	pushl  0xc(%ebp)
  801e30:	ff 75 08             	pushl  0x8(%ebp)
  801e33:	e8 3a 02 00 00       	call   802072 <nsipc_socket>
  801e38:	83 c4 10             	add    $0x10,%esp
  801e3b:	85 c0                	test   %eax,%eax
  801e3d:	78 05                	js     801e44 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  801e3f:	e8 a5 fe ff ff       	call   801ce9 <alloc_sockfd>
}
  801e44:	c9                   	leave  
  801e45:	c3                   	ret    

00801e46 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801e46:	55                   	push   %ebp
  801e47:	89 e5                	mov    %esp,%ebp
  801e49:	53                   	push   %ebx
  801e4a:	83 ec 04             	sub    $0x4,%esp
  801e4d:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801e4f:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801e56:	75 12                	jne    801e6a <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801e58:	83 ec 0c             	sub    $0xc,%esp
  801e5b:	6a 02                	push   $0x2
  801e5d:	e8 d4 07 00 00       	call   802636 <ipc_find_env>
  801e62:	a3 04 40 80 00       	mov    %eax,0x804004
  801e67:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801e6a:	6a 07                	push   $0x7
  801e6c:	68 00 60 80 00       	push   $0x806000
  801e71:	53                   	push   %ebx
  801e72:	ff 35 04 40 80 00    	pushl  0x804004
  801e78:	e8 65 07 00 00       	call   8025e2 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801e7d:	83 c4 0c             	add    $0xc,%esp
  801e80:	6a 00                	push   $0x0
  801e82:	6a 00                	push   $0x0
  801e84:	6a 00                	push   $0x0
  801e86:	e8 f0 06 00 00       	call   80257b <ipc_recv>
}
  801e8b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801e8e:	c9                   	leave  
  801e8f:	c3                   	ret    

00801e90 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801e90:	55                   	push   %ebp
  801e91:	89 e5                	mov    %esp,%ebp
  801e93:	56                   	push   %esi
  801e94:	53                   	push   %ebx
  801e95:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801e98:	8b 45 08             	mov    0x8(%ebp),%eax
  801e9b:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801ea0:	8b 06                	mov    (%esi),%eax
  801ea2:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801ea7:	b8 01 00 00 00       	mov    $0x1,%eax
  801eac:	e8 95 ff ff ff       	call   801e46 <nsipc>
  801eb1:	89 c3                	mov    %eax,%ebx
  801eb3:	85 c0                	test   %eax,%eax
  801eb5:	78 20                	js     801ed7 <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801eb7:	83 ec 04             	sub    $0x4,%esp
  801eba:	ff 35 10 60 80 00    	pushl  0x806010
  801ec0:	68 00 60 80 00       	push   $0x806000
  801ec5:	ff 75 0c             	pushl  0xc(%ebp)
  801ec8:	e8 b7 ea ff ff       	call   800984 <memmove>
		*addrlen = ret->ret_addrlen;
  801ecd:	a1 10 60 80 00       	mov    0x806010,%eax
  801ed2:	89 06                	mov    %eax,(%esi)
  801ed4:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  801ed7:	89 d8                	mov    %ebx,%eax
  801ed9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801edc:	5b                   	pop    %ebx
  801edd:	5e                   	pop    %esi
  801ede:	5d                   	pop    %ebp
  801edf:	c3                   	ret    

00801ee0 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801ee0:	55                   	push   %ebp
  801ee1:	89 e5                	mov    %esp,%ebp
  801ee3:	53                   	push   %ebx
  801ee4:	83 ec 08             	sub    $0x8,%esp
  801ee7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801eea:	8b 45 08             	mov    0x8(%ebp),%eax
  801eed:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801ef2:	53                   	push   %ebx
  801ef3:	ff 75 0c             	pushl  0xc(%ebp)
  801ef6:	68 04 60 80 00       	push   $0x806004
  801efb:	e8 84 ea ff ff       	call   800984 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801f00:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801f06:	b8 02 00 00 00       	mov    $0x2,%eax
  801f0b:	e8 36 ff ff ff       	call   801e46 <nsipc>
}
  801f10:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801f13:	c9                   	leave  
  801f14:	c3                   	ret    

00801f15 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801f15:	55                   	push   %ebp
  801f16:	89 e5                	mov    %esp,%ebp
  801f18:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801f1b:	8b 45 08             	mov    0x8(%ebp),%eax
  801f1e:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801f23:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f26:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801f2b:	b8 03 00 00 00       	mov    $0x3,%eax
  801f30:	e8 11 ff ff ff       	call   801e46 <nsipc>
}
  801f35:	c9                   	leave  
  801f36:	c3                   	ret    

00801f37 <nsipc_close>:

int
nsipc_close(int s)
{
  801f37:	55                   	push   %ebp
  801f38:	89 e5                	mov    %esp,%ebp
  801f3a:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801f3d:	8b 45 08             	mov    0x8(%ebp),%eax
  801f40:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801f45:	b8 04 00 00 00       	mov    $0x4,%eax
  801f4a:	e8 f7 fe ff ff       	call   801e46 <nsipc>
}
  801f4f:	c9                   	leave  
  801f50:	c3                   	ret    

00801f51 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801f51:	55                   	push   %ebp
  801f52:	89 e5                	mov    %esp,%ebp
  801f54:	53                   	push   %ebx
  801f55:	83 ec 08             	sub    $0x8,%esp
  801f58:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801f5b:	8b 45 08             	mov    0x8(%ebp),%eax
  801f5e:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801f63:	53                   	push   %ebx
  801f64:	ff 75 0c             	pushl  0xc(%ebp)
  801f67:	68 04 60 80 00       	push   $0x806004
  801f6c:	e8 13 ea ff ff       	call   800984 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801f71:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801f77:	b8 05 00 00 00       	mov    $0x5,%eax
  801f7c:	e8 c5 fe ff ff       	call   801e46 <nsipc>
}
  801f81:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801f84:	c9                   	leave  
  801f85:	c3                   	ret    

00801f86 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801f86:	55                   	push   %ebp
  801f87:	89 e5                	mov    %esp,%ebp
  801f89:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801f8c:	8b 45 08             	mov    0x8(%ebp),%eax
  801f8f:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801f94:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f97:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801f9c:	b8 06 00 00 00       	mov    $0x6,%eax
  801fa1:	e8 a0 fe ff ff       	call   801e46 <nsipc>
}
  801fa6:	c9                   	leave  
  801fa7:	c3                   	ret    

00801fa8 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801fa8:	55                   	push   %ebp
  801fa9:	89 e5                	mov    %esp,%ebp
  801fab:	56                   	push   %esi
  801fac:	53                   	push   %ebx
  801fad:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801fb0:	8b 45 08             	mov    0x8(%ebp),%eax
  801fb3:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801fb8:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801fbe:	8b 45 14             	mov    0x14(%ebp),%eax
  801fc1:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801fc6:	b8 07 00 00 00       	mov    $0x7,%eax
  801fcb:	e8 76 fe ff ff       	call   801e46 <nsipc>
  801fd0:	89 c3                	mov    %eax,%ebx
  801fd2:	85 c0                	test   %eax,%eax
  801fd4:	78 35                	js     80200b <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  801fd6:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801fdb:	7f 04                	jg     801fe1 <nsipc_recv+0x39>
  801fdd:	39 c6                	cmp    %eax,%esi
  801fdf:	7d 16                	jge    801ff7 <nsipc_recv+0x4f>
  801fe1:	68 f0 2e 80 00       	push   $0x802ef0
  801fe6:	68 03 2e 80 00       	push   $0x802e03
  801feb:	6a 62                	push   $0x62
  801fed:	68 05 2f 80 00       	push   $0x802f05
  801ff2:	e8 9d e1 ff ff       	call   800194 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801ff7:	83 ec 04             	sub    $0x4,%esp
  801ffa:	50                   	push   %eax
  801ffb:	68 00 60 80 00       	push   $0x806000
  802000:	ff 75 0c             	pushl  0xc(%ebp)
  802003:	e8 7c e9 ff ff       	call   800984 <memmove>
  802008:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  80200b:	89 d8                	mov    %ebx,%eax
  80200d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802010:	5b                   	pop    %ebx
  802011:	5e                   	pop    %esi
  802012:	5d                   	pop    %ebp
  802013:	c3                   	ret    

00802014 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  802014:	55                   	push   %ebp
  802015:	89 e5                	mov    %esp,%ebp
  802017:	53                   	push   %ebx
  802018:	83 ec 04             	sub    $0x4,%esp
  80201b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  80201e:	8b 45 08             	mov    0x8(%ebp),%eax
  802021:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  802026:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  80202c:	7e 16                	jle    802044 <nsipc_send+0x30>
  80202e:	68 11 2f 80 00       	push   $0x802f11
  802033:	68 03 2e 80 00       	push   $0x802e03
  802038:	6a 6d                	push   $0x6d
  80203a:	68 05 2f 80 00       	push   $0x802f05
  80203f:	e8 50 e1 ff ff       	call   800194 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  802044:	83 ec 04             	sub    $0x4,%esp
  802047:	53                   	push   %ebx
  802048:	ff 75 0c             	pushl  0xc(%ebp)
  80204b:	68 0c 60 80 00       	push   $0x80600c
  802050:	e8 2f e9 ff ff       	call   800984 <memmove>
	nsipcbuf.send.req_size = size;
  802055:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  80205b:	8b 45 14             	mov    0x14(%ebp),%eax
  80205e:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  802063:	b8 08 00 00 00       	mov    $0x8,%eax
  802068:	e8 d9 fd ff ff       	call   801e46 <nsipc>
}
  80206d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802070:	c9                   	leave  
  802071:	c3                   	ret    

00802072 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  802072:	55                   	push   %ebp
  802073:	89 e5                	mov    %esp,%ebp
  802075:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  802078:	8b 45 08             	mov    0x8(%ebp),%eax
  80207b:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  802080:	8b 45 0c             	mov    0xc(%ebp),%eax
  802083:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  802088:	8b 45 10             	mov    0x10(%ebp),%eax
  80208b:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  802090:	b8 09 00 00 00       	mov    $0x9,%eax
  802095:	e8 ac fd ff ff       	call   801e46 <nsipc>
}
  80209a:	c9                   	leave  
  80209b:	c3                   	ret    

0080209c <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  80209c:	55                   	push   %ebp
  80209d:	89 e5                	mov    %esp,%ebp
  80209f:	56                   	push   %esi
  8020a0:	53                   	push   %ebx
  8020a1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8020a4:	83 ec 0c             	sub    $0xc,%esp
  8020a7:	ff 75 08             	pushl  0x8(%ebp)
  8020aa:	e8 a8 ed ff ff       	call   800e57 <fd2data>
  8020af:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8020b1:	83 c4 08             	add    $0x8,%esp
  8020b4:	68 1d 2f 80 00       	push   $0x802f1d
  8020b9:	53                   	push   %ebx
  8020ba:	e8 33 e7 ff ff       	call   8007f2 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8020bf:	8b 46 04             	mov    0x4(%esi),%eax
  8020c2:	2b 06                	sub    (%esi),%eax
  8020c4:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8020ca:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8020d1:	00 00 00 
	stat->st_dev = &devpipe;
  8020d4:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  8020db:	30 80 00 
	return 0;
}
  8020de:	b8 00 00 00 00       	mov    $0x0,%eax
  8020e3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8020e6:	5b                   	pop    %ebx
  8020e7:	5e                   	pop    %esi
  8020e8:	5d                   	pop    %ebp
  8020e9:	c3                   	ret    

008020ea <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8020ea:	55                   	push   %ebp
  8020eb:	89 e5                	mov    %esp,%ebp
  8020ed:	53                   	push   %ebx
  8020ee:	83 ec 0c             	sub    $0xc,%esp
  8020f1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8020f4:	53                   	push   %ebx
  8020f5:	6a 00                	push   $0x0
  8020f7:	e8 7e eb ff ff       	call   800c7a <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8020fc:	89 1c 24             	mov    %ebx,(%esp)
  8020ff:	e8 53 ed ff ff       	call   800e57 <fd2data>
  802104:	83 c4 08             	add    $0x8,%esp
  802107:	50                   	push   %eax
  802108:	6a 00                	push   $0x0
  80210a:	e8 6b eb ff ff       	call   800c7a <sys_page_unmap>
}
  80210f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802112:	c9                   	leave  
  802113:	c3                   	ret    

00802114 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  802114:	55                   	push   %ebp
  802115:	89 e5                	mov    %esp,%ebp
  802117:	57                   	push   %edi
  802118:	56                   	push   %esi
  802119:	53                   	push   %ebx
  80211a:	83 ec 1c             	sub    $0x1c,%esp
  80211d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  802120:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  802122:	a1 08 40 80 00       	mov    0x804008,%eax
  802127:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  80212a:	83 ec 0c             	sub    $0xc,%esp
  80212d:	ff 75 e0             	pushl  -0x20(%ebp)
  802130:	e8 3a 05 00 00       	call   80266f <pageref>
  802135:	89 c3                	mov    %eax,%ebx
  802137:	89 3c 24             	mov    %edi,(%esp)
  80213a:	e8 30 05 00 00       	call   80266f <pageref>
  80213f:	83 c4 10             	add    $0x10,%esp
  802142:	39 c3                	cmp    %eax,%ebx
  802144:	0f 94 c1             	sete   %cl
  802147:	0f b6 c9             	movzbl %cl,%ecx
  80214a:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  80214d:	8b 15 08 40 80 00    	mov    0x804008,%edx
  802153:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  802156:	39 ce                	cmp    %ecx,%esi
  802158:	74 1b                	je     802175 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  80215a:	39 c3                	cmp    %eax,%ebx
  80215c:	75 c4                	jne    802122 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  80215e:	8b 42 58             	mov    0x58(%edx),%eax
  802161:	ff 75 e4             	pushl  -0x1c(%ebp)
  802164:	50                   	push   %eax
  802165:	56                   	push   %esi
  802166:	68 24 2f 80 00       	push   $0x802f24
  80216b:	e8 fd e0 ff ff       	call   80026d <cprintf>
  802170:	83 c4 10             	add    $0x10,%esp
  802173:	eb ad                	jmp    802122 <_pipeisclosed+0xe>
	}
}
  802175:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802178:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80217b:	5b                   	pop    %ebx
  80217c:	5e                   	pop    %esi
  80217d:	5f                   	pop    %edi
  80217e:	5d                   	pop    %ebp
  80217f:	c3                   	ret    

00802180 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802180:	55                   	push   %ebp
  802181:	89 e5                	mov    %esp,%ebp
  802183:	57                   	push   %edi
  802184:	56                   	push   %esi
  802185:	53                   	push   %ebx
  802186:	83 ec 28             	sub    $0x28,%esp
  802189:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  80218c:	56                   	push   %esi
  80218d:	e8 c5 ec ff ff       	call   800e57 <fd2data>
  802192:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802194:	83 c4 10             	add    $0x10,%esp
  802197:	bf 00 00 00 00       	mov    $0x0,%edi
  80219c:	eb 4b                	jmp    8021e9 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  80219e:	89 da                	mov    %ebx,%edx
  8021a0:	89 f0                	mov    %esi,%eax
  8021a2:	e8 6d ff ff ff       	call   802114 <_pipeisclosed>
  8021a7:	85 c0                	test   %eax,%eax
  8021a9:	75 48                	jne    8021f3 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8021ab:	e8 26 ea ff ff       	call   800bd6 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8021b0:	8b 43 04             	mov    0x4(%ebx),%eax
  8021b3:	8b 0b                	mov    (%ebx),%ecx
  8021b5:	8d 51 20             	lea    0x20(%ecx),%edx
  8021b8:	39 d0                	cmp    %edx,%eax
  8021ba:	73 e2                	jae    80219e <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8021bc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8021bf:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  8021c3:	88 4d e7             	mov    %cl,-0x19(%ebp)
  8021c6:	89 c2                	mov    %eax,%edx
  8021c8:	c1 fa 1f             	sar    $0x1f,%edx
  8021cb:	89 d1                	mov    %edx,%ecx
  8021cd:	c1 e9 1b             	shr    $0x1b,%ecx
  8021d0:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  8021d3:	83 e2 1f             	and    $0x1f,%edx
  8021d6:	29 ca                	sub    %ecx,%edx
  8021d8:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  8021dc:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8021e0:	83 c0 01             	add    $0x1,%eax
  8021e3:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8021e6:	83 c7 01             	add    $0x1,%edi
  8021e9:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8021ec:	75 c2                	jne    8021b0 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8021ee:	8b 45 10             	mov    0x10(%ebp),%eax
  8021f1:	eb 05                	jmp    8021f8 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8021f3:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8021f8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8021fb:	5b                   	pop    %ebx
  8021fc:	5e                   	pop    %esi
  8021fd:	5f                   	pop    %edi
  8021fe:	5d                   	pop    %ebp
  8021ff:	c3                   	ret    

00802200 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  802200:	55                   	push   %ebp
  802201:	89 e5                	mov    %esp,%ebp
  802203:	57                   	push   %edi
  802204:	56                   	push   %esi
  802205:	53                   	push   %ebx
  802206:	83 ec 18             	sub    $0x18,%esp
  802209:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  80220c:	57                   	push   %edi
  80220d:	e8 45 ec ff ff       	call   800e57 <fd2data>
  802212:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802214:	83 c4 10             	add    $0x10,%esp
  802217:	bb 00 00 00 00       	mov    $0x0,%ebx
  80221c:	eb 3d                	jmp    80225b <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  80221e:	85 db                	test   %ebx,%ebx
  802220:	74 04                	je     802226 <devpipe_read+0x26>
				return i;
  802222:	89 d8                	mov    %ebx,%eax
  802224:	eb 44                	jmp    80226a <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  802226:	89 f2                	mov    %esi,%edx
  802228:	89 f8                	mov    %edi,%eax
  80222a:	e8 e5 fe ff ff       	call   802114 <_pipeisclosed>
  80222f:	85 c0                	test   %eax,%eax
  802231:	75 32                	jne    802265 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  802233:	e8 9e e9 ff ff       	call   800bd6 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  802238:	8b 06                	mov    (%esi),%eax
  80223a:	3b 46 04             	cmp    0x4(%esi),%eax
  80223d:	74 df                	je     80221e <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  80223f:	99                   	cltd   
  802240:	c1 ea 1b             	shr    $0x1b,%edx
  802243:	01 d0                	add    %edx,%eax
  802245:	83 e0 1f             	and    $0x1f,%eax
  802248:	29 d0                	sub    %edx,%eax
  80224a:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  80224f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802252:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  802255:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802258:	83 c3 01             	add    $0x1,%ebx
  80225b:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  80225e:	75 d8                	jne    802238 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  802260:	8b 45 10             	mov    0x10(%ebp),%eax
  802263:	eb 05                	jmp    80226a <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802265:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  80226a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80226d:	5b                   	pop    %ebx
  80226e:	5e                   	pop    %esi
  80226f:	5f                   	pop    %edi
  802270:	5d                   	pop    %ebp
  802271:	c3                   	ret    

00802272 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  802272:	55                   	push   %ebp
  802273:	89 e5                	mov    %esp,%ebp
  802275:	56                   	push   %esi
  802276:	53                   	push   %ebx
  802277:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  80227a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80227d:	50                   	push   %eax
  80227e:	e8 eb eb ff ff       	call   800e6e <fd_alloc>
  802283:	83 c4 10             	add    $0x10,%esp
  802286:	89 c2                	mov    %eax,%edx
  802288:	85 c0                	test   %eax,%eax
  80228a:	0f 88 2c 01 00 00    	js     8023bc <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802290:	83 ec 04             	sub    $0x4,%esp
  802293:	68 07 04 00 00       	push   $0x407
  802298:	ff 75 f4             	pushl  -0xc(%ebp)
  80229b:	6a 00                	push   $0x0
  80229d:	e8 53 e9 ff ff       	call   800bf5 <sys_page_alloc>
  8022a2:	83 c4 10             	add    $0x10,%esp
  8022a5:	89 c2                	mov    %eax,%edx
  8022a7:	85 c0                	test   %eax,%eax
  8022a9:	0f 88 0d 01 00 00    	js     8023bc <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8022af:	83 ec 0c             	sub    $0xc,%esp
  8022b2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8022b5:	50                   	push   %eax
  8022b6:	e8 b3 eb ff ff       	call   800e6e <fd_alloc>
  8022bb:	89 c3                	mov    %eax,%ebx
  8022bd:	83 c4 10             	add    $0x10,%esp
  8022c0:	85 c0                	test   %eax,%eax
  8022c2:	0f 88 e2 00 00 00    	js     8023aa <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8022c8:	83 ec 04             	sub    $0x4,%esp
  8022cb:	68 07 04 00 00       	push   $0x407
  8022d0:	ff 75 f0             	pushl  -0x10(%ebp)
  8022d3:	6a 00                	push   $0x0
  8022d5:	e8 1b e9 ff ff       	call   800bf5 <sys_page_alloc>
  8022da:	89 c3                	mov    %eax,%ebx
  8022dc:	83 c4 10             	add    $0x10,%esp
  8022df:	85 c0                	test   %eax,%eax
  8022e1:	0f 88 c3 00 00 00    	js     8023aa <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8022e7:	83 ec 0c             	sub    $0xc,%esp
  8022ea:	ff 75 f4             	pushl  -0xc(%ebp)
  8022ed:	e8 65 eb ff ff       	call   800e57 <fd2data>
  8022f2:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8022f4:	83 c4 0c             	add    $0xc,%esp
  8022f7:	68 07 04 00 00       	push   $0x407
  8022fc:	50                   	push   %eax
  8022fd:	6a 00                	push   $0x0
  8022ff:	e8 f1 e8 ff ff       	call   800bf5 <sys_page_alloc>
  802304:	89 c3                	mov    %eax,%ebx
  802306:	83 c4 10             	add    $0x10,%esp
  802309:	85 c0                	test   %eax,%eax
  80230b:	0f 88 89 00 00 00    	js     80239a <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802311:	83 ec 0c             	sub    $0xc,%esp
  802314:	ff 75 f0             	pushl  -0x10(%ebp)
  802317:	e8 3b eb ff ff       	call   800e57 <fd2data>
  80231c:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  802323:	50                   	push   %eax
  802324:	6a 00                	push   $0x0
  802326:	56                   	push   %esi
  802327:	6a 00                	push   $0x0
  802329:	e8 0a e9 ff ff       	call   800c38 <sys_page_map>
  80232e:	89 c3                	mov    %eax,%ebx
  802330:	83 c4 20             	add    $0x20,%esp
  802333:	85 c0                	test   %eax,%eax
  802335:	78 55                	js     80238c <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  802337:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80233d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802340:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  802342:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802345:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  80234c:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  802352:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802355:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  802357:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80235a:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  802361:	83 ec 0c             	sub    $0xc,%esp
  802364:	ff 75 f4             	pushl  -0xc(%ebp)
  802367:	e8 db ea ff ff       	call   800e47 <fd2num>
  80236c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80236f:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  802371:	83 c4 04             	add    $0x4,%esp
  802374:	ff 75 f0             	pushl  -0x10(%ebp)
  802377:	e8 cb ea ff ff       	call   800e47 <fd2num>
  80237c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80237f:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  802382:	83 c4 10             	add    $0x10,%esp
  802385:	ba 00 00 00 00       	mov    $0x0,%edx
  80238a:	eb 30                	jmp    8023bc <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  80238c:	83 ec 08             	sub    $0x8,%esp
  80238f:	56                   	push   %esi
  802390:	6a 00                	push   $0x0
  802392:	e8 e3 e8 ff ff       	call   800c7a <sys_page_unmap>
  802397:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  80239a:	83 ec 08             	sub    $0x8,%esp
  80239d:	ff 75 f0             	pushl  -0x10(%ebp)
  8023a0:	6a 00                	push   $0x0
  8023a2:	e8 d3 e8 ff ff       	call   800c7a <sys_page_unmap>
  8023a7:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  8023aa:	83 ec 08             	sub    $0x8,%esp
  8023ad:	ff 75 f4             	pushl  -0xc(%ebp)
  8023b0:	6a 00                	push   $0x0
  8023b2:	e8 c3 e8 ff ff       	call   800c7a <sys_page_unmap>
  8023b7:	83 c4 10             	add    $0x10,%esp
  8023ba:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  8023bc:	89 d0                	mov    %edx,%eax
  8023be:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8023c1:	5b                   	pop    %ebx
  8023c2:	5e                   	pop    %esi
  8023c3:	5d                   	pop    %ebp
  8023c4:	c3                   	ret    

008023c5 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8023c5:	55                   	push   %ebp
  8023c6:	89 e5                	mov    %esp,%ebp
  8023c8:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8023cb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8023ce:	50                   	push   %eax
  8023cf:	ff 75 08             	pushl  0x8(%ebp)
  8023d2:	e8 e6 ea ff ff       	call   800ebd <fd_lookup>
  8023d7:	83 c4 10             	add    $0x10,%esp
  8023da:	85 c0                	test   %eax,%eax
  8023dc:	78 18                	js     8023f6 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8023de:	83 ec 0c             	sub    $0xc,%esp
  8023e1:	ff 75 f4             	pushl  -0xc(%ebp)
  8023e4:	e8 6e ea ff ff       	call   800e57 <fd2data>
	return _pipeisclosed(fd, p);
  8023e9:	89 c2                	mov    %eax,%edx
  8023eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8023ee:	e8 21 fd ff ff       	call   802114 <_pipeisclosed>
  8023f3:	83 c4 10             	add    $0x10,%esp
}
  8023f6:	c9                   	leave  
  8023f7:	c3                   	ret    

008023f8 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8023f8:	55                   	push   %ebp
  8023f9:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8023fb:	b8 00 00 00 00       	mov    $0x0,%eax
  802400:	5d                   	pop    %ebp
  802401:	c3                   	ret    

00802402 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  802402:	55                   	push   %ebp
  802403:	89 e5                	mov    %esp,%ebp
  802405:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  802408:	68 3c 2f 80 00       	push   $0x802f3c
  80240d:	ff 75 0c             	pushl  0xc(%ebp)
  802410:	e8 dd e3 ff ff       	call   8007f2 <strcpy>
	return 0;
}
  802415:	b8 00 00 00 00       	mov    $0x0,%eax
  80241a:	c9                   	leave  
  80241b:	c3                   	ret    

0080241c <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80241c:	55                   	push   %ebp
  80241d:	89 e5                	mov    %esp,%ebp
  80241f:	57                   	push   %edi
  802420:	56                   	push   %esi
  802421:	53                   	push   %ebx
  802422:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802428:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80242d:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802433:	eb 2d                	jmp    802462 <devcons_write+0x46>
		m = n - tot;
  802435:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802438:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  80243a:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  80243d:	ba 7f 00 00 00       	mov    $0x7f,%edx
  802442:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802445:	83 ec 04             	sub    $0x4,%esp
  802448:	53                   	push   %ebx
  802449:	03 45 0c             	add    0xc(%ebp),%eax
  80244c:	50                   	push   %eax
  80244d:	57                   	push   %edi
  80244e:	e8 31 e5 ff ff       	call   800984 <memmove>
		sys_cputs(buf, m);
  802453:	83 c4 08             	add    $0x8,%esp
  802456:	53                   	push   %ebx
  802457:	57                   	push   %edi
  802458:	e8 dc e6 ff ff       	call   800b39 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80245d:	01 de                	add    %ebx,%esi
  80245f:	83 c4 10             	add    $0x10,%esp
  802462:	89 f0                	mov    %esi,%eax
  802464:	3b 75 10             	cmp    0x10(%ebp),%esi
  802467:	72 cc                	jb     802435 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  802469:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80246c:	5b                   	pop    %ebx
  80246d:	5e                   	pop    %esi
  80246e:	5f                   	pop    %edi
  80246f:	5d                   	pop    %ebp
  802470:	c3                   	ret    

00802471 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  802471:	55                   	push   %ebp
  802472:	89 e5                	mov    %esp,%ebp
  802474:	83 ec 08             	sub    $0x8,%esp
  802477:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  80247c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802480:	74 2a                	je     8024ac <devcons_read+0x3b>
  802482:	eb 05                	jmp    802489 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  802484:	e8 4d e7 ff ff       	call   800bd6 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  802489:	e8 c9 e6 ff ff       	call   800b57 <sys_cgetc>
  80248e:	85 c0                	test   %eax,%eax
  802490:	74 f2                	je     802484 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  802492:	85 c0                	test   %eax,%eax
  802494:	78 16                	js     8024ac <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  802496:	83 f8 04             	cmp    $0x4,%eax
  802499:	74 0c                	je     8024a7 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  80249b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80249e:	88 02                	mov    %al,(%edx)
	return 1;
  8024a0:	b8 01 00 00 00       	mov    $0x1,%eax
  8024a5:	eb 05                	jmp    8024ac <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8024a7:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8024ac:	c9                   	leave  
  8024ad:	c3                   	ret    

008024ae <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8024ae:	55                   	push   %ebp
  8024af:	89 e5                	mov    %esp,%ebp
  8024b1:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8024b4:	8b 45 08             	mov    0x8(%ebp),%eax
  8024b7:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8024ba:	6a 01                	push   $0x1
  8024bc:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8024bf:	50                   	push   %eax
  8024c0:	e8 74 e6 ff ff       	call   800b39 <sys_cputs>
}
  8024c5:	83 c4 10             	add    $0x10,%esp
  8024c8:	c9                   	leave  
  8024c9:	c3                   	ret    

008024ca <getchar>:

int
getchar(void)
{
  8024ca:	55                   	push   %ebp
  8024cb:	89 e5                	mov    %esp,%ebp
  8024cd:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8024d0:	6a 01                	push   $0x1
  8024d2:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8024d5:	50                   	push   %eax
  8024d6:	6a 00                	push   $0x0
  8024d8:	e8 46 ec ff ff       	call   801123 <read>
	if (r < 0)
  8024dd:	83 c4 10             	add    $0x10,%esp
  8024e0:	85 c0                	test   %eax,%eax
  8024e2:	78 0f                	js     8024f3 <getchar+0x29>
		return r;
	if (r < 1)
  8024e4:	85 c0                	test   %eax,%eax
  8024e6:	7e 06                	jle    8024ee <getchar+0x24>
		return -E_EOF;
	return c;
  8024e8:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8024ec:	eb 05                	jmp    8024f3 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8024ee:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8024f3:	c9                   	leave  
  8024f4:	c3                   	ret    

008024f5 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8024f5:	55                   	push   %ebp
  8024f6:	89 e5                	mov    %esp,%ebp
  8024f8:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8024fb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8024fe:	50                   	push   %eax
  8024ff:	ff 75 08             	pushl  0x8(%ebp)
  802502:	e8 b6 e9 ff ff       	call   800ebd <fd_lookup>
  802507:	83 c4 10             	add    $0x10,%esp
  80250a:	85 c0                	test   %eax,%eax
  80250c:	78 11                	js     80251f <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  80250e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802511:	8b 15 58 30 80 00    	mov    0x803058,%edx
  802517:	39 10                	cmp    %edx,(%eax)
  802519:	0f 94 c0             	sete   %al
  80251c:	0f b6 c0             	movzbl %al,%eax
}
  80251f:	c9                   	leave  
  802520:	c3                   	ret    

00802521 <opencons>:

int
opencons(void)
{
  802521:	55                   	push   %ebp
  802522:	89 e5                	mov    %esp,%ebp
  802524:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802527:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80252a:	50                   	push   %eax
  80252b:	e8 3e e9 ff ff       	call   800e6e <fd_alloc>
  802530:	83 c4 10             	add    $0x10,%esp
		return r;
  802533:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802535:	85 c0                	test   %eax,%eax
  802537:	78 3e                	js     802577 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802539:	83 ec 04             	sub    $0x4,%esp
  80253c:	68 07 04 00 00       	push   $0x407
  802541:	ff 75 f4             	pushl  -0xc(%ebp)
  802544:	6a 00                	push   $0x0
  802546:	e8 aa e6 ff ff       	call   800bf5 <sys_page_alloc>
  80254b:	83 c4 10             	add    $0x10,%esp
		return r;
  80254e:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802550:	85 c0                	test   %eax,%eax
  802552:	78 23                	js     802577 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  802554:	8b 15 58 30 80 00    	mov    0x803058,%edx
  80255a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80255d:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80255f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802562:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802569:	83 ec 0c             	sub    $0xc,%esp
  80256c:	50                   	push   %eax
  80256d:	e8 d5 e8 ff ff       	call   800e47 <fd2num>
  802572:	89 c2                	mov    %eax,%edx
  802574:	83 c4 10             	add    $0x10,%esp
}
  802577:	89 d0                	mov    %edx,%eax
  802579:	c9                   	leave  
  80257a:	c3                   	ret    

0080257b <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80257b:	55                   	push   %ebp
  80257c:	89 e5                	mov    %esp,%ebp
  80257e:	56                   	push   %esi
  80257f:	53                   	push   %ebx
  802580:	8b 75 08             	mov    0x8(%ebp),%esi
  802583:	8b 45 0c             	mov    0xc(%ebp),%eax
  802586:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");

	// don't want to recv page
	if (pg == NULL)
  802589:	85 c0                	test   %eax,%eax
		pg = (void *)UTOP;
  80258b:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  802590:	0f 44 c2             	cmove  %edx,%eax

	int err = sys_ipc_recv(pg);
  802593:	83 ec 0c             	sub    $0xc,%esp
  802596:	50                   	push   %eax
  802597:	e8 09 e8 ff ff       	call   800da5 <sys_ipc_recv>

	if (from_env_store != NULL)
  80259c:	83 c4 10             	add    $0x10,%esp
  80259f:	85 f6                	test   %esi,%esi
  8025a1:	74 14                	je     8025b7 <ipc_recv+0x3c>
		*from_env_store = err < 0? 0 : thisenv->env_ipc_from;
  8025a3:	ba 00 00 00 00       	mov    $0x0,%edx
  8025a8:	85 c0                	test   %eax,%eax
  8025aa:	78 09                	js     8025b5 <ipc_recv+0x3a>
  8025ac:	8b 15 08 40 80 00    	mov    0x804008,%edx
  8025b2:	8b 52 74             	mov    0x74(%edx),%edx
  8025b5:	89 16                	mov    %edx,(%esi)
	
	if (perm_store != NULL)
  8025b7:	85 db                	test   %ebx,%ebx
  8025b9:	74 14                	je     8025cf <ipc_recv+0x54>
		*perm_store = err < 0? 0 : thisenv->env_ipc_perm;
  8025bb:	ba 00 00 00 00       	mov    $0x0,%edx
  8025c0:	85 c0                	test   %eax,%eax
  8025c2:	78 09                	js     8025cd <ipc_recv+0x52>
  8025c4:	8b 15 08 40 80 00    	mov    0x804008,%edx
  8025ca:	8b 52 78             	mov    0x78(%edx),%edx
  8025cd:	89 13                	mov    %edx,(%ebx)

	if (err < 0)
  8025cf:	85 c0                	test   %eax,%eax
  8025d1:	78 08                	js     8025db <ipc_recv+0x60>
		return err;
	return thisenv->env_ipc_value;
  8025d3:	a1 08 40 80 00       	mov    0x804008,%eax
  8025d8:	8b 40 70             	mov    0x70(%eax),%eax
}
  8025db:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8025de:	5b                   	pop    %ebx
  8025df:	5e                   	pop    %esi
  8025e0:	5d                   	pop    %ebp
  8025e1:	c3                   	ret    

008025e2 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8025e2:	55                   	push   %ebp
  8025e3:	89 e5                	mov    %esp,%ebp
  8025e5:	57                   	push   %edi
  8025e6:	56                   	push   %esi
  8025e7:	53                   	push   %ebx
  8025e8:	83 ec 0c             	sub    $0xc,%esp
  8025eb:	8b 7d 08             	mov    0x8(%ebp),%edi
  8025ee:	8b 75 0c             	mov    0xc(%ebp),%esi
  8025f1:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");

	// don't want to send page
	if (pg == NULL)
  8025f4:	85 db                	test   %ebx,%ebx
		pg = (void *)UTOP;
  8025f6:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  8025fb:	0f 44 d8             	cmove  %eax,%ebx
	
	int err = 0;
	
	do {

		err = sys_ipc_try_send(to_env, val, pg, perm);
  8025fe:	ff 75 14             	pushl  0x14(%ebp)
  802601:	53                   	push   %ebx
  802602:	56                   	push   %esi
  802603:	57                   	push   %edi
  802604:	e8 79 e7 ff ff       	call   800d82 <sys_ipc_try_send>

		if (err < 0) {
  802609:	83 c4 10             	add    $0x10,%esp
  80260c:	85 c0                	test   %eax,%eax
  80260e:	79 1e                	jns    80262e <ipc_send+0x4c>
			if (err == -E_IPC_NOT_RECV)
  802610:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802613:	75 07                	jne    80261c <ipc_send+0x3a>
				sys_yield();
  802615:	e8 bc e5 ff ff       	call   800bd6 <sys_yield>
  80261a:	eb e2                	jmp    8025fe <ipc_send+0x1c>
			else 
				panic("ipc_send: %e", err);
  80261c:	50                   	push   %eax
  80261d:	68 48 2f 80 00       	push   $0x802f48
  802622:	6a 49                	push   $0x49
  802624:	68 55 2f 80 00       	push   $0x802f55
  802629:	e8 66 db ff ff       	call   800194 <_panic>
		}

	} while (err < 0);

}
  80262e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802631:	5b                   	pop    %ebx
  802632:	5e                   	pop    %esi
  802633:	5f                   	pop    %edi
  802634:	5d                   	pop    %ebp
  802635:	c3                   	ret    

00802636 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802636:	55                   	push   %ebp
  802637:	89 e5                	mov    %esp,%ebp
  802639:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80263c:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802641:	6b d0 7c             	imul   $0x7c,%eax,%edx
  802644:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80264a:	8b 52 50             	mov    0x50(%edx),%edx
  80264d:	39 ca                	cmp    %ecx,%edx
  80264f:	75 0d                	jne    80265e <ipc_find_env+0x28>
			return envs[i].env_id;
  802651:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802654:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802659:	8b 40 48             	mov    0x48(%eax),%eax
  80265c:	eb 0f                	jmp    80266d <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80265e:	83 c0 01             	add    $0x1,%eax
  802661:	3d 00 04 00 00       	cmp    $0x400,%eax
  802666:	75 d9                	jne    802641 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802668:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80266d:	5d                   	pop    %ebp
  80266e:	c3                   	ret    

0080266f <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80266f:	55                   	push   %ebp
  802670:	89 e5                	mov    %esp,%ebp
  802672:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802675:	89 d0                	mov    %edx,%eax
  802677:	c1 e8 16             	shr    $0x16,%eax
  80267a:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802681:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802686:	f6 c1 01             	test   $0x1,%cl
  802689:	74 1d                	je     8026a8 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  80268b:	c1 ea 0c             	shr    $0xc,%edx
  80268e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802695:	f6 c2 01             	test   $0x1,%dl
  802698:	74 0e                	je     8026a8 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80269a:	c1 ea 0c             	shr    $0xc,%edx
  80269d:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8026a4:	ef 
  8026a5:	0f b7 c0             	movzwl %ax,%eax
}
  8026a8:	5d                   	pop    %ebp
  8026a9:	c3                   	ret    
  8026aa:	66 90                	xchg   %ax,%ax
  8026ac:	66 90                	xchg   %ax,%ax
  8026ae:	66 90                	xchg   %ax,%ax

008026b0 <__udivdi3>:
  8026b0:	55                   	push   %ebp
  8026b1:	57                   	push   %edi
  8026b2:	56                   	push   %esi
  8026b3:	53                   	push   %ebx
  8026b4:	83 ec 1c             	sub    $0x1c,%esp
  8026b7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  8026bb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  8026bf:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  8026c3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8026c7:	85 f6                	test   %esi,%esi
  8026c9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8026cd:	89 ca                	mov    %ecx,%edx
  8026cf:	89 f8                	mov    %edi,%eax
  8026d1:	75 3d                	jne    802710 <__udivdi3+0x60>
  8026d3:	39 cf                	cmp    %ecx,%edi
  8026d5:	0f 87 c5 00 00 00    	ja     8027a0 <__udivdi3+0xf0>
  8026db:	85 ff                	test   %edi,%edi
  8026dd:	89 fd                	mov    %edi,%ebp
  8026df:	75 0b                	jne    8026ec <__udivdi3+0x3c>
  8026e1:	b8 01 00 00 00       	mov    $0x1,%eax
  8026e6:	31 d2                	xor    %edx,%edx
  8026e8:	f7 f7                	div    %edi
  8026ea:	89 c5                	mov    %eax,%ebp
  8026ec:	89 c8                	mov    %ecx,%eax
  8026ee:	31 d2                	xor    %edx,%edx
  8026f0:	f7 f5                	div    %ebp
  8026f2:	89 c1                	mov    %eax,%ecx
  8026f4:	89 d8                	mov    %ebx,%eax
  8026f6:	89 cf                	mov    %ecx,%edi
  8026f8:	f7 f5                	div    %ebp
  8026fa:	89 c3                	mov    %eax,%ebx
  8026fc:	89 d8                	mov    %ebx,%eax
  8026fe:	89 fa                	mov    %edi,%edx
  802700:	83 c4 1c             	add    $0x1c,%esp
  802703:	5b                   	pop    %ebx
  802704:	5e                   	pop    %esi
  802705:	5f                   	pop    %edi
  802706:	5d                   	pop    %ebp
  802707:	c3                   	ret    
  802708:	90                   	nop
  802709:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802710:	39 ce                	cmp    %ecx,%esi
  802712:	77 74                	ja     802788 <__udivdi3+0xd8>
  802714:	0f bd fe             	bsr    %esi,%edi
  802717:	83 f7 1f             	xor    $0x1f,%edi
  80271a:	0f 84 98 00 00 00    	je     8027b8 <__udivdi3+0x108>
  802720:	bb 20 00 00 00       	mov    $0x20,%ebx
  802725:	89 f9                	mov    %edi,%ecx
  802727:	89 c5                	mov    %eax,%ebp
  802729:	29 fb                	sub    %edi,%ebx
  80272b:	d3 e6                	shl    %cl,%esi
  80272d:	89 d9                	mov    %ebx,%ecx
  80272f:	d3 ed                	shr    %cl,%ebp
  802731:	89 f9                	mov    %edi,%ecx
  802733:	d3 e0                	shl    %cl,%eax
  802735:	09 ee                	or     %ebp,%esi
  802737:	89 d9                	mov    %ebx,%ecx
  802739:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80273d:	89 d5                	mov    %edx,%ebp
  80273f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802743:	d3 ed                	shr    %cl,%ebp
  802745:	89 f9                	mov    %edi,%ecx
  802747:	d3 e2                	shl    %cl,%edx
  802749:	89 d9                	mov    %ebx,%ecx
  80274b:	d3 e8                	shr    %cl,%eax
  80274d:	09 c2                	or     %eax,%edx
  80274f:	89 d0                	mov    %edx,%eax
  802751:	89 ea                	mov    %ebp,%edx
  802753:	f7 f6                	div    %esi
  802755:	89 d5                	mov    %edx,%ebp
  802757:	89 c3                	mov    %eax,%ebx
  802759:	f7 64 24 0c          	mull   0xc(%esp)
  80275d:	39 d5                	cmp    %edx,%ebp
  80275f:	72 10                	jb     802771 <__udivdi3+0xc1>
  802761:	8b 74 24 08          	mov    0x8(%esp),%esi
  802765:	89 f9                	mov    %edi,%ecx
  802767:	d3 e6                	shl    %cl,%esi
  802769:	39 c6                	cmp    %eax,%esi
  80276b:	73 07                	jae    802774 <__udivdi3+0xc4>
  80276d:	39 d5                	cmp    %edx,%ebp
  80276f:	75 03                	jne    802774 <__udivdi3+0xc4>
  802771:	83 eb 01             	sub    $0x1,%ebx
  802774:	31 ff                	xor    %edi,%edi
  802776:	89 d8                	mov    %ebx,%eax
  802778:	89 fa                	mov    %edi,%edx
  80277a:	83 c4 1c             	add    $0x1c,%esp
  80277d:	5b                   	pop    %ebx
  80277e:	5e                   	pop    %esi
  80277f:	5f                   	pop    %edi
  802780:	5d                   	pop    %ebp
  802781:	c3                   	ret    
  802782:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802788:	31 ff                	xor    %edi,%edi
  80278a:	31 db                	xor    %ebx,%ebx
  80278c:	89 d8                	mov    %ebx,%eax
  80278e:	89 fa                	mov    %edi,%edx
  802790:	83 c4 1c             	add    $0x1c,%esp
  802793:	5b                   	pop    %ebx
  802794:	5e                   	pop    %esi
  802795:	5f                   	pop    %edi
  802796:	5d                   	pop    %ebp
  802797:	c3                   	ret    
  802798:	90                   	nop
  802799:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8027a0:	89 d8                	mov    %ebx,%eax
  8027a2:	f7 f7                	div    %edi
  8027a4:	31 ff                	xor    %edi,%edi
  8027a6:	89 c3                	mov    %eax,%ebx
  8027a8:	89 d8                	mov    %ebx,%eax
  8027aa:	89 fa                	mov    %edi,%edx
  8027ac:	83 c4 1c             	add    $0x1c,%esp
  8027af:	5b                   	pop    %ebx
  8027b0:	5e                   	pop    %esi
  8027b1:	5f                   	pop    %edi
  8027b2:	5d                   	pop    %ebp
  8027b3:	c3                   	ret    
  8027b4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8027b8:	39 ce                	cmp    %ecx,%esi
  8027ba:	72 0c                	jb     8027c8 <__udivdi3+0x118>
  8027bc:	31 db                	xor    %ebx,%ebx
  8027be:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8027c2:	0f 87 34 ff ff ff    	ja     8026fc <__udivdi3+0x4c>
  8027c8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8027cd:	e9 2a ff ff ff       	jmp    8026fc <__udivdi3+0x4c>
  8027d2:	66 90                	xchg   %ax,%ax
  8027d4:	66 90                	xchg   %ax,%ax
  8027d6:	66 90                	xchg   %ax,%ax
  8027d8:	66 90                	xchg   %ax,%ax
  8027da:	66 90                	xchg   %ax,%ax
  8027dc:	66 90                	xchg   %ax,%ax
  8027de:	66 90                	xchg   %ax,%ax

008027e0 <__umoddi3>:
  8027e0:	55                   	push   %ebp
  8027e1:	57                   	push   %edi
  8027e2:	56                   	push   %esi
  8027e3:	53                   	push   %ebx
  8027e4:	83 ec 1c             	sub    $0x1c,%esp
  8027e7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8027eb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8027ef:	8b 74 24 34          	mov    0x34(%esp),%esi
  8027f3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8027f7:	85 d2                	test   %edx,%edx
  8027f9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8027fd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802801:	89 f3                	mov    %esi,%ebx
  802803:	89 3c 24             	mov    %edi,(%esp)
  802806:	89 74 24 04          	mov    %esi,0x4(%esp)
  80280a:	75 1c                	jne    802828 <__umoddi3+0x48>
  80280c:	39 f7                	cmp    %esi,%edi
  80280e:	76 50                	jbe    802860 <__umoddi3+0x80>
  802810:	89 c8                	mov    %ecx,%eax
  802812:	89 f2                	mov    %esi,%edx
  802814:	f7 f7                	div    %edi
  802816:	89 d0                	mov    %edx,%eax
  802818:	31 d2                	xor    %edx,%edx
  80281a:	83 c4 1c             	add    $0x1c,%esp
  80281d:	5b                   	pop    %ebx
  80281e:	5e                   	pop    %esi
  80281f:	5f                   	pop    %edi
  802820:	5d                   	pop    %ebp
  802821:	c3                   	ret    
  802822:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802828:	39 f2                	cmp    %esi,%edx
  80282a:	89 d0                	mov    %edx,%eax
  80282c:	77 52                	ja     802880 <__umoddi3+0xa0>
  80282e:	0f bd ea             	bsr    %edx,%ebp
  802831:	83 f5 1f             	xor    $0x1f,%ebp
  802834:	75 5a                	jne    802890 <__umoddi3+0xb0>
  802836:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80283a:	0f 82 e0 00 00 00    	jb     802920 <__umoddi3+0x140>
  802840:	39 0c 24             	cmp    %ecx,(%esp)
  802843:	0f 86 d7 00 00 00    	jbe    802920 <__umoddi3+0x140>
  802849:	8b 44 24 08          	mov    0x8(%esp),%eax
  80284d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802851:	83 c4 1c             	add    $0x1c,%esp
  802854:	5b                   	pop    %ebx
  802855:	5e                   	pop    %esi
  802856:	5f                   	pop    %edi
  802857:	5d                   	pop    %ebp
  802858:	c3                   	ret    
  802859:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802860:	85 ff                	test   %edi,%edi
  802862:	89 fd                	mov    %edi,%ebp
  802864:	75 0b                	jne    802871 <__umoddi3+0x91>
  802866:	b8 01 00 00 00       	mov    $0x1,%eax
  80286b:	31 d2                	xor    %edx,%edx
  80286d:	f7 f7                	div    %edi
  80286f:	89 c5                	mov    %eax,%ebp
  802871:	89 f0                	mov    %esi,%eax
  802873:	31 d2                	xor    %edx,%edx
  802875:	f7 f5                	div    %ebp
  802877:	89 c8                	mov    %ecx,%eax
  802879:	f7 f5                	div    %ebp
  80287b:	89 d0                	mov    %edx,%eax
  80287d:	eb 99                	jmp    802818 <__umoddi3+0x38>
  80287f:	90                   	nop
  802880:	89 c8                	mov    %ecx,%eax
  802882:	89 f2                	mov    %esi,%edx
  802884:	83 c4 1c             	add    $0x1c,%esp
  802887:	5b                   	pop    %ebx
  802888:	5e                   	pop    %esi
  802889:	5f                   	pop    %edi
  80288a:	5d                   	pop    %ebp
  80288b:	c3                   	ret    
  80288c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802890:	8b 34 24             	mov    (%esp),%esi
  802893:	bf 20 00 00 00       	mov    $0x20,%edi
  802898:	89 e9                	mov    %ebp,%ecx
  80289a:	29 ef                	sub    %ebp,%edi
  80289c:	d3 e0                	shl    %cl,%eax
  80289e:	89 f9                	mov    %edi,%ecx
  8028a0:	89 f2                	mov    %esi,%edx
  8028a2:	d3 ea                	shr    %cl,%edx
  8028a4:	89 e9                	mov    %ebp,%ecx
  8028a6:	09 c2                	or     %eax,%edx
  8028a8:	89 d8                	mov    %ebx,%eax
  8028aa:	89 14 24             	mov    %edx,(%esp)
  8028ad:	89 f2                	mov    %esi,%edx
  8028af:	d3 e2                	shl    %cl,%edx
  8028b1:	89 f9                	mov    %edi,%ecx
  8028b3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8028b7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8028bb:	d3 e8                	shr    %cl,%eax
  8028bd:	89 e9                	mov    %ebp,%ecx
  8028bf:	89 c6                	mov    %eax,%esi
  8028c1:	d3 e3                	shl    %cl,%ebx
  8028c3:	89 f9                	mov    %edi,%ecx
  8028c5:	89 d0                	mov    %edx,%eax
  8028c7:	d3 e8                	shr    %cl,%eax
  8028c9:	89 e9                	mov    %ebp,%ecx
  8028cb:	09 d8                	or     %ebx,%eax
  8028cd:	89 d3                	mov    %edx,%ebx
  8028cf:	89 f2                	mov    %esi,%edx
  8028d1:	f7 34 24             	divl   (%esp)
  8028d4:	89 d6                	mov    %edx,%esi
  8028d6:	d3 e3                	shl    %cl,%ebx
  8028d8:	f7 64 24 04          	mull   0x4(%esp)
  8028dc:	39 d6                	cmp    %edx,%esi
  8028de:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8028e2:	89 d1                	mov    %edx,%ecx
  8028e4:	89 c3                	mov    %eax,%ebx
  8028e6:	72 08                	jb     8028f0 <__umoddi3+0x110>
  8028e8:	75 11                	jne    8028fb <__umoddi3+0x11b>
  8028ea:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8028ee:	73 0b                	jae    8028fb <__umoddi3+0x11b>
  8028f0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8028f4:	1b 14 24             	sbb    (%esp),%edx
  8028f7:	89 d1                	mov    %edx,%ecx
  8028f9:	89 c3                	mov    %eax,%ebx
  8028fb:	8b 54 24 08          	mov    0x8(%esp),%edx
  8028ff:	29 da                	sub    %ebx,%edx
  802901:	19 ce                	sbb    %ecx,%esi
  802903:	89 f9                	mov    %edi,%ecx
  802905:	89 f0                	mov    %esi,%eax
  802907:	d3 e0                	shl    %cl,%eax
  802909:	89 e9                	mov    %ebp,%ecx
  80290b:	d3 ea                	shr    %cl,%edx
  80290d:	89 e9                	mov    %ebp,%ecx
  80290f:	d3 ee                	shr    %cl,%esi
  802911:	09 d0                	or     %edx,%eax
  802913:	89 f2                	mov    %esi,%edx
  802915:	83 c4 1c             	add    $0x1c,%esp
  802918:	5b                   	pop    %ebx
  802919:	5e                   	pop    %esi
  80291a:	5f                   	pop    %edi
  80291b:	5d                   	pop    %ebp
  80291c:	c3                   	ret    
  80291d:	8d 76 00             	lea    0x0(%esi),%esi
  802920:	29 f9                	sub    %edi,%ecx
  802922:	19 d6                	sbb    %edx,%esi
  802924:	89 74 24 04          	mov    %esi,0x4(%esp)
  802928:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80292c:	e9 18 ff ff ff       	jmp    802849 <__umoddi3+0x69>
