
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
  800047:	e8 0d 10 00 00       	call   801059 <ipc_recv>
  80004c:	89 c3                	mov    %eax,%ebx
	cprintf("CPU %d: %d ", thisenv->env_cpunum, p);
  80004e:	a1 08 40 80 00       	mov    0x804008,%eax
  800053:	8b 40 5c             	mov    0x5c(%eax),%eax
  800056:	83 c4 0c             	add    $0xc,%esp
  800059:	53                   	push   %ebx
  80005a:	50                   	push   %eax
  80005b:	68 e0 25 80 00       	push   $0x8025e0
  800060:	e8 cc 01 00 00       	call   800231 <cprintf>

	// fork a right neighbor to continue the chain
	if ((id = fork()) < 0)
  800065:	e8 38 0e 00 00       	call   800ea2 <fork>
  80006a:	89 c7                	mov    %eax,%edi
  80006c:	83 c4 10             	add    $0x10,%esp
  80006f:	85 c0                	test   %eax,%eax
  800071:	79 12                	jns    800085 <primeproc+0x52>
		panic("fork: %e", id);
  800073:	50                   	push   %eax
  800074:	68 ec 25 80 00       	push   $0x8025ec
  800079:	6a 1a                	push   $0x1a
  80007b:	68 f5 25 80 00       	push   $0x8025f5
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
  800094:	e8 c0 0f 00 00       	call   801059 <ipc_recv>
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
  8000ab:	e8 10 10 00 00       	call   8010c0 <ipc_send>
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
  8000ba:	e8 e3 0d 00 00       	call   800ea2 <fork>
  8000bf:	89 c6                	mov    %eax,%esi
  8000c1:	85 c0                	test   %eax,%eax
  8000c3:	79 12                	jns    8000d7 <umain+0x22>
		panic("fork: %e", id);
  8000c5:	50                   	push   %eax
  8000c6:	68 ec 25 80 00       	push   $0x8025ec
  8000cb:	6a 2d                	push   $0x2d
  8000cd:	68 f5 25 80 00       	push   $0x8025f5
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
  8000eb:	e8 d0 0f 00 00       	call   8010c0 <ipc_send>
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
  800115:	a3 08 40 80 00       	mov    %eax,0x804008

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
  800144:	e8 cf 11 00 00       	call   801318 <close_all>
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
  800176:	68 10 26 80 00       	push   $0x802610
  80017b:	e8 b1 00 00 00       	call   800231 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800180:	83 c4 18             	add    $0x18,%esp
  800183:	53                   	push   %ebx
  800184:	ff 75 10             	pushl  0x10(%ebp)
  800187:	e8 54 00 00 00       	call   8001e0 <vcprintf>
	cprintf("\n");
  80018c:	c7 04 24 50 2b 80 00 	movl   $0x802b50,(%esp)
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
  800294:	e8 a7 20 00 00       	call   802340 <__udivdi3>
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
  8002d7:	e8 94 21 00 00       	call   802470 <__umoddi3>
  8002dc:	83 c4 14             	add    $0x14,%esp
  8002df:	0f be 80 33 26 80 00 	movsbl 0x802633(%eax),%eax
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
  8003db:	ff 24 85 80 27 80 00 	jmp    *0x802780(,%eax,4)
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
  80049f:	8b 14 85 e0 28 80 00 	mov    0x8028e0(,%eax,4),%edx
  8004a6:	85 d2                	test   %edx,%edx
  8004a8:	75 18                	jne    8004c2 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8004aa:	50                   	push   %eax
  8004ab:	68 4b 26 80 00       	push   $0x80264b
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
  8004c3:	68 e5 2a 80 00       	push   $0x802ae5
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
  8004e7:	b8 44 26 80 00       	mov    $0x802644,%eax
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
  800b62:	68 3f 29 80 00       	push   $0x80293f
  800b67:	6a 23                	push   $0x23
  800b69:	68 5c 29 80 00       	push   $0x80295c
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
  800be3:	68 3f 29 80 00       	push   $0x80293f
  800be8:	6a 23                	push   $0x23
  800bea:	68 5c 29 80 00       	push   $0x80295c
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
  800c25:	68 3f 29 80 00       	push   $0x80293f
  800c2a:	6a 23                	push   $0x23
  800c2c:	68 5c 29 80 00       	push   $0x80295c
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
  800c67:	68 3f 29 80 00       	push   $0x80293f
  800c6c:	6a 23                	push   $0x23
  800c6e:	68 5c 29 80 00       	push   $0x80295c
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
  800ca9:	68 3f 29 80 00       	push   $0x80293f
  800cae:	6a 23                	push   $0x23
  800cb0:	68 5c 29 80 00       	push   $0x80295c
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
  800ceb:	68 3f 29 80 00       	push   $0x80293f
  800cf0:	6a 23                	push   $0x23
  800cf2:	68 5c 29 80 00       	push   $0x80295c
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
  800d2d:	68 3f 29 80 00       	push   $0x80293f
  800d32:	6a 23                	push   $0x23
  800d34:	68 5c 29 80 00       	push   $0x80295c
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
  800d91:	68 3f 29 80 00       	push   $0x80293f
  800d96:	6a 23                	push   $0x23
  800d98:	68 5c 29 80 00       	push   $0x80295c
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

00800daa <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800daa:	55                   	push   %ebp
  800dab:	89 e5                	mov    %esp,%ebp
  800dad:	57                   	push   %edi
  800dae:	56                   	push   %esi
  800daf:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800db0:	ba 00 00 00 00       	mov    $0x0,%edx
  800db5:	b8 0e 00 00 00       	mov    $0xe,%eax
  800dba:	89 d1                	mov    %edx,%ecx
  800dbc:	89 d3                	mov    %edx,%ebx
  800dbe:	89 d7                	mov    %edx,%edi
  800dc0:	89 d6                	mov    %edx,%esi
  800dc2:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800dc4:	5b                   	pop    %ebx
  800dc5:	5e                   	pop    %esi
  800dc6:	5f                   	pop    %edi
  800dc7:	5d                   	pop    %ebp
  800dc8:	c3                   	ret    

00800dc9 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800dc9:	55                   	push   %ebp
  800dca:	89 e5                	mov    %esp,%ebp
  800dcc:	56                   	push   %esi
  800dcd:	53                   	push   %ebx
  800dce:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800dd1:	8b 18                	mov    (%eax),%ebx
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.

	if ((err & FEC_WR) != FEC_WR && ((uvpt[PGNUM(addr)] & PTE_COW) != PTE_COW)) {
  800dd3:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800dd7:	75 25                	jne    800dfe <pgfault+0x35>
  800dd9:	89 d8                	mov    %ebx,%eax
  800ddb:	c1 e8 0c             	shr    $0xc,%eax
  800dde:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800de5:	f6 c4 08             	test   $0x8,%ah
  800de8:	75 14                	jne    800dfe <pgfault+0x35>
		panic("pgfault: not due to a write or a COW page");
  800dea:	83 ec 04             	sub    $0x4,%esp
  800ded:	68 6c 29 80 00       	push   $0x80296c
  800df2:	6a 1e                	push   $0x1e
  800df4:	68 00 2a 80 00       	push   $0x802a00
  800df9:	e8 5a f3 ff ff       	call   800158 <_panic>

	// LAB 4: Your code here.

	// panic("pgfault not implemented");

	addr = ROUNDDOWN(addr, PGSIZE);
  800dfe:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	envid_t envid = sys_getenvid();
  800e04:	e8 72 fd ff ff       	call   800b7b <sys_getenvid>
  800e09:	89 c6                	mov    %eax,%esi

	// envid = 0;

	// Allocate a new page, map it at a temporary location (PFTEMP)
	r = sys_page_alloc(envid, (void *)PFTEMP, PTE_U | PTE_P | PTE_W);
  800e0b:	83 ec 04             	sub    $0x4,%esp
  800e0e:	6a 07                	push   $0x7
  800e10:	68 00 f0 7f 00       	push   $0x7ff000
  800e15:	50                   	push   %eax
  800e16:	e8 9e fd ff ff       	call   800bb9 <sys_page_alloc>
	if (r < 0)
  800e1b:	83 c4 10             	add    $0x10,%esp
  800e1e:	85 c0                	test   %eax,%eax
  800e20:	79 12                	jns    800e34 <pgfault+0x6b>
		panic("pgfault: sys_page_alloc failed: %e\n", r);
  800e22:	50                   	push   %eax
  800e23:	68 98 29 80 00       	push   $0x802998
  800e28:	6a 33                	push   $0x33
  800e2a:	68 00 2a 80 00       	push   $0x802a00
  800e2f:	e8 24 f3 ff ff       	call   800158 <_panic>
	
	// copy the data from the old page to the new page
	memcpy((void *) PFTEMP, (const void *) addr, PGSIZE);
  800e34:	83 ec 04             	sub    $0x4,%esp
  800e37:	68 00 10 00 00       	push   $0x1000
  800e3c:	53                   	push   %ebx
  800e3d:	68 00 f0 7f 00       	push   $0x7ff000
  800e42:	e8 69 fb ff ff       	call   8009b0 <memcpy>

	// move the new page to the old page's address
	r = sys_page_map(envid, (void *) PFTEMP, envid, addr, PTE_U | PTE_P | PTE_W);
  800e47:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800e4e:	53                   	push   %ebx
  800e4f:	56                   	push   %esi
  800e50:	68 00 f0 7f 00       	push   $0x7ff000
  800e55:	56                   	push   %esi
  800e56:	e8 a1 fd ff ff       	call   800bfc <sys_page_map>
	if (r < 0)
  800e5b:	83 c4 20             	add    $0x20,%esp
  800e5e:	85 c0                	test   %eax,%eax
  800e60:	79 12                	jns    800e74 <pgfault+0xab>
		panic("pgfault: sys_page_map failed: %e\n", r);
  800e62:	50                   	push   %eax
  800e63:	68 bc 29 80 00       	push   $0x8029bc
  800e68:	6a 3b                	push   $0x3b
  800e6a:	68 00 2a 80 00       	push   $0x802a00
  800e6f:	e8 e4 f2 ff ff       	call   800158 <_panic>

	// unmap temporary region
	r = sys_page_unmap(envid, (void *) PFTEMP);
  800e74:	83 ec 08             	sub    $0x8,%esp
  800e77:	68 00 f0 7f 00       	push   $0x7ff000
  800e7c:	56                   	push   %esi
  800e7d:	e8 bc fd ff ff       	call   800c3e <sys_page_unmap>
	if (r < 0)
  800e82:	83 c4 10             	add    $0x10,%esp
  800e85:	85 c0                	test   %eax,%eax
  800e87:	79 12                	jns    800e9b <pgfault+0xd2>
        panic("pgfault: page unmap failed: %e\n", r);
  800e89:	50                   	push   %eax
  800e8a:	68 e0 29 80 00       	push   $0x8029e0
  800e8f:	6a 40                	push   $0x40
  800e91:	68 00 2a 80 00       	push   $0x802a00
  800e96:	e8 bd f2 ff ff       	call   800158 <_panic>
}
  800e9b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e9e:	5b                   	pop    %ebx
  800e9f:	5e                   	pop    %esi
  800ea0:	5d                   	pop    %ebp
  800ea1:	c3                   	ret    

