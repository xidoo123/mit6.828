
obj/user/primes.debug:     file format elf32-i386


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
  80002c:	e8 c7 00 00 00       	call   8000f8 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <primeproc>:

#include <inc/lib.h>

unsigned
primeproc(void)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 1c             	sub    $0x1c,%esp
	int i, id, p;
	envid_t envid;

	// fetch a prime from our left neighbor
top:
	p = ipc_recv(&envid, 0, 0);
  80003c:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  80003f:	83 ec 04             	sub    $0x4,%esp
  800042:	6a 00                	push   $0x0
  800044:	6a 00                	push   $0x0
  800046:	56                   	push   %esi
  800047:	e8 ee 0f 00 00       	call   80103a <ipc_recv>
  80004c:	89 c3                	mov    %eax,%ebx
	cprintf("CPU %d: %d ", thisenv->env_cpunum, p);
  80004e:	a1 04 40 80 00       	mov    0x804004,%eax
  800053:	8b 40 5c             	mov    0x5c(%eax),%eax
  800056:	83 c4 0c             	add    $0xc,%esp
  800059:	53                   	push   %ebx
  80005a:	50                   	push   %eax
  80005b:	68 60 21 80 00       	push   $0x802160
  800060:	e8 cc 01 00 00       	call   800231 <cprintf>

	// fork a right neighbor to continue the chain
	if ((id = fork()) < 0)
  800065:	e8 19 0e 00 00       	call   800e83 <fork>
  80006a:	89 c7                	mov    %eax,%edi
  80006c:	83 c4 10             	add    $0x10,%esp
  80006f:	85 c0                	test   %eax,%eax
  800071:	79 12                	jns    800085 <primeproc+0x52>
		panic("fork: %e", id);
  800073:	50                   	push   %eax
  800074:	68 6c 21 80 00       	push   $0x80216c
  800079:	6a 1a                	push   $0x1a
  80007b:	68 75 21 80 00       	push   $0x802175
  800080:	e8 d3 00 00 00       	call   800158 <_panic>
	if (id == 0)
  800085:	85 c0                	test   %eax,%eax
  800087:	74 b6                	je     80003f <primeproc+0xc>
		goto top;

	// filter out multiples of our prime
	while (1) {
		i = ipc_recv(&envid, 0, 0);
  800089:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  80008c:	83 ec 04             	sub    $0x4,%esp
  80008f:	6a 00                	push   $0x0
  800091:	6a 00                	push   $0x0
  800093:	56                   	push   %esi
  800094:	e8 a1 0f 00 00       	call   80103a <ipc_recv>
  800099:	89 c1                	mov    %eax,%ecx
		if (i % p)
  80009b:	99                   	cltd   
  80009c:	f7 fb                	idiv   %ebx
  80009e:	83 c4 10             	add    $0x10,%esp
  8000a1:	85 d2                	test   %edx,%edx
  8000a3:	74 e7                	je     80008c <primeproc+0x59>
			ipc_send(id, i, 0, 0);
  8000a5:	6a 00                	push   $0x0
  8000a7:	6a 00                	push   $0x0
  8000a9:	51                   	push   %ecx
  8000aa:	57                   	push   %edi
  8000ab:	e8 f1 0f 00 00       	call   8010a1 <ipc_send>
  8000b0:	83 c4 10             	add    $0x10,%esp
  8000b3:	eb d7                	jmp    80008c <primeproc+0x59>

008000b5 <umain>:
	}
}

void
umain(int argc, char **argv)
{
  8000b5:	55                   	push   %ebp
  8000b6:	89 e5                	mov    %esp,%ebp
  8000b8:	56                   	push   %esi
  8000b9:	53                   	push   %ebx
	int i, id;

	// fork the first prime process in the chain
	if ((id = fork()) < 0)
  8000ba:	e8 c4 0d 00 00       	call   800e83 <fork>
  8000bf:	89 c6                	mov    %eax,%esi
  8000c1:	85 c0                	test   %eax,%eax
  8000c3:	79 12                	jns    8000d7 <umain+0x22>
		panic("fork: %e", id);
  8000c5:	50                   	push   %eax
  8000c6:	68 6c 21 80 00       	push   $0x80216c
  8000cb:	6a 2d                	push   $0x2d
  8000cd:	68 75 21 80 00       	push   $0x802175
  8000d2:	e8 81 00 00 00       	call   800158 <_panic>
  8000d7:	bb 02 00 00 00       	mov    $0x2,%ebx
	if (id == 0)
  8000dc:	85 c0                	test   %eax,%eax
  8000de:	75 05                	jne    8000e5 <umain+0x30>
		primeproc();
  8000e0:	e8 4e ff ff ff       	call   800033 <primeproc>

	// feed all the integers through
	for (i = 2; ; i++)
		ipc_send(id, i, 0, 0);
  8000e5:	6a 00                	push   $0x0
  8000e7:	6a 00                	push   $0x0
  8000e9:	53                   	push   %ebx
  8000ea:	56                   	push   %esi
  8000eb:	e8 b1 0f 00 00       	call   8010a1 <ipc_send>
		panic("fork: %e", id);
	if (id == 0)
		primeproc();

	// feed all the integers through
	for (i = 2; ; i++)
  8000f0:	83 c3 01             	add    $0x1,%ebx
  8000f3:	83 c4 10             	add    $0x10,%esp
  8000f6:	eb ed                	jmp    8000e5 <umain+0x30>

008000f8 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000f8:	55                   	push   %ebp
  8000f9:	89 e5                	mov    %esp,%ebp
  8000fb:	56                   	push   %esi
  8000fc:	53                   	push   %ebx
  8000fd:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800100:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800103:	e8 73 0a 00 00       	call   800b7b <sys_getenvid>
  800108:	25 ff 03 00 00       	and    $0x3ff,%eax
  80010d:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800110:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800115:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80011a:	85 db                	test   %ebx,%ebx
  80011c:	7e 07                	jle    800125 <libmain+0x2d>
		binaryname = argv[0];
  80011e:	8b 06                	mov    (%esi),%eax
  800120:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800125:	83 ec 08             	sub    $0x8,%esp
  800128:	56                   	push   %esi
  800129:	53                   	push   %ebx
  80012a:	e8 86 ff ff ff       	call   8000b5 <umain>

	// exit gracefully
	exit();
  80012f:	e8 0a 00 00 00       	call   80013e <exit>
}
  800134:	83 c4 10             	add    $0x10,%esp
  800137:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80013a:	5b                   	pop    %ebx
  80013b:	5e                   	pop    %esi
  80013c:	5d                   	pop    %ebp
  80013d:	c3                   	ret    

0080013e <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80013e:	55                   	push   %ebp
  80013f:	89 e5                	mov    %esp,%ebp
  800141:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800144:	e8 b0 11 00 00       	call   8012f9 <close_all>
	sys_env_destroy(0);
  800149:	83 ec 0c             	sub    $0xc,%esp
  80014c:	6a 00                	push   $0x0
  80014e:	e8 e7 09 00 00       	call   800b3a <sys_env_destroy>
}
  800153:	83 c4 10             	add    $0x10,%esp
  800156:	c9                   	leave  
  800157:	c3                   	ret    

00800158 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800158:	55                   	push   %ebp
  800159:	89 e5                	mov    %esp,%ebp
  80015b:	56                   	push   %esi
  80015c:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80015d:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800160:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800166:	e8 10 0a 00 00       	call   800b7b <sys_getenvid>
  80016b:	83 ec 0c             	sub    $0xc,%esp
  80016e:	ff 75 0c             	pushl  0xc(%ebp)
  800171:	ff 75 08             	pushl  0x8(%ebp)
  800174:	56                   	push   %esi
  800175:	50                   	push   %eax
  800176:	68 90 21 80 00       	push   $0x802190
  80017b:	e8 b1 00 00 00       	call   800231 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800180:	83 c4 18             	add    $0x18,%esp
  800183:	53                   	push   %ebx
  800184:	ff 75 10             	pushl  0x10(%ebp)
  800187:	e8 54 00 00 00       	call   8001e0 <vcprintf>
	cprintf("\n");
  80018c:	c7 04 24 93 26 80 00 	movl   $0x802693,(%esp)
  800193:	e8 99 00 00 00       	call   800231 <cprintf>
  800198:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80019b:	cc                   	int3   
  80019c:	eb fd                	jmp    80019b <_panic+0x43>

0080019e <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80019e:	55                   	push   %ebp
  80019f:	89 e5                	mov    %esp,%ebp
  8001a1:	53                   	push   %ebx
  8001a2:	83 ec 04             	sub    $0x4,%esp
  8001a5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001a8:	8b 13                	mov    (%ebx),%edx
  8001aa:	8d 42 01             	lea    0x1(%edx),%eax
  8001ad:	89 03                	mov    %eax,(%ebx)
  8001af:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001b2:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001b6:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001bb:	75 1a                	jne    8001d7 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8001bd:	83 ec 08             	sub    $0x8,%esp
  8001c0:	68 ff 00 00 00       	push   $0xff
  8001c5:	8d 43 08             	lea    0x8(%ebx),%eax
  8001c8:	50                   	push   %eax
  8001c9:	e8 2f 09 00 00       	call   800afd <sys_cputs>
		b->idx = 0;
  8001ce:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001d4:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8001d7:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001db:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001de:	c9                   	leave  
  8001df:	c3                   	ret    

008001e0 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001e0:	55                   	push   %ebp
  8001e1:	89 e5                	mov    %esp,%ebp
  8001e3:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001e9:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001f0:	00 00 00 
	b.cnt = 0;
  8001f3:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001fa:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001fd:	ff 75 0c             	pushl  0xc(%ebp)
  800200:	ff 75 08             	pushl  0x8(%ebp)
  800203:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800209:	50                   	push   %eax
  80020a:	68 9e 01 80 00       	push   $0x80019e
  80020f:	e8 54 01 00 00       	call   800368 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800214:	83 c4 08             	add    $0x8,%esp
  800217:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80021d:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800223:	50                   	push   %eax
  800224:	e8 d4 08 00 00       	call   800afd <sys_cputs>

	return b.cnt;
}
  800229:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80022f:	c9                   	leave  
  800230:	c3                   	ret    

00800231 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800231:	55                   	push   %ebp
  800232:	89 e5                	mov    %esp,%ebp
  800234:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800237:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80023a:	50                   	push   %eax
  80023b:	ff 75 08             	pushl  0x8(%ebp)
  80023e:	e8 9d ff ff ff       	call   8001e0 <vcprintf>
	va_end(ap);

	return cnt;
}
  800243:	c9                   	leave  
  800244:	c3                   	ret    

00800245 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800245:	55                   	push   %ebp
  800246:	89 e5                	mov    %esp,%ebp
  800248:	57                   	push   %edi
  800249:	56                   	push   %esi
  80024a:	53                   	push   %ebx
  80024b:	83 ec 1c             	sub    $0x1c,%esp
  80024e:	89 c7                	mov    %eax,%edi
  800250:	89 d6                	mov    %edx,%esi
  800252:	8b 45 08             	mov    0x8(%ebp),%eax
  800255:	8b 55 0c             	mov    0xc(%ebp),%edx
  800258:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80025b:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80025e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800261:	bb 00 00 00 00       	mov    $0x0,%ebx
  800266:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800269:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80026c:	39 d3                	cmp    %edx,%ebx
  80026e:	72 05                	jb     800275 <printnum+0x30>
  800270:	39 45 10             	cmp    %eax,0x10(%ebp)
  800273:	77 45                	ja     8002ba <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800275:	83 ec 0c             	sub    $0xc,%esp
  800278:	ff 75 18             	pushl  0x18(%ebp)
  80027b:	8b 45 14             	mov    0x14(%ebp),%eax
  80027e:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800281:	53                   	push   %ebx
  800282:	ff 75 10             	pushl  0x10(%ebp)
  800285:	83 ec 08             	sub    $0x8,%esp
  800288:	ff 75 e4             	pushl  -0x1c(%ebp)
  80028b:	ff 75 e0             	pushl  -0x20(%ebp)
  80028e:	ff 75 dc             	pushl  -0x24(%ebp)
  800291:	ff 75 d8             	pushl  -0x28(%ebp)
  800294:	e8 27 1c 00 00       	call   801ec0 <__udivdi3>
  800299:	83 c4 18             	add    $0x18,%esp
  80029c:	52                   	push   %edx
  80029d:	50                   	push   %eax
  80029e:	89 f2                	mov    %esi,%edx
  8002a0:	89 f8                	mov    %edi,%eax
  8002a2:	e8 9e ff ff ff       	call   800245 <printnum>
  8002a7:	83 c4 20             	add    $0x20,%esp
  8002aa:	eb 18                	jmp    8002c4 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002ac:	83 ec 08             	sub    $0x8,%esp
  8002af:	56                   	push   %esi
  8002b0:	ff 75 18             	pushl  0x18(%ebp)
  8002b3:	ff d7                	call   *%edi
  8002b5:	83 c4 10             	add    $0x10,%esp
  8002b8:	eb 03                	jmp    8002bd <printnum+0x78>
  8002ba:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002bd:	83 eb 01             	sub    $0x1,%ebx
  8002c0:	85 db                	test   %ebx,%ebx
  8002c2:	7f e8                	jg     8002ac <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002c4:	83 ec 08             	sub    $0x8,%esp
  8002c7:	56                   	push   %esi
  8002c8:	83 ec 04             	sub    $0x4,%esp
  8002cb:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002ce:	ff 75 e0             	pushl  -0x20(%ebp)
  8002d1:	ff 75 dc             	pushl  -0x24(%ebp)
  8002d4:	ff 75 d8             	pushl  -0x28(%ebp)
  8002d7:	e8 14 1d 00 00       	call   801ff0 <__umoddi3>
  8002dc:	83 c4 14             	add    $0x14,%esp
  8002df:	0f be 80 b3 21 80 00 	movsbl 0x8021b3(%eax),%eax
  8002e6:	50                   	push   %eax
  8002e7:	ff d7                	call   *%edi
}
  8002e9:	83 c4 10             	add    $0x10,%esp
  8002ec:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002ef:	5b                   	pop    %ebx
  8002f0:	5e                   	pop    %esi
  8002f1:	5f                   	pop    %edi
  8002f2:	5d                   	pop    %ebp
  8002f3:	c3                   	ret    

008002f4 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002f4:	55                   	push   %ebp
  8002f5:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002f7:	83 fa 01             	cmp    $0x1,%edx
  8002fa:	7e 0e                	jle    80030a <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002fc:	8b 10                	mov    (%eax),%edx
  8002fe:	8d 4a 08             	lea    0x8(%edx),%ecx
  800301:	89 08                	mov    %ecx,(%eax)
  800303:	8b 02                	mov    (%edx),%eax
  800305:	8b 52 04             	mov    0x4(%edx),%edx
  800308:	eb 22                	jmp    80032c <getuint+0x38>
	else if (lflag)
  80030a:	85 d2                	test   %edx,%edx
  80030c:	74 10                	je     80031e <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80030e:	8b 10                	mov    (%eax),%edx
  800310:	8d 4a 04             	lea    0x4(%edx),%ecx
  800313:	89 08                	mov    %ecx,(%eax)
  800315:	8b 02                	mov    (%edx),%eax
  800317:	ba 00 00 00 00       	mov    $0x0,%edx
  80031c:	eb 0e                	jmp    80032c <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80031e:	8b 10                	mov    (%eax),%edx
  800320:	8d 4a 04             	lea    0x4(%edx),%ecx
  800323:	89 08                	mov    %ecx,(%eax)
  800325:	8b 02                	mov    (%edx),%eax
  800327:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80032c:	5d                   	pop    %ebp
  80032d:	c3                   	ret    

0080032e <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80032e:	55                   	push   %ebp
  80032f:	89 e5                	mov    %esp,%ebp
  800331:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800334:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800338:	8b 10                	mov    (%eax),%edx
  80033a:	3b 50 04             	cmp    0x4(%eax),%edx
  80033d:	73 0a                	jae    800349 <sprintputch+0x1b>
		*b->buf++ = ch;
  80033f:	8d 4a 01             	lea    0x1(%edx),%ecx
  800342:	89 08                	mov    %ecx,(%eax)
  800344:	8b 45 08             	mov    0x8(%ebp),%eax
  800347:	88 02                	mov    %al,(%edx)
}
  800349:	5d                   	pop    %ebp
  80034a:	c3                   	ret    

0080034b <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80034b:	55                   	push   %ebp
  80034c:	89 e5                	mov    %esp,%ebp
  80034e:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800351:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800354:	50                   	push   %eax
  800355:	ff 75 10             	pushl  0x10(%ebp)
  800358:	ff 75 0c             	pushl  0xc(%ebp)
  80035b:	ff 75 08             	pushl  0x8(%ebp)
  80035e:	e8 05 00 00 00       	call   800368 <vprintfmt>
	va_end(ap);
}
  800363:	83 c4 10             	add    $0x10,%esp
  800366:	c9                   	leave  
  800367:	c3                   	ret    