00800ea2 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800ea2:	55                   	push   %ebp
  800ea3:	89 e5                	mov    %esp,%ebp
  800ea5:	57                   	push   %edi
  800ea6:	56                   	push   %esi
  800ea7:	53                   	push   %ebx
  800ea8:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	// cprintf("[fork]\n");
	int r;

	set_pgfault_handler(pgfault);
  800eab:	68 c9 0d 80 00       	push   $0x800dc9
  800eb0:	e8 dc 13 00 00       	call   802291 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800eb5:	b8 07 00 00 00       	mov    $0x7,%eax
  800eba:	cd 30                	int    $0x30

	envid_t envid = sys_exofork();
	if (envid < 0)
  800ebc:	83 c4 10             	add    $0x10,%esp
  800ebf:	85 c0                	test   %eax,%eax
  800ec1:	0f 88 64 01 00 00    	js     80102b <fork+0x189>
  800ec7:	bb 00 00 80 00       	mov    $0x800000,%ebx
  800ecc:	be 00 08 00 00       	mov    $0x800,%esi
		return envid;

	// fix "thisenv" in the child process
	if (envid == 0) {
  800ed1:	85 c0                	test   %eax,%eax
  800ed3:	75 21                	jne    800ef6 <fork+0x54>
		thisenv = &envs[ENVX(sys_getenvid())];
  800ed5:	e8 a1 fc ff ff       	call   800b7b <sys_getenvid>
  800eda:	25 ff 03 00 00       	and    $0x3ff,%eax
  800edf:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800ee2:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800ee7:	a3 08 40 80 00       	mov    %eax,0x804008
        return 0;
  800eec:	ba 00 00 00 00       	mov    $0x0,%edx
  800ef1:	e9 3f 01 00 00       	jmp    801035 <fork+0x193>
  800ef6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800ef9:	89 c7                	mov    %eax,%edi
	for (uint32_t pn = PGNUM(UTEXT); pn < PGNUM(USTACKTOP); pn++) {

		addr = pn * PGSIZE;

		// if level-2 page exists
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P) {
  800efb:	89 d8                	mov    %ebx,%eax
  800efd:	c1 e8 16             	shr    $0x16,%eax
  800f00:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f07:	a8 01                	test   $0x1,%al
  800f09:	0f 84 bd 00 00 00    	je     800fcc <fork+0x12a>
			
			// if real PTE exists
			if ((uvpt[PGNUM(addr)] & PTE_P) == PTE_P) {
  800f0f:	89 d8                	mov    %ebx,%eax
  800f11:	c1 e8 0c             	shr    $0xc,%eax
  800f14:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f1b:	f6 c2 01             	test   $0x1,%dl
  800f1e:	0f 84 a8 00 00 00    	je     800fcc <fork+0x12a>

				// For each writable or copy-on-write page
				// if ((uvpt[PGNUM(addr)] & (PTE_W | PTE_COW)) != 0) {
				if ((uvpt[PGNUM(addr)] & PTE_U) != 0) {
  800f24:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f2b:	a8 04                	test   $0x4,%al
  800f2d:	0f 84 99 00 00 00    	je     800fcc <fork+0x12a>
	// r = envid2env(envid, &env, 1);
	// if (r < 0)
	// 	return r;	// E_BAD_ENV
	// envid_t parent_envid = env->env_parent_id;

	if (uvpt[pn] & PTE_SHARE) {
  800f33:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800f3a:	f6 c4 04             	test   $0x4,%ah
  800f3d:	74 17                	je     800f56 <fork+0xb4>
		sys_page_map(0, (void *)va, envid, (void *)va, PTE_SYSCALL);
  800f3f:	83 ec 0c             	sub    $0xc,%esp
  800f42:	68 07 0e 00 00       	push   $0xe07
  800f47:	53                   	push   %ebx
  800f48:	57                   	push   %edi
  800f49:	53                   	push   %ebx
  800f4a:	6a 00                	push   $0x0
  800f4c:	e8 ab fc ff ff       	call   800bfc <sys_page_map>
  800f51:	83 c4 20             	add    $0x20,%esp
  800f54:	eb 76                	jmp    800fcc <fork+0x12a>
	}
	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {
  800f56:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800f5d:	a8 02                	test   $0x2,%al
  800f5f:	75 0c                	jne    800f6d <fork+0xcb>
  800f61:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800f68:	f6 c4 08             	test   $0x8,%ah
  800f6b:	74 3f                	je     800fac <fork+0x10a>

		// map the page copy-on-write into the address space of the child
        r = sys_page_map(0, (void *)va, envid, (void *)va, PTE_P|PTE_U|PTE_COW);
  800f6d:	83 ec 0c             	sub    $0xc,%esp
  800f70:	68 05 08 00 00       	push   $0x805
  800f75:	53                   	push   %ebx
  800f76:	57                   	push   %edi
  800f77:	53                   	push   %ebx
  800f78:	6a 00                	push   $0x0
  800f7a:	e8 7d fc ff ff       	call   800bfc <sys_page_map>
		if (r < 0)
  800f7f:	83 c4 20             	add    $0x20,%esp
  800f82:	85 c0                	test   %eax,%eax
  800f84:	0f 88 a5 00 00 00    	js     80102f <fork+0x18d>
            return r;

		// remap the page copy-on-write in its own(parent) address space
        r = sys_page_map(0, (void *)va, 0, (void *)va, PTE_P|PTE_U|PTE_COW);
  800f8a:	83 ec 0c             	sub    $0xc,%esp
  800f8d:	68 05 08 00 00       	push   $0x805
  800f92:	53                   	push   %ebx
  800f93:	6a 00                	push   $0x0
  800f95:	53                   	push   %ebx
  800f96:	6a 00                	push   $0x0
  800f98:	e8 5f fc ff ff       	call   800bfc <sys_page_map>
  800f9d:	83 c4 20             	add    $0x20,%esp
  800fa0:	85 c0                	test   %eax,%eax
  800fa2:	b9 00 00 00 00       	mov    $0x0,%ecx
  800fa7:	0f 4f c1             	cmovg  %ecx,%eax
  800faa:	eb 1c                	jmp    800fc8 <fork+0x126>
		if (r < 0)
            return r;
    }
    else {
        r = sys_page_map(0, (void *)va, envid, (void *)va, PTE_P|PTE_U);
  800fac:	83 ec 0c             	sub    $0xc,%esp
  800faf:	6a 05                	push   $0x5
  800fb1:	53                   	push   %ebx
  800fb2:	57                   	push   %edi
  800fb3:	53                   	push   %ebx
  800fb4:	6a 00                	push   $0x0
  800fb6:	e8 41 fc ff ff       	call   800bfc <sys_page_map>
  800fbb:	83 c4 20             	add    $0x20,%esp
  800fbe:	85 c0                	test   %eax,%eax
  800fc0:	b9 00 00 00 00       	mov    $0x0,%ecx
  800fc5:	0f 4f c1             	cmovg  %ecx,%eax

				// For each writable or copy-on-write page
				// if ((uvpt[PGNUM(addr)] & (PTE_W | PTE_COW)) != 0) {
				if ((uvpt[PGNUM(addr)] & PTE_U) != 0) {
					r = duppage(envid, pn);
					if (r < 0)
  800fc8:	85 c0                	test   %eax,%eax
  800fca:	78 67                	js     801033 <fork+0x191>
        return 0;
	}

	// For each writable or copy-on-write page in its address space below UTOP, the parent calls duppage
	uint32_t addr;
	for (uint32_t pn = PGNUM(UTEXT); pn < PGNUM(USTACKTOP); pn++) {
  800fcc:	83 c6 01             	add    $0x1,%esi
  800fcf:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  800fd5:	81 fe fe eb 0e 00    	cmp    $0xeebfe,%esi
  800fdb:	0f 85 1a ff ff ff    	jne    800efb <fork+0x59>
  800fe1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
		}
	}

	// allocate a fresh page in the child for the exception stack
	r = sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U | PTE_P | PTE_W);
  800fe4:	83 ec 04             	sub    $0x4,%esp
  800fe7:	6a 07                	push   $0x7
  800fe9:	68 00 f0 bf ee       	push   $0xeebff000
  800fee:	57                   	push   %edi
  800fef:	e8 c5 fb ff ff       	call   800bb9 <sys_page_alloc>
	if (r < 0)
  800ff4:	83 c4 10             	add    $0x10,%esp
		return r;
  800ff7:	89 c2                	mov    %eax,%edx
		}
	}

	// allocate a fresh page in the child for the exception stack
	r = sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U | PTE_P | PTE_W);
	if (r < 0)
  800ff9:	85 c0                	test   %eax,%eax
  800ffb:	78 38                	js     801035 <fork+0x193>
		return r;

	// The parent sets the user page fault entrypoint for the child to look like its own
	extern void _pgfault_upcall(void);
	r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  800ffd:	83 ec 08             	sub    $0x8,%esp
  801000:	68 d8 22 80 00       	push   $0x8022d8
  801005:	57                   	push   %edi
  801006:	e8 f9 fc ff ff       	call   800d04 <sys_env_set_pgfault_upcall>
	if (r < 0)
  80100b:	83 c4 10             	add    $0x10,%esp
		return r;
  80100e:	89 c2                	mov    %eax,%edx
		return r;

	// The parent sets the user page fault entrypoint for the child to look like its own
	extern void _pgfault_upcall(void);
	r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
	if (r < 0)
  801010:	85 c0                	test   %eax,%eax
  801012:	78 21                	js     801035 <fork+0x193>
		return r;

	// The child is now ready to run, so the parent marks it runnable
	r = sys_env_set_status(envid, ENV_RUNNABLE);
  801014:	83 ec 08             	sub    $0x8,%esp
  801017:	6a 02                	push   $0x2
  801019:	57                   	push   %edi
  80101a:	e8 61 fc ff ff       	call   800c80 <sys_env_set_status>
	if (r < 0)
  80101f:	83 c4 10             	add    $0x10,%esp
		return r;

	return envid;
  801022:	85 c0                	test   %eax,%eax
  801024:	0f 48 f8             	cmovs  %eax,%edi
  801027:	89 fa                	mov    %edi,%edx
  801029:	eb 0a                	jmp    801035 <fork+0x193>

	set_pgfault_handler(pgfault);

	envid_t envid = sys_exofork();
	if (envid < 0)
		return envid;
  80102b:	89 c2                	mov    %eax,%edx
  80102d:	eb 06                	jmp    801035 <fork+0x193>
		sys_page_map(0, (void *)va, envid, (void *)va, PTE_SYSCALL);
	}
	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {

		// map the page copy-on-write into the address space of the child
        r = sys_page_map(0, (void *)va, envid, (void *)va, PTE_P|PTE_U|PTE_COW);
  80102f:	89 c2                	mov    %eax,%edx
  801031:	eb 02                	jmp    801035 <fork+0x193>
  801033:	89 c2                	mov    %eax,%edx
	if (r < 0)
		return r;

	return envid;
	// panic("fork not implemented");
}
  801035:	89 d0                	mov    %edx,%eax
  801037:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80103a:	5b                   	pop    %ebx
  80103b:	5e                   	pop    %esi
  80103c:	5f                   	pop    %edi
  80103d:	5d                   	pop    %ebp
  80103e:	c3                   	ret    

0080103f <sfork>:

// Challenge!
int
sfork(void)
{
  80103f:	55                   	push   %ebp
  801040:	89 e5                	mov    %esp,%ebp
  801042:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801045:	68 0b 2a 80 00       	push   $0x802a0b
  80104a:	68 c9 00 00 00       	push   $0xc9
  80104f:	68 00 2a 80 00       	push   $0x802a00
  801054:	e8 ff f0 ff ff       	call   800158 <_panic>

00801059 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801059:	55                   	push   %ebp
  80105a:	89 e5                	mov    %esp,%ebp
  80105c:	56                   	push   %esi
  80105d:	53                   	push   %ebx
  80105e:	8b 75 08             	mov    0x8(%ebp),%esi
  801061:	8b 45 0c             	mov    0xc(%ebp),%eax
  801064:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");

	// don't want to recv page
	if (pg == NULL)
  801067:	85 c0                	test   %eax,%eax
		pg = (void *)UTOP;
  801069:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  80106e:	0f 44 c2             	cmove  %edx,%eax

	int err = sys_ipc_recv(pg);
  801071:	83 ec 0c             	sub    $0xc,%esp
  801074:	50                   	push   %eax
  801075:	e8 ef fc ff ff       	call   800d69 <sys_ipc_recv>

	if (from_env_store != NULL)
  80107a:	83 c4 10             	add    $0x10,%esp
  80107d:	85 f6                	test   %esi,%esi
  80107f:	74 14                	je     801095 <ipc_recv+0x3c>
		*from_env_store = err < 0? 0 : thisenv->env_ipc_from;
  801081:	ba 00 00 00 00       	mov    $0x0,%edx
  801086:	85 c0                	test   %eax,%eax
  801088:	78 09                	js     801093 <ipc_recv+0x3a>
  80108a:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801090:	8b 52 74             	mov    0x74(%edx),%edx
  801093:	89 16                	mov    %edx,(%esi)
	
	if (perm_store != NULL)
  801095:	85 db                	test   %ebx,%ebx
  801097:	74 14                	je     8010ad <ipc_recv+0x54>
		*perm_store = err < 0? 0 : thisenv->env_ipc_perm;
  801099:	ba 00 00 00 00       	mov    $0x0,%edx
  80109e:	85 c0                	test   %eax,%eax
  8010a0:	78 09                	js     8010ab <ipc_recv+0x52>
  8010a2:	8b 15 08 40 80 00    	mov    0x804008,%edx
  8010a8:	8b 52 78             	mov    0x78(%edx),%edx
  8010ab:	89 13                	mov    %edx,(%ebx)

	if (err < 0)
  8010ad:	85 c0                	test   %eax,%eax
  8010af:	78 08                	js     8010b9 <ipc_recv+0x60>
		return err;
	return thisenv->env_ipc_value;
  8010b1:	a1 08 40 80 00       	mov    0x804008,%eax
  8010b6:	8b 40 70             	mov    0x70(%eax),%eax
}
  8010b9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8010bc:	5b                   	pop    %ebx
  8010bd:	5e                   	pop    %esi
  8010be:	5d                   	pop    %ebp
  8010bf:	c3                   	ret    

008010c0 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8010c0:	55                   	push   %ebp
  8010c1:	89 e5                	mov    %esp,%ebp
  8010c3:	57                   	push   %edi
  8010c4:	56                   	push   %esi
  8010c5:	53                   	push   %ebx
  8010c6:	83 ec 0c             	sub    $0xc,%esp
  8010c9:	8b 7d 08             	mov    0x8(%ebp),%edi
  8010cc:	8b 75 0c             	mov    0xc(%ebp),%esi
  8010cf:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");

	// don't want to send page
	if (pg == NULL)
  8010d2:	85 db                	test   %ebx,%ebx
		pg = (void *)UTOP;
  8010d4:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  8010d9:	0f 44 d8             	cmove  %eax,%ebx
	
	int err = 0;
	
	do {

		err = sys_ipc_try_send(to_env, val, pg, perm);
  8010dc:	ff 75 14             	pushl  0x14(%ebp)
  8010df:	53                   	push   %ebx
  8010e0:	56                   	push   %esi
  8010e1:	57                   	push   %edi
  8010e2:	e8 5f fc ff ff       	call   800d46 <sys_ipc_try_send>

		if (err < 0) {
  8010e7:	83 c4 10             	add    $0x10,%esp
  8010ea:	85 c0                	test   %eax,%eax
  8010ec:	79 1e                	jns    80110c <ipc_send+0x4c>
			if (err == -E_IPC_NOT_RECV)
  8010ee:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8010f1:	75 07                	jne    8010fa <ipc_send+0x3a>
				sys_yield();
  8010f3:	e8 a2 fa ff ff       	call   800b9a <sys_yield>
  8010f8:	eb e2                	jmp    8010dc <ipc_send+0x1c>
			else 
				panic("ipc_send: %e", err);
  8010fa:	50                   	push   %eax
  8010fb:	68 21 2a 80 00       	push   $0x802a21
  801100:	6a 49                	push   $0x49
  801102:	68 2e 2a 80 00       	push   $0x802a2e
  801107:	e8 4c f0 ff ff       	call   800158 <_panic>
		}

	} while (err < 0);

}
  80110c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80110f:	5b                   	pop    %ebx
  801110:	5e                   	pop    %esi
  801111:	5f                   	pop    %edi
  801112:	5d                   	pop    %ebp
  801113:	c3                   	ret    

00801114 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801114:	55                   	push   %ebp
  801115:	89 e5                	mov    %esp,%ebp
  801117:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80111a:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80111f:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801122:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801128:	8b 52 50             	mov    0x50(%edx),%edx
  80112b:	39 ca                	cmp    %ecx,%edx
  80112d:	75 0d                	jne    80113c <ipc_find_env+0x28>
			return envs[i].env_id;
  80112f:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801132:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801137:	8b 40 48             	mov    0x48(%eax),%eax
  80113a:	eb 0f                	jmp    80114b <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80113c:	83 c0 01             	add    $0x1,%eax
  80113f:	3d 00 04 00 00       	cmp    $0x400,%eax
  801144:	75 d9                	jne    80111f <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801146:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80114b:	5d                   	pop    %ebp
  80114c:	c3                   	ret    

0080114d <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80114d:	55                   	push   %ebp
  80114e:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801150:	8b 45 08             	mov    0x8(%ebp),%eax
  801153:	05 00 00 00 30       	add    $0x30000000,%eax
  801158:	c1 e8 0c             	shr    $0xc,%eax
}
  80115b:	5d                   	pop    %ebp
  80115c:	c3                   	ret    

0080115d <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80115d:	55                   	push   %ebp
  80115e:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801160:	8b 45 08             	mov    0x8(%ebp),%eax
  801163:	05 00 00 00 30       	add    $0x30000000,%eax
  801168:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80116d:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801172:	5d                   	pop    %ebp
  801173:	c3                   	ret    

00801174 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801174:	55                   	push   %ebp
  801175:	89 e5                	mov    %esp,%ebp
  801177:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80117a:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80117f:	89 c2                	mov    %eax,%edx
  801181:	c1 ea 16             	shr    $0x16,%edx
  801184:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80118b:	f6 c2 01             	test   $0x1,%dl
  80118e:	74 11                	je     8011a1 <fd_alloc+0x2d>
  801190:	89 c2                	mov    %eax,%edx
  801192:	c1 ea 0c             	shr    $0xc,%edx
  801195:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80119c:	f6 c2 01             	test   $0x1,%dl
  80119f:	75 09                	jne    8011aa <fd_alloc+0x36>
			*fd_store = fd;
  8011a1:	89 01                	mov    %eax,(%ecx)
			return 0;
  8011a3:	b8 00 00 00 00       	mov    $0x0,%eax
  8011a8:	eb 17                	jmp    8011c1 <fd_alloc+0x4d>
  8011aa:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8011af:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8011b4:	75 c9                	jne    80117f <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8011b6:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8011bc:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8011c1:	5d                   	pop    %ebp
  8011c2:	c3                   	ret    

008011c3 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8011c3:	55                   	push   %ebp
  8011c4:	89 e5                	mov    %esp,%ebp
  8011c6:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8011c9:	83 f8 1f             	cmp    $0x1f,%eax
  8011cc:	77 36                	ja     801204 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8011ce:	c1 e0 0c             	shl    $0xc,%eax
  8011d1:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8011d6:	89 c2                	mov    %eax,%edx
  8011d8:	c1 ea 16             	shr    $0x16,%edx
  8011db:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8011e2:	f6 c2 01             	test   $0x1,%dl
  8011e5:	74 24                	je     80120b <fd_lookup+0x48>
  8011e7:	89 c2                	mov    %eax,%edx
  8011e9:	c1 ea 0c             	shr    $0xc,%edx
  8011ec:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8011f3:	f6 c2 01             	test   $0x1,%dl
  8011f6:	74 1a                	je     801212 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8011f8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011fb:	89 02                	mov    %eax,(%edx)
	return 0;
  8011fd:	b8 00 00 00 00       	mov    $0x0,%eax
  801202:	eb 13                	jmp    801217 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801204:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801209:	eb 0c                	jmp    801217 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80120b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801210:	eb 05                	jmp    801217 <fd_lookup+0x54>
  801212:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801217:	5d                   	pop    %ebp
  801218:	c3                   	ret    