00800368 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800368:	55                   	push   %ebp
  800369:	89 e5                	mov    %esp,%ebp
  80036b:	57                   	push   %edi
  80036c:	56                   	push   %esi
  80036d:	53                   	push   %ebx
  80036e:	83 ec 2c             	sub    $0x2c,%esp
  800371:	8b 75 08             	mov    0x8(%ebp),%esi
  800374:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800377:	8b 7d 10             	mov    0x10(%ebp),%edi
  80037a:	eb 12                	jmp    80038e <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80037c:	85 c0                	test   %eax,%eax
  80037e:	0f 84 89 03 00 00    	je     80070d <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  800384:	83 ec 08             	sub    $0x8,%esp
  800387:	53                   	push   %ebx
  800388:	50                   	push   %eax
  800389:	ff d6                	call   *%esi
  80038b:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80038e:	83 c7 01             	add    $0x1,%edi
  800391:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800395:	83 f8 25             	cmp    $0x25,%eax
  800398:	75 e2                	jne    80037c <vprintfmt+0x14>
  80039a:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80039e:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8003a5:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003ac:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8003b3:	ba 00 00 00 00       	mov    $0x0,%edx
  8003b8:	eb 07                	jmp    8003c1 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ba:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8003bd:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003c1:	8d 47 01             	lea    0x1(%edi),%eax
  8003c4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003c7:	0f b6 07             	movzbl (%edi),%eax
  8003ca:	0f b6 c8             	movzbl %al,%ecx
  8003cd:	83 e8 23             	sub    $0x23,%eax
  8003d0:	3c 55                	cmp    $0x55,%al
  8003d2:	0f 87 1a 03 00 00    	ja     8006f2 <vprintfmt+0x38a>
  8003d8:	0f b6 c0             	movzbl %al,%eax
  8003db:	ff 24 85 00 23 80 00 	jmp    *0x802300(,%eax,4)
  8003e2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003e5:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8003e9:	eb d6                	jmp    8003c1 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003eb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003ee:	b8 00 00 00 00       	mov    $0x0,%eax
  8003f3:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003f6:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003f9:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8003fd:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800400:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800403:	83 fa 09             	cmp    $0x9,%edx
  800406:	77 39                	ja     800441 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800408:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80040b:	eb e9                	jmp    8003f6 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80040d:	8b 45 14             	mov    0x14(%ebp),%eax
  800410:	8d 48 04             	lea    0x4(%eax),%ecx
  800413:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800416:	8b 00                	mov    (%eax),%eax
  800418:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80041b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80041e:	eb 27                	jmp    800447 <vprintfmt+0xdf>
  800420:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800423:	85 c0                	test   %eax,%eax
  800425:	b9 00 00 00 00       	mov    $0x0,%ecx
  80042a:	0f 49 c8             	cmovns %eax,%ecx
  80042d:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800430:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800433:	eb 8c                	jmp    8003c1 <vprintfmt+0x59>
  800435:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800438:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80043f:	eb 80                	jmp    8003c1 <vprintfmt+0x59>
  800441:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800444:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800447:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80044b:	0f 89 70 ff ff ff    	jns    8003c1 <vprintfmt+0x59>
				width = precision, precision = -1;
  800451:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800454:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800457:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80045e:	e9 5e ff ff ff       	jmp    8003c1 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800463:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800466:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800469:	e9 53 ff ff ff       	jmp    8003c1 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80046e:	8b 45 14             	mov    0x14(%ebp),%eax
  800471:	8d 50 04             	lea    0x4(%eax),%edx
  800474:	89 55 14             	mov    %edx,0x14(%ebp)
  800477:	83 ec 08             	sub    $0x8,%esp
  80047a:	53                   	push   %ebx
  80047b:	ff 30                	pushl  (%eax)
  80047d:	ff d6                	call   *%esi
			break;
  80047f:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800482:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800485:	e9 04 ff ff ff       	jmp    80038e <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80048a:	8b 45 14             	mov    0x14(%ebp),%eax
  80048d:	8d 50 04             	lea    0x4(%eax),%edx
  800490:	89 55 14             	mov    %edx,0x14(%ebp)
  800493:	8b 00                	mov    (%eax),%eax
  800495:	99                   	cltd   
  800496:	31 d0                	xor    %edx,%eax
  800498:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80049a:	83 f8 0f             	cmp    $0xf,%eax
  80049d:	7f 0b                	jg     8004aa <vprintfmt+0x142>
  80049f:	8b 14 85 60 24 80 00 	mov    0x802460(,%eax,4),%edx
  8004a6:	85 d2                	test   %edx,%edx
  8004a8:	75 18                	jne    8004c2 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8004aa:	50                   	push   %eax
  8004ab:	68 cb 21 80 00       	push   $0x8021cb
  8004b0:	53                   	push   %ebx
  8004b1:	56                   	push   %esi
  8004b2:	e8 94 fe ff ff       	call   80034b <printfmt>
  8004b7:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ba:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8004bd:	e9 cc fe ff ff       	jmp    80038e <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8004c2:	52                   	push   %edx
  8004c3:	68 61 26 80 00       	push   $0x802661
  8004c8:	53                   	push   %ebx
  8004c9:	56                   	push   %esi
  8004ca:	e8 7c fe ff ff       	call   80034b <printfmt>
  8004cf:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004d2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004d5:	e9 b4 fe ff ff       	jmp    80038e <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004da:	8b 45 14             	mov    0x14(%ebp),%eax
  8004dd:	8d 50 04             	lea    0x4(%eax),%edx
  8004e0:	89 55 14             	mov    %edx,0x14(%ebp)
  8004e3:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8004e5:	85 ff                	test   %edi,%edi
  8004e7:	b8 c4 21 80 00       	mov    $0x8021c4,%eax
  8004ec:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8004ef:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004f3:	0f 8e 94 00 00 00    	jle    80058d <vprintfmt+0x225>
  8004f9:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8004fd:	0f 84 98 00 00 00    	je     80059b <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  800503:	83 ec 08             	sub    $0x8,%esp
  800506:	ff 75 d0             	pushl  -0x30(%ebp)
  800509:	57                   	push   %edi
  80050a:	e8 86 02 00 00       	call   800795 <strnlen>
  80050f:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800512:	29 c1                	sub    %eax,%ecx
  800514:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800517:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80051a:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80051e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800521:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800524:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800526:	eb 0f                	jmp    800537 <vprintfmt+0x1cf>
					putch(padc, putdat);
  800528:	83 ec 08             	sub    $0x8,%esp
  80052b:	53                   	push   %ebx
  80052c:	ff 75 e0             	pushl  -0x20(%ebp)
  80052f:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800531:	83 ef 01             	sub    $0x1,%edi
  800534:	83 c4 10             	add    $0x10,%esp
  800537:	85 ff                	test   %edi,%edi
  800539:	7f ed                	jg     800528 <vprintfmt+0x1c0>
  80053b:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80053e:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800541:	85 c9                	test   %ecx,%ecx
  800543:	b8 00 00 00 00       	mov    $0x0,%eax
  800548:	0f 49 c1             	cmovns %ecx,%eax
  80054b:	29 c1                	sub    %eax,%ecx
  80054d:	89 75 08             	mov    %esi,0x8(%ebp)
  800550:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800553:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800556:	89 cb                	mov    %ecx,%ebx
  800558:	eb 4d                	jmp    8005a7 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80055a:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80055e:	74 1b                	je     80057b <vprintfmt+0x213>
  800560:	0f be c0             	movsbl %al,%eax
  800563:	83 e8 20             	sub    $0x20,%eax
  800566:	83 f8 5e             	cmp    $0x5e,%eax
  800569:	76 10                	jbe    80057b <vprintfmt+0x213>
					putch('?', putdat);
  80056b:	83 ec 08             	sub    $0x8,%esp
  80056e:	ff 75 0c             	pushl  0xc(%ebp)
  800571:	6a 3f                	push   $0x3f
  800573:	ff 55 08             	call   *0x8(%ebp)
  800576:	83 c4 10             	add    $0x10,%esp
  800579:	eb 0d                	jmp    800588 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  80057b:	83 ec 08             	sub    $0x8,%esp
  80057e:	ff 75 0c             	pushl  0xc(%ebp)
  800581:	52                   	push   %edx
  800582:	ff 55 08             	call   *0x8(%ebp)
  800585:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800588:	83 eb 01             	sub    $0x1,%ebx
  80058b:	eb 1a                	jmp    8005a7 <vprintfmt+0x23f>
  80058d:	89 75 08             	mov    %esi,0x8(%ebp)
  800590:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800593:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800596:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800599:	eb 0c                	jmp    8005a7 <vprintfmt+0x23f>
  80059b:	89 75 08             	mov    %esi,0x8(%ebp)
  80059e:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005a1:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005a4:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8005a7:	83 c7 01             	add    $0x1,%edi
  8005aa:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8005ae:	0f be d0             	movsbl %al,%edx
  8005b1:	85 d2                	test   %edx,%edx
  8005b3:	74 23                	je     8005d8 <vprintfmt+0x270>
  8005b5:	85 f6                	test   %esi,%esi
  8005b7:	78 a1                	js     80055a <vprintfmt+0x1f2>
  8005b9:	83 ee 01             	sub    $0x1,%esi
  8005bc:	79 9c                	jns    80055a <vprintfmt+0x1f2>
  8005be:	89 df                	mov    %ebx,%edi
  8005c0:	8b 75 08             	mov    0x8(%ebp),%esi
  8005c3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005c6:	eb 18                	jmp    8005e0 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005c8:	83 ec 08             	sub    $0x8,%esp
  8005cb:	53                   	push   %ebx
  8005cc:	6a 20                	push   $0x20
  8005ce:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005d0:	83 ef 01             	sub    $0x1,%edi
  8005d3:	83 c4 10             	add    $0x10,%esp
  8005d6:	eb 08                	jmp    8005e0 <vprintfmt+0x278>
  8005d8:	89 df                	mov    %ebx,%edi
  8005da:	8b 75 08             	mov    0x8(%ebp),%esi
  8005dd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005e0:	85 ff                	test   %edi,%edi
  8005e2:	7f e4                	jg     8005c8 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005e4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005e7:	e9 a2 fd ff ff       	jmp    80038e <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005ec:	83 fa 01             	cmp    $0x1,%edx
  8005ef:	7e 16                	jle    800607 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8005f1:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f4:	8d 50 08             	lea    0x8(%eax),%edx
  8005f7:	89 55 14             	mov    %edx,0x14(%ebp)
  8005fa:	8b 50 04             	mov    0x4(%eax),%edx
  8005fd:	8b 00                	mov    (%eax),%eax
  8005ff:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800602:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800605:	eb 32                	jmp    800639 <vprintfmt+0x2d1>
	else if (lflag)
  800607:	85 d2                	test   %edx,%edx
  800609:	74 18                	je     800623 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  80060b:	8b 45 14             	mov    0x14(%ebp),%eax
  80060e:	8d 50 04             	lea    0x4(%eax),%edx
  800611:	89 55 14             	mov    %edx,0x14(%ebp)
  800614:	8b 00                	mov    (%eax),%eax
  800616:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800619:	89 c1                	mov    %eax,%ecx
  80061b:	c1 f9 1f             	sar    $0x1f,%ecx
  80061e:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800621:	eb 16                	jmp    800639 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  800623:	8b 45 14             	mov    0x14(%ebp),%eax
  800626:	8d 50 04             	lea    0x4(%eax),%edx
  800629:	89 55 14             	mov    %edx,0x14(%ebp)
  80062c:	8b 00                	mov    (%eax),%eax
  80062e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800631:	89 c1                	mov    %eax,%ecx
  800633:	c1 f9 1f             	sar    $0x1f,%ecx
  800636:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800639:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80063c:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80063f:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800644:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800648:	79 74                	jns    8006be <vprintfmt+0x356>
				putch('-', putdat);
  80064a:	83 ec 08             	sub    $0x8,%esp
  80064d:	53                   	push   %ebx
  80064e:	6a 2d                	push   $0x2d
  800650:	ff d6                	call   *%esi
				num = -(long long) num;
  800652:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800655:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800658:	f7 d8                	neg    %eax
  80065a:	83 d2 00             	adc    $0x0,%edx
  80065d:	f7 da                	neg    %edx
  80065f:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800662:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800667:	eb 55                	jmp    8006be <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800669:	8d 45 14             	lea    0x14(%ebp),%eax
  80066c:	e8 83 fc ff ff       	call   8002f4 <getuint>
			base = 10;
  800671:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800676:	eb 46                	jmp    8006be <vprintfmt+0x356>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
  800678:	8d 45 14             	lea    0x14(%ebp),%eax
  80067b:	e8 74 fc ff ff       	call   8002f4 <getuint>
			base = 8;
  800680:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800685:	eb 37                	jmp    8006be <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  800687:	83 ec 08             	sub    $0x8,%esp
  80068a:	53                   	push   %ebx
  80068b:	6a 30                	push   $0x30
  80068d:	ff d6                	call   *%esi
			putch('x', putdat);
  80068f:	83 c4 08             	add    $0x8,%esp
  800692:	53                   	push   %ebx
  800693:	6a 78                	push   $0x78
  800695:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800697:	8b 45 14             	mov    0x14(%ebp),%eax
  80069a:	8d 50 04             	lea    0x4(%eax),%edx
  80069d:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8006a0:	8b 00                	mov    (%eax),%eax
  8006a2:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8006a7:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8006aa:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8006af:	eb 0d                	jmp    8006be <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006b1:	8d 45 14             	lea    0x14(%ebp),%eax
  8006b4:	e8 3b fc ff ff       	call   8002f4 <getuint>
			base = 16;
  8006b9:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006be:	83 ec 0c             	sub    $0xc,%esp
  8006c1:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8006c5:	57                   	push   %edi
  8006c6:	ff 75 e0             	pushl  -0x20(%ebp)
  8006c9:	51                   	push   %ecx
  8006ca:	52                   	push   %edx
  8006cb:	50                   	push   %eax
  8006cc:	89 da                	mov    %ebx,%edx
  8006ce:	89 f0                	mov    %esi,%eax
  8006d0:	e8 70 fb ff ff       	call   800245 <printnum>
			break;
  8006d5:	83 c4 20             	add    $0x20,%esp
  8006d8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006db:	e9 ae fc ff ff       	jmp    80038e <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006e0:	83 ec 08             	sub    $0x8,%esp
  8006e3:	53                   	push   %ebx
  8006e4:	51                   	push   %ecx
  8006e5:	ff d6                	call   *%esi
			break;
  8006e7:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006ea:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006ed:	e9 9c fc ff ff       	jmp    80038e <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006f2:	83 ec 08             	sub    $0x8,%esp
  8006f5:	53                   	push   %ebx
  8006f6:	6a 25                	push   $0x25
  8006f8:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006fa:	83 c4 10             	add    $0x10,%esp
  8006fd:	eb 03                	jmp    800702 <vprintfmt+0x39a>
  8006ff:	83 ef 01             	sub    $0x1,%edi
  800702:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800706:	75 f7                	jne    8006ff <vprintfmt+0x397>
  800708:	e9 81 fc ff ff       	jmp    80038e <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  80070d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800710:	5b                   	pop    %ebx
  800711:	5e                   	pop    %esi
  800712:	5f                   	pop    %edi
  800713:	5d                   	pop    %ebp
  800714:	c3                   	ret    

00800715 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800715:	55                   	push   %ebp
  800716:	89 e5                	mov    %esp,%ebp
  800718:	83 ec 18             	sub    $0x18,%esp
  80071b:	8b 45 08             	mov    0x8(%ebp),%eax
  80071e:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800721:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800724:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800728:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80072b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800732:	85 c0                	test   %eax,%eax
  800734:	74 26                	je     80075c <vsnprintf+0x47>
  800736:	85 d2                	test   %edx,%edx
  800738:	7e 22                	jle    80075c <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80073a:	ff 75 14             	pushl  0x14(%ebp)
  80073d:	ff 75 10             	pushl  0x10(%ebp)
  800740:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800743:	50                   	push   %eax
  800744:	68 2e 03 80 00       	push   $0x80032e
  800749:	e8 1a fc ff ff       	call   800368 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80074e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800751:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800754:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800757:	83 c4 10             	add    $0x10,%esp
  80075a:	eb 05                	jmp    800761 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80075c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800761:	c9                   	leave  
  800762:	c3                   	ret    

00800763 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800763:	55                   	push   %ebp
  800764:	89 e5                	mov    %esp,%ebp
  800766:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800769:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80076c:	50                   	push   %eax
  80076d:	ff 75 10             	pushl  0x10(%ebp)
  800770:	ff 75 0c             	pushl  0xc(%ebp)
  800773:	ff 75 08             	pushl  0x8(%ebp)
  800776:	e8 9a ff ff ff       	call   800715 <vsnprintf>
	va_end(ap);

	return rc;
}
  80077b:	c9                   	leave  
  80077c:	c3                   	ret    

0080077d <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80077d:	55                   	push   %ebp
  80077e:	89 e5                	mov    %esp,%ebp
  800780:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800783:	b8 00 00 00 00       	mov    $0x0,%eax
  800788:	eb 03                	jmp    80078d <strlen+0x10>
		n++;
  80078a:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80078d:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800791:	75 f7                	jne    80078a <strlen+0xd>
		n++;
	return n;
}
  800793:	5d                   	pop    %ebp
  800794:	c3                   	ret    

00800795 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800795:	55                   	push   %ebp
  800796:	89 e5                	mov    %esp,%ebp
  800798:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80079b:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80079e:	ba 00 00 00 00       	mov    $0x0,%edx
  8007a3:	eb 03                	jmp    8007a8 <strnlen+0x13>
		n++;
  8007a5:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007a8:	39 c2                	cmp    %eax,%edx
  8007aa:	74 08                	je     8007b4 <strnlen+0x1f>
  8007ac:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8007b0:	75 f3                	jne    8007a5 <strnlen+0x10>
  8007b2:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8007b4:	5d                   	pop    %ebp
  8007b5:	c3                   	ret    

008007b6 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007b6:	55                   	push   %ebp
  8007b7:	89 e5                	mov    %esp,%ebp
  8007b9:	53                   	push   %ebx
  8007ba:	8b 45 08             	mov    0x8(%ebp),%eax
  8007bd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007c0:	89 c2                	mov    %eax,%edx
  8007c2:	83 c2 01             	add    $0x1,%edx
  8007c5:	83 c1 01             	add    $0x1,%ecx
  8007c8:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8007cc:	88 5a ff             	mov    %bl,-0x1(%edx)
  8007cf:	84 db                	test   %bl,%bl
  8007d1:	75 ef                	jne    8007c2 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8007d3:	5b                   	pop    %ebx
  8007d4:	5d                   	pop    %ebp
  8007d5:	c3                   	ret    

008007d6 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007d6:	55                   	push   %ebp
  8007d7:	89 e5                	mov    %esp,%ebp
  8007d9:	53                   	push   %ebx
  8007da:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007dd:	53                   	push   %ebx
  8007de:	e8 9a ff ff ff       	call   80077d <strlen>
  8007e3:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007e6:	ff 75 0c             	pushl  0xc(%ebp)
  8007e9:	01 d8                	add    %ebx,%eax
  8007eb:	50                   	push   %eax
  8007ec:	e8 c5 ff ff ff       	call   8007b6 <strcpy>
	return dst;
}
  8007f1:	89 d8                	mov    %ebx,%eax
  8007f3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007f6:	c9                   	leave  
  8007f7:	c3                   	ret    

008007f8 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007f8:	55                   	push   %ebp
  8007f9:	89 e5                	mov    %esp,%ebp
  8007fb:	56                   	push   %esi
  8007fc:	53                   	push   %ebx
  8007fd:	8b 75 08             	mov    0x8(%ebp),%esi
  800800:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800803:	89 f3                	mov    %esi,%ebx
  800805:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800808:	89 f2                	mov    %esi,%edx
  80080a:	eb 0f                	jmp    80081b <strncpy+0x23>
		*dst++ = *src;
  80080c:	83 c2 01             	add    $0x1,%edx
  80080f:	0f b6 01             	movzbl (%ecx),%eax
  800812:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800815:	80 39 01             	cmpb   $0x1,(%ecx)
  800818:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80081b:	39 da                	cmp    %ebx,%edx
  80081d:	75 ed                	jne    80080c <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80081f:	89 f0                	mov    %esi,%eax
  800821:	5b                   	pop    %ebx
  800822:	5e                   	pop    %esi
  800823:	5d                   	pop    %ebp
  800824:	c3                   	ret    

00800825 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800825:	55                   	push   %ebp
  800826:	89 e5                	mov    %esp,%ebp
  800828:	56                   	push   %esi
  800829:	53                   	push   %ebx
  80082a:	8b 75 08             	mov    0x8(%ebp),%esi
  80082d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800830:	8b 55 10             	mov    0x10(%ebp),%edx
  800833:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800835:	85 d2                	test   %edx,%edx
  800837:	74 21                	je     80085a <strlcpy+0x35>
  800839:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80083d:	89 f2                	mov    %esi,%edx
  80083f:	eb 09                	jmp    80084a <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800841:	83 c2 01             	add    $0x1,%edx
  800844:	83 c1 01             	add    $0x1,%ecx
  800847:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80084a:	39 c2                	cmp    %eax,%edx
  80084c:	74 09                	je     800857 <strlcpy+0x32>
  80084e:	0f b6 19             	movzbl (%ecx),%ebx
  800851:	84 db                	test   %bl,%bl
  800853:	75 ec                	jne    800841 <strlcpy+0x1c>
  800855:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800857:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80085a:	29 f0                	sub    %esi,%eax
}
  80085c:	5b                   	pop    %ebx
  80085d:	5e                   	pop    %esi
  80085e:	5d                   	pop    %ebp
  80085f:	c3                   	ret    

00800860 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800860:	55                   	push   %ebp
  800861:	89 e5                	mov    %esp,%ebp
  800863:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800866:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800869:	eb 06                	jmp    800871 <strcmp+0x11>
		p++, q++;
  80086b:	83 c1 01             	add    $0x1,%ecx
  80086e:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800871:	0f b6 01             	movzbl (%ecx),%eax
  800874:	84 c0                	test   %al,%al
  800876:	74 04                	je     80087c <strcmp+0x1c>
  800878:	3a 02                	cmp    (%edx),%al
  80087a:	74 ef                	je     80086b <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80087c:	0f b6 c0             	movzbl %al,%eax
  80087f:	0f b6 12             	movzbl (%edx),%edx
  800882:	29 d0                	sub    %edx,%eax
}
  800884:	5d                   	pop    %ebp
  800885:	c3                   	ret    

00800886 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800886:	55                   	push   %ebp
  800887:	89 e5                	mov    %esp,%ebp
  800889:	53                   	push   %ebx
  80088a:	8b 45 08             	mov    0x8(%ebp),%eax
  80088d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800890:	89 c3                	mov    %eax,%ebx
  800892:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800895:	eb 06                	jmp    80089d <strncmp+0x17>
		n--, p++, q++;
  800897:	83 c0 01             	add    $0x1,%eax
  80089a:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80089d:	39 d8                	cmp    %ebx,%eax
  80089f:	74 15                	je     8008b6 <strncmp+0x30>
  8008a1:	0f b6 08             	movzbl (%eax),%ecx
  8008a4:	84 c9                	test   %cl,%cl
  8008a6:	74 04                	je     8008ac <strncmp+0x26>
  8008a8:	3a 0a                	cmp    (%edx),%cl
  8008aa:	74 eb                	je     800897 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008ac:	0f b6 00             	movzbl (%eax),%eax
  8008af:	0f b6 12             	movzbl (%edx),%edx
  8008b2:	29 d0                	sub    %edx,%eax
  8008b4:	eb 05                	jmp    8008bb <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008b6:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008bb:	5b                   	pop    %ebx
  8008bc:	5d                   	pop    %ebp
  8008bd:	c3                   	ret    

008008be <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008be:	55                   	push   %ebp
  8008bf:	89 e5                	mov    %esp,%ebp
  8008c1:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c4:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008c8:	eb 07                	jmp    8008d1 <strchr+0x13>
		if (*s == c)
  8008ca:	38 ca                	cmp    %cl,%dl
  8008cc:	74 0f                	je     8008dd <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008ce:	83 c0 01             	add    $0x1,%eax
  8008d1:	0f b6 10             	movzbl (%eax),%edx
  8008d4:	84 d2                	test   %dl,%dl
  8008d6:	75 f2                	jne    8008ca <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8008d8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008dd:	5d                   	pop    %ebp
  8008de:	c3                   	ret    

008008df <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008df:	55                   	push   %ebp
  8008e0:	89 e5                	mov    %esp,%ebp
  8008e2:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e5:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008e9:	eb 03                	jmp    8008ee <strfind+0xf>
  8008eb:	83 c0 01             	add    $0x1,%eax
  8008ee:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008f1:	38 ca                	cmp    %cl,%dl
  8008f3:	74 04                	je     8008f9 <strfind+0x1a>
  8008f5:	84 d2                	test   %dl,%dl
  8008f7:	75 f2                	jne    8008eb <strfind+0xc>
			break;
	return (char *) s;
}
  8008f9:	5d                   	pop    %ebp
  8008fa:	c3                   	ret    

008008fb <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008fb:	55                   	push   %ebp
  8008fc:	89 e5                	mov    %esp,%ebp
  8008fe:	57                   	push   %edi
  8008ff:	56                   	push   %esi
  800900:	53                   	push   %ebx
  800901:	8b 7d 08             	mov    0x8(%ebp),%edi
  800904:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800907:	85 c9                	test   %ecx,%ecx
  800909:	74 36                	je     800941 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80090b:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800911:	75 28                	jne    80093b <memset+0x40>
  800913:	f6 c1 03             	test   $0x3,%cl
  800916:	75 23                	jne    80093b <memset+0x40>
		c &= 0xFF;
  800918:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80091c:	89 d3                	mov    %edx,%ebx
  80091e:	c1 e3 08             	shl    $0x8,%ebx
  800921:	89 d6                	mov    %edx,%esi
  800923:	c1 e6 18             	shl    $0x18,%esi
  800926:	89 d0                	mov    %edx,%eax
  800928:	c1 e0 10             	shl    $0x10,%eax
  80092b:	09 f0                	or     %esi,%eax
  80092d:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  80092f:	89 d8                	mov    %ebx,%eax
  800931:	09 d0                	or     %edx,%eax
  800933:	c1 e9 02             	shr    $0x2,%ecx
  800936:	fc                   	cld    
  800937:	f3 ab                	rep stos %eax,%es:(%edi)
  800939:	eb 06                	jmp    800941 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80093b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80093e:	fc                   	cld    
  80093f:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800941:	89 f8                	mov    %edi,%eax
  800943:	5b                   	pop    %ebx
  800944:	5e                   	pop    %esi
  800945:	5f                   	pop    %edi
  800946:	5d                   	pop    %ebp
  800947:	c3                   	ret    

00800948 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800948:	55                   	push   %ebp
  800949:	89 e5                	mov    %esp,%ebp
  80094b:	57                   	push   %edi
  80094c:	56                   	push   %esi
  80094d:	8b 45 08             	mov    0x8(%ebp),%eax
  800950:	8b 75 0c             	mov    0xc(%ebp),%esi
  800953:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800956:	39 c6                	cmp    %eax,%esi
  800958:	73 35                	jae    80098f <memmove+0x47>
  80095a:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80095d:	39 d0                	cmp    %edx,%eax
  80095f:	73 2e                	jae    80098f <memmove+0x47>
		s += n;
		d += n;
  800961:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800964:	89 d6                	mov    %edx,%esi
  800966:	09 fe                	or     %edi,%esi
  800968:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80096e:	75 13                	jne    800983 <memmove+0x3b>
  800970:	f6 c1 03             	test   $0x3,%cl
  800973:	75 0e                	jne    800983 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800975:	83 ef 04             	sub    $0x4,%edi
  800978:	8d 72 fc             	lea    -0x4(%edx),%esi
  80097b:	c1 e9 02             	shr    $0x2,%ecx
  80097e:	fd                   	std    
  80097f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800981:	eb 09                	jmp    80098c <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800983:	83 ef 01             	sub    $0x1,%edi
  800986:	8d 72 ff             	lea    -0x1(%edx),%esi
  800989:	fd                   	std    
  80098a:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80098c:	fc                   	cld    
  80098d:	eb 1d                	jmp    8009ac <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80098f:	89 f2                	mov    %esi,%edx
  800991:	09 c2                	or     %eax,%edx
  800993:	f6 c2 03             	test   $0x3,%dl
  800996:	75 0f                	jne    8009a7 <memmove+0x5f>
  800998:	f6 c1 03             	test   $0x3,%cl
  80099b:	75 0a                	jne    8009a7 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  80099d:	c1 e9 02             	shr    $0x2,%ecx
  8009a0:	89 c7                	mov    %eax,%edi
  8009a2:	fc                   	cld    
  8009a3:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009a5:	eb 05                	jmp    8009ac <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009a7:	89 c7                	mov    %eax,%edi
  8009a9:	fc                   	cld    
  8009aa:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009ac:	5e                   	pop    %esi
  8009ad:	5f                   	pop    %edi
  8009ae:	5d                   	pop    %ebp
  8009af:	c3                   	ret    

008009b0 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009b0:	55                   	push   %ebp
  8009b1:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8009b3:	ff 75 10             	pushl  0x10(%ebp)
  8009b6:	ff 75 0c             	pushl  0xc(%ebp)
  8009b9:	ff 75 08             	pushl  0x8(%ebp)
  8009bc:	e8 87 ff ff ff       	call   800948 <memmove>
}
  8009c1:	c9                   	leave  
  8009c2:	c3                   	ret    

008009c3 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009c3:	55                   	push   %ebp
  8009c4:	89 e5                	mov    %esp,%ebp
  8009c6:	56                   	push   %esi
  8009c7:	53                   	push   %ebx
  8009c8:	8b 45 08             	mov    0x8(%ebp),%eax
  8009cb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009ce:	89 c6                	mov    %eax,%esi
  8009d0:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009d3:	eb 1a                	jmp    8009ef <memcmp+0x2c>
		if (*s1 != *s2)
  8009d5:	0f b6 08             	movzbl (%eax),%ecx
  8009d8:	0f b6 1a             	movzbl (%edx),%ebx
  8009db:	38 d9                	cmp    %bl,%cl
  8009dd:	74 0a                	je     8009e9 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8009df:	0f b6 c1             	movzbl %cl,%eax
  8009e2:	0f b6 db             	movzbl %bl,%ebx
  8009e5:	29 d8                	sub    %ebx,%eax
  8009e7:	eb 0f                	jmp    8009f8 <memcmp+0x35>
		s1++, s2++;
  8009e9:	83 c0 01             	add    $0x1,%eax
  8009ec:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009ef:	39 f0                	cmp    %esi,%eax
  8009f1:	75 e2                	jne    8009d5 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009f3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009f8:	5b                   	pop    %ebx
  8009f9:	5e                   	pop    %esi
  8009fa:	5d                   	pop    %ebp
  8009fb:	c3                   	ret    

008009fc <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009fc:	55                   	push   %ebp
  8009fd:	89 e5                	mov    %esp,%ebp
  8009ff:	53                   	push   %ebx
  800a00:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a03:	89 c1                	mov    %eax,%ecx
  800a05:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800a08:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a0c:	eb 0a                	jmp    800a18 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a0e:	0f b6 10             	movzbl (%eax),%edx
  800a11:	39 da                	cmp    %ebx,%edx
  800a13:	74 07                	je     800a1c <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a15:	83 c0 01             	add    $0x1,%eax
  800a18:	39 c8                	cmp    %ecx,%eax
  800a1a:	72 f2                	jb     800a0e <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a1c:	5b                   	pop    %ebx
  800a1d:	5d                   	pop    %ebp
  800a1e:	c3                   	ret    

00800a1f <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a1f:	55                   	push   %ebp
  800a20:	89 e5                	mov    %esp,%ebp
  800a22:	57                   	push   %edi
  800a23:	56                   	push   %esi
  800a24:	53                   	push   %ebx
  800a25:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a28:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a2b:	eb 03                	jmp    800a30 <strtol+0x11>
		s++;
  800a2d:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a30:	0f b6 01             	movzbl (%ecx),%eax
  800a33:	3c 20                	cmp    $0x20,%al
  800a35:	74 f6                	je     800a2d <strtol+0xe>
  800a37:	3c 09                	cmp    $0x9,%al
  800a39:	74 f2                	je     800a2d <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a3b:	3c 2b                	cmp    $0x2b,%al
  800a3d:	75 0a                	jne    800a49 <strtol+0x2a>
		s++;
  800a3f:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a42:	bf 00 00 00 00       	mov    $0x0,%edi
  800a47:	eb 11                	jmp    800a5a <strtol+0x3b>
  800a49:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a4e:	3c 2d                	cmp    $0x2d,%al
  800a50:	75 08                	jne    800a5a <strtol+0x3b>
		s++, neg = 1;
  800a52:	83 c1 01             	add    $0x1,%ecx
  800a55:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a5a:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a60:	75 15                	jne    800a77 <strtol+0x58>
  800a62:	80 39 30             	cmpb   $0x30,(%ecx)
  800a65:	75 10                	jne    800a77 <strtol+0x58>
  800a67:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a6b:	75 7c                	jne    800ae9 <strtol+0xca>
		s += 2, base = 16;
  800a6d:	83 c1 02             	add    $0x2,%ecx
  800a70:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a75:	eb 16                	jmp    800a8d <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800a77:	85 db                	test   %ebx,%ebx
  800a79:	75 12                	jne    800a8d <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a7b:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a80:	80 39 30             	cmpb   $0x30,(%ecx)
  800a83:	75 08                	jne    800a8d <strtol+0x6e>
		s++, base = 8;
  800a85:	83 c1 01             	add    $0x1,%ecx
  800a88:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a8d:	b8 00 00 00 00       	mov    $0x0,%eax
  800a92:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a95:	0f b6 11             	movzbl (%ecx),%edx
  800a98:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a9b:	89 f3                	mov    %esi,%ebx
  800a9d:	80 fb 09             	cmp    $0x9,%bl
  800aa0:	77 08                	ja     800aaa <strtol+0x8b>
			dig = *s - '0';
  800aa2:	0f be d2             	movsbl %dl,%edx
  800aa5:	83 ea 30             	sub    $0x30,%edx
  800aa8:	eb 22                	jmp    800acc <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800aaa:	8d 72 9f             	lea    -0x61(%edx),%esi
  800aad:	89 f3                	mov    %esi,%ebx
  800aaf:	80 fb 19             	cmp    $0x19,%bl
  800ab2:	77 08                	ja     800abc <strtol+0x9d>
			dig = *s - 'a' + 10;
  800ab4:	0f be d2             	movsbl %dl,%edx
  800ab7:	83 ea 57             	sub    $0x57,%edx
  800aba:	eb 10                	jmp    800acc <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800abc:	8d 72 bf             	lea    -0x41(%edx),%esi
  800abf:	89 f3                	mov    %esi,%ebx
  800ac1:	80 fb 19             	cmp    $0x19,%bl
  800ac4:	77 16                	ja     800adc <strtol+0xbd>
			dig = *s - 'A' + 10;
  800ac6:	0f be d2             	movsbl %dl,%edx
  800ac9:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800acc:	3b 55 10             	cmp    0x10(%ebp),%edx
  800acf:	7d 0b                	jge    800adc <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800ad1:	83 c1 01             	add    $0x1,%ecx
  800ad4:	0f af 45 10          	imul   0x10(%ebp),%eax
  800ad8:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800ada:	eb b9                	jmp    800a95 <strtol+0x76>

	if (endptr)
  800adc:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ae0:	74 0d                	je     800aef <strtol+0xd0>
		*endptr = (char *) s;
  800ae2:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ae5:	89 0e                	mov    %ecx,(%esi)
  800ae7:	eb 06                	jmp    800aef <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ae9:	85 db                	test   %ebx,%ebx
  800aeb:	74 98                	je     800a85 <strtol+0x66>
  800aed:	eb 9e                	jmp    800a8d <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800aef:	89 c2                	mov    %eax,%edx
  800af1:	f7 da                	neg    %edx
  800af3:	85 ff                	test   %edi,%edi
  800af5:	0f 45 c2             	cmovne %edx,%eax
}
  800af8:	5b                   	pop    %ebx
  800af9:	5e                   	pop    %esi
  800afa:	5f                   	pop    %edi
  800afb:	5d                   	pop    %ebp
  800afc:	c3                   	ret    

00800afd <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800afd:	55                   	push   %ebp
  800afe:	89 e5                	mov    %esp,%ebp
  800b00:	57                   	push   %edi
  800b01:	56                   	push   %esi
  800b02:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b03:	b8 00 00 00 00       	mov    $0x0,%eax
  800b08:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b0b:	8b 55 08             	mov    0x8(%ebp),%edx
  800b0e:	89 c3                	mov    %eax,%ebx
  800b10:	89 c7                	mov    %eax,%edi
  800b12:	89 c6                	mov    %eax,%esi
  800b14:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b16:	5b                   	pop    %ebx
  800b17:	5e                   	pop    %esi
  800b18:	5f                   	pop    %edi
  800b19:	5d                   	pop    %ebp
  800b1a:	c3                   	ret    

00800b1b <sys_cgetc>:

int
sys_cgetc(void)
{
  800b1b:	55                   	push   %ebp
  800b1c:	89 e5                	mov    %esp,%ebp
  800b1e:	57                   	push   %edi
  800b1f:	56                   	push   %esi
  800b20:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b21:	ba 00 00 00 00       	mov    $0x0,%edx
  800b26:	b8 01 00 00 00       	mov    $0x1,%eax
  800b2b:	89 d1                	mov    %edx,%ecx
  800b2d:	89 d3                	mov    %edx,%ebx
  800b2f:	89 d7                	mov    %edx,%edi
  800b31:	89 d6                	mov    %edx,%esi
  800b33:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b35:	5b                   	pop    %ebx
  800b36:	5e                   	pop    %esi
  800b37:	5f                   	pop    %edi
  800b38:	5d                   	pop    %ebp
  800b39:	c3                   	ret    

00800b3a <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b3a:	55                   	push   %ebp
  800b3b:	89 e5                	mov    %esp,%ebp
  800b3d:	57                   	push   %edi
  800b3e:	56                   	push   %esi
  800b3f:	53                   	push   %ebx
  800b40:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b43:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b48:	b8 03 00 00 00       	mov    $0x3,%eax
  800b4d:	8b 55 08             	mov    0x8(%ebp),%edx
  800b50:	89 cb                	mov    %ecx,%ebx
  800b52:	89 cf                	mov    %ecx,%edi
  800b54:	89 ce                	mov    %ecx,%esi
  800b56:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b58:	85 c0                	test   %eax,%eax
  800b5a:	7e 17                	jle    800b73 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b5c:	83 ec 0c             	sub    $0xc,%esp
  800b5f:	50                   	push   %eax
  800b60:	6a 03                	push   $0x3
  800b62:	68 bf 24 80 00       	push   $0x8024bf
  800b67:	6a 23                	push   $0x23
  800b69:	68 dc 24 80 00       	push   $0x8024dc
  800b6e:	e8 e5 f5 ff ff       	call   800158 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b73:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b76:	5b                   	pop    %ebx
  800b77:	5e                   	pop    %esi
  800b78:	5f                   	pop    %edi
  800b79:	5d                   	pop    %ebp
  800b7a:	c3                   	ret    

00800b7b <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b7b:	55                   	push   %ebp
  800b7c:	89 e5                	mov    %esp,%ebp
  800b7e:	57                   	push   %edi
  800b7f:	56                   	push   %esi
  800b80:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b81:	ba 00 00 00 00       	mov    $0x0,%edx
  800b86:	b8 02 00 00 00       	mov    $0x2,%eax
  800b8b:	89 d1                	mov    %edx,%ecx
  800b8d:	89 d3                	mov    %edx,%ebx
  800b8f:	89 d7                	mov    %edx,%edi
  800b91:	89 d6                	mov    %edx,%esi
  800b93:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b95:	5b                   	pop    %ebx
  800b96:	5e                   	pop    %esi
  800b97:	5f                   	pop    %edi
  800b98:	5d                   	pop    %ebp
  800b99:	c3                   	ret    

00800b9a <sys_yield>:

void
sys_yield(void)
{
  800b9a:	55                   	push   %ebp
  800b9b:	89 e5                	mov    %esp,%ebp
  800b9d:	57                   	push   %edi
  800b9e:	56                   	push   %esi
  800b9f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ba0:	ba 00 00 00 00       	mov    $0x0,%edx
  800ba5:	b8 0b 00 00 00       	mov    $0xb,%eax
  800baa:	89 d1                	mov    %edx,%ecx
  800bac:	89 d3                	mov    %edx,%ebx
  800bae:	89 d7                	mov    %edx,%edi
  800bb0:	89 d6                	mov    %edx,%esi
  800bb2:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800bb4:	5b                   	pop    %ebx
  800bb5:	5e                   	pop    %esi
  800bb6:	5f                   	pop    %edi
  800bb7:	5d                   	pop    %ebp
  800bb8:	c3                   	ret    

00800bb9 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800bb9:	55                   	push   %ebp
  800bba:	89 e5                	mov    %esp,%ebp
  800bbc:	57                   	push   %edi
  800bbd:	56                   	push   %esi
  800bbe:	53                   	push   %ebx
  800bbf:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bc2:	be 00 00 00 00       	mov    $0x0,%esi
  800bc7:	b8 04 00 00 00       	mov    $0x4,%eax
  800bcc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bcf:	8b 55 08             	mov    0x8(%ebp),%edx
  800bd2:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bd5:	89 f7                	mov    %esi,%edi
  800bd7:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bd9:	85 c0                	test   %eax,%eax
  800bdb:	7e 17                	jle    800bf4 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bdd:	83 ec 0c             	sub    $0xc,%esp
  800be0:	50                   	push   %eax
  800be1:	6a 04                	push   $0x4
  800be3:	68 bf 24 80 00       	push   $0x8024bf
  800be8:	6a 23                	push   $0x23
  800bea:	68 dc 24 80 00       	push   $0x8024dc
  800bef:	e8 64 f5 ff ff       	call   800158 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800bf4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bf7:	5b                   	pop    %ebx
  800bf8:	5e                   	pop    %esi
  800bf9:	5f                   	pop    %edi
  800bfa:	5d                   	pop    %ebp
  800bfb:	c3                   	ret    

00800bfc <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800bfc:	55                   	push   %ebp
  800bfd:	89 e5                	mov    %esp,%ebp
  800bff:	57                   	push   %edi
  800c00:	56                   	push   %esi
  800c01:	53                   	push   %ebx
  800c02:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c05:	b8 05 00 00 00       	mov    $0x5,%eax
  800c0a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c0d:	8b 55 08             	mov    0x8(%ebp),%edx
  800c10:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c13:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c16:	8b 75 18             	mov    0x18(%ebp),%esi
  800c19:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c1b:	85 c0                	test   %eax,%eax
  800c1d:	7e 17                	jle    800c36 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c1f:	83 ec 0c             	sub    $0xc,%esp
  800c22:	50                   	push   %eax
  800c23:	6a 05                	push   $0x5
  800c25:	68 bf 24 80 00       	push   $0x8024bf
  800c2a:	6a 23                	push   $0x23
  800c2c:	68 dc 24 80 00       	push   $0x8024dc
  800c31:	e8 22 f5 ff ff       	call   800158 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c36:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c39:	5b                   	pop    %ebx
  800c3a:	5e                   	pop    %esi
  800c3b:	5f                   	pop    %edi
  800c3c:	5d                   	pop    %ebp
  800c3d:	c3                   	ret    

00800c3e <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c3e:	55                   	push   %ebp
  800c3f:	89 e5                	mov    %esp,%ebp
  800c41:	57                   	push   %edi
  800c42:	56                   	push   %esi
  800c43:	53                   	push   %ebx
  800c44:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c47:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c4c:	b8 06 00 00 00       	mov    $0x6,%eax
  800c51:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c54:	8b 55 08             	mov    0x8(%ebp),%edx
  800c57:	89 df                	mov    %ebx,%edi
  800c59:	89 de                	mov    %ebx,%esi
  800c5b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c5d:	85 c0                	test   %eax,%eax
  800c5f:	7e 17                	jle    800c78 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c61:	83 ec 0c             	sub    $0xc,%esp
  800c64:	50                   	push   %eax
  800c65:	6a 06                	push   $0x6
  800c67:	68 bf 24 80 00       	push   $0x8024bf
  800c6c:	6a 23                	push   $0x23
  800c6e:	68 dc 24 80 00       	push   $0x8024dc
  800c73:	e8 e0 f4 ff ff       	call   800158 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c78:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c7b:	5b                   	pop    %ebx
  800c7c:	5e                   	pop    %esi
  800c7d:	5f                   	pop    %edi
  800c7e:	5d                   	pop    %ebp
  800c7f:	c3                   	ret    

00800c80 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c80:	55                   	push   %ebp
  800c81:	89 e5                	mov    %esp,%ebp
  800c83:	57                   	push   %edi
  800c84:	56                   	push   %esi
  800c85:	53                   	push   %ebx
  800c86:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c89:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c8e:	b8 08 00 00 00       	mov    $0x8,%eax
  800c93:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c96:	8b 55 08             	mov    0x8(%ebp),%edx
  800c99:	89 df                	mov    %ebx,%edi
  800c9b:	89 de                	mov    %ebx,%esi
  800c9d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c9f:	85 c0                	test   %eax,%eax
  800ca1:	7e 17                	jle    800cba <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ca3:	83 ec 0c             	sub    $0xc,%esp
  800ca6:	50                   	push   %eax
  800ca7:	6a 08                	push   $0x8
  800ca9:	68 bf 24 80 00       	push   $0x8024bf
  800cae:	6a 23                	push   $0x23
  800cb0:	68 dc 24 80 00       	push   $0x8024dc
  800cb5:	e8 9e f4 ff ff       	call   800158 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800cba:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cbd:	5b                   	pop    %ebx
  800cbe:	5e                   	pop    %esi
  800cbf:	5f                   	pop    %edi
  800cc0:	5d                   	pop    %ebp
  800cc1:	c3                   	ret    

00800cc2 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800cc2:	55                   	push   %ebp
  800cc3:	89 e5                	mov    %esp,%ebp
  800cc5:	57                   	push   %edi
  800cc6:	56                   	push   %esi
  800cc7:	53                   	push   %ebx
  800cc8:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ccb:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cd0:	b8 09 00 00 00       	mov    $0x9,%eax
  800cd5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cd8:	8b 55 08             	mov    0x8(%ebp),%edx
  800cdb:	89 df                	mov    %ebx,%edi
  800cdd:	89 de                	mov    %ebx,%esi
  800cdf:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ce1:	85 c0                	test   %eax,%eax
  800ce3:	7e 17                	jle    800cfc <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ce5:	83 ec 0c             	sub    $0xc,%esp
  800ce8:	50                   	push   %eax
  800ce9:	6a 09                	push   $0x9
  800ceb:	68 bf 24 80 00       	push   $0x8024bf
  800cf0:	6a 23                	push   $0x23
  800cf2:	68 dc 24 80 00       	push   $0x8024dc
  800cf7:	e8 5c f4 ff ff       	call   800158 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800cfc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cff:	5b                   	pop    %ebx
  800d00:	5e                   	pop    %esi
  800d01:	5f                   	pop    %edi
  800d02:	5d                   	pop    %ebp
  800d03:	c3                   	ret    

00800d04 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d04:	55                   	push   %ebp
  800d05:	89 e5                	mov    %esp,%ebp
  800d07:	57                   	push   %edi
  800d08:	56                   	push   %esi
  800d09:	53                   	push   %ebx
  800d0a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d0d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d12:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d17:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d1a:	8b 55 08             	mov    0x8(%ebp),%edx
  800d1d:	89 df                	mov    %ebx,%edi
  800d1f:	89 de                	mov    %ebx,%esi
  800d21:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d23:	85 c0                	test   %eax,%eax
  800d25:	7e 17                	jle    800d3e <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d27:	83 ec 0c             	sub    $0xc,%esp
  800d2a:	50                   	push   %eax
  800d2b:	6a 0a                	push   $0xa
  800d2d:	68 bf 24 80 00       	push   $0x8024bf
  800d32:	6a 23                	push   $0x23
  800d34:	68 dc 24 80 00       	push   $0x8024dc
  800d39:	e8 1a f4 ff ff       	call   800158 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d3e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d41:	5b                   	pop    %ebx
  800d42:	5e                   	pop    %esi
  800d43:	5f                   	pop    %edi
  800d44:	5d                   	pop    %ebp
  800d45:	c3                   	ret    

00800d46 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d46:	55                   	push   %ebp
  800d47:	89 e5                	mov    %esp,%ebp
  800d49:	57                   	push   %edi
  800d4a:	56                   	push   %esi
  800d4b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d4c:	be 00 00 00 00       	mov    $0x0,%esi
  800d51:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d56:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d59:	8b 55 08             	mov    0x8(%ebp),%edx
  800d5c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d5f:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d62:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d64:	5b                   	pop    %ebx
  800d65:	5e                   	pop    %esi
  800d66:	5f                   	pop    %edi
  800d67:	5d                   	pop    %ebp
  800d68:	c3                   	ret    

00800d69 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d69:	55                   	push   %ebp
  800d6a:	89 e5                	mov    %esp,%ebp
  800d6c:	57                   	push   %edi
  800d6d:	56                   	push   %esi
  800d6e:	53                   	push   %ebx
  800d6f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d72:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d77:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d7c:	8b 55 08             	mov    0x8(%ebp),%edx
  800d7f:	89 cb                	mov    %ecx,%ebx
  800d81:	89 cf                	mov    %ecx,%edi
  800d83:	89 ce                	mov    %ecx,%esi
  800d85:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d87:	85 c0                	test   %eax,%eax
  800d89:	7e 17                	jle    800da2 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d8b:	83 ec 0c             	sub    $0xc,%esp
  800d8e:	50                   	push   %eax
  800d8f:	6a 0d                	push   $0xd
  800d91:	68 bf 24 80 00       	push   $0x8024bf
  800d96:	6a 23                	push   $0x23
  800d98:	68 dc 24 80 00       	push   $0x8024dc
  800d9d:	e8 b6 f3 ff ff       	call   800158 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800da2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800da5:	5b                   	pop    %ebx
  800da6:	5e                   	pop    %esi
  800da7:	5f                   	pop    %edi
  800da8:	5d                   	pop    %ebp
  800da9:	c3                   	ret    

00800daa <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800daa:	55                   	push   %ebp
  800dab:	89 e5                	mov    %esp,%ebp
  800dad:	56                   	push   %esi
  800dae:	53                   	push   %ebx
  800daf:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800db2:	8b 18                	mov    (%eax),%ebx
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.

	if ((err & FEC_WR) != FEC_WR && ((uvpt[PGNUM(addr)] & PTE_COW) != PTE_COW)) {
  800db4:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800db8:	75 25                	jne    800ddf <pgfault+0x35>
  800dba:	89 d8                	mov    %ebx,%eax
  800dbc:	c1 e8 0c             	shr    $0xc,%eax
  800dbf:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800dc6:	f6 c4 08             	test   $0x8,%ah
  800dc9:	75 14                	jne    800ddf <pgfault+0x35>
		panic("pgfault: not due to a write or a COW page");
  800dcb:	83 ec 04             	sub    $0x4,%esp
  800dce:	68 ec 24 80 00       	push   $0x8024ec
  800dd3:	6a 1e                	push   $0x1e
  800dd5:	68 80 25 80 00       	push   $0x802580
  800dda:	e8 79 f3 ff ff       	call   800158 <_panic>

	// LAB 4: Your code here.

	// panic("pgfault not implemented");

	addr = ROUNDDOWN(addr, PGSIZE);
  800ddf:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	envid_t envid = sys_getenvid();
  800de5:	e8 91 fd ff ff       	call   800b7b <sys_getenvid>
  800dea:	89 c6                	mov    %eax,%esi

	// envid = 0;

	// Allocate a new page, map it at a temporary location (PFTEMP)
	r = sys_page_alloc(envid, (void *)PFTEMP, PTE_U | PTE_P | PTE_W);
  800dec:	83 ec 04             	sub    $0x4,%esp
  800def:	6a 07                	push   $0x7
  800df1:	68 00 f0 7f 00       	push   $0x7ff000
  800df6:	50                   	push   %eax
  800df7:	e8 bd fd ff ff       	call   800bb9 <sys_page_alloc>
	if (r < 0)
  800dfc:	83 c4 10             	add    $0x10,%esp
  800dff:	85 c0                	test   %eax,%eax
  800e01:	79 12                	jns    800e15 <pgfault+0x6b>
		panic("pgfault: sys_page_alloc failed: %e\n", r);
  800e03:	50                   	push   %eax
  800e04:	68 18 25 80 00       	push   $0x802518
  800e09:	6a 33                	push   $0x33
  800e0b:	68 80 25 80 00       	push   $0x802580
  800e10:	e8 43 f3 ff ff       	call   800158 <_panic>
	
	// copy the data from the old page to the new page
	memcpy((void *) PFTEMP, (const void *) addr, PGSIZE);
  800e15:	83 ec 04             	sub    $0x4,%esp
  800e18:	68 00 10 00 00       	push   $0x1000
  800e1d:	53                   	push   %ebx
  800e1e:	68 00 f0 7f 00       	push   $0x7ff000
  800e23:	e8 88 fb ff ff       	call   8009b0 <memcpy>

	// move the new page to the old page's address
	r = sys_page_map(envid, (void *) PFTEMP, envid, addr, PTE_U | PTE_P | PTE_W);
  800e28:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800e2f:	53                   	push   %ebx
  800e30:	56                   	push   %esi
  800e31:	68 00 f0 7f 00       	push   $0x7ff000
  800e36:	56                   	push   %esi
  800e37:	e8 c0 fd ff ff       	call   800bfc <sys_page_map>
	if (r < 0)
  800e3c:	83 c4 20             	add    $0x20,%esp
  800e3f:	85 c0                	test   %eax,%eax
  800e41:	79 12                	jns    800e55 <pgfault+0xab>
		panic("pgfault: sys_page_map failed: %e\n", r);
  800e43:	50                   	push   %eax
  800e44:	68 3c 25 80 00       	push   $0x80253c
  800e49:	6a 3b                	push   $0x3b
  800e4b:	68 80 25 80 00       	push   $0x802580
  800e50:	e8 03 f3 ff ff       	call   800158 <_panic>

	// unmap temporary region
	r = sys_page_unmap(envid, (void *) PFTEMP);
  800e55:	83 ec 08             	sub    $0x8,%esp
  800e58:	68 00 f0 7f 00       	push   $0x7ff000
  800e5d:	56                   	push   %esi
  800e5e:	e8 db fd ff ff       	call   800c3e <sys_page_unmap>
	if (r < 0)
  800e63:	83 c4 10             	add    $0x10,%esp
  800e66:	85 c0                	test   %eax,%eax
  800e68:	79 12                	jns    800e7c <pgfault+0xd2>
        panic("pgfault: page unmap failed: %e\n", r);
  800e6a:	50                   	push   %eax
  800e6b:	68 60 25 80 00       	push   $0x802560
  800e70:	6a 40                	push   $0x40
  800e72:	68 80 25 80 00       	push   $0x802580
  800e77:	e8 dc f2 ff ff       	call   800158 <_panic>
}
  800e7c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e7f:	5b                   	pop    %ebx
  800e80:	5e                   	pop    %esi
  800e81:	5d                   	pop    %ebp
  800e82:	c3                   	ret    

00800e83 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800e83:	55                   	push   %ebp
  800e84:	89 e5                	mov    %esp,%ebp
  800e86:	57                   	push   %edi
  800e87:	56                   	push   %esi
  800e88:	53                   	push   %ebx
  800e89:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	// cprintf("[fork]\n");
	int r;

	set_pgfault_handler(pgfault);
  800e8c:	68 aa 0d 80 00       	push   $0x800daa
  800e91:	e8 75 0f 00 00       	call   801e0b <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800e96:	b8 07 00 00 00       	mov    $0x7,%eax
  800e9b:	cd 30                	int    $0x30

	envid_t envid = sys_exofork();
	if (envid < 0)
  800e9d:	83 c4 10             	add    $0x10,%esp
  800ea0:	85 c0                	test   %eax,%eax
  800ea2:	0f 88 64 01 00 00    	js     80100c <fork+0x189>
  800ea8:	bb 00 00 80 00       	mov    $0x800000,%ebx
  800ead:	be 00 08 00 00       	mov    $0x800,%esi
		return envid;

	// fix "thisenv" in the child process
	if (envid == 0) {
  800eb2:	85 c0                	test   %eax,%eax
  800eb4:	75 21                	jne    800ed7 <fork+0x54>
		thisenv = &envs[ENVX(sys_getenvid())];
  800eb6:	e8 c0 fc ff ff       	call   800b7b <sys_getenvid>
  800ebb:	25 ff 03 00 00       	and    $0x3ff,%eax
  800ec0:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800ec3:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800ec8:	a3 04 40 80 00       	mov    %eax,0x804004
        return 0;
  800ecd:	ba 00 00 00 00       	mov    $0x0,%edx
  800ed2:	e9 3f 01 00 00       	jmp    801016 <fork+0x193>
  800ed7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800eda:	89 c7                	mov    %eax,%edi
	for (uint32_t pn = PGNUM(UTEXT); pn < PGNUM(USTACKTOP); pn++) {

		addr = pn * PGSIZE;

		// if level-2 page exists
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P) {
  800edc:	89 d8                	mov    %ebx,%eax
  800ede:	c1 e8 16             	shr    $0x16,%eax
  800ee1:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800ee8:	a8 01                	test   $0x1,%al
  800eea:	0f 84 bd 00 00 00    	je     800fad <fork+0x12a>
			
			// if real PTE exists
			if ((uvpt[PGNUM(addr)] & PTE_P) == PTE_P) {
  800ef0:	89 d8                	mov    %ebx,%eax
  800ef2:	c1 e8 0c             	shr    $0xc,%eax
  800ef5:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800efc:	f6 c2 01             	test   $0x1,%dl
  800eff:	0f 84 a8 00 00 00    	je     800fad <fork+0x12a>

				// For each writable or copy-on-write page
				// if ((uvpt[PGNUM(addr)] & (PTE_W | PTE_COW)) != 0) {
				if ((uvpt[PGNUM(addr)] & PTE_U) != 0) {
  800f05:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f0c:	a8 04                	test   $0x4,%al
  800f0e:	0f 84 99 00 00 00    	je     800fad <fork+0x12a>
	// r = envid2env(envid, &env, 1);
	// if (r < 0)
	// 	return r;	// E_BAD_ENV
	// envid_t parent_envid = env->env_parent_id;

	if (uvpt[pn] & PTE_SHARE) {
  800f14:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800f1b:	f6 c4 04             	test   $0x4,%ah
  800f1e:	74 17                	je     800f37 <fork+0xb4>
		sys_page_map(0, (void *)va, envid, (void *)va, PTE_SYSCALL);
  800f20:	83 ec 0c             	sub    $0xc,%esp
  800f23:	68 07 0e 00 00       	push   $0xe07
  800f28:	53                   	push   %ebx
  800f29:	57                   	push   %edi
  800f2a:	53                   	push   %ebx
  800f2b:	6a 00                	push   $0x0
  800f2d:	e8 ca fc ff ff       	call   800bfc <sys_page_map>
  800f32:	83 c4 20             	add    $0x20,%esp
  800f35:	eb 76                	jmp    800fad <fork+0x12a>
	}
	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {
  800f37:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800f3e:	a8 02                	test   $0x2,%al
  800f40:	75 0c                	jne    800f4e <fork+0xcb>
  800f42:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800f49:	f6 c4 08             	test   $0x8,%ah
  800f4c:	74 3f                	je     800f8d <fork+0x10a>

		// map the page copy-on-write into the address space of the child
        r = sys_page_map(0, (void *)va, envid, (void *)va, PTE_P|PTE_U|PTE_COW);
  800f4e:	83 ec 0c             	sub    $0xc,%esp
  800f51:	68 05 08 00 00       	push   $0x805
  800f56:	53                   	push   %ebx
  800f57:	57                   	push   %edi
  800f58:	53                   	push   %ebx
  800f59:	6a 00                	push   $0x0
  800f5b:	e8 9c fc ff ff       	call   800bfc <sys_page_map>
		if (r < 0)
  800f60:	83 c4 20             	add    $0x20,%esp
  800f63:	85 c0                	test   %eax,%eax
  800f65:	0f 88 a5 00 00 00    	js     801010 <fork+0x18d>
            return r;

		// remap the page copy-on-write in its own(parent) address space
        r = sys_page_map(0, (void *)va, 0, (void *)va, PTE_P|PTE_U|PTE_COW);
  800f6b:	83 ec 0c             	sub    $0xc,%esp
  800f6e:	68 05 08 00 00       	push   $0x805
  800f73:	53                   	push   %ebx
  800f74:	6a 00                	push   $0x0
  800f76:	53                   	push   %ebx
  800f77:	6a 00                	push   $0x0
  800f79:	e8 7e fc ff ff       	call   800bfc <sys_page_map>
  800f7e:	83 c4 20             	add    $0x20,%esp
  800f81:	85 c0                	test   %eax,%eax
  800f83:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f88:	0f 4f c1             	cmovg  %ecx,%eax
  800f8b:	eb 1c                	jmp    800fa9 <fork+0x126>
		if (r < 0)
            return r;
    }
    else {
        r = sys_page_map(0, (void *)va, envid, (void *)va, PTE_P|PTE_U);
  800f8d:	83 ec 0c             	sub    $0xc,%esp
  800f90:	6a 05                	push   $0x5
  800f92:	53                   	push   %ebx
  800f93:	57                   	push   %edi
  800f94:	53                   	push   %ebx
  800f95:	6a 00                	push   $0x0
  800f97:	e8 60 fc ff ff       	call   800bfc <sys_page_map>
  800f9c:	83 c4 20             	add    $0x20,%esp
  800f9f:	85 c0                	test   %eax,%eax
  800fa1:	b9 00 00 00 00       	mov    $0x0,%ecx
  800fa6:	0f 4f c1             	cmovg  %ecx,%eax

				// For each writable or copy-on-write page
				// if ((uvpt[PGNUM(addr)] & (PTE_W | PTE_COW)) != 0) {
				if ((uvpt[PGNUM(addr)] & PTE_U) != 0) {
					r = duppage(envid, pn);
					if (r < 0)
  800fa9:	85 c0                	test   %eax,%eax
  800fab:	78 67                	js     801014 <fork+0x191>
        return 0;
	}

	// For each writable or copy-on-write page in its address space below UTOP, the parent calls duppage
	uint32_t addr;
	for (uint32_t pn = PGNUM(UTEXT); pn < PGNUM(USTACKTOP); pn++) {
  800fad:	83 c6 01             	add    $0x1,%esi
  800fb0:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  800fb6:	81 fe fe eb 0e 00    	cmp    $0xeebfe,%esi
  800fbc:	0f 85 1a ff ff ff    	jne    800edc <fork+0x59>
  800fc2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
		}
	}

	// allocate a fresh page in the child for the exception stack
	r = sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U | PTE_P | PTE_W);
  800fc5:	83 ec 04             	sub    $0x4,%esp
  800fc8:	6a 07                	push   $0x7
  800fca:	68 00 f0 bf ee       	push   $0xeebff000
  800fcf:	57                   	push   %edi
  800fd0:	e8 e4 fb ff ff       	call   800bb9 <sys_page_alloc>
	if (r < 0)
  800fd5:	83 c4 10             	add    $0x10,%esp
		return r;
  800fd8:	89 c2                	mov    %eax,%edx
		}
	}

	// allocate a fresh page in the child for the exception stack
	r = sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U | PTE_P | PTE_W);
	if (r < 0)
  800fda:	85 c0                	test   %eax,%eax
  800fdc:	78 38                	js     801016 <fork+0x193>
		return r;

	// The parent sets the user page fault entrypoint for the child to look like its own
	extern void _pgfault_upcall(void);
	r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  800fde:	83 ec 08             	sub    $0x8,%esp
  800fe1:	68 52 1e 80 00       	push   $0x801e52
  800fe6:	57                   	push   %edi
  800fe7:	e8 18 fd ff ff       	call   800d04 <sys_env_set_pgfault_upcall>
	if (r < 0)
  800fec:	83 c4 10             	add    $0x10,%esp
		return r;
  800fef:	89 c2                	mov    %eax,%edx
		return r;

	// The parent sets the user page fault entrypoint for the child to look like its own
	extern void _pgfault_upcall(void);
	r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
	if (r < 0)
  800ff1:	85 c0                	test   %eax,%eax
  800ff3:	78 21                	js     801016 <fork+0x193>
		return r;

	// The child is now ready to run, so the parent marks it runnable
	r = sys_env_set_status(envid, ENV_RUNNABLE);
  800ff5:	83 ec 08             	sub    $0x8,%esp
  800ff8:	6a 02                	push   $0x2
  800ffa:	57                   	push   %edi
  800ffb:	e8 80 fc ff ff       	call   800c80 <sys_env_set_status>
	if (r < 0)
  801000:	83 c4 10             	add    $0x10,%esp
		return r;

	return envid;
  801003:	85 c0                	test   %eax,%eax
  801005:	0f 48 f8             	cmovs  %eax,%edi
  801008:	89 fa                	mov    %edi,%edx
  80100a:	eb 0a                	jmp    801016 <fork+0x193>

	set_pgfault_handler(pgfault);

	envid_t envid = sys_exofork();
	if (envid < 0)
		return envid;
  80100c:	89 c2                	mov    %eax,%edx
  80100e:	eb 06                	jmp    801016 <fork+0x193>
		sys_page_map(0, (void *)va, envid, (void *)va, PTE_SYSCALL);
	}
	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {

		// map the page copy-on-write into the address space of the child
        r = sys_page_map(0, (void *)va, envid, (void *)va, PTE_P|PTE_U|PTE_COW);
  801010:	89 c2                	mov    %eax,%edx
  801012:	eb 02                	jmp    801016 <fork+0x193>
  801014:	89 c2                	mov    %eax,%edx
	if (r < 0)
		return r;

	return envid;
	// panic("fork not implemented");
}
  801016:	89 d0                	mov    %edx,%eax
  801018:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80101b:	5b                   	pop    %ebx
  80101c:	5e                   	pop    %esi
  80101d:	5f                   	pop    %edi
  80101e:	5d                   	pop    %ebp
  80101f:	c3                   	ret    

00801020 <sfork>:

// Challenge!
int
sfork(void)
{
  801020:	55                   	push   %ebp
  801021:	89 e5                	mov    %esp,%ebp
  801023:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801026:	68 8b 25 80 00       	push   $0x80258b
  80102b:	68 c9 00 00 00       	push   $0xc9
  801030:	68 80 25 80 00       	push   $0x802580
  801035:	e8 1e f1 ff ff       	call   800158 <_panic>

0080103a <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80103a:	55                   	push   %ebp
  80103b:	89 e5                	mov    %esp,%ebp
  80103d:	56                   	push   %esi
  80103e:	53                   	push   %ebx
  80103f:	8b 75 08             	mov    0x8(%ebp),%esi
  801042:	8b 45 0c             	mov    0xc(%ebp),%eax
  801045:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");

	// don't want to recv page
	if (pg == NULL)
  801048:	85 c0                	test   %eax,%eax
		pg = (void *)UTOP;
  80104a:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  80104f:	0f 44 c2             	cmove  %edx,%eax

	int err = sys_ipc_recv(pg);
  801052:	83 ec 0c             	sub    $0xc,%esp
  801055:	50                   	push   %eax
  801056:	e8 0e fd ff ff       	call   800d69 <sys_ipc_recv>

	if (from_env_store != NULL)
  80105b:	83 c4 10             	add    $0x10,%esp
  80105e:	85 f6                	test   %esi,%esi
  801060:	74 14                	je     801076 <ipc_recv+0x3c>
		*from_env_store = err < 0? 0 : thisenv->env_ipc_from;
  801062:	ba 00 00 00 00       	mov    $0x0,%edx
  801067:	85 c0                	test   %eax,%eax
  801069:	78 09                	js     801074 <ipc_recv+0x3a>
  80106b:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801071:	8b 52 74             	mov    0x74(%edx),%edx
  801074:	89 16                	mov    %edx,(%esi)
	
	if (perm_store != NULL)
  801076:	85 db                	test   %ebx,%ebx
  801078:	74 14                	je     80108e <ipc_recv+0x54>
		*perm_store = err < 0? 0 : thisenv->env_ipc_perm;
  80107a:	ba 00 00 00 00       	mov    $0x0,%edx
  80107f:	85 c0                	test   %eax,%eax
  801081:	78 09                	js     80108c <ipc_recv+0x52>
  801083:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801089:	8b 52 78             	mov    0x78(%edx),%edx
  80108c:	89 13                	mov    %edx,(%ebx)

	if (err < 0)
  80108e:	85 c0                	test   %eax,%eax
  801090:	78 08                	js     80109a <ipc_recv+0x60>
		return err;
	return thisenv->env_ipc_value;
  801092:	a1 04 40 80 00       	mov    0x804004,%eax
  801097:	8b 40 70             	mov    0x70(%eax),%eax
}
  80109a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80109d:	5b                   	pop    %ebx
  80109e:	5e                   	pop    %esi
  80109f:	5d                   	pop    %ebp
  8010a0:	c3                   	ret    

008010a1 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8010a1:	55                   	push   %ebp
  8010a2:	89 e5                	mov    %esp,%ebp
  8010a4:	57                   	push   %edi
  8010a5:	56                   	push   %esi
  8010a6:	53                   	push   %ebx
  8010a7:	83 ec 0c             	sub    $0xc,%esp
  8010aa:	8b 7d 08             	mov    0x8(%ebp),%edi
  8010ad:	8b 75 0c             	mov    0xc(%ebp),%esi
  8010b0:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");

	// don't want to send page
	if (pg == NULL)
  8010b3:	85 db                	test   %ebx,%ebx
		pg = (void *)UTOP;
  8010b5:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  8010ba:	0f 44 d8             	cmove  %eax,%ebx
	
	int err = 0;
	
	do {

		err = sys_ipc_try_send(to_env, val, pg, perm);
  8010bd:	ff 75 14             	pushl  0x14(%ebp)
  8010c0:	53                   	push   %ebx
  8010c1:	56                   	push   %esi
  8010c2:	57                   	push   %edi
  8010c3:	e8 7e fc ff ff       	call   800d46 <sys_ipc_try_send>

		if (err < 0) {
  8010c8:	83 c4 10             	add    $0x10,%esp
  8010cb:	85 c0                	test   %eax,%eax
  8010cd:	79 1e                	jns    8010ed <ipc_send+0x4c>
			if (err == -E_IPC_NOT_RECV)
  8010cf:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8010d2:	75 07                	jne    8010db <ipc_send+0x3a>
				sys_yield();
  8010d4:	e8 c1 fa ff ff       	call   800b9a <sys_yield>
  8010d9:	eb e2                	jmp    8010bd <ipc_send+0x1c>
			else 
				panic("ipc_send: %e", err);
  8010db:	50                   	push   %eax
  8010dc:	68 a1 25 80 00       	push   $0x8025a1
  8010e1:	6a 49                	push   $0x49
  8010e3:	68 ae 25 80 00       	push   $0x8025ae
  8010e8:	e8 6b f0 ff ff       	call   800158 <_panic>
		}

	} while (err < 0);

}
  8010ed:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010f0:	5b                   	pop    %ebx
  8010f1:	5e                   	pop    %esi
  8010f2:	5f                   	pop    %edi
  8010f3:	5d                   	pop    %ebp
  8010f4:	c3                   	ret    