00801219 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801219:	55                   	push   %ebp
  80121a:	89 e5                	mov    %esp,%ebp
  80121c:	83 ec 08             	sub    $0x8,%esp
  80121f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801222:	ba b8 2a 80 00       	mov    $0x802ab8,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801227:	eb 13                	jmp    80123c <dev_lookup+0x23>
  801229:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80122c:	39 08                	cmp    %ecx,(%eax)
  80122e:	75 0c                	jne    80123c <dev_lookup+0x23>
			*dev = devtab[i];
  801230:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801233:	89 01                	mov    %eax,(%ecx)
			return 0;
  801235:	b8 00 00 00 00       	mov    $0x0,%eax
  80123a:	eb 2e                	jmp    80126a <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80123c:	8b 02                	mov    (%edx),%eax
  80123e:	85 c0                	test   %eax,%eax
  801240:	75 e7                	jne    801229 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801242:	a1 08 40 80 00       	mov    0x804008,%eax
  801247:	8b 40 48             	mov    0x48(%eax),%eax
  80124a:	83 ec 04             	sub    $0x4,%esp
  80124d:	51                   	push   %ecx
  80124e:	50                   	push   %eax
  80124f:	68 38 2a 80 00       	push   $0x802a38
  801254:	e8 d8 ef ff ff       	call   800231 <cprintf>
	*dev = 0;
  801259:	8b 45 0c             	mov    0xc(%ebp),%eax
  80125c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801262:	83 c4 10             	add    $0x10,%esp
  801265:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80126a:	c9                   	leave  
  80126b:	c3                   	ret    

0080126c <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80126c:	55                   	push   %ebp
  80126d:	89 e5                	mov    %esp,%ebp
  80126f:	56                   	push   %esi
  801270:	53                   	push   %ebx
  801271:	83 ec 10             	sub    $0x10,%esp
  801274:	8b 75 08             	mov    0x8(%ebp),%esi
  801277:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80127a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80127d:	50                   	push   %eax
  80127e:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801284:	c1 e8 0c             	shr    $0xc,%eax
  801287:	50                   	push   %eax
  801288:	e8 36 ff ff ff       	call   8011c3 <fd_lookup>
  80128d:	83 c4 08             	add    $0x8,%esp
  801290:	85 c0                	test   %eax,%eax
  801292:	78 05                	js     801299 <fd_close+0x2d>
	    || fd != fd2)
  801294:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801297:	74 0c                	je     8012a5 <fd_close+0x39>
		return (must_exist ? r : 0);
  801299:	84 db                	test   %bl,%bl
  80129b:	ba 00 00 00 00       	mov    $0x0,%edx
  8012a0:	0f 44 c2             	cmove  %edx,%eax
  8012a3:	eb 41                	jmp    8012e6 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8012a5:	83 ec 08             	sub    $0x8,%esp
  8012a8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012ab:	50                   	push   %eax
  8012ac:	ff 36                	pushl  (%esi)
  8012ae:	e8 66 ff ff ff       	call   801219 <dev_lookup>
  8012b3:	89 c3                	mov    %eax,%ebx
  8012b5:	83 c4 10             	add    $0x10,%esp
  8012b8:	85 c0                	test   %eax,%eax
  8012ba:	78 1a                	js     8012d6 <fd_close+0x6a>
		if (dev->dev_close)
  8012bc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012bf:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8012c2:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8012c7:	85 c0                	test   %eax,%eax
  8012c9:	74 0b                	je     8012d6 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8012cb:	83 ec 0c             	sub    $0xc,%esp
  8012ce:	56                   	push   %esi
  8012cf:	ff d0                	call   *%eax
  8012d1:	89 c3                	mov    %eax,%ebx
  8012d3:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8012d6:	83 ec 08             	sub    $0x8,%esp
  8012d9:	56                   	push   %esi
  8012da:	6a 00                	push   $0x0
  8012dc:	e8 5d f9 ff ff       	call   800c3e <sys_page_unmap>
	return r;
  8012e1:	83 c4 10             	add    $0x10,%esp
  8012e4:	89 d8                	mov    %ebx,%eax
}
  8012e6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012e9:	5b                   	pop    %ebx
  8012ea:	5e                   	pop    %esi
  8012eb:	5d                   	pop    %ebp
  8012ec:	c3                   	ret    

008012ed <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8012ed:	55                   	push   %ebp
  8012ee:	89 e5                	mov    %esp,%ebp
  8012f0:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8012f3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012f6:	50                   	push   %eax
  8012f7:	ff 75 08             	pushl  0x8(%ebp)
  8012fa:	e8 c4 fe ff ff       	call   8011c3 <fd_lookup>
  8012ff:	83 c4 08             	add    $0x8,%esp
  801302:	85 c0                	test   %eax,%eax
  801304:	78 10                	js     801316 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801306:	83 ec 08             	sub    $0x8,%esp
  801309:	6a 01                	push   $0x1
  80130b:	ff 75 f4             	pushl  -0xc(%ebp)
  80130e:	e8 59 ff ff ff       	call   80126c <fd_close>
  801313:	83 c4 10             	add    $0x10,%esp
}
  801316:	c9                   	leave  
  801317:	c3                   	ret    

00801318 <close_all>:

void
close_all(void)
{
  801318:	55                   	push   %ebp
  801319:	89 e5                	mov    %esp,%ebp
  80131b:	53                   	push   %ebx
  80131c:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80131f:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801324:	83 ec 0c             	sub    $0xc,%esp
  801327:	53                   	push   %ebx
  801328:	e8 c0 ff ff ff       	call   8012ed <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80132d:	83 c3 01             	add    $0x1,%ebx
  801330:	83 c4 10             	add    $0x10,%esp
  801333:	83 fb 20             	cmp    $0x20,%ebx
  801336:	75 ec                	jne    801324 <close_all+0xc>
		close(i);
}
  801338:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80133b:	c9                   	leave  
  80133c:	c3                   	ret    

0080133d <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80133d:	55                   	push   %ebp
  80133e:	89 e5                	mov    %esp,%ebp
  801340:	57                   	push   %edi
  801341:	56                   	push   %esi
  801342:	53                   	push   %ebx
  801343:	83 ec 2c             	sub    $0x2c,%esp
  801346:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801349:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80134c:	50                   	push   %eax
  80134d:	ff 75 08             	pushl  0x8(%ebp)
  801350:	e8 6e fe ff ff       	call   8011c3 <fd_lookup>
  801355:	83 c4 08             	add    $0x8,%esp
  801358:	85 c0                	test   %eax,%eax
  80135a:	0f 88 c1 00 00 00    	js     801421 <dup+0xe4>
		return r;
	close(newfdnum);
  801360:	83 ec 0c             	sub    $0xc,%esp
  801363:	56                   	push   %esi
  801364:	e8 84 ff ff ff       	call   8012ed <close>

	newfd = INDEX2FD(newfdnum);
  801369:	89 f3                	mov    %esi,%ebx
  80136b:	c1 e3 0c             	shl    $0xc,%ebx
  80136e:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801374:	83 c4 04             	add    $0x4,%esp
  801377:	ff 75 e4             	pushl  -0x1c(%ebp)
  80137a:	e8 de fd ff ff       	call   80115d <fd2data>
  80137f:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801381:	89 1c 24             	mov    %ebx,(%esp)
  801384:	e8 d4 fd ff ff       	call   80115d <fd2data>
  801389:	83 c4 10             	add    $0x10,%esp
  80138c:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80138f:	89 f8                	mov    %edi,%eax
  801391:	c1 e8 16             	shr    $0x16,%eax
  801394:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80139b:	a8 01                	test   $0x1,%al
  80139d:	74 37                	je     8013d6 <dup+0x99>
  80139f:	89 f8                	mov    %edi,%eax
  8013a1:	c1 e8 0c             	shr    $0xc,%eax
  8013a4:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8013ab:	f6 c2 01             	test   $0x1,%dl
  8013ae:	74 26                	je     8013d6 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8013b0:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8013b7:	83 ec 0c             	sub    $0xc,%esp
  8013ba:	25 07 0e 00 00       	and    $0xe07,%eax
  8013bf:	50                   	push   %eax
  8013c0:	ff 75 d4             	pushl  -0x2c(%ebp)
  8013c3:	6a 00                	push   $0x0
  8013c5:	57                   	push   %edi
  8013c6:	6a 00                	push   $0x0
  8013c8:	e8 2f f8 ff ff       	call   800bfc <sys_page_map>
  8013cd:	89 c7                	mov    %eax,%edi
  8013cf:	83 c4 20             	add    $0x20,%esp
  8013d2:	85 c0                	test   %eax,%eax
  8013d4:	78 2e                	js     801404 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8013d6:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8013d9:	89 d0                	mov    %edx,%eax
  8013db:	c1 e8 0c             	shr    $0xc,%eax
  8013de:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8013e5:	83 ec 0c             	sub    $0xc,%esp
  8013e8:	25 07 0e 00 00       	and    $0xe07,%eax
  8013ed:	50                   	push   %eax
  8013ee:	53                   	push   %ebx
  8013ef:	6a 00                	push   $0x0
  8013f1:	52                   	push   %edx
  8013f2:	6a 00                	push   $0x0
  8013f4:	e8 03 f8 ff ff       	call   800bfc <sys_page_map>
  8013f9:	89 c7                	mov    %eax,%edi
  8013fb:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8013fe:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801400:	85 ff                	test   %edi,%edi
  801402:	79 1d                	jns    801421 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801404:	83 ec 08             	sub    $0x8,%esp
  801407:	53                   	push   %ebx
  801408:	6a 00                	push   $0x0
  80140a:	e8 2f f8 ff ff       	call   800c3e <sys_page_unmap>
	sys_page_unmap(0, nva);
  80140f:	83 c4 08             	add    $0x8,%esp
  801412:	ff 75 d4             	pushl  -0x2c(%ebp)
  801415:	6a 00                	push   $0x0
  801417:	e8 22 f8 ff ff       	call   800c3e <sys_page_unmap>
	return r;
  80141c:	83 c4 10             	add    $0x10,%esp
  80141f:	89 f8                	mov    %edi,%eax
}
  801421:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801424:	5b                   	pop    %ebx
  801425:	5e                   	pop    %esi
  801426:	5f                   	pop    %edi
  801427:	5d                   	pop    %ebp
  801428:	c3                   	ret    

00801429 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801429:	55                   	push   %ebp
  80142a:	89 e5                	mov    %esp,%ebp
  80142c:	53                   	push   %ebx
  80142d:	83 ec 14             	sub    $0x14,%esp
  801430:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801433:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801436:	50                   	push   %eax
  801437:	53                   	push   %ebx
  801438:	e8 86 fd ff ff       	call   8011c3 <fd_lookup>
  80143d:	83 c4 08             	add    $0x8,%esp
  801440:	89 c2                	mov    %eax,%edx
  801442:	85 c0                	test   %eax,%eax
  801444:	78 6d                	js     8014b3 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801446:	83 ec 08             	sub    $0x8,%esp
  801449:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80144c:	50                   	push   %eax
  80144d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801450:	ff 30                	pushl  (%eax)
  801452:	e8 c2 fd ff ff       	call   801219 <dev_lookup>
  801457:	83 c4 10             	add    $0x10,%esp
  80145a:	85 c0                	test   %eax,%eax
  80145c:	78 4c                	js     8014aa <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80145e:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801461:	8b 42 08             	mov    0x8(%edx),%eax
  801464:	83 e0 03             	and    $0x3,%eax
  801467:	83 f8 01             	cmp    $0x1,%eax
  80146a:	75 21                	jne    80148d <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80146c:	a1 08 40 80 00       	mov    0x804008,%eax
  801471:	8b 40 48             	mov    0x48(%eax),%eax
  801474:	83 ec 04             	sub    $0x4,%esp
  801477:	53                   	push   %ebx
  801478:	50                   	push   %eax
  801479:	68 7c 2a 80 00       	push   $0x802a7c
  80147e:	e8 ae ed ff ff       	call   800231 <cprintf>
		return -E_INVAL;
  801483:	83 c4 10             	add    $0x10,%esp
  801486:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80148b:	eb 26                	jmp    8014b3 <read+0x8a>
	}
	if (!dev->dev_read)
  80148d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801490:	8b 40 08             	mov    0x8(%eax),%eax
  801493:	85 c0                	test   %eax,%eax
  801495:	74 17                	je     8014ae <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801497:	83 ec 04             	sub    $0x4,%esp
  80149a:	ff 75 10             	pushl  0x10(%ebp)
  80149d:	ff 75 0c             	pushl  0xc(%ebp)
  8014a0:	52                   	push   %edx
  8014a1:	ff d0                	call   *%eax
  8014a3:	89 c2                	mov    %eax,%edx
  8014a5:	83 c4 10             	add    $0x10,%esp
  8014a8:	eb 09                	jmp    8014b3 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014aa:	89 c2                	mov    %eax,%edx
  8014ac:	eb 05                	jmp    8014b3 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8014ae:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8014b3:	89 d0                	mov    %edx,%eax
  8014b5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014b8:	c9                   	leave  
  8014b9:	c3                   	ret    

008014ba <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8014ba:	55                   	push   %ebp
  8014bb:	89 e5                	mov    %esp,%ebp
  8014bd:	57                   	push   %edi
  8014be:	56                   	push   %esi
  8014bf:	53                   	push   %ebx
  8014c0:	83 ec 0c             	sub    $0xc,%esp
  8014c3:	8b 7d 08             	mov    0x8(%ebp),%edi
  8014c6:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8014c9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8014ce:	eb 21                	jmp    8014f1 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8014d0:	83 ec 04             	sub    $0x4,%esp
  8014d3:	89 f0                	mov    %esi,%eax
  8014d5:	29 d8                	sub    %ebx,%eax
  8014d7:	50                   	push   %eax
  8014d8:	89 d8                	mov    %ebx,%eax
  8014da:	03 45 0c             	add    0xc(%ebp),%eax
  8014dd:	50                   	push   %eax
  8014de:	57                   	push   %edi
  8014df:	e8 45 ff ff ff       	call   801429 <read>
		if (m < 0)
  8014e4:	83 c4 10             	add    $0x10,%esp
  8014e7:	85 c0                	test   %eax,%eax
  8014e9:	78 10                	js     8014fb <readn+0x41>
			return m;
		if (m == 0)
  8014eb:	85 c0                	test   %eax,%eax
  8014ed:	74 0a                	je     8014f9 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8014ef:	01 c3                	add    %eax,%ebx
  8014f1:	39 f3                	cmp    %esi,%ebx
  8014f3:	72 db                	jb     8014d0 <readn+0x16>
  8014f5:	89 d8                	mov    %ebx,%eax
  8014f7:	eb 02                	jmp    8014fb <readn+0x41>
  8014f9:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8014fb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014fe:	5b                   	pop    %ebx
  8014ff:	5e                   	pop    %esi
  801500:	5f                   	pop    %edi
  801501:	5d                   	pop    %ebp
  801502:	c3                   	ret    

00801503 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801503:	55                   	push   %ebp
  801504:	89 e5                	mov    %esp,%ebp
  801506:	53                   	push   %ebx
  801507:	83 ec 14             	sub    $0x14,%esp
  80150a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80150d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801510:	50                   	push   %eax
  801511:	53                   	push   %ebx
  801512:	e8 ac fc ff ff       	call   8011c3 <fd_lookup>
  801517:	83 c4 08             	add    $0x8,%esp
  80151a:	89 c2                	mov    %eax,%edx
  80151c:	85 c0                	test   %eax,%eax
  80151e:	78 68                	js     801588 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801520:	83 ec 08             	sub    $0x8,%esp
  801523:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801526:	50                   	push   %eax
  801527:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80152a:	ff 30                	pushl  (%eax)
  80152c:	e8 e8 fc ff ff       	call   801219 <dev_lookup>
  801531:	83 c4 10             	add    $0x10,%esp
  801534:	85 c0                	test   %eax,%eax
  801536:	78 47                	js     80157f <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801538:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80153b:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80153f:	75 21                	jne    801562 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801541:	a1 08 40 80 00       	mov    0x804008,%eax
  801546:	8b 40 48             	mov    0x48(%eax),%eax
  801549:	83 ec 04             	sub    $0x4,%esp
  80154c:	53                   	push   %ebx
  80154d:	50                   	push   %eax
  80154e:	68 98 2a 80 00       	push   $0x802a98
  801553:	e8 d9 ec ff ff       	call   800231 <cprintf>
		return -E_INVAL;
  801558:	83 c4 10             	add    $0x10,%esp
  80155b:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801560:	eb 26                	jmp    801588 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801562:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801565:	8b 52 0c             	mov    0xc(%edx),%edx
  801568:	85 d2                	test   %edx,%edx
  80156a:	74 17                	je     801583 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80156c:	83 ec 04             	sub    $0x4,%esp
  80156f:	ff 75 10             	pushl  0x10(%ebp)
  801572:	ff 75 0c             	pushl  0xc(%ebp)
  801575:	50                   	push   %eax
  801576:	ff d2                	call   *%edx
  801578:	89 c2                	mov    %eax,%edx
  80157a:	83 c4 10             	add    $0x10,%esp
  80157d:	eb 09                	jmp    801588 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80157f:	89 c2                	mov    %eax,%edx
  801581:	eb 05                	jmp    801588 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801583:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801588:	89 d0                	mov    %edx,%eax
  80158a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80158d:	c9                   	leave  
  80158e:	c3                   	ret    