008010f5 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8010f5:	55                   	push   %ebp
  8010f6:	89 e5                	mov    %esp,%ebp
  8010f8:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8010fb:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801100:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801103:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801109:	8b 52 50             	mov    0x50(%edx),%edx
  80110c:	39 ca                	cmp    %ecx,%edx
  80110e:	75 0d                	jne    80111d <ipc_find_env+0x28>
			return envs[i].env_id;
  801110:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801113:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801118:	8b 40 48             	mov    0x48(%eax),%eax
  80111b:	eb 0f                	jmp    80112c <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80111d:	83 c0 01             	add    $0x1,%eax
  801120:	3d 00 04 00 00       	cmp    $0x400,%eax
  801125:	75 d9                	jne    801100 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801127:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80112c:	5d                   	pop    %ebp
  80112d:	c3                   	ret    

0080112e <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80112e:	55                   	push   %ebp
  80112f:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801131:	8b 45 08             	mov    0x8(%ebp),%eax
  801134:	05 00 00 00 30       	add    $0x30000000,%eax
  801139:	c1 e8 0c             	shr    $0xc,%eax
}
  80113c:	5d                   	pop    %ebp
  80113d:	c3                   	ret    

0080113e <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80113e:	55                   	push   %ebp
  80113f:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801141:	8b 45 08             	mov    0x8(%ebp),%eax
  801144:	05 00 00 00 30       	add    $0x30000000,%eax
  801149:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80114e:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801153:	5d                   	pop    %ebp
  801154:	c3                   	ret    

00801155 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801155:	55                   	push   %ebp
  801156:	89 e5                	mov    %esp,%ebp
  801158:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80115b:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801160:	89 c2                	mov    %eax,%edx
  801162:	c1 ea 16             	shr    $0x16,%edx
  801165:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80116c:	f6 c2 01             	test   $0x1,%dl
  80116f:	74 11                	je     801182 <fd_alloc+0x2d>
  801171:	89 c2                	mov    %eax,%edx
  801173:	c1 ea 0c             	shr    $0xc,%edx
  801176:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80117d:	f6 c2 01             	test   $0x1,%dl
  801180:	75 09                	jne    80118b <fd_alloc+0x36>
			*fd_store = fd;
  801182:	89 01                	mov    %eax,(%ecx)
			return 0;
  801184:	b8 00 00 00 00       	mov    $0x0,%eax
  801189:	eb 17                	jmp    8011a2 <fd_alloc+0x4d>
  80118b:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801190:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801195:	75 c9                	jne    801160 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801197:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  80119d:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8011a2:	5d                   	pop    %ebp
  8011a3:	c3                   	ret    

008011a4 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8011a4:	55                   	push   %ebp
  8011a5:	89 e5                	mov    %esp,%ebp
  8011a7:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8011aa:	83 f8 1f             	cmp    $0x1f,%eax
  8011ad:	77 36                	ja     8011e5 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8011af:	c1 e0 0c             	shl    $0xc,%eax
  8011b2:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8011b7:	89 c2                	mov    %eax,%edx
  8011b9:	c1 ea 16             	shr    $0x16,%edx
  8011bc:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8011c3:	f6 c2 01             	test   $0x1,%dl
  8011c6:	74 24                	je     8011ec <fd_lookup+0x48>
  8011c8:	89 c2                	mov    %eax,%edx
  8011ca:	c1 ea 0c             	shr    $0xc,%edx
  8011cd:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8011d4:	f6 c2 01             	test   $0x1,%dl
  8011d7:	74 1a                	je     8011f3 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8011d9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011dc:	89 02                	mov    %eax,(%edx)
	return 0;
  8011de:	b8 00 00 00 00       	mov    $0x0,%eax
  8011e3:	eb 13                	jmp    8011f8 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8011e5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011ea:	eb 0c                	jmp    8011f8 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8011ec:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011f1:	eb 05                	jmp    8011f8 <fd_lookup+0x54>
  8011f3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8011f8:	5d                   	pop    %ebp
  8011f9:	c3                   	ret    

008011fa <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8011fa:	55                   	push   %ebp
  8011fb:	89 e5                	mov    %esp,%ebp
  8011fd:	83 ec 08             	sub    $0x8,%esp
  801200:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801203:	ba 38 26 80 00       	mov    $0x802638,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801208:	eb 13                	jmp    80121d <dev_lookup+0x23>
  80120a:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80120d:	39 08                	cmp    %ecx,(%eax)
  80120f:	75 0c                	jne    80121d <dev_lookup+0x23>
			*dev = devtab[i];
  801211:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801214:	89 01                	mov    %eax,(%ecx)
			return 0;
  801216:	b8 00 00 00 00       	mov    $0x0,%eax
  80121b:	eb 2e                	jmp    80124b <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80121d:	8b 02                	mov    (%edx),%eax
  80121f:	85 c0                	test   %eax,%eax
  801221:	75 e7                	jne    80120a <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801223:	a1 04 40 80 00       	mov    0x804004,%eax
  801228:	8b 40 48             	mov    0x48(%eax),%eax
  80122b:	83 ec 04             	sub    $0x4,%esp
  80122e:	51                   	push   %ecx
  80122f:	50                   	push   %eax
  801230:	68 b8 25 80 00       	push   $0x8025b8
  801235:	e8 f7 ef ff ff       	call   800231 <cprintf>
	*dev = 0;
  80123a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80123d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801243:	83 c4 10             	add    $0x10,%esp
  801246:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80124b:	c9                   	leave  
  80124c:	c3                   	ret    

0080124d <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80124d:	55                   	push   %ebp
  80124e:	89 e5                	mov    %esp,%ebp
  801250:	56                   	push   %esi
  801251:	53                   	push   %ebx
  801252:	83 ec 10             	sub    $0x10,%esp
  801255:	8b 75 08             	mov    0x8(%ebp),%esi
  801258:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80125b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80125e:	50                   	push   %eax
  80125f:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801265:	c1 e8 0c             	shr    $0xc,%eax
  801268:	50                   	push   %eax
  801269:	e8 36 ff ff ff       	call   8011a4 <fd_lookup>
  80126e:	83 c4 08             	add    $0x8,%esp
  801271:	85 c0                	test   %eax,%eax
  801273:	78 05                	js     80127a <fd_close+0x2d>
	    || fd != fd2)
  801275:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801278:	74 0c                	je     801286 <fd_close+0x39>
		return (must_exist ? r : 0);
  80127a:	84 db                	test   %bl,%bl
  80127c:	ba 00 00 00 00       	mov    $0x0,%edx
  801281:	0f 44 c2             	cmove  %edx,%eax
  801284:	eb 41                	jmp    8012c7 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801286:	83 ec 08             	sub    $0x8,%esp
  801289:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80128c:	50                   	push   %eax
  80128d:	ff 36                	pushl  (%esi)
  80128f:	e8 66 ff ff ff       	call   8011fa <dev_lookup>
  801294:	89 c3                	mov    %eax,%ebx
  801296:	83 c4 10             	add    $0x10,%esp
  801299:	85 c0                	test   %eax,%eax
  80129b:	78 1a                	js     8012b7 <fd_close+0x6a>
		if (dev->dev_close)
  80129d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012a0:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8012a3:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8012a8:	85 c0                	test   %eax,%eax
  8012aa:	74 0b                	je     8012b7 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8012ac:	83 ec 0c             	sub    $0xc,%esp
  8012af:	56                   	push   %esi
  8012b0:	ff d0                	call   *%eax
  8012b2:	89 c3                	mov    %eax,%ebx
  8012b4:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8012b7:	83 ec 08             	sub    $0x8,%esp
  8012ba:	56                   	push   %esi
  8012bb:	6a 00                	push   $0x0
  8012bd:	e8 7c f9 ff ff       	call   800c3e <sys_page_unmap>
	return r;
  8012c2:	83 c4 10             	add    $0x10,%esp
  8012c5:	89 d8                	mov    %ebx,%eax
}
  8012c7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012ca:	5b                   	pop    %ebx
  8012cb:	5e                   	pop    %esi
  8012cc:	5d                   	pop    %ebp
  8012cd:	c3                   	ret    

008012ce <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8012ce:	55                   	push   %ebp
  8012cf:	89 e5                	mov    %esp,%ebp
  8012d1:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8012d4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012d7:	50                   	push   %eax
  8012d8:	ff 75 08             	pushl  0x8(%ebp)
  8012db:	e8 c4 fe ff ff       	call   8011a4 <fd_lookup>
  8012e0:	83 c4 08             	add    $0x8,%esp
  8012e3:	85 c0                	test   %eax,%eax
  8012e5:	78 10                	js     8012f7 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8012e7:	83 ec 08             	sub    $0x8,%esp
  8012ea:	6a 01                	push   $0x1
  8012ec:	ff 75 f4             	pushl  -0xc(%ebp)
  8012ef:	e8 59 ff ff ff       	call   80124d <fd_close>
  8012f4:	83 c4 10             	add    $0x10,%esp
}
  8012f7:	c9                   	leave  
  8012f8:	c3                   	ret    

008012f9 <close_all>:

void
close_all(void)
{
  8012f9:	55                   	push   %ebp
  8012fa:	89 e5                	mov    %esp,%ebp
  8012fc:	53                   	push   %ebx
  8012fd:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801300:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801305:	83 ec 0c             	sub    $0xc,%esp
  801308:	53                   	push   %ebx
  801309:	e8 c0 ff ff ff       	call   8012ce <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80130e:	83 c3 01             	add    $0x1,%ebx
  801311:	83 c4 10             	add    $0x10,%esp
  801314:	83 fb 20             	cmp    $0x20,%ebx
  801317:	75 ec                	jne    801305 <close_all+0xc>
		close(i);
}
  801319:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80131c:	c9                   	leave  
  80131d:	c3                   	ret    

0080131e <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80131e:	55                   	push   %ebp
  80131f:	89 e5                	mov    %esp,%ebp
  801321:	57                   	push   %edi
  801322:	56                   	push   %esi
  801323:	53                   	push   %ebx
  801324:	83 ec 2c             	sub    $0x2c,%esp
  801327:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80132a:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80132d:	50                   	push   %eax
  80132e:	ff 75 08             	pushl  0x8(%ebp)
  801331:	e8 6e fe ff ff       	call   8011a4 <fd_lookup>
  801336:	83 c4 08             	add    $0x8,%esp
  801339:	85 c0                	test   %eax,%eax
  80133b:	0f 88 c1 00 00 00    	js     801402 <dup+0xe4>
		return r;
	close(newfdnum);
  801341:	83 ec 0c             	sub    $0xc,%esp
  801344:	56                   	push   %esi
  801345:	e8 84 ff ff ff       	call   8012ce <close>

	newfd = INDEX2FD(newfdnum);
  80134a:	89 f3                	mov    %esi,%ebx
  80134c:	c1 e3 0c             	shl    $0xc,%ebx
  80134f:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801355:	83 c4 04             	add    $0x4,%esp
  801358:	ff 75 e4             	pushl  -0x1c(%ebp)
  80135b:	e8 de fd ff ff       	call   80113e <fd2data>
  801360:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801362:	89 1c 24             	mov    %ebx,(%esp)
  801365:	e8 d4 fd ff ff       	call   80113e <fd2data>
  80136a:	83 c4 10             	add    $0x10,%esp
  80136d:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801370:	89 f8                	mov    %edi,%eax
  801372:	c1 e8 16             	shr    $0x16,%eax
  801375:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80137c:	a8 01                	test   $0x1,%al
  80137e:	74 37                	je     8013b7 <dup+0x99>
  801380:	89 f8                	mov    %edi,%eax
  801382:	c1 e8 0c             	shr    $0xc,%eax
  801385:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80138c:	f6 c2 01             	test   $0x1,%dl
  80138f:	74 26                	je     8013b7 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801391:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801398:	83 ec 0c             	sub    $0xc,%esp
  80139b:	25 07 0e 00 00       	and    $0xe07,%eax
  8013a0:	50                   	push   %eax
  8013a1:	ff 75 d4             	pushl  -0x2c(%ebp)
  8013a4:	6a 00                	push   $0x0
  8013a6:	57                   	push   %edi
  8013a7:	6a 00                	push   $0x0
  8013a9:	e8 4e f8 ff ff       	call   800bfc <sys_page_map>
  8013ae:	89 c7                	mov    %eax,%edi
  8013b0:	83 c4 20             	add    $0x20,%esp
  8013b3:	85 c0                	test   %eax,%eax
  8013b5:	78 2e                	js     8013e5 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8013b7:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8013ba:	89 d0                	mov    %edx,%eax
  8013bc:	c1 e8 0c             	shr    $0xc,%eax
  8013bf:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8013c6:	83 ec 0c             	sub    $0xc,%esp
  8013c9:	25 07 0e 00 00       	and    $0xe07,%eax
  8013ce:	50                   	push   %eax
  8013cf:	53                   	push   %ebx
  8013d0:	6a 00                	push   $0x0
  8013d2:	52                   	push   %edx
  8013d3:	6a 00                	push   $0x0
  8013d5:	e8 22 f8 ff ff       	call   800bfc <sys_page_map>
  8013da:	89 c7                	mov    %eax,%edi
  8013dc:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8013df:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8013e1:	85 ff                	test   %edi,%edi
  8013e3:	79 1d                	jns    801402 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8013e5:	83 ec 08             	sub    $0x8,%esp
  8013e8:	53                   	push   %ebx
  8013e9:	6a 00                	push   $0x0
  8013eb:	e8 4e f8 ff ff       	call   800c3e <sys_page_unmap>
	sys_page_unmap(0, nva);
  8013f0:	83 c4 08             	add    $0x8,%esp
  8013f3:	ff 75 d4             	pushl  -0x2c(%ebp)
  8013f6:	6a 00                	push   $0x0
  8013f8:	e8 41 f8 ff ff       	call   800c3e <sys_page_unmap>
	return r;
  8013fd:	83 c4 10             	add    $0x10,%esp
  801400:	89 f8                	mov    %edi,%eax
}
  801402:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801405:	5b                   	pop    %ebx
  801406:	5e                   	pop    %esi
  801407:	5f                   	pop    %edi
  801408:	5d                   	pop    %ebp
  801409:	c3                   	ret    

0080140a <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80140a:	55                   	push   %ebp
  80140b:	89 e5                	mov    %esp,%ebp
  80140d:	53                   	push   %ebx
  80140e:	83 ec 14             	sub    $0x14,%esp
  801411:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801414:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801417:	50                   	push   %eax
  801418:	53                   	push   %ebx
  801419:	e8 86 fd ff ff       	call   8011a4 <fd_lookup>
  80141e:	83 c4 08             	add    $0x8,%esp
  801421:	89 c2                	mov    %eax,%edx
  801423:	85 c0                	test   %eax,%eax
  801425:	78 6d                	js     801494 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801427:	83 ec 08             	sub    $0x8,%esp
  80142a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80142d:	50                   	push   %eax
  80142e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801431:	ff 30                	pushl  (%eax)
  801433:	e8 c2 fd ff ff       	call   8011fa <dev_lookup>
  801438:	83 c4 10             	add    $0x10,%esp
  80143b:	85 c0                	test   %eax,%eax
  80143d:	78 4c                	js     80148b <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80143f:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801442:	8b 42 08             	mov    0x8(%edx),%eax
  801445:	83 e0 03             	and    $0x3,%eax
  801448:	83 f8 01             	cmp    $0x1,%eax
  80144b:	75 21                	jne    80146e <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80144d:	a1 04 40 80 00       	mov    0x804004,%eax
  801452:	8b 40 48             	mov    0x48(%eax),%eax
  801455:	83 ec 04             	sub    $0x4,%esp
  801458:	53                   	push   %ebx
  801459:	50                   	push   %eax
  80145a:	68 fc 25 80 00       	push   $0x8025fc
  80145f:	e8 cd ed ff ff       	call   800231 <cprintf>
		return -E_INVAL;
  801464:	83 c4 10             	add    $0x10,%esp
  801467:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80146c:	eb 26                	jmp    801494 <read+0x8a>
	}
	if (!dev->dev_read)
  80146e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801471:	8b 40 08             	mov    0x8(%eax),%eax
  801474:	85 c0                	test   %eax,%eax
  801476:	74 17                	je     80148f <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801478:	83 ec 04             	sub    $0x4,%esp
  80147b:	ff 75 10             	pushl  0x10(%ebp)
  80147e:	ff 75 0c             	pushl  0xc(%ebp)
  801481:	52                   	push   %edx
  801482:	ff d0                	call   *%eax
  801484:	89 c2                	mov    %eax,%edx
  801486:	83 c4 10             	add    $0x10,%esp
  801489:	eb 09                	jmp    801494 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80148b:	89 c2                	mov    %eax,%edx
  80148d:	eb 05                	jmp    801494 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80148f:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801494:	89 d0                	mov    %edx,%eax
  801496:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801499:	c9                   	leave  
  80149a:	c3                   	ret    

0080149b <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80149b:	55                   	push   %ebp
  80149c:	89 e5                	mov    %esp,%ebp
  80149e:	57                   	push   %edi
  80149f:	56                   	push   %esi
  8014a0:	53                   	push   %ebx
  8014a1:	83 ec 0c             	sub    $0xc,%esp
  8014a4:	8b 7d 08             	mov    0x8(%ebp),%edi
  8014a7:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8014aa:	bb 00 00 00 00       	mov    $0x0,%ebx
  8014af:	eb 21                	jmp    8014d2 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8014b1:	83 ec 04             	sub    $0x4,%esp
  8014b4:	89 f0                	mov    %esi,%eax
  8014b6:	29 d8                	sub    %ebx,%eax
  8014b8:	50                   	push   %eax
  8014b9:	89 d8                	mov    %ebx,%eax
  8014bb:	03 45 0c             	add    0xc(%ebp),%eax
  8014be:	50                   	push   %eax
  8014bf:	57                   	push   %edi
  8014c0:	e8 45 ff ff ff       	call   80140a <read>
		if (m < 0)
  8014c5:	83 c4 10             	add    $0x10,%esp
  8014c8:	85 c0                	test   %eax,%eax
  8014ca:	78 10                	js     8014dc <readn+0x41>
			return m;
		if (m == 0)
  8014cc:	85 c0                	test   %eax,%eax
  8014ce:	74 0a                	je     8014da <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8014d0:	01 c3                	add    %eax,%ebx
  8014d2:	39 f3                	cmp    %esi,%ebx
  8014d4:	72 db                	jb     8014b1 <readn+0x16>
  8014d6:	89 d8                	mov    %ebx,%eax
  8014d8:	eb 02                	jmp    8014dc <readn+0x41>
  8014da:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8014dc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014df:	5b                   	pop    %ebx
  8014e0:	5e                   	pop    %esi
  8014e1:	5f                   	pop    %edi
  8014e2:	5d                   	pop    %ebp
  8014e3:	c3                   	ret    

008014e4 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8014e4:	55                   	push   %ebp
  8014e5:	89 e5                	mov    %esp,%ebp
  8014e7:	53                   	push   %ebx
  8014e8:	83 ec 14             	sub    $0x14,%esp
  8014eb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014ee:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014f1:	50                   	push   %eax
  8014f2:	53                   	push   %ebx
  8014f3:	e8 ac fc ff ff       	call   8011a4 <fd_lookup>
  8014f8:	83 c4 08             	add    $0x8,%esp
  8014fb:	89 c2                	mov    %eax,%edx
  8014fd:	85 c0                	test   %eax,%eax
  8014ff:	78 68                	js     801569 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801501:	83 ec 08             	sub    $0x8,%esp
  801504:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801507:	50                   	push   %eax
  801508:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80150b:	ff 30                	pushl  (%eax)
  80150d:	e8 e8 fc ff ff       	call   8011fa <dev_lookup>
  801512:	83 c4 10             	add    $0x10,%esp
  801515:	85 c0                	test   %eax,%eax
  801517:	78 47                	js     801560 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801519:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80151c:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801520:	75 21                	jne    801543 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801522:	a1 04 40 80 00       	mov    0x804004,%eax
  801527:	8b 40 48             	mov    0x48(%eax),%eax
  80152a:	83 ec 04             	sub    $0x4,%esp
  80152d:	53                   	push   %ebx
  80152e:	50                   	push   %eax
  80152f:	68 18 26 80 00       	push   $0x802618
  801534:	e8 f8 ec ff ff       	call   800231 <cprintf>
		return -E_INVAL;
  801539:	83 c4 10             	add    $0x10,%esp
  80153c:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801541:	eb 26                	jmp    801569 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801543:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801546:	8b 52 0c             	mov    0xc(%edx),%edx
  801549:	85 d2                	test   %edx,%edx
  80154b:	74 17                	je     801564 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80154d:	83 ec 04             	sub    $0x4,%esp
  801550:	ff 75 10             	pushl  0x10(%ebp)
  801553:	ff 75 0c             	pushl  0xc(%ebp)
  801556:	50                   	push   %eax
  801557:	ff d2                	call   *%edx
  801559:	89 c2                	mov    %eax,%edx
  80155b:	83 c4 10             	add    $0x10,%esp
  80155e:	eb 09                	jmp    801569 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801560:	89 c2                	mov    %eax,%edx
  801562:	eb 05                	jmp    801569 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801564:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801569:	89 d0                	mov    %edx,%eax
  80156b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80156e:	c9                   	leave  
  80156f:	c3                   	ret    

00801570 <seek>:

int
seek(int fdnum, off_t offset)
{
  801570:	55                   	push   %ebp
  801571:	89 e5                	mov    %esp,%ebp
  801573:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801576:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801579:	50                   	push   %eax
  80157a:	ff 75 08             	pushl  0x8(%ebp)
  80157d:	e8 22 fc ff ff       	call   8011a4 <fd_lookup>
  801582:	83 c4 08             	add    $0x8,%esp
  801585:	85 c0                	test   %eax,%eax
  801587:	78 0e                	js     801597 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801589:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80158c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80158f:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801592:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801597:	c9                   	leave  
  801598:	c3                   	ret    

00801599 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801599:	55                   	push   %ebp
  80159a:	89 e5                	mov    %esp,%ebp
  80159c:	53                   	push   %ebx
  80159d:	83 ec 14             	sub    $0x14,%esp
  8015a0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015a3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015a6:	50                   	push   %eax
  8015a7:	53                   	push   %ebx
  8015a8:	e8 f7 fb ff ff       	call   8011a4 <fd_lookup>
  8015ad:	83 c4 08             	add    $0x8,%esp
  8015b0:	89 c2                	mov    %eax,%edx
  8015b2:	85 c0                	test   %eax,%eax
  8015b4:	78 65                	js     80161b <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015b6:	83 ec 08             	sub    $0x8,%esp
  8015b9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015bc:	50                   	push   %eax
  8015bd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015c0:	ff 30                	pushl  (%eax)
  8015c2:	e8 33 fc ff ff       	call   8011fa <dev_lookup>
  8015c7:	83 c4 10             	add    $0x10,%esp
  8015ca:	85 c0                	test   %eax,%eax
  8015cc:	78 44                	js     801612 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8015ce:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015d1:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8015d5:	75 21                	jne    8015f8 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8015d7:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8015dc:	8b 40 48             	mov    0x48(%eax),%eax
  8015df:	83 ec 04             	sub    $0x4,%esp
  8015e2:	53                   	push   %ebx
  8015e3:	50                   	push   %eax
  8015e4:	68 d8 25 80 00       	push   $0x8025d8
  8015e9:	e8 43 ec ff ff       	call   800231 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8015ee:	83 c4 10             	add    $0x10,%esp
  8015f1:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8015f6:	eb 23                	jmp    80161b <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8015f8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015fb:	8b 52 18             	mov    0x18(%edx),%edx
  8015fe:	85 d2                	test   %edx,%edx
  801600:	74 14                	je     801616 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801602:	83 ec 08             	sub    $0x8,%esp
  801605:	ff 75 0c             	pushl  0xc(%ebp)
  801608:	50                   	push   %eax
  801609:	ff d2                	call   *%edx
  80160b:	89 c2                	mov    %eax,%edx
  80160d:	83 c4 10             	add    $0x10,%esp
  801610:	eb 09                	jmp    80161b <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801612:	89 c2                	mov    %eax,%edx
  801614:	eb 05                	jmp    80161b <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801616:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  80161b:	89 d0                	mov    %edx,%eax
  80161d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801620:	c9                   	leave  
  801621:	c3                   	ret    

00801622 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801622:	55                   	push   %ebp
  801623:	89 e5                	mov    %esp,%ebp
  801625:	53                   	push   %ebx
  801626:	83 ec 14             	sub    $0x14,%esp
  801629:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80162c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80162f:	50                   	push   %eax
  801630:	ff 75 08             	pushl  0x8(%ebp)
  801633:	e8 6c fb ff ff       	call   8011a4 <fd_lookup>
  801638:	83 c4 08             	add    $0x8,%esp
  80163b:	89 c2                	mov    %eax,%edx
  80163d:	85 c0                	test   %eax,%eax
  80163f:	78 58                	js     801699 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801641:	83 ec 08             	sub    $0x8,%esp
  801644:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801647:	50                   	push   %eax
  801648:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80164b:	ff 30                	pushl  (%eax)
  80164d:	e8 a8 fb ff ff       	call   8011fa <dev_lookup>
  801652:	83 c4 10             	add    $0x10,%esp
  801655:	85 c0                	test   %eax,%eax
  801657:	78 37                	js     801690 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801659:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80165c:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801660:	74 32                	je     801694 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801662:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801665:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80166c:	00 00 00 
	stat->st_isdir = 0;
  80166f:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801676:	00 00 00 
	stat->st_dev = dev;
  801679:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80167f:	83 ec 08             	sub    $0x8,%esp
  801682:	53                   	push   %ebx
  801683:	ff 75 f0             	pushl  -0x10(%ebp)
  801686:	ff 50 14             	call   *0x14(%eax)
  801689:	89 c2                	mov    %eax,%edx
  80168b:	83 c4 10             	add    $0x10,%esp
  80168e:	eb 09                	jmp    801699 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801690:	89 c2                	mov    %eax,%edx
  801692:	eb 05                	jmp    801699 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801694:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801699:	89 d0                	mov    %edx,%eax
  80169b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80169e:	c9                   	leave  
  80169f:	c3                   	ret    

008016a0 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8016a0:	55                   	push   %ebp
  8016a1:	89 e5                	mov    %esp,%ebp
  8016a3:	56                   	push   %esi
  8016a4:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8016a5:	83 ec 08             	sub    $0x8,%esp
  8016a8:	6a 00                	push   $0x0
  8016aa:	ff 75 08             	pushl  0x8(%ebp)
  8016ad:	e8 d6 01 00 00       	call   801888 <open>
  8016b2:	89 c3                	mov    %eax,%ebx
  8016b4:	83 c4 10             	add    $0x10,%esp
  8016b7:	85 c0                	test   %eax,%eax
  8016b9:	78 1b                	js     8016d6 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8016bb:	83 ec 08             	sub    $0x8,%esp
  8016be:	ff 75 0c             	pushl  0xc(%ebp)
  8016c1:	50                   	push   %eax
  8016c2:	e8 5b ff ff ff       	call   801622 <fstat>
  8016c7:	89 c6                	mov    %eax,%esi
	close(fd);
  8016c9:	89 1c 24             	mov    %ebx,(%esp)
  8016cc:	e8 fd fb ff ff       	call   8012ce <close>
	return r;
  8016d1:	83 c4 10             	add    $0x10,%esp
  8016d4:	89 f0                	mov    %esi,%eax
}
  8016d6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016d9:	5b                   	pop    %ebx
  8016da:	5e                   	pop    %esi
  8016db:	5d                   	pop    %ebp
  8016dc:	c3                   	ret    