0080158f <seek>:

int
seek(int fdnum, off_t offset)
{
  80158f:	55                   	push   %ebp
  801590:	89 e5                	mov    %esp,%ebp
  801592:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801595:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801598:	50                   	push   %eax
  801599:	ff 75 08             	pushl  0x8(%ebp)
  80159c:	e8 22 fc ff ff       	call   8011c3 <fd_lookup>
  8015a1:	83 c4 08             	add    $0x8,%esp
  8015a4:	85 c0                	test   %eax,%eax
  8015a6:	78 0e                	js     8015b6 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8015a8:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8015ab:	8b 55 0c             	mov    0xc(%ebp),%edx
  8015ae:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8015b1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8015b6:	c9                   	leave  
  8015b7:	c3                   	ret    

008015b8 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8015b8:	55                   	push   %ebp
  8015b9:	89 e5                	mov    %esp,%ebp
  8015bb:	53                   	push   %ebx
  8015bc:	83 ec 14             	sub    $0x14,%esp
  8015bf:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015c2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015c5:	50                   	push   %eax
  8015c6:	53                   	push   %ebx
  8015c7:	e8 f7 fb ff ff       	call   8011c3 <fd_lookup>
  8015cc:	83 c4 08             	add    $0x8,%esp
  8015cf:	89 c2                	mov    %eax,%edx
  8015d1:	85 c0                	test   %eax,%eax
  8015d3:	78 65                	js     80163a <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015d5:	83 ec 08             	sub    $0x8,%esp
  8015d8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015db:	50                   	push   %eax
  8015dc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015df:	ff 30                	pushl  (%eax)
  8015e1:	e8 33 fc ff ff       	call   801219 <dev_lookup>
  8015e6:	83 c4 10             	add    $0x10,%esp
  8015e9:	85 c0                	test   %eax,%eax
  8015eb:	78 44                	js     801631 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8015ed:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015f0:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8015f4:	75 21                	jne    801617 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8015f6:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8015fb:	8b 40 48             	mov    0x48(%eax),%eax
  8015fe:	83 ec 04             	sub    $0x4,%esp
  801601:	53                   	push   %ebx
  801602:	50                   	push   %eax
  801603:	68 58 2a 80 00       	push   $0x802a58
  801608:	e8 24 ec ff ff       	call   800231 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80160d:	83 c4 10             	add    $0x10,%esp
  801610:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801615:	eb 23                	jmp    80163a <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801617:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80161a:	8b 52 18             	mov    0x18(%edx),%edx
  80161d:	85 d2                	test   %edx,%edx
  80161f:	74 14                	je     801635 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801621:	83 ec 08             	sub    $0x8,%esp
  801624:	ff 75 0c             	pushl  0xc(%ebp)
  801627:	50                   	push   %eax
  801628:	ff d2                	call   *%edx
  80162a:	89 c2                	mov    %eax,%edx
  80162c:	83 c4 10             	add    $0x10,%esp
  80162f:	eb 09                	jmp    80163a <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801631:	89 c2                	mov    %eax,%edx
  801633:	eb 05                	jmp    80163a <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801635:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  80163a:	89 d0                	mov    %edx,%eax
  80163c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80163f:	c9                   	leave  
  801640:	c3                   	ret    

00801641 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801641:	55                   	push   %ebp
  801642:	89 e5                	mov    %esp,%ebp
  801644:	53                   	push   %ebx
  801645:	83 ec 14             	sub    $0x14,%esp
  801648:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80164b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80164e:	50                   	push   %eax
  80164f:	ff 75 08             	pushl  0x8(%ebp)
  801652:	e8 6c fb ff ff       	call   8011c3 <fd_lookup>
  801657:	83 c4 08             	add    $0x8,%esp
  80165a:	89 c2                	mov    %eax,%edx
  80165c:	85 c0                	test   %eax,%eax
  80165e:	78 58                	js     8016b8 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801660:	83 ec 08             	sub    $0x8,%esp
  801663:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801666:	50                   	push   %eax
  801667:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80166a:	ff 30                	pushl  (%eax)
  80166c:	e8 a8 fb ff ff       	call   801219 <dev_lookup>
  801671:	83 c4 10             	add    $0x10,%esp
  801674:	85 c0                	test   %eax,%eax
  801676:	78 37                	js     8016af <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801678:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80167b:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80167f:	74 32                	je     8016b3 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801681:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801684:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80168b:	00 00 00 
	stat->st_isdir = 0;
  80168e:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801695:	00 00 00 
	stat->st_dev = dev;
  801698:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80169e:	83 ec 08             	sub    $0x8,%esp
  8016a1:	53                   	push   %ebx
  8016a2:	ff 75 f0             	pushl  -0x10(%ebp)
  8016a5:	ff 50 14             	call   *0x14(%eax)
  8016a8:	89 c2                	mov    %eax,%edx
  8016aa:	83 c4 10             	add    $0x10,%esp
  8016ad:	eb 09                	jmp    8016b8 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016af:	89 c2                	mov    %eax,%edx
  8016b1:	eb 05                	jmp    8016b8 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8016b3:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8016b8:	89 d0                	mov    %edx,%eax
  8016ba:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016bd:	c9                   	leave  
  8016be:	c3                   	ret    

008016bf <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8016bf:	55                   	push   %ebp
  8016c0:	89 e5                	mov    %esp,%ebp
  8016c2:	56                   	push   %esi
  8016c3:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8016c4:	83 ec 08             	sub    $0x8,%esp
  8016c7:	6a 00                	push   $0x0
  8016c9:	ff 75 08             	pushl  0x8(%ebp)
  8016cc:	e8 d6 01 00 00       	call   8018a7 <open>
  8016d1:	89 c3                	mov    %eax,%ebx
  8016d3:	83 c4 10             	add    $0x10,%esp
  8016d6:	85 c0                	test   %eax,%eax
  8016d8:	78 1b                	js     8016f5 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8016da:	83 ec 08             	sub    $0x8,%esp
  8016dd:	ff 75 0c             	pushl  0xc(%ebp)
  8016e0:	50                   	push   %eax
  8016e1:	e8 5b ff ff ff       	call   801641 <fstat>
  8016e6:	89 c6                	mov    %eax,%esi
	close(fd);
  8016e8:	89 1c 24             	mov    %ebx,(%esp)
  8016eb:	e8 fd fb ff ff       	call   8012ed <close>
	return r;
  8016f0:	83 c4 10             	add    $0x10,%esp
  8016f3:	89 f0                	mov    %esi,%eax
}
  8016f5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016f8:	5b                   	pop    %ebx
  8016f9:	5e                   	pop    %esi
  8016fa:	5d                   	pop    %ebp
  8016fb:	c3                   	ret    

008016fc <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8016fc:	55                   	push   %ebp
  8016fd:	89 e5                	mov    %esp,%ebp
  8016ff:	56                   	push   %esi
  801700:	53                   	push   %ebx
  801701:	89 c6                	mov    %eax,%esi
  801703:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801705:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80170c:	75 12                	jne    801720 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80170e:	83 ec 0c             	sub    $0xc,%esp
  801711:	6a 01                	push   $0x1
  801713:	e8 fc f9 ff ff       	call   801114 <ipc_find_env>
  801718:	a3 00 40 80 00       	mov    %eax,0x804000
  80171d:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801720:	6a 07                	push   $0x7
  801722:	68 00 50 80 00       	push   $0x805000
  801727:	56                   	push   %esi
  801728:	ff 35 00 40 80 00    	pushl  0x804000
  80172e:	e8 8d f9 ff ff       	call   8010c0 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801733:	83 c4 0c             	add    $0xc,%esp
  801736:	6a 00                	push   $0x0
  801738:	53                   	push   %ebx
  801739:	6a 00                	push   $0x0
  80173b:	e8 19 f9 ff ff       	call   801059 <ipc_recv>
}
  801740:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801743:	5b                   	pop    %ebx
  801744:	5e                   	pop    %esi
  801745:	5d                   	pop    %ebp
  801746:	c3                   	ret    

00801747 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801747:	55                   	push   %ebp
  801748:	89 e5                	mov    %esp,%ebp
  80174a:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80174d:	8b 45 08             	mov    0x8(%ebp),%eax
  801750:	8b 40 0c             	mov    0xc(%eax),%eax
  801753:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801758:	8b 45 0c             	mov    0xc(%ebp),%eax
  80175b:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801760:	ba 00 00 00 00       	mov    $0x0,%edx
  801765:	b8 02 00 00 00       	mov    $0x2,%eax
  80176a:	e8 8d ff ff ff       	call   8016fc <fsipc>
}
  80176f:	c9                   	leave  
  801770:	c3                   	ret    

00801771 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801771:	55                   	push   %ebp
  801772:	89 e5                	mov    %esp,%ebp
  801774:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801777:	8b 45 08             	mov    0x8(%ebp),%eax
  80177a:	8b 40 0c             	mov    0xc(%eax),%eax
  80177d:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801782:	ba 00 00 00 00       	mov    $0x0,%edx
  801787:	b8 06 00 00 00       	mov    $0x6,%eax
  80178c:	e8 6b ff ff ff       	call   8016fc <fsipc>
}
  801791:	c9                   	leave  
  801792:	c3                   	ret    

00801793 <devfile_stat>:

}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801793:	55                   	push   %ebp
  801794:	89 e5                	mov    %esp,%ebp
  801796:	53                   	push   %ebx
  801797:	83 ec 04             	sub    $0x4,%esp
  80179a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80179d:	8b 45 08             	mov    0x8(%ebp),%eax
  8017a0:	8b 40 0c             	mov    0xc(%eax),%eax
  8017a3:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8017a8:	ba 00 00 00 00       	mov    $0x0,%edx
  8017ad:	b8 05 00 00 00       	mov    $0x5,%eax
  8017b2:	e8 45 ff ff ff       	call   8016fc <fsipc>
  8017b7:	85 c0                	test   %eax,%eax
  8017b9:	78 2c                	js     8017e7 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8017bb:	83 ec 08             	sub    $0x8,%esp
  8017be:	68 00 50 80 00       	push   $0x805000
  8017c3:	53                   	push   %ebx
  8017c4:	e8 ed ef ff ff       	call   8007b6 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8017c9:	a1 80 50 80 00       	mov    0x805080,%eax
  8017ce:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8017d4:	a1 84 50 80 00       	mov    0x805084,%eax
  8017d9:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8017df:	83 c4 10             	add    $0x10,%esp
  8017e2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017e7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017ea:	c9                   	leave  
  8017eb:	c3                   	ret    

008017ec <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8017ec:	55                   	push   %ebp
  8017ed:	89 e5                	mov    %esp,%ebp
  8017ef:	83 ec 0c             	sub    $0xc,%esp
  8017f2:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	// panic("devfile_write not implemented");

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8017f5:	8b 55 08             	mov    0x8(%ebp),%edx
  8017f8:	8b 52 0c             	mov    0xc(%edx),%edx
  8017fb:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  801801:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  801806:	50                   	push   %eax
  801807:	ff 75 0c             	pushl  0xc(%ebp)
  80180a:	68 08 50 80 00       	push   $0x805008
  80180f:	e8 34 f1 ff ff       	call   800948 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  801814:	ba 00 00 00 00       	mov    $0x0,%edx
  801819:	b8 04 00 00 00       	mov    $0x4,%eax
  80181e:	e8 d9 fe ff ff       	call   8016fc <fsipc>

}
  801823:	c9                   	leave  
  801824:	c3                   	ret    

00801825 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801825:	55                   	push   %ebp
  801826:	89 e5                	mov    %esp,%ebp
  801828:	56                   	push   %esi
  801829:	53                   	push   %ebx
  80182a:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80182d:	8b 45 08             	mov    0x8(%ebp),%eax
  801830:	8b 40 0c             	mov    0xc(%eax),%eax
  801833:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801838:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80183e:	ba 00 00 00 00       	mov    $0x0,%edx
  801843:	b8 03 00 00 00       	mov    $0x3,%eax
  801848:	e8 af fe ff ff       	call   8016fc <fsipc>
  80184d:	89 c3                	mov    %eax,%ebx
  80184f:	85 c0                	test   %eax,%eax
  801851:	78 4b                	js     80189e <devfile_read+0x79>
		return r;
	assert(r <= n);
  801853:	39 c6                	cmp    %eax,%esi
  801855:	73 16                	jae    80186d <devfile_read+0x48>
  801857:	68 cc 2a 80 00       	push   $0x802acc
  80185c:	68 d3 2a 80 00       	push   $0x802ad3
  801861:	6a 7c                	push   $0x7c
  801863:	68 e8 2a 80 00       	push   $0x802ae8
  801868:	e8 eb e8 ff ff       	call   800158 <_panic>
	assert(r <= PGSIZE);
  80186d:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801872:	7e 16                	jle    80188a <devfile_read+0x65>
  801874:	68 f3 2a 80 00       	push   $0x802af3
  801879:	68 d3 2a 80 00       	push   $0x802ad3
  80187e:	6a 7d                	push   $0x7d
  801880:	68 e8 2a 80 00       	push   $0x802ae8
  801885:	e8 ce e8 ff ff       	call   800158 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80188a:	83 ec 04             	sub    $0x4,%esp
  80188d:	50                   	push   %eax
  80188e:	68 00 50 80 00       	push   $0x805000
  801893:	ff 75 0c             	pushl  0xc(%ebp)
  801896:	e8 ad f0 ff ff       	call   800948 <memmove>
	return r;
  80189b:	83 c4 10             	add    $0x10,%esp
}
  80189e:	89 d8                	mov    %ebx,%eax
  8018a0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018a3:	5b                   	pop    %ebx
  8018a4:	5e                   	pop    %esi
  8018a5:	5d                   	pop    %ebp
  8018a6:	c3                   	ret    

008018a7 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8018a7:	55                   	push   %ebp
  8018a8:	89 e5                	mov    %esp,%ebp
  8018aa:	53                   	push   %ebx
  8018ab:	83 ec 20             	sub    $0x20,%esp
  8018ae:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8018b1:	53                   	push   %ebx
  8018b2:	e8 c6 ee ff ff       	call   80077d <strlen>
  8018b7:	83 c4 10             	add    $0x10,%esp
  8018ba:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8018bf:	7f 67                	jg     801928 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8018c1:	83 ec 0c             	sub    $0xc,%esp
  8018c4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018c7:	50                   	push   %eax
  8018c8:	e8 a7 f8 ff ff       	call   801174 <fd_alloc>
  8018cd:	83 c4 10             	add    $0x10,%esp
		return r;
  8018d0:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8018d2:	85 c0                	test   %eax,%eax
  8018d4:	78 57                	js     80192d <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8018d6:	83 ec 08             	sub    $0x8,%esp
  8018d9:	53                   	push   %ebx
  8018da:	68 00 50 80 00       	push   $0x805000
  8018df:	e8 d2 ee ff ff       	call   8007b6 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8018e4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018e7:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8018ec:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8018ef:	b8 01 00 00 00       	mov    $0x1,%eax
  8018f4:	e8 03 fe ff ff       	call   8016fc <fsipc>
  8018f9:	89 c3                	mov    %eax,%ebx
  8018fb:	83 c4 10             	add    $0x10,%esp
  8018fe:	85 c0                	test   %eax,%eax
  801900:	79 14                	jns    801916 <open+0x6f>
		fd_close(fd, 0);
  801902:	83 ec 08             	sub    $0x8,%esp
  801905:	6a 00                	push   $0x0
  801907:	ff 75 f4             	pushl  -0xc(%ebp)
  80190a:	e8 5d f9 ff ff       	call   80126c <fd_close>
		return r;
  80190f:	83 c4 10             	add    $0x10,%esp
  801912:	89 da                	mov    %ebx,%edx
  801914:	eb 17                	jmp    80192d <open+0x86>
	}

	return fd2num(fd);
  801916:	83 ec 0c             	sub    $0xc,%esp
  801919:	ff 75 f4             	pushl  -0xc(%ebp)
  80191c:	e8 2c f8 ff ff       	call   80114d <fd2num>
  801921:	89 c2                	mov    %eax,%edx
  801923:	83 c4 10             	add    $0x10,%esp
  801926:	eb 05                	jmp    80192d <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801928:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  80192d:	89 d0                	mov    %edx,%eax
  80192f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801932:	c9                   	leave  
  801933:	c3                   	ret    

00801934 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801934:	55                   	push   %ebp
  801935:	89 e5                	mov    %esp,%ebp
  801937:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80193a:	ba 00 00 00 00       	mov    $0x0,%edx
  80193f:	b8 08 00 00 00       	mov    $0x8,%eax
  801944:	e8 b3 fd ff ff       	call   8016fc <fsipc>
}
  801949:	c9                   	leave  
  80194a:	c3                   	ret    

0080194b <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  80194b:	55                   	push   %ebp
  80194c:	89 e5                	mov    %esp,%ebp
  80194e:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  801951:	68 ff 2a 80 00       	push   $0x802aff
  801956:	ff 75 0c             	pushl  0xc(%ebp)
  801959:	e8 58 ee ff ff       	call   8007b6 <strcpy>
	return 0;
}
  80195e:	b8 00 00 00 00       	mov    $0x0,%eax
  801963:	c9                   	leave  
  801964:	c3                   	ret    

00801965 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801965:	55                   	push   %ebp
  801966:	89 e5                	mov    %esp,%ebp
  801968:	53                   	push   %ebx
  801969:	83 ec 10             	sub    $0x10,%esp
  80196c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  80196f:	53                   	push   %ebx
  801970:	e8 87 09 00 00       	call   8022fc <pageref>
  801975:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  801978:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  80197d:	83 f8 01             	cmp    $0x1,%eax
  801980:	75 10                	jne    801992 <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  801982:	83 ec 0c             	sub    $0xc,%esp
  801985:	ff 73 0c             	pushl  0xc(%ebx)
  801988:	e8 c0 02 00 00       	call   801c4d <nsipc_close>
  80198d:	89 c2                	mov    %eax,%edx
  80198f:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  801992:	89 d0                	mov    %edx,%eax
  801994:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801997:	c9                   	leave  
  801998:	c3                   	ret    

00801999 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801999:	55                   	push   %ebp
  80199a:	89 e5                	mov    %esp,%ebp
  80199c:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  80199f:	6a 00                	push   $0x0
  8019a1:	ff 75 10             	pushl  0x10(%ebp)
  8019a4:	ff 75 0c             	pushl  0xc(%ebp)
  8019a7:	8b 45 08             	mov    0x8(%ebp),%eax
  8019aa:	ff 70 0c             	pushl  0xc(%eax)
  8019ad:	e8 78 03 00 00       	call   801d2a <nsipc_send>
}
  8019b2:	c9                   	leave  
  8019b3:	c3                   	ret    

008019b4 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  8019b4:	55                   	push   %ebp
  8019b5:	89 e5                	mov    %esp,%ebp
  8019b7:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  8019ba:	6a 00                	push   $0x0
  8019bc:	ff 75 10             	pushl  0x10(%ebp)
  8019bf:	ff 75 0c             	pushl  0xc(%ebp)
  8019c2:	8b 45 08             	mov    0x8(%ebp),%eax
  8019c5:	ff 70 0c             	pushl  0xc(%eax)
  8019c8:	e8 f1 02 00 00       	call   801cbe <nsipc_recv>
}
  8019cd:	c9                   	leave  
  8019ce:	c3                   	ret    

008019cf <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  8019cf:	55                   	push   %ebp
  8019d0:	89 e5                	mov    %esp,%ebp
  8019d2:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  8019d5:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8019d8:	52                   	push   %edx
  8019d9:	50                   	push   %eax
  8019da:	e8 e4 f7 ff ff       	call   8011c3 <fd_lookup>
  8019df:	83 c4 10             	add    $0x10,%esp
  8019e2:	85 c0                	test   %eax,%eax
  8019e4:	78 17                	js     8019fd <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  8019e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019e9:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  8019ef:	39 08                	cmp    %ecx,(%eax)
  8019f1:	75 05                	jne    8019f8 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  8019f3:	8b 40 0c             	mov    0xc(%eax),%eax
  8019f6:	eb 05                	jmp    8019fd <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  8019f8:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  8019fd:	c9                   	leave  
  8019fe:	c3                   	ret    

008019ff <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  8019ff:	55                   	push   %ebp
  801a00:	89 e5                	mov    %esp,%ebp
  801a02:	56                   	push   %esi
  801a03:	53                   	push   %ebx
  801a04:	83 ec 1c             	sub    $0x1c,%esp
  801a07:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801a09:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a0c:	50                   	push   %eax
  801a0d:	e8 62 f7 ff ff       	call   801174 <fd_alloc>
  801a12:	89 c3                	mov    %eax,%ebx
  801a14:	83 c4 10             	add    $0x10,%esp
  801a17:	85 c0                	test   %eax,%eax
  801a19:	78 1b                	js     801a36 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801a1b:	83 ec 04             	sub    $0x4,%esp
  801a1e:	68 07 04 00 00       	push   $0x407
  801a23:	ff 75 f4             	pushl  -0xc(%ebp)
  801a26:	6a 00                	push   $0x0
  801a28:	e8 8c f1 ff ff       	call   800bb9 <sys_page_alloc>
  801a2d:	89 c3                	mov    %eax,%ebx
  801a2f:	83 c4 10             	add    $0x10,%esp
  801a32:	85 c0                	test   %eax,%eax
  801a34:	79 10                	jns    801a46 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  801a36:	83 ec 0c             	sub    $0xc,%esp
  801a39:	56                   	push   %esi
  801a3a:	e8 0e 02 00 00       	call   801c4d <nsipc_close>
		return r;
  801a3f:	83 c4 10             	add    $0x10,%esp
  801a42:	89 d8                	mov    %ebx,%eax
  801a44:	eb 24                	jmp    801a6a <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801a46:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801a4c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a4f:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801a51:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a54:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801a5b:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801a5e:	83 ec 0c             	sub    $0xc,%esp
  801a61:	50                   	push   %eax
  801a62:	e8 e6 f6 ff ff       	call   80114d <fd2num>
  801a67:	83 c4 10             	add    $0x10,%esp
}
  801a6a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a6d:	5b                   	pop    %ebx
  801a6e:	5e                   	pop    %esi
  801a6f:	5d                   	pop    %ebp
  801a70:	c3                   	ret    

00801a71 <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801a71:	55                   	push   %ebp
  801a72:	89 e5                	mov    %esp,%ebp
  801a74:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801a77:	8b 45 08             	mov    0x8(%ebp),%eax
  801a7a:	e8 50 ff ff ff       	call   8019cf <fd2sockid>
		return r;
  801a7f:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  801a81:	85 c0                	test   %eax,%eax
  801a83:	78 1f                	js     801aa4 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801a85:	83 ec 04             	sub    $0x4,%esp
  801a88:	ff 75 10             	pushl  0x10(%ebp)
  801a8b:	ff 75 0c             	pushl  0xc(%ebp)
  801a8e:	50                   	push   %eax
  801a8f:	e8 12 01 00 00       	call   801ba6 <nsipc_accept>
  801a94:	83 c4 10             	add    $0x10,%esp
		return r;
  801a97:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801a99:	85 c0                	test   %eax,%eax
  801a9b:	78 07                	js     801aa4 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  801a9d:	e8 5d ff ff ff       	call   8019ff <alloc_sockfd>
  801aa2:	89 c1                	mov    %eax,%ecx
}
  801aa4:	89 c8                	mov    %ecx,%eax
  801aa6:	c9                   	leave  
  801aa7:	c3                   	ret    

00801aa8 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801aa8:	55                   	push   %ebp
  801aa9:	89 e5                	mov    %esp,%ebp
  801aab:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801aae:	8b 45 08             	mov    0x8(%ebp),%eax
  801ab1:	e8 19 ff ff ff       	call   8019cf <fd2sockid>
  801ab6:	85 c0                	test   %eax,%eax
  801ab8:	78 12                	js     801acc <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  801aba:	83 ec 04             	sub    $0x4,%esp
  801abd:	ff 75 10             	pushl  0x10(%ebp)
  801ac0:	ff 75 0c             	pushl  0xc(%ebp)
  801ac3:	50                   	push   %eax
  801ac4:	e8 2d 01 00 00       	call   801bf6 <nsipc_bind>
  801ac9:	83 c4 10             	add    $0x10,%esp
}
  801acc:	c9                   	leave  
  801acd:	c3                   	ret    

00801ace <shutdown>:

int
shutdown(int s, int how)
{
  801ace:	55                   	push   %ebp
  801acf:	89 e5                	mov    %esp,%ebp
  801ad1:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801ad4:	8b 45 08             	mov    0x8(%ebp),%eax
  801ad7:	e8 f3 fe ff ff       	call   8019cf <fd2sockid>
  801adc:	85 c0                	test   %eax,%eax
  801ade:	78 0f                	js     801aef <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801ae0:	83 ec 08             	sub    $0x8,%esp
  801ae3:	ff 75 0c             	pushl  0xc(%ebp)
  801ae6:	50                   	push   %eax
  801ae7:	e8 3f 01 00 00       	call   801c2b <nsipc_shutdown>
  801aec:	83 c4 10             	add    $0x10,%esp
}
  801aef:	c9                   	leave  
  801af0:	c3                   	ret    

00801af1 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801af1:	55                   	push   %ebp
  801af2:	89 e5                	mov    %esp,%ebp
  801af4:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801af7:	8b 45 08             	mov    0x8(%ebp),%eax
  801afa:	e8 d0 fe ff ff       	call   8019cf <fd2sockid>
  801aff:	85 c0                	test   %eax,%eax
  801b01:	78 12                	js     801b15 <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  801b03:	83 ec 04             	sub    $0x4,%esp
  801b06:	ff 75 10             	pushl  0x10(%ebp)
  801b09:	ff 75 0c             	pushl  0xc(%ebp)
  801b0c:	50                   	push   %eax
  801b0d:	e8 55 01 00 00       	call   801c67 <nsipc_connect>
  801b12:	83 c4 10             	add    $0x10,%esp
}
  801b15:	c9                   	leave  
  801b16:	c3                   	ret    

00801b17 <listen>:

int
listen(int s, int backlog)
{
  801b17:	55                   	push   %ebp
  801b18:	89 e5                	mov    %esp,%ebp
  801b1a:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801b1d:	8b 45 08             	mov    0x8(%ebp),%eax
  801b20:	e8 aa fe ff ff       	call   8019cf <fd2sockid>
  801b25:	85 c0                	test   %eax,%eax
  801b27:	78 0f                	js     801b38 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801b29:	83 ec 08             	sub    $0x8,%esp
  801b2c:	ff 75 0c             	pushl  0xc(%ebp)
  801b2f:	50                   	push   %eax
  801b30:	e8 67 01 00 00       	call   801c9c <nsipc_listen>
  801b35:	83 c4 10             	add    $0x10,%esp
}
  801b38:	c9                   	leave  
  801b39:	c3                   	ret    

00801b3a <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801b3a:	55                   	push   %ebp
  801b3b:	89 e5                	mov    %esp,%ebp
  801b3d:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801b40:	ff 75 10             	pushl  0x10(%ebp)
  801b43:	ff 75 0c             	pushl  0xc(%ebp)
  801b46:	ff 75 08             	pushl  0x8(%ebp)
  801b49:	e8 3a 02 00 00       	call   801d88 <nsipc_socket>
  801b4e:	83 c4 10             	add    $0x10,%esp
  801b51:	85 c0                	test   %eax,%eax
  801b53:	78 05                	js     801b5a <socket+0x20>
		return r;
	return alloc_sockfd(r);
  801b55:	e8 a5 fe ff ff       	call   8019ff <alloc_sockfd>
}
  801b5a:	c9                   	leave  
  801b5b:	c3                   	ret    

00801b5c <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801b5c:	55                   	push   %ebp
  801b5d:	89 e5                	mov    %esp,%ebp
  801b5f:	53                   	push   %ebx
  801b60:	83 ec 04             	sub    $0x4,%esp
  801b63:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801b65:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801b6c:	75 12                	jne    801b80 <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801b6e:	83 ec 0c             	sub    $0xc,%esp
  801b71:	6a 02                	push   $0x2
  801b73:	e8 9c f5 ff ff       	call   801114 <ipc_find_env>
  801b78:	a3 04 40 80 00       	mov    %eax,0x804004
  801b7d:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801b80:	6a 07                	push   $0x7
  801b82:	68 00 60 80 00       	push   $0x806000
  801b87:	53                   	push   %ebx
  801b88:	ff 35 04 40 80 00    	pushl  0x804004
  801b8e:	e8 2d f5 ff ff       	call   8010c0 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801b93:	83 c4 0c             	add    $0xc,%esp
  801b96:	6a 00                	push   $0x0
  801b98:	6a 00                	push   $0x0
  801b9a:	6a 00                	push   $0x0
  801b9c:	e8 b8 f4 ff ff       	call   801059 <ipc_recv>
}
  801ba1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ba4:	c9                   	leave  
  801ba5:	c3                   	ret    

00801ba6 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801ba6:	55                   	push   %ebp
  801ba7:	89 e5                	mov    %esp,%ebp
  801ba9:	56                   	push   %esi
  801baa:	53                   	push   %ebx
  801bab:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801bae:	8b 45 08             	mov    0x8(%ebp),%eax
  801bb1:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801bb6:	8b 06                	mov    (%esi),%eax
  801bb8:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801bbd:	b8 01 00 00 00       	mov    $0x1,%eax
  801bc2:	e8 95 ff ff ff       	call   801b5c <nsipc>
  801bc7:	89 c3                	mov    %eax,%ebx
  801bc9:	85 c0                	test   %eax,%eax
  801bcb:	78 20                	js     801bed <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801bcd:	83 ec 04             	sub    $0x4,%esp
  801bd0:	ff 35 10 60 80 00    	pushl  0x806010
  801bd6:	68 00 60 80 00       	push   $0x806000
  801bdb:	ff 75 0c             	pushl  0xc(%ebp)
  801bde:	e8 65 ed ff ff       	call   800948 <memmove>
		*addrlen = ret->ret_addrlen;
  801be3:	a1 10 60 80 00       	mov    0x806010,%eax
  801be8:	89 06                	mov    %eax,(%esi)
  801bea:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  801bed:	89 d8                	mov    %ebx,%eax
  801bef:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801bf2:	5b                   	pop    %ebx
  801bf3:	5e                   	pop    %esi
  801bf4:	5d                   	pop    %ebp
  801bf5:	c3                   	ret    