008016dd <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8016dd:	55                   	push   %ebp
  8016de:	89 e5                	mov    %esp,%ebp
  8016e0:	56                   	push   %esi
  8016e1:	53                   	push   %ebx
  8016e2:	89 c6                	mov    %eax,%esi
  8016e4:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8016e6:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8016ed:	75 12                	jne    801701 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8016ef:	83 ec 0c             	sub    $0xc,%esp
  8016f2:	6a 01                	push   $0x1
  8016f4:	e8 fc f9 ff ff       	call   8010f5 <ipc_find_env>
  8016f9:	a3 00 40 80 00       	mov    %eax,0x804000
  8016fe:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801701:	6a 07                	push   $0x7
  801703:	68 00 50 80 00       	push   $0x805000
  801708:	56                   	push   %esi
  801709:	ff 35 00 40 80 00    	pushl  0x804000
  80170f:	e8 8d f9 ff ff       	call   8010a1 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801714:	83 c4 0c             	add    $0xc,%esp
  801717:	6a 00                	push   $0x0
  801719:	53                   	push   %ebx
  80171a:	6a 00                	push   $0x0
  80171c:	e8 19 f9 ff ff       	call   80103a <ipc_recv>
}
  801721:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801724:	5b                   	pop    %ebx
  801725:	5e                   	pop    %esi
  801726:	5d                   	pop    %ebp
  801727:	c3                   	ret    

00801728 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801728:	55                   	push   %ebp
  801729:	89 e5                	mov    %esp,%ebp
  80172b:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80172e:	8b 45 08             	mov    0x8(%ebp),%eax
  801731:	8b 40 0c             	mov    0xc(%eax),%eax
  801734:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801739:	8b 45 0c             	mov    0xc(%ebp),%eax
  80173c:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801741:	ba 00 00 00 00       	mov    $0x0,%edx
  801746:	b8 02 00 00 00       	mov    $0x2,%eax
  80174b:	e8 8d ff ff ff       	call   8016dd <fsipc>
}
  801750:	c9                   	leave  
  801751:	c3                   	ret    

00801752 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801752:	55                   	push   %ebp
  801753:	89 e5                	mov    %esp,%ebp
  801755:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801758:	8b 45 08             	mov    0x8(%ebp),%eax
  80175b:	8b 40 0c             	mov    0xc(%eax),%eax
  80175e:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801763:	ba 00 00 00 00       	mov    $0x0,%edx
  801768:	b8 06 00 00 00       	mov    $0x6,%eax
  80176d:	e8 6b ff ff ff       	call   8016dd <fsipc>
}
  801772:	c9                   	leave  
  801773:	c3                   	ret    

00801774 <devfile_stat>:

}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801774:	55                   	push   %ebp
  801775:	89 e5                	mov    %esp,%ebp
  801777:	53                   	push   %ebx
  801778:	83 ec 04             	sub    $0x4,%esp
  80177b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80177e:	8b 45 08             	mov    0x8(%ebp),%eax
  801781:	8b 40 0c             	mov    0xc(%eax),%eax
  801784:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801789:	ba 00 00 00 00       	mov    $0x0,%edx
  80178e:	b8 05 00 00 00       	mov    $0x5,%eax
  801793:	e8 45 ff ff ff       	call   8016dd <fsipc>
  801798:	85 c0                	test   %eax,%eax
  80179a:	78 2c                	js     8017c8 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80179c:	83 ec 08             	sub    $0x8,%esp
  80179f:	68 00 50 80 00       	push   $0x805000
  8017a4:	53                   	push   %ebx
  8017a5:	e8 0c f0 ff ff       	call   8007b6 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8017aa:	a1 80 50 80 00       	mov    0x805080,%eax
  8017af:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8017b5:	a1 84 50 80 00       	mov    0x805084,%eax
  8017ba:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8017c0:	83 c4 10             	add    $0x10,%esp
  8017c3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017c8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017cb:	c9                   	leave  
  8017cc:	c3                   	ret    

008017cd <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8017cd:	55                   	push   %ebp
  8017ce:	89 e5                	mov    %esp,%ebp
  8017d0:	83 ec 0c             	sub    $0xc,%esp
  8017d3:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	// panic("devfile_write not implemented");

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8017d6:	8b 55 08             	mov    0x8(%ebp),%edx
  8017d9:	8b 52 0c             	mov    0xc(%edx),%edx
  8017dc:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  8017e2:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  8017e7:	50                   	push   %eax
  8017e8:	ff 75 0c             	pushl  0xc(%ebp)
  8017eb:	68 08 50 80 00       	push   $0x805008
  8017f0:	e8 53 f1 ff ff       	call   800948 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  8017f5:	ba 00 00 00 00       	mov    $0x0,%edx
  8017fa:	b8 04 00 00 00       	mov    $0x4,%eax
  8017ff:	e8 d9 fe ff ff       	call   8016dd <fsipc>

}
  801804:	c9                   	leave  
  801805:	c3                   	ret    

00801806 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801806:	55                   	push   %ebp
  801807:	89 e5                	mov    %esp,%ebp
  801809:	56                   	push   %esi
  80180a:	53                   	push   %ebx
  80180b:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80180e:	8b 45 08             	mov    0x8(%ebp),%eax
  801811:	8b 40 0c             	mov    0xc(%eax),%eax
  801814:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801819:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80181f:	ba 00 00 00 00       	mov    $0x0,%edx
  801824:	b8 03 00 00 00       	mov    $0x3,%eax
  801829:	e8 af fe ff ff       	call   8016dd <fsipc>
  80182e:	89 c3                	mov    %eax,%ebx
  801830:	85 c0                	test   %eax,%eax
  801832:	78 4b                	js     80187f <devfile_read+0x79>
		return r;
	assert(r <= n);
  801834:	39 c6                	cmp    %eax,%esi
  801836:	73 16                	jae    80184e <devfile_read+0x48>
  801838:	68 48 26 80 00       	push   $0x802648
  80183d:	68 4f 26 80 00       	push   $0x80264f
  801842:	6a 7c                	push   $0x7c
  801844:	68 64 26 80 00       	push   $0x802664
  801849:	e8 0a e9 ff ff       	call   800158 <_panic>
	assert(r <= PGSIZE);
  80184e:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801853:	7e 16                	jle    80186b <devfile_read+0x65>
  801855:	68 6f 26 80 00       	push   $0x80266f
  80185a:	68 4f 26 80 00       	push   $0x80264f
  80185f:	6a 7d                	push   $0x7d
  801861:	68 64 26 80 00       	push   $0x802664
  801866:	e8 ed e8 ff ff       	call   800158 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80186b:	83 ec 04             	sub    $0x4,%esp
  80186e:	50                   	push   %eax
  80186f:	68 00 50 80 00       	push   $0x805000
  801874:	ff 75 0c             	pushl  0xc(%ebp)
  801877:	e8 cc f0 ff ff       	call   800948 <memmove>
	return r;
  80187c:	83 c4 10             	add    $0x10,%esp
}
  80187f:	89 d8                	mov    %ebx,%eax
  801881:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801884:	5b                   	pop    %ebx
  801885:	5e                   	pop    %esi
  801886:	5d                   	pop    %ebp
  801887:	c3                   	ret    

00801888 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801888:	55                   	push   %ebp
  801889:	89 e5                	mov    %esp,%ebp
  80188b:	53                   	push   %ebx
  80188c:	83 ec 20             	sub    $0x20,%esp
  80188f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801892:	53                   	push   %ebx
  801893:	e8 e5 ee ff ff       	call   80077d <strlen>
  801898:	83 c4 10             	add    $0x10,%esp
  80189b:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8018a0:	7f 67                	jg     801909 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8018a2:	83 ec 0c             	sub    $0xc,%esp
  8018a5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018a8:	50                   	push   %eax
  8018a9:	e8 a7 f8 ff ff       	call   801155 <fd_alloc>
  8018ae:	83 c4 10             	add    $0x10,%esp
		return r;
  8018b1:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8018b3:	85 c0                	test   %eax,%eax
  8018b5:	78 57                	js     80190e <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8018b7:	83 ec 08             	sub    $0x8,%esp
  8018ba:	53                   	push   %ebx
  8018bb:	68 00 50 80 00       	push   $0x805000
  8018c0:	e8 f1 ee ff ff       	call   8007b6 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8018c5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018c8:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8018cd:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8018d0:	b8 01 00 00 00       	mov    $0x1,%eax
  8018d5:	e8 03 fe ff ff       	call   8016dd <fsipc>
  8018da:	89 c3                	mov    %eax,%ebx
  8018dc:	83 c4 10             	add    $0x10,%esp
  8018df:	85 c0                	test   %eax,%eax
  8018e1:	79 14                	jns    8018f7 <open+0x6f>
		fd_close(fd, 0);
  8018e3:	83 ec 08             	sub    $0x8,%esp
  8018e6:	6a 00                	push   $0x0
  8018e8:	ff 75 f4             	pushl  -0xc(%ebp)
  8018eb:	e8 5d f9 ff ff       	call   80124d <fd_close>
		return r;
  8018f0:	83 c4 10             	add    $0x10,%esp
  8018f3:	89 da                	mov    %ebx,%edx
  8018f5:	eb 17                	jmp    80190e <open+0x86>
	}

	return fd2num(fd);
  8018f7:	83 ec 0c             	sub    $0xc,%esp
  8018fa:	ff 75 f4             	pushl  -0xc(%ebp)
  8018fd:	e8 2c f8 ff ff       	call   80112e <fd2num>
  801902:	89 c2                	mov    %eax,%edx
  801904:	83 c4 10             	add    $0x10,%esp
  801907:	eb 05                	jmp    80190e <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801909:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  80190e:	89 d0                	mov    %edx,%eax
  801910:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801913:	c9                   	leave  
  801914:	c3                   	ret    

00801915 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801915:	55                   	push   %ebp
  801916:	89 e5                	mov    %esp,%ebp
  801918:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80191b:	ba 00 00 00 00       	mov    $0x0,%edx
  801920:	b8 08 00 00 00       	mov    $0x8,%eax
  801925:	e8 b3 fd ff ff       	call   8016dd <fsipc>
}
  80192a:	c9                   	leave  
  80192b:	c3                   	ret    

0080192c <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  80192c:	55                   	push   %ebp
  80192d:	89 e5                	mov    %esp,%ebp
  80192f:	56                   	push   %esi
  801930:	53                   	push   %ebx
  801931:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801934:	83 ec 0c             	sub    $0xc,%esp
  801937:	ff 75 08             	pushl  0x8(%ebp)
  80193a:	e8 ff f7 ff ff       	call   80113e <fd2data>
  80193f:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801941:	83 c4 08             	add    $0x8,%esp
  801944:	68 7b 26 80 00       	push   $0x80267b
  801949:	53                   	push   %ebx
  80194a:	e8 67 ee ff ff       	call   8007b6 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  80194f:	8b 46 04             	mov    0x4(%esi),%eax
  801952:	2b 06                	sub    (%esi),%eax
  801954:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80195a:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801961:	00 00 00 
	stat->st_dev = &devpipe;
  801964:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  80196b:	30 80 00 
	return 0;
}
  80196e:	b8 00 00 00 00       	mov    $0x0,%eax
  801973:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801976:	5b                   	pop    %ebx
  801977:	5e                   	pop    %esi
  801978:	5d                   	pop    %ebp
  801979:	c3                   	ret    

0080197a <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80197a:	55                   	push   %ebp
  80197b:	89 e5                	mov    %esp,%ebp
  80197d:	53                   	push   %ebx
  80197e:	83 ec 0c             	sub    $0xc,%esp
  801981:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801984:	53                   	push   %ebx
  801985:	6a 00                	push   $0x0
  801987:	e8 b2 f2 ff ff       	call   800c3e <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  80198c:	89 1c 24             	mov    %ebx,(%esp)
  80198f:	e8 aa f7 ff ff       	call   80113e <fd2data>
  801994:	83 c4 08             	add    $0x8,%esp
  801997:	50                   	push   %eax
  801998:	6a 00                	push   $0x0
  80199a:	e8 9f f2 ff ff       	call   800c3e <sys_page_unmap>
}
  80199f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019a2:	c9                   	leave  
  8019a3:	c3                   	ret    

008019a4 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8019a4:	55                   	push   %ebp
  8019a5:	89 e5                	mov    %esp,%ebp
  8019a7:	57                   	push   %edi
  8019a8:	56                   	push   %esi
  8019a9:	53                   	push   %ebx
  8019aa:	83 ec 1c             	sub    $0x1c,%esp
  8019ad:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8019b0:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8019b2:	a1 04 40 80 00       	mov    0x804004,%eax
  8019b7:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  8019ba:	83 ec 0c             	sub    $0xc,%esp
  8019bd:	ff 75 e0             	pushl  -0x20(%ebp)
  8019c0:	e8 b1 04 00 00       	call   801e76 <pageref>
  8019c5:	89 c3                	mov    %eax,%ebx
  8019c7:	89 3c 24             	mov    %edi,(%esp)
  8019ca:	e8 a7 04 00 00       	call   801e76 <pageref>
  8019cf:	83 c4 10             	add    $0x10,%esp
  8019d2:	39 c3                	cmp    %eax,%ebx
  8019d4:	0f 94 c1             	sete   %cl
  8019d7:	0f b6 c9             	movzbl %cl,%ecx
  8019da:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  8019dd:	8b 15 04 40 80 00    	mov    0x804004,%edx
  8019e3:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8019e6:	39 ce                	cmp    %ecx,%esi
  8019e8:	74 1b                	je     801a05 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  8019ea:	39 c3                	cmp    %eax,%ebx
  8019ec:	75 c4                	jne    8019b2 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8019ee:	8b 42 58             	mov    0x58(%edx),%eax
  8019f1:	ff 75 e4             	pushl  -0x1c(%ebp)
  8019f4:	50                   	push   %eax
  8019f5:	56                   	push   %esi
  8019f6:	68 82 26 80 00       	push   $0x802682
  8019fb:	e8 31 e8 ff ff       	call   800231 <cprintf>
  801a00:	83 c4 10             	add    $0x10,%esp
  801a03:	eb ad                	jmp    8019b2 <_pipeisclosed+0xe>
	}
}
  801a05:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801a08:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a0b:	5b                   	pop    %ebx
  801a0c:	5e                   	pop    %esi
  801a0d:	5f                   	pop    %edi
  801a0e:	5d                   	pop    %ebp
  801a0f:	c3                   	ret    

00801a10 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801a10:	55                   	push   %ebp
  801a11:	89 e5                	mov    %esp,%ebp
  801a13:	57                   	push   %edi
  801a14:	56                   	push   %esi
  801a15:	53                   	push   %ebx
  801a16:	83 ec 28             	sub    $0x28,%esp
  801a19:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801a1c:	56                   	push   %esi
  801a1d:	e8 1c f7 ff ff       	call   80113e <fd2data>
  801a22:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a24:	83 c4 10             	add    $0x10,%esp
  801a27:	bf 00 00 00 00       	mov    $0x0,%edi
  801a2c:	eb 4b                	jmp    801a79 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801a2e:	89 da                	mov    %ebx,%edx
  801a30:	89 f0                	mov    %esi,%eax
  801a32:	e8 6d ff ff ff       	call   8019a4 <_pipeisclosed>
  801a37:	85 c0                	test   %eax,%eax
  801a39:	75 48                	jne    801a83 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801a3b:	e8 5a f1 ff ff       	call   800b9a <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801a40:	8b 43 04             	mov    0x4(%ebx),%eax
  801a43:	8b 0b                	mov    (%ebx),%ecx
  801a45:	8d 51 20             	lea    0x20(%ecx),%edx
  801a48:	39 d0                	cmp    %edx,%eax
  801a4a:	73 e2                	jae    801a2e <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801a4c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a4f:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801a53:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801a56:	89 c2                	mov    %eax,%edx
  801a58:	c1 fa 1f             	sar    $0x1f,%edx
  801a5b:	89 d1                	mov    %edx,%ecx
  801a5d:	c1 e9 1b             	shr    $0x1b,%ecx
  801a60:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801a63:	83 e2 1f             	and    $0x1f,%edx
  801a66:	29 ca                	sub    %ecx,%edx
  801a68:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801a6c:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801a70:	83 c0 01             	add    $0x1,%eax
  801a73:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a76:	83 c7 01             	add    $0x1,%edi
  801a79:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801a7c:	75 c2                	jne    801a40 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801a7e:	8b 45 10             	mov    0x10(%ebp),%eax
  801a81:	eb 05                	jmp    801a88 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801a83:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801a88:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a8b:	5b                   	pop    %ebx
  801a8c:	5e                   	pop    %esi
  801a8d:	5f                   	pop    %edi
  801a8e:	5d                   	pop    %ebp
  801a8f:	c3                   	ret    