00801bf6 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801bf6:	55                   	push   %ebp
  801bf7:	89 e5                	mov    %esp,%ebp
  801bf9:	53                   	push   %ebx
  801bfa:	83 ec 08             	sub    $0x8,%esp
  801bfd:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801c00:	8b 45 08             	mov    0x8(%ebp),%eax
  801c03:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801c08:	53                   	push   %ebx
  801c09:	ff 75 0c             	pushl  0xc(%ebp)
  801c0c:	68 04 60 80 00       	push   $0x806004
  801c11:	e8 32 ed ff ff       	call   800948 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801c16:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801c1c:	b8 02 00 00 00       	mov    $0x2,%eax
  801c21:	e8 36 ff ff ff       	call   801b5c <nsipc>
}
  801c26:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c29:	c9                   	leave  
  801c2a:	c3                   	ret    

00801c2b <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801c2b:	55                   	push   %ebp
  801c2c:	89 e5                	mov    %esp,%ebp
  801c2e:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801c31:	8b 45 08             	mov    0x8(%ebp),%eax
  801c34:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801c39:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c3c:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801c41:	b8 03 00 00 00       	mov    $0x3,%eax
  801c46:	e8 11 ff ff ff       	call   801b5c <nsipc>
}
  801c4b:	c9                   	leave  
  801c4c:	c3                   	ret    

00801c4d <nsipc_close>:

int
nsipc_close(int s)
{
  801c4d:	55                   	push   %ebp
  801c4e:	89 e5                	mov    %esp,%ebp
  801c50:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801c53:	8b 45 08             	mov    0x8(%ebp),%eax
  801c56:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801c5b:	b8 04 00 00 00       	mov    $0x4,%eax
  801c60:	e8 f7 fe ff ff       	call   801b5c <nsipc>
}
  801c65:	c9                   	leave  
  801c66:	c3                   	ret    

00801c67 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801c67:	55                   	push   %ebp
  801c68:	89 e5                	mov    %esp,%ebp
  801c6a:	53                   	push   %ebx
  801c6b:	83 ec 08             	sub    $0x8,%esp
  801c6e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801c71:	8b 45 08             	mov    0x8(%ebp),%eax
  801c74:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801c79:	53                   	push   %ebx
  801c7a:	ff 75 0c             	pushl  0xc(%ebp)
  801c7d:	68 04 60 80 00       	push   $0x806004
  801c82:	e8 c1 ec ff ff       	call   800948 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801c87:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801c8d:	b8 05 00 00 00       	mov    $0x5,%eax
  801c92:	e8 c5 fe ff ff       	call   801b5c <nsipc>
}
  801c97:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c9a:	c9                   	leave  
  801c9b:	c3                   	ret    

00801c9c <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801c9c:	55                   	push   %ebp
  801c9d:	89 e5                	mov    %esp,%ebp
  801c9f:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801ca2:	8b 45 08             	mov    0x8(%ebp),%eax
  801ca5:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801caa:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cad:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801cb2:	b8 06 00 00 00       	mov    $0x6,%eax
  801cb7:	e8 a0 fe ff ff       	call   801b5c <nsipc>
}
  801cbc:	c9                   	leave  
  801cbd:	c3                   	ret    

00801cbe <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801cbe:	55                   	push   %ebp
  801cbf:	89 e5                	mov    %esp,%ebp
  801cc1:	56                   	push   %esi
  801cc2:	53                   	push   %ebx
  801cc3:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801cc6:	8b 45 08             	mov    0x8(%ebp),%eax
  801cc9:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801cce:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801cd4:	8b 45 14             	mov    0x14(%ebp),%eax
  801cd7:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801cdc:	b8 07 00 00 00       	mov    $0x7,%eax
  801ce1:	e8 76 fe ff ff       	call   801b5c <nsipc>
  801ce6:	89 c3                	mov    %eax,%ebx
  801ce8:	85 c0                	test   %eax,%eax
  801cea:	78 35                	js     801d21 <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  801cec:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801cf1:	7f 04                	jg     801cf7 <nsipc_recv+0x39>
  801cf3:	39 c6                	cmp    %eax,%esi
  801cf5:	7d 16                	jge    801d0d <nsipc_recv+0x4f>
  801cf7:	68 0b 2b 80 00       	push   $0x802b0b
  801cfc:	68 d3 2a 80 00       	push   $0x802ad3
  801d01:	6a 62                	push   $0x62
  801d03:	68 20 2b 80 00       	push   $0x802b20
  801d08:	e8 4b e4 ff ff       	call   800158 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801d0d:	83 ec 04             	sub    $0x4,%esp
  801d10:	50                   	push   %eax
  801d11:	68 00 60 80 00       	push   $0x806000
  801d16:	ff 75 0c             	pushl  0xc(%ebp)
  801d19:	e8 2a ec ff ff       	call   800948 <memmove>
  801d1e:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801d21:	89 d8                	mov    %ebx,%eax
  801d23:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d26:	5b                   	pop    %ebx
  801d27:	5e                   	pop    %esi
  801d28:	5d                   	pop    %ebp
  801d29:	c3                   	ret    

00801d2a <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801d2a:	55                   	push   %ebp
  801d2b:	89 e5                	mov    %esp,%ebp
  801d2d:	53                   	push   %ebx
  801d2e:	83 ec 04             	sub    $0x4,%esp
  801d31:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801d34:	8b 45 08             	mov    0x8(%ebp),%eax
  801d37:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801d3c:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801d42:	7e 16                	jle    801d5a <nsipc_send+0x30>
  801d44:	68 2c 2b 80 00       	push   $0x802b2c
  801d49:	68 d3 2a 80 00       	push   $0x802ad3
  801d4e:	6a 6d                	push   $0x6d
  801d50:	68 20 2b 80 00       	push   $0x802b20
  801d55:	e8 fe e3 ff ff       	call   800158 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801d5a:	83 ec 04             	sub    $0x4,%esp
  801d5d:	53                   	push   %ebx
  801d5e:	ff 75 0c             	pushl  0xc(%ebp)
  801d61:	68 0c 60 80 00       	push   $0x80600c
  801d66:	e8 dd eb ff ff       	call   800948 <memmove>
	nsipcbuf.send.req_size = size;
  801d6b:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801d71:	8b 45 14             	mov    0x14(%ebp),%eax
  801d74:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801d79:	b8 08 00 00 00       	mov    $0x8,%eax
  801d7e:	e8 d9 fd ff ff       	call   801b5c <nsipc>
}
  801d83:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801d86:	c9                   	leave  
  801d87:	c3                   	ret    

00801d88 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801d88:	55                   	push   %ebp
  801d89:	89 e5                	mov    %esp,%ebp
  801d8b:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801d8e:	8b 45 08             	mov    0x8(%ebp),%eax
  801d91:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801d96:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d99:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801d9e:	8b 45 10             	mov    0x10(%ebp),%eax
  801da1:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801da6:	b8 09 00 00 00       	mov    $0x9,%eax
  801dab:	e8 ac fd ff ff       	call   801b5c <nsipc>
}
  801db0:	c9                   	leave  
  801db1:	c3                   	ret    

00801db2 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801db2:	55                   	push   %ebp
  801db3:	89 e5                	mov    %esp,%ebp
  801db5:	56                   	push   %esi
  801db6:	53                   	push   %ebx
  801db7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801dba:	83 ec 0c             	sub    $0xc,%esp
  801dbd:	ff 75 08             	pushl  0x8(%ebp)
  801dc0:	e8 98 f3 ff ff       	call   80115d <fd2data>
  801dc5:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801dc7:	83 c4 08             	add    $0x8,%esp
  801dca:	68 38 2b 80 00       	push   $0x802b38
  801dcf:	53                   	push   %ebx
  801dd0:	e8 e1 e9 ff ff       	call   8007b6 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801dd5:	8b 46 04             	mov    0x4(%esi),%eax
  801dd8:	2b 06                	sub    (%esi),%eax
  801dda:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801de0:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801de7:	00 00 00 
	stat->st_dev = &devpipe;
  801dea:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801df1:	30 80 00 
	return 0;
}
  801df4:	b8 00 00 00 00       	mov    $0x0,%eax
  801df9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801dfc:	5b                   	pop    %ebx
  801dfd:	5e                   	pop    %esi
  801dfe:	5d                   	pop    %ebp
  801dff:	c3                   	ret    

00801e00 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801e00:	55                   	push   %ebp
  801e01:	89 e5                	mov    %esp,%ebp
  801e03:	53                   	push   %ebx
  801e04:	83 ec 0c             	sub    $0xc,%esp
  801e07:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801e0a:	53                   	push   %ebx
  801e0b:	6a 00                	push   $0x0
  801e0d:	e8 2c ee ff ff       	call   800c3e <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801e12:	89 1c 24             	mov    %ebx,(%esp)
  801e15:	e8 43 f3 ff ff       	call   80115d <fd2data>
  801e1a:	83 c4 08             	add    $0x8,%esp
  801e1d:	50                   	push   %eax
  801e1e:	6a 00                	push   $0x0
  801e20:	e8 19 ee ff ff       	call   800c3e <sys_page_unmap>
}
  801e25:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801e28:	c9                   	leave  
  801e29:	c3                   	ret    

00801e2a <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801e2a:	55                   	push   %ebp
  801e2b:	89 e5                	mov    %esp,%ebp
  801e2d:	57                   	push   %edi
  801e2e:	56                   	push   %esi
  801e2f:	53                   	push   %ebx
  801e30:	83 ec 1c             	sub    $0x1c,%esp
  801e33:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801e36:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801e38:	a1 08 40 80 00       	mov    0x804008,%eax
  801e3d:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801e40:	83 ec 0c             	sub    $0xc,%esp
  801e43:	ff 75 e0             	pushl  -0x20(%ebp)
  801e46:	e8 b1 04 00 00       	call   8022fc <pageref>
  801e4b:	89 c3                	mov    %eax,%ebx
  801e4d:	89 3c 24             	mov    %edi,(%esp)
  801e50:	e8 a7 04 00 00       	call   8022fc <pageref>
  801e55:	83 c4 10             	add    $0x10,%esp
  801e58:	39 c3                	cmp    %eax,%ebx
  801e5a:	0f 94 c1             	sete   %cl
  801e5d:	0f b6 c9             	movzbl %cl,%ecx
  801e60:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801e63:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801e69:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801e6c:	39 ce                	cmp    %ecx,%esi
  801e6e:	74 1b                	je     801e8b <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801e70:	39 c3                	cmp    %eax,%ebx
  801e72:	75 c4                	jne    801e38 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801e74:	8b 42 58             	mov    0x58(%edx),%eax
  801e77:	ff 75 e4             	pushl  -0x1c(%ebp)
  801e7a:	50                   	push   %eax
  801e7b:	56                   	push   %esi
  801e7c:	68 3f 2b 80 00       	push   $0x802b3f
  801e81:	e8 ab e3 ff ff       	call   800231 <cprintf>
  801e86:	83 c4 10             	add    $0x10,%esp
  801e89:	eb ad                	jmp    801e38 <_pipeisclosed+0xe>
	}
}
  801e8b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801e8e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e91:	5b                   	pop    %ebx
  801e92:	5e                   	pop    %esi
  801e93:	5f                   	pop    %edi
  801e94:	5d                   	pop    %ebp
  801e95:	c3                   	ret    

00801e96 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801e96:	55                   	push   %ebp
  801e97:	89 e5                	mov    %esp,%ebp
  801e99:	57                   	push   %edi
  801e9a:	56                   	push   %esi
  801e9b:	53                   	push   %ebx
  801e9c:	83 ec 28             	sub    $0x28,%esp
  801e9f:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801ea2:	56                   	push   %esi
  801ea3:	e8 b5 f2 ff ff       	call   80115d <fd2data>
  801ea8:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801eaa:	83 c4 10             	add    $0x10,%esp
  801ead:	bf 00 00 00 00       	mov    $0x0,%edi
  801eb2:	eb 4b                	jmp    801eff <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801eb4:	89 da                	mov    %ebx,%edx
  801eb6:	89 f0                	mov    %esi,%eax
  801eb8:	e8 6d ff ff ff       	call   801e2a <_pipeisclosed>
  801ebd:	85 c0                	test   %eax,%eax
  801ebf:	75 48                	jne    801f09 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801ec1:	e8 d4 ec ff ff       	call   800b9a <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801ec6:	8b 43 04             	mov    0x4(%ebx),%eax
  801ec9:	8b 0b                	mov    (%ebx),%ecx
  801ecb:	8d 51 20             	lea    0x20(%ecx),%edx
  801ece:	39 d0                	cmp    %edx,%eax
  801ed0:	73 e2                	jae    801eb4 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801ed2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801ed5:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801ed9:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801edc:	89 c2                	mov    %eax,%edx
  801ede:	c1 fa 1f             	sar    $0x1f,%edx
  801ee1:	89 d1                	mov    %edx,%ecx
  801ee3:	c1 e9 1b             	shr    $0x1b,%ecx
  801ee6:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801ee9:	83 e2 1f             	and    $0x1f,%edx
  801eec:	29 ca                	sub    %ecx,%edx
  801eee:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801ef2:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801ef6:	83 c0 01             	add    $0x1,%eax
  801ef9:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801efc:	83 c7 01             	add    $0x1,%edi
  801eff:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801f02:	75 c2                	jne    801ec6 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801f04:	8b 45 10             	mov    0x10(%ebp),%eax
  801f07:	eb 05                	jmp    801f0e <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801f09:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801f0e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f11:	5b                   	pop    %ebx
  801f12:	5e                   	pop    %esi
  801f13:	5f                   	pop    %edi
  801f14:	5d                   	pop    %ebp
  801f15:	c3                   	ret    

00801f16 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801f16:	55                   	push   %ebp
  801f17:	89 e5                	mov    %esp,%ebp
  801f19:	57                   	push   %edi
  801f1a:	56                   	push   %esi
  801f1b:	53                   	push   %ebx
  801f1c:	83 ec 18             	sub    $0x18,%esp
  801f1f:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801f22:	57                   	push   %edi
  801f23:	e8 35 f2 ff ff       	call   80115d <fd2data>
  801f28:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801f2a:	83 c4 10             	add    $0x10,%esp
  801f2d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801f32:	eb 3d                	jmp    801f71 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801f34:	85 db                	test   %ebx,%ebx
  801f36:	74 04                	je     801f3c <devpipe_read+0x26>
				return i;
  801f38:	89 d8                	mov    %ebx,%eax
  801f3a:	eb 44                	jmp    801f80 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801f3c:	89 f2                	mov    %esi,%edx
  801f3e:	89 f8                	mov    %edi,%eax
  801f40:	e8 e5 fe ff ff       	call   801e2a <_pipeisclosed>
  801f45:	85 c0                	test   %eax,%eax
  801f47:	75 32                	jne    801f7b <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801f49:	e8 4c ec ff ff       	call   800b9a <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801f4e:	8b 06                	mov    (%esi),%eax
  801f50:	3b 46 04             	cmp    0x4(%esi),%eax
  801f53:	74 df                	je     801f34 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801f55:	99                   	cltd   
  801f56:	c1 ea 1b             	shr    $0x1b,%edx
  801f59:	01 d0                	add    %edx,%eax
  801f5b:	83 e0 1f             	and    $0x1f,%eax
  801f5e:	29 d0                	sub    %edx,%eax
  801f60:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801f65:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801f68:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801f6b:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801f6e:	83 c3 01             	add    $0x1,%ebx
  801f71:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801f74:	75 d8                	jne    801f4e <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801f76:	8b 45 10             	mov    0x10(%ebp),%eax
  801f79:	eb 05                	jmp    801f80 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801f7b:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801f80:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f83:	5b                   	pop    %ebx
  801f84:	5e                   	pop    %esi
  801f85:	5f                   	pop    %edi
  801f86:	5d                   	pop    %ebp
  801f87:	c3                   	ret    

00801f88 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801f88:	55                   	push   %ebp
  801f89:	89 e5                	mov    %esp,%ebp
  801f8b:	56                   	push   %esi
  801f8c:	53                   	push   %ebx
  801f8d:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801f90:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f93:	50                   	push   %eax
  801f94:	e8 db f1 ff ff       	call   801174 <fd_alloc>
  801f99:	83 c4 10             	add    $0x10,%esp
  801f9c:	89 c2                	mov    %eax,%edx
  801f9e:	85 c0                	test   %eax,%eax
  801fa0:	0f 88 2c 01 00 00    	js     8020d2 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801fa6:	83 ec 04             	sub    $0x4,%esp
  801fa9:	68 07 04 00 00       	push   $0x407
  801fae:	ff 75 f4             	pushl  -0xc(%ebp)
  801fb1:	6a 00                	push   $0x0
  801fb3:	e8 01 ec ff ff       	call   800bb9 <sys_page_alloc>
  801fb8:	83 c4 10             	add    $0x10,%esp
  801fbb:	89 c2                	mov    %eax,%edx
  801fbd:	85 c0                	test   %eax,%eax
  801fbf:	0f 88 0d 01 00 00    	js     8020d2 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801fc5:	83 ec 0c             	sub    $0xc,%esp
  801fc8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801fcb:	50                   	push   %eax
  801fcc:	e8 a3 f1 ff ff       	call   801174 <fd_alloc>
  801fd1:	89 c3                	mov    %eax,%ebx
  801fd3:	83 c4 10             	add    $0x10,%esp
  801fd6:	85 c0                	test   %eax,%eax
  801fd8:	0f 88 e2 00 00 00    	js     8020c0 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801fde:	83 ec 04             	sub    $0x4,%esp
  801fe1:	68 07 04 00 00       	push   $0x407
  801fe6:	ff 75 f0             	pushl  -0x10(%ebp)
  801fe9:	6a 00                	push   $0x0
  801feb:	e8 c9 eb ff ff       	call   800bb9 <sys_page_alloc>
  801ff0:	89 c3                	mov    %eax,%ebx
  801ff2:	83 c4 10             	add    $0x10,%esp
  801ff5:	85 c0                	test   %eax,%eax
  801ff7:	0f 88 c3 00 00 00    	js     8020c0 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801ffd:	83 ec 0c             	sub    $0xc,%esp
  802000:	ff 75 f4             	pushl  -0xc(%ebp)
  802003:	e8 55 f1 ff ff       	call   80115d <fd2data>
  802008:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80200a:	83 c4 0c             	add    $0xc,%esp
  80200d:	68 07 04 00 00       	push   $0x407
  802012:	50                   	push   %eax
  802013:	6a 00                	push   $0x0
  802015:	e8 9f eb ff ff       	call   800bb9 <sys_page_alloc>
  80201a:	89 c3                	mov    %eax,%ebx
  80201c:	83 c4 10             	add    $0x10,%esp
  80201f:	85 c0                	test   %eax,%eax
  802021:	0f 88 89 00 00 00    	js     8020b0 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802027:	83 ec 0c             	sub    $0xc,%esp
  80202a:	ff 75 f0             	pushl  -0x10(%ebp)
  80202d:	e8 2b f1 ff ff       	call   80115d <fd2data>
  802032:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  802039:	50                   	push   %eax
  80203a:	6a 00                	push   $0x0
  80203c:	56                   	push   %esi
  80203d:	6a 00                	push   $0x0
  80203f:	e8 b8 eb ff ff       	call   800bfc <sys_page_map>
  802044:	89 c3                	mov    %eax,%ebx
  802046:	83 c4 20             	add    $0x20,%esp
  802049:	85 c0                	test   %eax,%eax
  80204b:	78 55                	js     8020a2 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  80204d:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  802053:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802056:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  802058:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80205b:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  802062:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  802068:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80206b:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  80206d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802070:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  802077:	83 ec 0c             	sub    $0xc,%esp
  80207a:	ff 75 f4             	pushl  -0xc(%ebp)
  80207d:	e8 cb f0 ff ff       	call   80114d <fd2num>
  802082:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802085:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  802087:	83 c4 04             	add    $0x4,%esp
  80208a:	ff 75 f0             	pushl  -0x10(%ebp)
  80208d:	e8 bb f0 ff ff       	call   80114d <fd2num>
  802092:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802095:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  802098:	83 c4 10             	add    $0x10,%esp
  80209b:	ba 00 00 00 00       	mov    $0x0,%edx
  8020a0:	eb 30                	jmp    8020d2 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  8020a2:	83 ec 08             	sub    $0x8,%esp
  8020a5:	56                   	push   %esi
  8020a6:	6a 00                	push   $0x0
  8020a8:	e8 91 eb ff ff       	call   800c3e <sys_page_unmap>
  8020ad:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  8020b0:	83 ec 08             	sub    $0x8,%esp
  8020b3:	ff 75 f0             	pushl  -0x10(%ebp)
  8020b6:	6a 00                	push   $0x0
  8020b8:	e8 81 eb ff ff       	call   800c3e <sys_page_unmap>
  8020bd:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  8020c0:	83 ec 08             	sub    $0x8,%esp
  8020c3:	ff 75 f4             	pushl  -0xc(%ebp)
  8020c6:	6a 00                	push   $0x0
  8020c8:	e8 71 eb ff ff       	call   800c3e <sys_page_unmap>
  8020cd:	83 c4 10             	add    $0x10,%esp
  8020d0:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  8020d2:	89 d0                	mov    %edx,%eax
  8020d4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8020d7:	5b                   	pop    %ebx
  8020d8:	5e                   	pop    %esi
  8020d9:	5d                   	pop    %ebp
  8020da:	c3                   	ret    

008020db <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8020db:	55                   	push   %ebp
  8020dc:	89 e5                	mov    %esp,%ebp
  8020de:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8020e1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8020e4:	50                   	push   %eax
  8020e5:	ff 75 08             	pushl  0x8(%ebp)
  8020e8:	e8 d6 f0 ff ff       	call   8011c3 <fd_lookup>
  8020ed:	83 c4 10             	add    $0x10,%esp
  8020f0:	85 c0                	test   %eax,%eax
  8020f2:	78 18                	js     80210c <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8020f4:	83 ec 0c             	sub    $0xc,%esp
  8020f7:	ff 75 f4             	pushl  -0xc(%ebp)
  8020fa:	e8 5e f0 ff ff       	call   80115d <fd2data>
	return _pipeisclosed(fd, p);
  8020ff:	89 c2                	mov    %eax,%edx
  802101:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802104:	e8 21 fd ff ff       	call   801e2a <_pipeisclosed>
  802109:	83 c4 10             	add    $0x10,%esp
}
  80210c:	c9                   	leave  
  80210d:	c3                   	ret    

0080210e <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  80210e:	55                   	push   %ebp
  80210f:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  802111:	b8 00 00 00 00       	mov    $0x0,%eax
  802116:	5d                   	pop    %ebp
  802117:	c3                   	ret    

00802118 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  802118:	55                   	push   %ebp
  802119:	89 e5                	mov    %esp,%ebp
  80211b:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  80211e:	68 57 2b 80 00       	push   $0x802b57
  802123:	ff 75 0c             	pushl  0xc(%ebp)
  802126:	e8 8b e6 ff ff       	call   8007b6 <strcpy>
	return 0;
}
  80212b:	b8 00 00 00 00       	mov    $0x0,%eax
  802130:	c9                   	leave  
  802131:	c3                   	ret    

00802132 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802132:	55                   	push   %ebp
  802133:	89 e5                	mov    %esp,%ebp
  802135:	57                   	push   %edi
  802136:	56                   	push   %esi
  802137:	53                   	push   %ebx
  802138:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80213e:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802143:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802149:	eb 2d                	jmp    802178 <devcons_write+0x46>
		m = n - tot;
  80214b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80214e:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  802150:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  802153:	ba 7f 00 00 00       	mov    $0x7f,%edx
  802158:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80215b:	83 ec 04             	sub    $0x4,%esp
  80215e:	53                   	push   %ebx
  80215f:	03 45 0c             	add    0xc(%ebp),%eax
  802162:	50                   	push   %eax
  802163:	57                   	push   %edi
  802164:	e8 df e7 ff ff       	call   800948 <memmove>
		sys_cputs(buf, m);
  802169:	83 c4 08             	add    $0x8,%esp
  80216c:	53                   	push   %ebx
  80216d:	57                   	push   %edi
  80216e:	e8 8a e9 ff ff       	call   800afd <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802173:	01 de                	add    %ebx,%esi
  802175:	83 c4 10             	add    $0x10,%esp
  802178:	89 f0                	mov    %esi,%eax
  80217a:	3b 75 10             	cmp    0x10(%ebp),%esi
  80217d:	72 cc                	jb     80214b <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  80217f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802182:	5b                   	pop    %ebx
  802183:	5e                   	pop    %esi
  802184:	5f                   	pop    %edi
  802185:	5d                   	pop    %ebp
  802186:	c3                   	ret    

00802187 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  802187:	55                   	push   %ebp
  802188:	89 e5                	mov    %esp,%ebp
  80218a:	83 ec 08             	sub    $0x8,%esp
  80218d:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  802192:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802196:	74 2a                	je     8021c2 <devcons_read+0x3b>
  802198:	eb 05                	jmp    80219f <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  80219a:	e8 fb e9 ff ff       	call   800b9a <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  80219f:	e8 77 e9 ff ff       	call   800b1b <sys_cgetc>
  8021a4:	85 c0                	test   %eax,%eax
  8021a6:	74 f2                	je     80219a <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8021a8:	85 c0                	test   %eax,%eax
  8021aa:	78 16                	js     8021c2 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8021ac:	83 f8 04             	cmp    $0x4,%eax
  8021af:	74 0c                	je     8021bd <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  8021b1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8021b4:	88 02                	mov    %al,(%edx)
	return 1;
  8021b6:	b8 01 00 00 00       	mov    $0x1,%eax
  8021bb:	eb 05                	jmp    8021c2 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8021bd:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8021c2:	c9                   	leave  
  8021c3:	c3                   	ret    

008021c4 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8021c4:	55                   	push   %ebp
  8021c5:	89 e5                	mov    %esp,%ebp
  8021c7:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8021ca:	8b 45 08             	mov    0x8(%ebp),%eax
  8021cd:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8021d0:	6a 01                	push   $0x1
  8021d2:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8021d5:	50                   	push   %eax
  8021d6:	e8 22 e9 ff ff       	call   800afd <sys_cputs>
}
  8021db:	83 c4 10             	add    $0x10,%esp
  8021de:	c9                   	leave  
  8021df:	c3                   	ret    

008021e0 <getchar>:

int
getchar(void)
{
  8021e0:	55                   	push   %ebp
  8021e1:	89 e5                	mov    %esp,%ebp
  8021e3:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8021e6:	6a 01                	push   $0x1
  8021e8:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8021eb:	50                   	push   %eax
  8021ec:	6a 00                	push   $0x0
  8021ee:	e8 36 f2 ff ff       	call   801429 <read>
	if (r < 0)
  8021f3:	83 c4 10             	add    $0x10,%esp
  8021f6:	85 c0                	test   %eax,%eax
  8021f8:	78 0f                	js     802209 <getchar+0x29>
		return r;
	if (r < 1)
  8021fa:	85 c0                	test   %eax,%eax
  8021fc:	7e 06                	jle    802204 <getchar+0x24>
		return -E_EOF;
	return c;
  8021fe:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  802202:	eb 05                	jmp    802209 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  802204:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  802209:	c9                   	leave  
  80220a:	c3                   	ret    

0080220b <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  80220b:	55                   	push   %ebp
  80220c:	89 e5                	mov    %esp,%ebp
  80220e:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802211:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802214:	50                   	push   %eax
  802215:	ff 75 08             	pushl  0x8(%ebp)
  802218:	e8 a6 ef ff ff       	call   8011c3 <fd_lookup>
  80221d:	83 c4 10             	add    $0x10,%esp
  802220:	85 c0                	test   %eax,%eax
  802222:	78 11                	js     802235 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  802224:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802227:	8b 15 58 30 80 00    	mov    0x803058,%edx
  80222d:	39 10                	cmp    %edx,(%eax)
  80222f:	0f 94 c0             	sete   %al
  802232:	0f b6 c0             	movzbl %al,%eax
}
  802235:	c9                   	leave  
  802236:	c3                   	ret    

00802237 <opencons>:

int
opencons(void)
{
  802237:	55                   	push   %ebp
  802238:	89 e5                	mov    %esp,%ebp
  80223a:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80223d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802240:	50                   	push   %eax
  802241:	e8 2e ef ff ff       	call   801174 <fd_alloc>
  802246:	83 c4 10             	add    $0x10,%esp
		return r;
  802249:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80224b:	85 c0                	test   %eax,%eax
  80224d:	78 3e                	js     80228d <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80224f:	83 ec 04             	sub    $0x4,%esp
  802252:	68 07 04 00 00       	push   $0x407
  802257:	ff 75 f4             	pushl  -0xc(%ebp)
  80225a:	6a 00                	push   $0x0
  80225c:	e8 58 e9 ff ff       	call   800bb9 <sys_page_alloc>
  802261:	83 c4 10             	add    $0x10,%esp
		return r;
  802264:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802266:	85 c0                	test   %eax,%eax
  802268:	78 23                	js     80228d <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  80226a:	8b 15 58 30 80 00    	mov    0x803058,%edx
  802270:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802273:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  802275:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802278:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80227f:	83 ec 0c             	sub    $0xc,%esp
  802282:	50                   	push   %eax
  802283:	e8 c5 ee ff ff       	call   80114d <fd2num>
  802288:	89 c2                	mov    %eax,%edx
  80228a:	83 c4 10             	add    $0x10,%esp
}
  80228d:	89 d0                	mov    %edx,%eax
  80228f:	c9                   	leave  
  802290:	c3                   	ret    

00802291 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802291:	55                   	push   %ebp
  802292:	89 e5                	mov    %esp,%ebp
  802294:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  802297:	83 3d 00 70 80 00 00 	cmpl   $0x0,0x807000
  80229e:	75 2e                	jne    8022ce <set_pgfault_handler+0x3d>
		// First time through!
		// LAB 4: Your code here.
		// panic("set_pgfault_handler not implemented");

		sys_page_alloc(sys_getenvid(), (void *) (UXSTACKTOP - PGSIZE), PTE_SYSCALL);
  8022a0:	e8 d6 e8 ff ff       	call   800b7b <sys_getenvid>
  8022a5:	83 ec 04             	sub    $0x4,%esp
  8022a8:	68 07 0e 00 00       	push   $0xe07
  8022ad:	68 00 f0 bf ee       	push   $0xeebff000
  8022b2:	50                   	push   %eax
  8022b3:	e8 01 e9 ff ff       	call   800bb9 <sys_page_alloc>
		sys_env_set_pgfault_upcall(sys_getenvid(), _pgfault_upcall);
  8022b8:	e8 be e8 ff ff       	call   800b7b <sys_getenvid>
  8022bd:	83 c4 08             	add    $0x8,%esp
  8022c0:	68 d8 22 80 00       	push   $0x8022d8
  8022c5:	50                   	push   %eax
  8022c6:	e8 39 ea ff ff       	call   800d04 <sys_env_set_pgfault_upcall>
  8022cb:	83 c4 10             	add    $0x10,%esp
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8022ce:	8b 45 08             	mov    0x8(%ebp),%eax
  8022d1:	a3 00 70 80 00       	mov    %eax,0x807000
}
  8022d6:	c9                   	leave  
  8022d7:	c3                   	ret    