00801a90 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801a90:	55                   	push   %ebp
  801a91:	89 e5                	mov    %esp,%ebp
  801a93:	57                   	push   %edi
  801a94:	56                   	push   %esi
  801a95:	53                   	push   %ebx
  801a96:	83 ec 18             	sub    $0x18,%esp
  801a99:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801a9c:	57                   	push   %edi
  801a9d:	e8 9c f6 ff ff       	call   80113e <fd2data>
  801aa2:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801aa4:	83 c4 10             	add    $0x10,%esp
  801aa7:	bb 00 00 00 00       	mov    $0x0,%ebx
  801aac:	eb 3d                	jmp    801aeb <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801aae:	85 db                	test   %ebx,%ebx
  801ab0:	74 04                	je     801ab6 <devpipe_read+0x26>
				return i;
  801ab2:	89 d8                	mov    %ebx,%eax
  801ab4:	eb 44                	jmp    801afa <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801ab6:	89 f2                	mov    %esi,%edx
  801ab8:	89 f8                	mov    %edi,%eax
  801aba:	e8 e5 fe ff ff       	call   8019a4 <_pipeisclosed>
  801abf:	85 c0                	test   %eax,%eax
  801ac1:	75 32                	jne    801af5 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801ac3:	e8 d2 f0 ff ff       	call   800b9a <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801ac8:	8b 06                	mov    (%esi),%eax
  801aca:	3b 46 04             	cmp    0x4(%esi),%eax
  801acd:	74 df                	je     801aae <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801acf:	99                   	cltd   
  801ad0:	c1 ea 1b             	shr    $0x1b,%edx
  801ad3:	01 d0                	add    %edx,%eax
  801ad5:	83 e0 1f             	and    $0x1f,%eax
  801ad8:	29 d0                	sub    %edx,%eax
  801ada:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801adf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801ae2:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801ae5:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ae8:	83 c3 01             	add    $0x1,%ebx
  801aeb:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801aee:	75 d8                	jne    801ac8 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801af0:	8b 45 10             	mov    0x10(%ebp),%eax
  801af3:	eb 05                	jmp    801afa <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801af5:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801afa:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801afd:	5b                   	pop    %ebx
  801afe:	5e                   	pop    %esi
  801aff:	5f                   	pop    %edi
  801b00:	5d                   	pop    %ebp
  801b01:	c3                   	ret    

00801b02 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801b02:	55                   	push   %ebp
  801b03:	89 e5                	mov    %esp,%ebp
  801b05:	56                   	push   %esi
  801b06:	53                   	push   %ebx
  801b07:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801b0a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b0d:	50                   	push   %eax
  801b0e:	e8 42 f6 ff ff       	call   801155 <fd_alloc>
  801b13:	83 c4 10             	add    $0x10,%esp
  801b16:	89 c2                	mov    %eax,%edx
  801b18:	85 c0                	test   %eax,%eax
  801b1a:	0f 88 2c 01 00 00    	js     801c4c <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b20:	83 ec 04             	sub    $0x4,%esp
  801b23:	68 07 04 00 00       	push   $0x407
  801b28:	ff 75 f4             	pushl  -0xc(%ebp)
  801b2b:	6a 00                	push   $0x0
  801b2d:	e8 87 f0 ff ff       	call   800bb9 <sys_page_alloc>
  801b32:	83 c4 10             	add    $0x10,%esp
  801b35:	89 c2                	mov    %eax,%edx
  801b37:	85 c0                	test   %eax,%eax
  801b39:	0f 88 0d 01 00 00    	js     801c4c <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801b3f:	83 ec 0c             	sub    $0xc,%esp
  801b42:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801b45:	50                   	push   %eax
  801b46:	e8 0a f6 ff ff       	call   801155 <fd_alloc>
  801b4b:	89 c3                	mov    %eax,%ebx
  801b4d:	83 c4 10             	add    $0x10,%esp
  801b50:	85 c0                	test   %eax,%eax
  801b52:	0f 88 e2 00 00 00    	js     801c3a <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b58:	83 ec 04             	sub    $0x4,%esp
  801b5b:	68 07 04 00 00       	push   $0x407
  801b60:	ff 75 f0             	pushl  -0x10(%ebp)
  801b63:	6a 00                	push   $0x0
  801b65:	e8 4f f0 ff ff       	call   800bb9 <sys_page_alloc>
  801b6a:	89 c3                	mov    %eax,%ebx
  801b6c:	83 c4 10             	add    $0x10,%esp
  801b6f:	85 c0                	test   %eax,%eax
  801b71:	0f 88 c3 00 00 00    	js     801c3a <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801b77:	83 ec 0c             	sub    $0xc,%esp
  801b7a:	ff 75 f4             	pushl  -0xc(%ebp)
  801b7d:	e8 bc f5 ff ff       	call   80113e <fd2data>
  801b82:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b84:	83 c4 0c             	add    $0xc,%esp
  801b87:	68 07 04 00 00       	push   $0x407
  801b8c:	50                   	push   %eax
  801b8d:	6a 00                	push   $0x0
  801b8f:	e8 25 f0 ff ff       	call   800bb9 <sys_page_alloc>
  801b94:	89 c3                	mov    %eax,%ebx
  801b96:	83 c4 10             	add    $0x10,%esp
  801b99:	85 c0                	test   %eax,%eax
  801b9b:	0f 88 89 00 00 00    	js     801c2a <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ba1:	83 ec 0c             	sub    $0xc,%esp
  801ba4:	ff 75 f0             	pushl  -0x10(%ebp)
  801ba7:	e8 92 f5 ff ff       	call   80113e <fd2data>
  801bac:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801bb3:	50                   	push   %eax
  801bb4:	6a 00                	push   $0x0
  801bb6:	56                   	push   %esi
  801bb7:	6a 00                	push   $0x0
  801bb9:	e8 3e f0 ff ff       	call   800bfc <sys_page_map>
  801bbe:	89 c3                	mov    %eax,%ebx
  801bc0:	83 c4 20             	add    $0x20,%esp
  801bc3:	85 c0                	test   %eax,%eax
  801bc5:	78 55                	js     801c1c <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801bc7:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801bcd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bd0:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801bd2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bd5:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801bdc:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801be2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801be5:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801be7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801bea:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801bf1:	83 ec 0c             	sub    $0xc,%esp
  801bf4:	ff 75 f4             	pushl  -0xc(%ebp)
  801bf7:	e8 32 f5 ff ff       	call   80112e <fd2num>
  801bfc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801bff:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801c01:	83 c4 04             	add    $0x4,%esp
  801c04:	ff 75 f0             	pushl  -0x10(%ebp)
  801c07:	e8 22 f5 ff ff       	call   80112e <fd2num>
  801c0c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c0f:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801c12:	83 c4 10             	add    $0x10,%esp
  801c15:	ba 00 00 00 00       	mov    $0x0,%edx
  801c1a:	eb 30                	jmp    801c4c <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801c1c:	83 ec 08             	sub    $0x8,%esp
  801c1f:	56                   	push   %esi
  801c20:	6a 00                	push   $0x0
  801c22:	e8 17 f0 ff ff       	call   800c3e <sys_page_unmap>
  801c27:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801c2a:	83 ec 08             	sub    $0x8,%esp
  801c2d:	ff 75 f0             	pushl  -0x10(%ebp)
  801c30:	6a 00                	push   $0x0
  801c32:	e8 07 f0 ff ff       	call   800c3e <sys_page_unmap>
  801c37:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801c3a:	83 ec 08             	sub    $0x8,%esp
  801c3d:	ff 75 f4             	pushl  -0xc(%ebp)
  801c40:	6a 00                	push   $0x0
  801c42:	e8 f7 ef ff ff       	call   800c3e <sys_page_unmap>
  801c47:	83 c4 10             	add    $0x10,%esp
  801c4a:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801c4c:	89 d0                	mov    %edx,%eax
  801c4e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c51:	5b                   	pop    %ebx
  801c52:	5e                   	pop    %esi
  801c53:	5d                   	pop    %ebp
  801c54:	c3                   	ret    

00801c55 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801c55:	55                   	push   %ebp
  801c56:	89 e5                	mov    %esp,%ebp
  801c58:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801c5b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c5e:	50                   	push   %eax
  801c5f:	ff 75 08             	pushl  0x8(%ebp)
  801c62:	e8 3d f5 ff ff       	call   8011a4 <fd_lookup>
  801c67:	83 c4 10             	add    $0x10,%esp
  801c6a:	85 c0                	test   %eax,%eax
  801c6c:	78 18                	js     801c86 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801c6e:	83 ec 0c             	sub    $0xc,%esp
  801c71:	ff 75 f4             	pushl  -0xc(%ebp)
  801c74:	e8 c5 f4 ff ff       	call   80113e <fd2data>
	return _pipeisclosed(fd, p);
  801c79:	89 c2                	mov    %eax,%edx
  801c7b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c7e:	e8 21 fd ff ff       	call   8019a4 <_pipeisclosed>
  801c83:	83 c4 10             	add    $0x10,%esp
}
  801c86:	c9                   	leave  
  801c87:	c3                   	ret    

00801c88 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801c88:	55                   	push   %ebp
  801c89:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801c8b:	b8 00 00 00 00       	mov    $0x0,%eax
  801c90:	5d                   	pop    %ebp
  801c91:	c3                   	ret    

00801c92 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801c92:	55                   	push   %ebp
  801c93:	89 e5                	mov    %esp,%ebp
  801c95:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801c98:	68 9a 26 80 00       	push   $0x80269a
  801c9d:	ff 75 0c             	pushl  0xc(%ebp)
  801ca0:	e8 11 eb ff ff       	call   8007b6 <strcpy>
	return 0;
}
  801ca5:	b8 00 00 00 00       	mov    $0x0,%eax
  801caa:	c9                   	leave  
  801cab:	c3                   	ret    

00801cac <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801cac:	55                   	push   %ebp
  801cad:	89 e5                	mov    %esp,%ebp
  801caf:	57                   	push   %edi
  801cb0:	56                   	push   %esi
  801cb1:	53                   	push   %ebx
  801cb2:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801cb8:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801cbd:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801cc3:	eb 2d                	jmp    801cf2 <devcons_write+0x46>
		m = n - tot;
  801cc5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801cc8:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801cca:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801ccd:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801cd2:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801cd5:	83 ec 04             	sub    $0x4,%esp
  801cd8:	53                   	push   %ebx
  801cd9:	03 45 0c             	add    0xc(%ebp),%eax
  801cdc:	50                   	push   %eax
  801cdd:	57                   	push   %edi
  801cde:	e8 65 ec ff ff       	call   800948 <memmove>
		sys_cputs(buf, m);
  801ce3:	83 c4 08             	add    $0x8,%esp
  801ce6:	53                   	push   %ebx
  801ce7:	57                   	push   %edi
  801ce8:	e8 10 ee ff ff       	call   800afd <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801ced:	01 de                	add    %ebx,%esi
  801cef:	83 c4 10             	add    $0x10,%esp
  801cf2:	89 f0                	mov    %esi,%eax
  801cf4:	3b 75 10             	cmp    0x10(%ebp),%esi
  801cf7:	72 cc                	jb     801cc5 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801cf9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801cfc:	5b                   	pop    %ebx
  801cfd:	5e                   	pop    %esi
  801cfe:	5f                   	pop    %edi
  801cff:	5d                   	pop    %ebp
  801d00:	c3                   	ret    

00801d01 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801d01:	55                   	push   %ebp
  801d02:	89 e5                	mov    %esp,%ebp
  801d04:	83 ec 08             	sub    $0x8,%esp
  801d07:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801d0c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801d10:	74 2a                	je     801d3c <devcons_read+0x3b>
  801d12:	eb 05                	jmp    801d19 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801d14:	e8 81 ee ff ff       	call   800b9a <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801d19:	e8 fd ed ff ff       	call   800b1b <sys_cgetc>
  801d1e:	85 c0                	test   %eax,%eax
  801d20:	74 f2                	je     801d14 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801d22:	85 c0                	test   %eax,%eax
  801d24:	78 16                	js     801d3c <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801d26:	83 f8 04             	cmp    $0x4,%eax
  801d29:	74 0c                	je     801d37 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801d2b:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d2e:	88 02                	mov    %al,(%edx)
	return 1;
  801d30:	b8 01 00 00 00       	mov    $0x1,%eax
  801d35:	eb 05                	jmp    801d3c <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801d37:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801d3c:	c9                   	leave  
  801d3d:	c3                   	ret    

00801d3e <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801d3e:	55                   	push   %ebp
  801d3f:	89 e5                	mov    %esp,%ebp
  801d41:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801d44:	8b 45 08             	mov    0x8(%ebp),%eax
  801d47:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801d4a:	6a 01                	push   $0x1
  801d4c:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801d4f:	50                   	push   %eax
  801d50:	e8 a8 ed ff ff       	call   800afd <sys_cputs>
}
  801d55:	83 c4 10             	add    $0x10,%esp
  801d58:	c9                   	leave  
  801d59:	c3                   	ret    

00801d5a <getchar>:

int
getchar(void)
{
  801d5a:	55                   	push   %ebp
  801d5b:	89 e5                	mov    %esp,%ebp
  801d5d:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801d60:	6a 01                	push   $0x1
  801d62:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801d65:	50                   	push   %eax
  801d66:	6a 00                	push   $0x0
  801d68:	e8 9d f6 ff ff       	call   80140a <read>
	if (r < 0)
  801d6d:	83 c4 10             	add    $0x10,%esp
  801d70:	85 c0                	test   %eax,%eax
  801d72:	78 0f                	js     801d83 <getchar+0x29>
		return r;
	if (r < 1)
  801d74:	85 c0                	test   %eax,%eax
  801d76:	7e 06                	jle    801d7e <getchar+0x24>
		return -E_EOF;
	return c;
  801d78:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801d7c:	eb 05                	jmp    801d83 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801d7e:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801d83:	c9                   	leave  
  801d84:	c3                   	ret    

00801d85 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801d85:	55                   	push   %ebp
  801d86:	89 e5                	mov    %esp,%ebp
  801d88:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801d8b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d8e:	50                   	push   %eax
  801d8f:	ff 75 08             	pushl  0x8(%ebp)
  801d92:	e8 0d f4 ff ff       	call   8011a4 <fd_lookup>
  801d97:	83 c4 10             	add    $0x10,%esp
  801d9a:	85 c0                	test   %eax,%eax
  801d9c:	78 11                	js     801daf <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801d9e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801da1:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801da7:	39 10                	cmp    %edx,(%eax)
  801da9:	0f 94 c0             	sete   %al
  801dac:	0f b6 c0             	movzbl %al,%eax
}
  801daf:	c9                   	leave  
  801db0:	c3                   	ret    

00801db1 <opencons>:

int
opencons(void)
{
  801db1:	55                   	push   %ebp
  801db2:	89 e5                	mov    %esp,%ebp
  801db4:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801db7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801dba:	50                   	push   %eax
  801dbb:	e8 95 f3 ff ff       	call   801155 <fd_alloc>
  801dc0:	83 c4 10             	add    $0x10,%esp
		return r;
  801dc3:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801dc5:	85 c0                	test   %eax,%eax
  801dc7:	78 3e                	js     801e07 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801dc9:	83 ec 04             	sub    $0x4,%esp
  801dcc:	68 07 04 00 00       	push   $0x407
  801dd1:	ff 75 f4             	pushl  -0xc(%ebp)
  801dd4:	6a 00                	push   $0x0
  801dd6:	e8 de ed ff ff       	call   800bb9 <sys_page_alloc>
  801ddb:	83 c4 10             	add    $0x10,%esp
		return r;
  801dde:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801de0:	85 c0                	test   %eax,%eax
  801de2:	78 23                	js     801e07 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801de4:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801dea:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ded:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801def:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801df2:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801df9:	83 ec 0c             	sub    $0xc,%esp
  801dfc:	50                   	push   %eax
  801dfd:	e8 2c f3 ff ff       	call   80112e <fd2num>
  801e02:	89 c2                	mov    %eax,%edx
  801e04:	83 c4 10             	add    $0x10,%esp
}
  801e07:	89 d0                	mov    %edx,%eax
  801e09:	c9                   	leave  
  801e0a:	c3                   	ret    

00801e0b <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801e0b:	55                   	push   %ebp
  801e0c:	89 e5                	mov    %esp,%ebp
  801e0e:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801e11:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801e18:	75 2e                	jne    801e48 <set_pgfault_handler+0x3d>
		// First time through!
		// LAB 4: Your code here.
		// panic("set_pgfault_handler not implemented");

		sys_page_alloc(sys_getenvid(), (void *) (UXSTACKTOP - PGSIZE), PTE_SYSCALL);
  801e1a:	e8 5c ed ff ff       	call   800b7b <sys_getenvid>
  801e1f:	83 ec 04             	sub    $0x4,%esp
  801e22:	68 07 0e 00 00       	push   $0xe07
  801e27:	68 00 f0 bf ee       	push   $0xeebff000
  801e2c:	50                   	push   %eax
  801e2d:	e8 87 ed ff ff       	call   800bb9 <sys_page_alloc>
		sys_env_set_pgfault_upcall(sys_getenvid(), _pgfault_upcall);
  801e32:	e8 44 ed ff ff       	call   800b7b <sys_getenvid>
  801e37:	83 c4 08             	add    $0x8,%esp
  801e3a:	68 52 1e 80 00       	push   $0x801e52
  801e3f:	50                   	push   %eax
  801e40:	e8 bf ee ff ff       	call   800d04 <sys_env_set_pgfault_upcall>
  801e45:	83 c4 10             	add    $0x10,%esp
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801e48:	8b 45 08             	mov    0x8(%ebp),%eax
  801e4b:	a3 00 60 80 00       	mov    %eax,0x806000
}
  801e50:	c9                   	leave  
  801e51:	c3                   	ret    

00801e52 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801e52:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801e53:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801e58:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801e5a:	83 c4 04             	add    $0x4,%esp
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.

	movl 48(%esp), %eax		// trap-time esp
  801e5d:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl 40(%esp), %ebx		// trap-time eip
  801e61:	8b 5c 24 28          	mov    0x28(%esp),%ebx

	// load eip into esp-4
	// in order to return to trap-time eip later, in the meantime not changing trap-time esp
	movl %ebx, -4(%eax)	
  801e65:	89 58 fc             	mov    %ebx,-0x4(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.

	addl $8, %esp 			// esp now points to trap-time registers
  801e68:	83 c4 08             	add    $0x8,%esp
	popal					// pop to all registers
  801e6b:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

	addl $4, %esp			// esp now points to trap-time eflags
  801e6c:	83 c4 04             	add    $0x4,%esp
	popfl					// pop to eflags
  801e6f:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.

	popl %esp				// pop to esp
  801e70:	5c                   	pop    %esp
	// subl $4, %esp		// arithmetic operation will change eflags!!!
	lea -4(%esp), %esp		// subl $4, %esp
  801e71:	8d 64 24 fc          	lea    -0x4(%esp),%esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.

	ret
  801e75:	c3                   	ret    

00801e76 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801e76:	55                   	push   %ebp
  801e77:	89 e5                	mov    %esp,%ebp
  801e79:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801e7c:	89 d0                	mov    %edx,%eax
  801e7e:	c1 e8 16             	shr    $0x16,%eax
  801e81:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801e88:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801e8d:	f6 c1 01             	test   $0x1,%cl
  801e90:	74 1d                	je     801eaf <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801e92:	c1 ea 0c             	shr    $0xc,%edx
  801e95:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801e9c:	f6 c2 01             	test   $0x1,%dl
  801e9f:	74 0e                	je     801eaf <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801ea1:	c1 ea 0c             	shr    $0xc,%edx
  801ea4:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801eab:	ef 
  801eac:	0f b7 c0             	movzwl %ax,%eax
}
  801eaf:	5d                   	pop    %ebp
  801eb0:	c3                   	ret    
  801eb1:	66 90                	xchg   %ax,%ax
  801eb3:	66 90                	xchg   %ax,%ax
  801eb5:	66 90                	xchg   %ax,%ax
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