008022d8 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8022d8:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8022d9:	a1 00 70 80 00       	mov    0x807000,%eax
	call *%eax
  8022de:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8022e0:	83 c4 04             	add    $0x4,%esp
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.

	movl 48(%esp), %eax		// trap-time esp
  8022e3:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl 40(%esp), %ebx		// trap-time eip
  8022e7:	8b 5c 24 28          	mov    0x28(%esp),%ebx

	// load eip into esp-4
	// in order to return to trap-time eip later, in the meantime not changing trap-time esp
	movl %ebx, -4(%eax)	
  8022eb:	89 58 fc             	mov    %ebx,-0x4(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.

	addl $8, %esp 			// esp now points to trap-time registers
  8022ee:	83 c4 08             	add    $0x8,%esp
	popal					// pop to all registers
  8022f1:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

	addl $4, %esp			// esp now points to trap-time eflags
  8022f2:	83 c4 04             	add    $0x4,%esp
	popfl					// pop to eflags
  8022f5:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.

	popl %esp				// pop to esp
  8022f6:	5c                   	pop    %esp
	// subl $4, %esp		// arithmetic operation will change eflags!!!
	lea -4(%esp), %esp		// subl $4, %esp
  8022f7:	8d 64 24 fc          	lea    -0x4(%esp),%esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.

	ret
  8022fb:	c3                   	ret    

008022fc <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8022fc:	55                   	push   %ebp
  8022fd:	89 e5                	mov    %esp,%ebp
  8022ff:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802302:	89 d0                	mov    %edx,%eax
  802304:	c1 e8 16             	shr    $0x16,%eax
  802307:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  80230e:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802313:	f6 c1 01             	test   $0x1,%cl
  802316:	74 1d                	je     802335 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802318:	c1 ea 0c             	shr    $0xc,%edx
  80231b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802322:	f6 c2 01             	test   $0x1,%dl
  802325:	74 0e                	je     802335 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802327:	c1 ea 0c             	shr    $0xc,%edx
  80232a:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802331:	ef 
  802332:	0f b7 c0             	movzwl %ax,%eax
}
  802335:	5d                   	pop    %ebp
  802336:	c3                   	ret    
  802337:	66 90                	xchg   %ax,%ax
  802339:	66 90                	xchg   %ax,%ax
  80233b:	66 90                	xchg   %ax,%ax
  80233d:	66 90                	xchg   %ax,%ax
  80233f:	90                   	nop

00802340 <__udivdi3>:
  802340:	55                   	push   %ebp
  802341:	57                   	push   %edi
  802342:	56                   	push   %esi
  802343:	53                   	push   %ebx
  802344:	83 ec 1c             	sub    $0x1c,%esp
  802347:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80234b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80234f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802353:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802357:	85 f6                	test   %esi,%esi
  802359:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80235d:	89 ca                	mov    %ecx,%edx
  80235f:	89 f8                	mov    %edi,%eax
  802361:	75 3d                	jne    8023a0 <__udivdi3+0x60>
  802363:	39 cf                	cmp    %ecx,%edi
  802365:	0f 87 c5 00 00 00    	ja     802430 <__udivdi3+0xf0>
  80236b:	85 ff                	test   %edi,%edi
  80236d:	89 fd                	mov    %edi,%ebp
  80236f:	75 0b                	jne    80237c <__udivdi3+0x3c>
  802371:	b8 01 00 00 00       	mov    $0x1,%eax
  802376:	31 d2                	xor    %edx,%edx
  802378:	f7 f7                	div    %edi
  80237a:	89 c5                	mov    %eax,%ebp
  80237c:	89 c8                	mov    %ecx,%eax
  80237e:	31 d2                	xor    %edx,%edx
  802380:	f7 f5                	div    %ebp
  802382:	89 c1                	mov    %eax,%ecx
  802384:	89 d8                	mov    %ebx,%eax
  802386:	89 cf                	mov    %ecx,%edi
  802388:	f7 f5                	div    %ebp
  80238a:	89 c3                	mov    %eax,%ebx
  80238c:	89 d8                	mov    %ebx,%eax
  80238e:	89 fa                	mov    %edi,%edx
  802390:	83 c4 1c             	add    $0x1c,%esp
  802393:	5b                   	pop    %ebx
  802394:	5e                   	pop    %esi
  802395:	5f                   	pop    %edi
  802396:	5d                   	pop    %ebp
  802397:	c3                   	ret    
  802398:	90                   	nop
  802399:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8023a0:	39 ce                	cmp    %ecx,%esi
  8023a2:	77 74                	ja     802418 <__udivdi3+0xd8>
  8023a4:	0f bd fe             	bsr    %esi,%edi
  8023a7:	83 f7 1f             	xor    $0x1f,%edi
  8023aa:	0f 84 98 00 00 00    	je     802448 <__udivdi3+0x108>
  8023b0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8023b5:	89 f9                	mov    %edi,%ecx
  8023b7:	89 c5                	mov    %eax,%ebp
  8023b9:	29 fb                	sub    %edi,%ebx
  8023bb:	d3 e6                	shl    %cl,%esi
  8023bd:	89 d9                	mov    %ebx,%ecx
  8023bf:	d3 ed                	shr    %cl,%ebp
  8023c1:	89 f9                	mov    %edi,%ecx
  8023c3:	d3 e0                	shl    %cl,%eax
  8023c5:	09 ee                	or     %ebp,%esi
  8023c7:	89 d9                	mov    %ebx,%ecx
  8023c9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8023cd:	89 d5                	mov    %edx,%ebp
  8023cf:	8b 44 24 08          	mov    0x8(%esp),%eax
  8023d3:	d3 ed                	shr    %cl,%ebp
  8023d5:	89 f9                	mov    %edi,%ecx
  8023d7:	d3 e2                	shl    %cl,%edx
  8023d9:	89 d9                	mov    %ebx,%ecx
  8023db:	d3 e8                	shr    %cl,%eax
  8023dd:	09 c2                	or     %eax,%edx
  8023df:	89 d0                	mov    %edx,%eax
  8023e1:	89 ea                	mov    %ebp,%edx
  8023e3:	f7 f6                	div    %esi
  8023e5:	89 d5                	mov    %edx,%ebp
  8023e7:	89 c3                	mov    %eax,%ebx
  8023e9:	f7 64 24 0c          	mull   0xc(%esp)
  8023ed:	39 d5                	cmp    %edx,%ebp
  8023ef:	72 10                	jb     802401 <__udivdi3+0xc1>
  8023f1:	8b 74 24 08          	mov    0x8(%esp),%esi
  8023f5:	89 f9                	mov    %edi,%ecx
  8023f7:	d3 e6                	shl    %cl,%esi
  8023f9:	39 c6                	cmp    %eax,%esi
  8023fb:	73 07                	jae    802404 <__udivdi3+0xc4>
  8023fd:	39 d5                	cmp    %edx,%ebp
  8023ff:	75 03                	jne    802404 <__udivdi3+0xc4>
  802401:	83 eb 01             	sub    $0x1,%ebx
  802404:	31 ff                	xor    %edi,%edi
  802406:	89 d8                	mov    %ebx,%eax
  802408:	89 fa                	mov    %edi,%edx
  80240a:	83 c4 1c             	add    $0x1c,%esp
  80240d:	5b                   	pop    %ebx
  80240e:	5e                   	pop    %esi
  80240f:	5f                   	pop    %edi
  802410:	5d                   	pop    %ebp
  802411:	c3                   	ret    
  802412:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802418:	31 ff                	xor    %edi,%edi
  80241a:	31 db                	xor    %ebx,%ebx
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
  802430:	89 d8                	mov    %ebx,%eax
  802432:	f7 f7                	div    %edi
  802434:	31 ff                	xor    %edi,%edi
  802436:	89 c3                	mov    %eax,%ebx
  802438:	89 d8                	mov    %ebx,%eax
  80243a:	89 fa                	mov    %edi,%edx
  80243c:	83 c4 1c             	add    $0x1c,%esp
  80243f:	5b                   	pop    %ebx
  802440:	5e                   	pop    %esi
  802441:	5f                   	pop    %edi
  802442:	5d                   	pop    %ebp
  802443:	c3                   	ret    
  802444:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802448:	39 ce                	cmp    %ecx,%esi
  80244a:	72 0c                	jb     802458 <__udivdi3+0x118>
  80244c:	31 db                	xor    %ebx,%ebx
  80244e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802452:	0f 87 34 ff ff ff    	ja     80238c <__udivdi3+0x4c>
  802458:	bb 01 00 00 00       	mov    $0x1,%ebx
  80245d:	e9 2a ff ff ff       	jmp    80238c <__udivdi3+0x4c>
  802462:	66 90                	xchg   %ax,%ax
  802464:	66 90                	xchg   %ax,%ax
  802466:	66 90                	xchg   %ax,%ax
  802468:	66 90                	xchg   %ax,%ax
  80246a:	66 90                	xchg   %ax,%ax
  80246c:	66 90                	xchg   %ax,%ax
  80246e:	66 90                	xchg   %ax,%ax

00802470 <__umoddi3>:
  802470:	55                   	push   %ebp
  802471:	57                   	push   %edi
  802472:	56                   	push   %esi
  802473:	53                   	push   %ebx
  802474:	83 ec 1c             	sub    $0x1c,%esp
  802477:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80247b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80247f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802483:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802487:	85 d2                	test   %edx,%edx
  802489:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80248d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802491:	89 f3                	mov    %esi,%ebx
  802493:	89 3c 24             	mov    %edi,(%esp)
  802496:	89 74 24 04          	mov    %esi,0x4(%esp)
  80249a:	75 1c                	jne    8024b8 <__umoddi3+0x48>
  80249c:	39 f7                	cmp    %esi,%edi
  80249e:	76 50                	jbe    8024f0 <__umoddi3+0x80>
  8024a0:	89 c8                	mov    %ecx,%eax
  8024a2:	89 f2                	mov    %esi,%edx
  8024a4:	f7 f7                	div    %edi
  8024a6:	89 d0                	mov    %edx,%eax
  8024a8:	31 d2                	xor    %edx,%edx
  8024aa:	83 c4 1c             	add    $0x1c,%esp
  8024ad:	5b                   	pop    %ebx
  8024ae:	5e                   	pop    %esi
  8024af:	5f                   	pop    %edi
  8024b0:	5d                   	pop    %ebp
  8024b1:	c3                   	ret    
  8024b2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8024b8:	39 f2                	cmp    %esi,%edx
  8024ba:	89 d0                	mov    %edx,%eax
  8024bc:	77 52                	ja     802510 <__umoddi3+0xa0>
  8024be:	0f bd ea             	bsr    %edx,%ebp
  8024c1:	83 f5 1f             	xor    $0x1f,%ebp
  8024c4:	75 5a                	jne    802520 <__umoddi3+0xb0>
  8024c6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8024ca:	0f 82 e0 00 00 00    	jb     8025b0 <__umoddi3+0x140>
  8024d0:	39 0c 24             	cmp    %ecx,(%esp)
  8024d3:	0f 86 d7 00 00 00    	jbe    8025b0 <__umoddi3+0x140>
  8024d9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8024dd:	8b 54 24 04          	mov    0x4(%esp),%edx
  8024e1:	83 c4 1c             	add    $0x1c,%esp
  8024e4:	5b                   	pop    %ebx
  8024e5:	5e                   	pop    %esi
  8024e6:	5f                   	pop    %edi
  8024e7:	5d                   	pop    %ebp
  8024e8:	c3                   	ret    
  8024e9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8024f0:	85 ff                	test   %edi,%edi
  8024f2:	89 fd                	mov    %edi,%ebp
  8024f4:	75 0b                	jne    802501 <__umoddi3+0x91>
  8024f6:	b8 01 00 00 00       	mov    $0x1,%eax
  8024fb:	31 d2                	xor    %edx,%edx
  8024fd:	f7 f7                	div    %edi
  8024ff:	89 c5                	mov    %eax,%ebp
  802501:	89 f0                	mov    %esi,%eax
  802503:	31 d2                	xor    %edx,%edx
  802505:	f7 f5                	div    %ebp
  802507:	89 c8                	mov    %ecx,%eax
  802509:	f7 f5                	div    %ebp
  80250b:	89 d0                	mov    %edx,%eax
  80250d:	eb 99                	jmp    8024a8 <__umoddi3+0x38>
  80250f:	90                   	nop
  802510:	89 c8                	mov    %ecx,%eax
  802512:	89 f2                	mov    %esi,%edx
  802514:	83 c4 1c             	add    $0x1c,%esp
  802517:	5b                   	pop    %ebx
  802518:	5e                   	pop    %esi
  802519:	5f                   	pop    %edi
  80251a:	5d                   	pop    %ebp
  80251b:	c3                   	ret    
  80251c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802520:	8b 34 24             	mov    (%esp),%esi
  802523:	bf 20 00 00 00       	mov    $0x20,%edi
  802528:	89 e9                	mov    %ebp,%ecx
  80252a:	29 ef                	sub    %ebp,%edi
  80252c:	d3 e0                	shl    %cl,%eax
  80252e:	89 f9                	mov    %edi,%ecx
  802530:	89 f2                	mov    %esi,%edx
  802532:	d3 ea                	shr    %cl,%edx
  802534:	89 e9                	mov    %ebp,%ecx
  802536:	09 c2                	or     %eax,%edx
  802538:	89 d8                	mov    %ebx,%eax
  80253a:	89 14 24             	mov    %edx,(%esp)
  80253d:	89 f2                	mov    %esi,%edx
  80253f:	d3 e2                	shl    %cl,%edx
  802541:	89 f9                	mov    %edi,%ecx
  802543:	89 54 24 04          	mov    %edx,0x4(%esp)
  802547:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80254b:	d3 e8                	shr    %cl,%eax
  80254d:	89 e9                	mov    %ebp,%ecx
  80254f:	89 c6                	mov    %eax,%esi
  802551:	d3 e3                	shl    %cl,%ebx
  802553:	89 f9                	mov    %edi,%ecx
  802555:	89 d0                	mov    %edx,%eax
  802557:	d3 e8                	shr    %cl,%eax
  802559:	89 e9                	mov    %ebp,%ecx
  80255b:	09 d8                	or     %ebx,%eax
  80255d:	89 d3                	mov    %edx,%ebx
  80255f:	89 f2                	mov    %esi,%edx
  802561:	f7 34 24             	divl   (%esp)
  802564:	89 d6                	mov    %edx,%esi
  802566:	d3 e3                	shl    %cl,%ebx
  802568:	f7 64 24 04          	mull   0x4(%esp)
  80256c:	39 d6                	cmp    %edx,%esi
  80256e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802572:	89 d1                	mov    %edx,%ecx
  802574:	89 c3                	mov    %eax,%ebx
  802576:	72 08                	jb     802580 <__umoddi3+0x110>
  802578:	75 11                	jne    80258b <__umoddi3+0x11b>
  80257a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80257e:	73 0b                	jae    80258b <__umoddi3+0x11b>
  802580:	2b 44 24 04          	sub    0x4(%esp),%eax
  802584:	1b 14 24             	sbb    (%esp),%edx
  802587:	89 d1                	mov    %edx,%ecx
  802589:	89 c3                	mov    %eax,%ebx
  80258b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80258f:	29 da                	sub    %ebx,%edx
  802591:	19 ce                	sbb    %ecx,%esi
  802593:	89 f9                	mov    %edi,%ecx
  802595:	89 f0                	mov    %esi,%eax
  802597:	d3 e0                	shl    %cl,%eax
  802599:	89 e9                	mov    %ebp,%ecx
  80259b:	d3 ea                	shr    %cl,%edx
  80259d:	89 e9                	mov    %ebp,%ecx
  80259f:	d3 ee                	shr    %cl,%esi
  8025a1:	09 d0                	or     %edx,%eax
  8025a3:	89 f2                	mov    %esi,%edx
  8025a5:	83 c4 1c             	add    $0x1c,%esp
  8025a8:	5b                   	pop    %ebx
  8025a9:	5e                   	pop    %esi
  8025aa:	5f                   	pop    %edi
  8025ab:	5d                   	pop    %ebp
  8025ac:	c3                   	ret    
  8025ad:	8d 76 00             	lea    0x0(%esi),%esi
  8025b0:	29 f9                	sub    %edi,%ecx
  8025b2:	19 d6                	sbb    %edx,%esi
  8025b4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8025b8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8025bc:	e9 18 ff ff ff       	jmp    8024d9 <__umoddi3+0x69>
