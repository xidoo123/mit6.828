
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
  800047:	e8 2f 10 00 00       	call   80107b <ipc_recv>
  80004c:	89 c3                	mov    %eax,%ebx
	cprintf("CPU %d: %d ", thisenv->env_cpunum, p);
  80004e:	a1 04 40 80 00       	mov    0x804004,%eax
  800053:	8b 40 5c             	mov    0x5c(%eax),%eax
  800056:	83 c4 0c             	add    $0xc,%esp
  800059:	53                   	push   %ebx
  80005a:	50                   	push   %eax
  80005b:	68 a0 21 80 00       	push   $0x8021a0
  800060:	e8 cc 01 00 00       	call   800231 <cprintf>

	// fork a right neighbor to continue the chain
	if ((id = fork()) < 0)
  800065:	e8 57 0e 00 00       	call   800ec1 <fork>
  80006a:	89 c7                	mov    %eax,%edi
  80006c:	83 c4 10             	add    $0x10,%esp
  80006f:	85 c0                	test   %eax,%eax
  800071:	79 12                	jns    800085 <primeproc+0x52>
		panic("fork: %e", id);
  800073:	50                   	push   %eax
  800074:	68 ac 21 80 00       	push   $0x8021ac
  800079:	6a 1a                	push   $0x1a
  80007b:	68 b5 21 80 00       	push   $0x8021b5
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
  800094:	e8 e2 0f 00 00       	call   80107b <ipc_recv>
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
  8000ab:	e8 32 10 00 00       	call   8010e2 <ipc_send>
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
  8000ba:	e8 02 0e 00 00       	call   800ec1 <fork>
  8000bf:	89 c6                	mov    %eax,%esi
  8000c1:	85 c0                	test   %eax,%eax
  8000c3:	79 12                	jns    8000d7 <umain+0x22>
		panic("fork: %e", id);
  8000c5:	50                   	push   %eax
  8000c6:	68 ac 21 80 00       	push   $0x8021ac
  8000cb:	6a 2d                	push   $0x2d
  8000cd:	68 b5 21 80 00       	push   $0x8021b5
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
  8000eb:	e8 f2 0f 00 00       	call   8010e2 <ipc_send>
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
  800144:	e8 f1 11 00 00       	call   80133a <close_all>
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
  800176:	68 d0 21 80 00       	push   $0x8021d0
  80017b:	e8 b1 00 00 00       	call   800231 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800180:	83 c4 18             	add    $0x18,%esp
  800183:	53                   	push   %ebx
  800184:	ff 75 10             	pushl  0x10(%ebp)
  800187:	e8 54 00 00 00       	call   8001e0 <vcprintf>
	cprintf("\n");
  80018c:	c7 04 24 e9 25 80 00 	movl   $0x8025e9,(%esp)
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
  800294:	e8 67 1c 00 00       	call   801f00 <__udivdi3>
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
  8002d7:	e8 54 1d 00 00       	call   802030 <__umoddi3>
  8002dc:	83 c4 14             	add    $0x14,%esp
  8002df:	0f be 80 f3 21 80 00 	movsbl 0x8021f3(%eax),%eax
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
  8003db:	ff 24 85 40 23 80 00 	jmp    *0x802340(,%eax,4)
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
  80049f:	8b 14 85 a0 24 80 00 	mov    0x8024a0(,%eax,4),%edx
  8004a6:	85 d2                	test   %edx,%edx
  8004a8:	75 18                	jne    8004c2 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8004aa:	50                   	push   %eax
  8004ab:	68 0b 22 80 00       	push   $0x80220b
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
  8004c3:	68 c1 26 80 00       	push   $0x8026c1
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
  8004e7:	b8 04 22 80 00       	mov    $0x802204,%eax
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
  800b62:	68 ff 24 80 00       	push   $0x8024ff
  800b67:	6a 23                	push   $0x23
  800b69:	68 1c 25 80 00       	push   $0x80251c
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
  800be3:	68 ff 24 80 00       	push   $0x8024ff
  800be8:	6a 23                	push   $0x23
  800bea:	68 1c 25 80 00       	push   $0x80251c
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
  800c25:	68 ff 24 80 00       	push   $0x8024ff
  800c2a:	6a 23                	push   $0x23
  800c2c:	68 1c 25 80 00       	push   $0x80251c
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
  800c67:	68 ff 24 80 00       	push   $0x8024ff
  800c6c:	6a 23                	push   $0x23
  800c6e:	68 1c 25 80 00       	push   $0x80251c
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
  800ca9:	68 ff 24 80 00       	push   $0x8024ff
  800cae:	6a 23                	push   $0x23
  800cb0:	68 1c 25 80 00       	push   $0x80251c
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
  800ceb:	68 ff 24 80 00       	push   $0x8024ff
  800cf0:	6a 23                	push   $0x23
  800cf2:	68 1c 25 80 00       	push   $0x80251c
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
  800d2d:	68 ff 24 80 00       	push   $0x8024ff
  800d32:	6a 23                	push   $0x23
  800d34:	68 1c 25 80 00       	push   $0x80251c
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
  800d91:	68 ff 24 80 00       	push   $0x8024ff
  800d96:	6a 23                	push   $0x23
  800d98:	68 1c 25 80 00       	push   $0x80251c
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
  800dad:	57                   	push   %edi
  800dae:	56                   	push   %esi
  800daf:	53                   	push   %ebx
  800db0:	83 ec 0c             	sub    $0xc,%esp
  800db3:	8b 75 08             	mov    0x8(%ebp),%esi
	void *addr = (void *) utf->utf_fault_va;
  800db6:	8b 1e                	mov    (%esi),%ebx
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.

	if ((err & FEC_WR) != FEC_WR && ((uvpt[PGNUM(addr)] & PTE_COW) != PTE_COW)) {
  800db8:	f6 46 04 02          	testb  $0x2,0x4(%esi)
  800dbc:	75 25                	jne    800de3 <pgfault+0x39>
  800dbe:	89 d8                	mov    %ebx,%eax
  800dc0:	c1 e8 0c             	shr    $0xc,%eax
  800dc3:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800dca:	f6 c4 08             	test   $0x8,%ah
  800dcd:	75 14                	jne    800de3 <pgfault+0x39>
		panic("pgfault: not due to a write or a COW page");
  800dcf:	83 ec 04             	sub    $0x4,%esp
  800dd2:	68 2c 25 80 00       	push   $0x80252c
  800dd7:	6a 1e                	push   $0x1e
  800dd9:	68 c0 25 80 00       	push   $0x8025c0
  800dde:	e8 75 f3 ff ff       	call   800158 <_panic>

	// LAB 4: Your code here.

	// panic("pgfault not implemented");

	addr = ROUNDDOWN(addr, PGSIZE);
  800de3:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	envid_t envid = sys_getenvid();
  800de9:	e8 8d fd ff ff       	call   800b7b <sys_getenvid>
  800dee:	89 c7                	mov    %eax,%edi

	if ( (uint32_t)addr ==  0xeebfd000) {
  800df0:	81 fb 00 d0 bf ee    	cmp    $0xeebfd000,%ebx
  800df6:	75 31                	jne    800e29 <pgfault+0x7f>
		cprintf("[hit %e]\n", utf->utf_err);
  800df8:	83 ec 08             	sub    $0x8,%esp
  800dfb:	ff 76 04             	pushl  0x4(%esi)
  800dfe:	68 cb 25 80 00       	push   $0x8025cb
  800e03:	e8 29 f4 ff ff       	call   800231 <cprintf>
		cprintf("[hit 0x%x]\n", utf->utf_eip);
  800e08:	83 c4 08             	add    $0x8,%esp
  800e0b:	ff 76 28             	pushl  0x28(%esi)
  800e0e:	68 d5 25 80 00       	push   $0x8025d5
  800e13:	e8 19 f4 ff ff       	call   800231 <cprintf>
		cprintf("[hit %d]\n", envid);
  800e18:	83 c4 08             	add    $0x8,%esp
  800e1b:	57                   	push   %edi
  800e1c:	68 e1 25 80 00       	push   $0x8025e1
  800e21:	e8 0b f4 ff ff       	call   800231 <cprintf>
  800e26:	83 c4 10             	add    $0x10,%esp
	}

	// envid = 0;

	// Allocate a new page, map it at a temporary location (PFTEMP)
	r = sys_page_alloc(envid, (void *)PFTEMP, PTE_U | PTE_P | PTE_W);
  800e29:	83 ec 04             	sub    $0x4,%esp
  800e2c:	6a 07                	push   $0x7
  800e2e:	68 00 f0 7f 00       	push   $0x7ff000
  800e33:	57                   	push   %edi
  800e34:	e8 80 fd ff ff       	call   800bb9 <sys_page_alloc>
	if (r < 0)
  800e39:	83 c4 10             	add    $0x10,%esp
  800e3c:	85 c0                	test   %eax,%eax
  800e3e:	79 12                	jns    800e52 <pgfault+0xa8>
		panic("pgfault: sys_page_alloc failed: %e\n", r);
  800e40:	50                   	push   %eax
  800e41:	68 58 25 80 00       	push   $0x802558
  800e46:	6a 39                	push   $0x39
  800e48:	68 c0 25 80 00       	push   $0x8025c0
  800e4d:	e8 06 f3 ff ff       	call   800158 <_panic>
	
	// copy the data from the old page to the new page
	memcpy((void *) PFTEMP, (const void *) addr, PGSIZE);
  800e52:	83 ec 04             	sub    $0x4,%esp
  800e55:	68 00 10 00 00       	push   $0x1000
  800e5a:	53                   	push   %ebx
  800e5b:	68 00 f0 7f 00       	push   $0x7ff000
  800e60:	e8 4b fb ff ff       	call   8009b0 <memcpy>

	// move the new page to the old page's address
	r = sys_page_map(envid, (void *) PFTEMP, envid, addr, PTE_U | PTE_P | PTE_W);
  800e65:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800e6c:	53                   	push   %ebx
  800e6d:	57                   	push   %edi
  800e6e:	68 00 f0 7f 00       	push   $0x7ff000
  800e73:	57                   	push   %edi
  800e74:	e8 83 fd ff ff       	call   800bfc <sys_page_map>
	if (r < 0)
  800e79:	83 c4 20             	add    $0x20,%esp
  800e7c:	85 c0                	test   %eax,%eax
  800e7e:	79 12                	jns    800e92 <pgfault+0xe8>
		panic("pgfault: sys_page_map failed: %e\n", r);
  800e80:	50                   	push   %eax
  800e81:	68 7c 25 80 00       	push   $0x80257c
  800e86:	6a 41                	push   $0x41
  800e88:	68 c0 25 80 00       	push   $0x8025c0
  800e8d:	e8 c6 f2 ff ff       	call   800158 <_panic>

	// unmap temporary region
	r = sys_page_unmap(envid, (void *) PFTEMP);
  800e92:	83 ec 08             	sub    $0x8,%esp
  800e95:	68 00 f0 7f 00       	push   $0x7ff000
  800e9a:	57                   	push   %edi
  800e9b:	e8 9e fd ff ff       	call   800c3e <sys_page_unmap>
	if (r < 0)
  800ea0:	83 c4 10             	add    $0x10,%esp
  800ea3:	85 c0                	test   %eax,%eax
  800ea5:	79 12                	jns    800eb9 <pgfault+0x10f>
        panic("pgfault: page unmap failed: %e\n", r);
  800ea7:	50                   	push   %eax
  800ea8:	68 a0 25 80 00       	push   $0x8025a0
  800ead:	6a 46                	push   $0x46
  800eaf:	68 c0 25 80 00       	push   $0x8025c0
  800eb4:	e8 9f f2 ff ff       	call   800158 <_panic>
}
  800eb9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ebc:	5b                   	pop    %ebx
  800ebd:	5e                   	pop    %esi
  800ebe:	5f                   	pop    %edi
  800ebf:	5d                   	pop    %ebp
  800ec0:	c3                   	ret    

00800ec1 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800ec1:	55                   	push   %ebp
  800ec2:	89 e5                	mov    %esp,%ebp
  800ec4:	57                   	push   %edi
  800ec5:	56                   	push   %esi
  800ec6:	53                   	push   %ebx
  800ec7:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	// cprintf("[fork]\n");
	int r;

	set_pgfault_handler(pgfault);
  800eca:	68 aa 0d 80 00       	push   $0x800daa
  800ecf:	e8 78 0f 00 00       	call   801e4c <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800ed4:	b8 07 00 00 00       	mov    $0x7,%eax
  800ed9:	cd 30                	int    $0x30

	envid_t envid = sys_exofork();
	if (envid < 0)
  800edb:	83 c4 10             	add    $0x10,%esp
  800ede:	85 c0                	test   %eax,%eax
  800ee0:	0f 88 67 01 00 00    	js     80104d <fork+0x18c>
  800ee6:	bb 00 00 80 00       	mov    $0x800000,%ebx
  800eeb:	be 00 08 00 00       	mov    $0x800,%esi
		return envid;

	// fix "thisenv" in the child process
	if (envid == 0) {
  800ef0:	85 c0                	test   %eax,%eax
  800ef2:	75 21                	jne    800f15 <fork+0x54>
		thisenv = &envs[ENVX(sys_getenvid())];
  800ef4:	e8 82 fc ff ff       	call   800b7b <sys_getenvid>
  800ef9:	25 ff 03 00 00       	and    $0x3ff,%eax
  800efe:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800f01:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800f06:	a3 04 40 80 00       	mov    %eax,0x804004
        return 0;
  800f0b:	ba 00 00 00 00       	mov    $0x0,%edx
  800f10:	e9 42 01 00 00       	jmp    801057 <fork+0x196>
  800f15:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800f18:	89 c7                	mov    %eax,%edi
	for (uint32_t pn = PGNUM(UTEXT); pn < PGNUM(USTACKTOP); pn++) {

		addr = pn * PGSIZE;

		// if level-2 page exists
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P) {
  800f1a:	89 d8                	mov    %ebx,%eax
  800f1c:	c1 e8 16             	shr    $0x16,%eax
  800f1f:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f26:	a8 01                	test   $0x1,%al
  800f28:	0f 84 c0 00 00 00    	je     800fee <fork+0x12d>
			
			// if real PTE exists
			if ((uvpt[PGNUM(addr)] & PTE_P) == PTE_P) {
  800f2e:	89 d8                	mov    %ebx,%eax
  800f30:	c1 e8 0c             	shr    $0xc,%eax
  800f33:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f3a:	f6 c2 01             	test   $0x1,%dl
  800f3d:	0f 84 ab 00 00 00    	je     800fee <fork+0x12d>

				// For each writable or copy-on-write page
				if ((uvpt[PGNUM(addr)] & (PTE_W | PTE_COW)) != 0) {
  800f43:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f4a:	a9 02 08 00 00       	test   $0x802,%eax
  800f4f:	0f 84 99 00 00 00    	je     800fee <fork+0x12d>
	// r = envid2env(envid, &env, 1);
	// if (r < 0)
	// 	return r;	// E_BAD_ENV
	// envid_t parent_envid = env->env_parent_id;

	if (uvpt[pn] & PTE_SHARE) {
  800f55:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800f5c:	f6 c4 04             	test   $0x4,%ah
  800f5f:	74 17                	je     800f78 <fork+0xb7>
		sys_page_map(0, (void *)va, envid, (void *)va, PTE_SYSCALL);
  800f61:	83 ec 0c             	sub    $0xc,%esp
  800f64:	68 07 0e 00 00       	push   $0xe07
  800f69:	53                   	push   %ebx
  800f6a:	57                   	push   %edi
  800f6b:	53                   	push   %ebx
  800f6c:	6a 00                	push   $0x0
  800f6e:	e8 89 fc ff ff       	call   800bfc <sys_page_map>
  800f73:	83 c4 20             	add    $0x20,%esp
  800f76:	eb 76                	jmp    800fee <fork+0x12d>
	}
	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {
  800f78:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800f7f:	a8 02                	test   $0x2,%al
  800f81:	75 0c                	jne    800f8f <fork+0xce>
  800f83:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800f8a:	f6 c4 08             	test   $0x8,%ah
  800f8d:	74 3f                	je     800fce <fork+0x10d>

		// map the page copy-on-write into the address space of the child
        r = sys_page_map(0, (void *)va, envid, (void *)va, PTE_P|PTE_U|PTE_COW);
  800f8f:	83 ec 0c             	sub    $0xc,%esp
  800f92:	68 05 08 00 00       	push   $0x805
  800f97:	53                   	push   %ebx
  800f98:	57                   	push   %edi
  800f99:	53                   	push   %ebx
  800f9a:	6a 00                	push   $0x0
  800f9c:	e8 5b fc ff ff       	call   800bfc <sys_page_map>
		if (r < 0)
  800fa1:	83 c4 20             	add    $0x20,%esp
  800fa4:	85 c0                	test   %eax,%eax
  800fa6:	0f 88 a5 00 00 00    	js     801051 <fork+0x190>
            return r;

		// remap the page copy-on-write in its own(parent) address space
        r = sys_page_map(0, (void *)va, 0, (void *)va, PTE_P|PTE_U|PTE_COW);
  800fac:	83 ec 0c             	sub    $0xc,%esp
  800faf:	68 05 08 00 00       	push   $0x805
  800fb4:	53                   	push   %ebx
  800fb5:	6a 00                	push   $0x0
  800fb7:	53                   	push   %ebx
  800fb8:	6a 00                	push   $0x0
  800fba:	e8 3d fc ff ff       	call   800bfc <sys_page_map>
  800fbf:	83 c4 20             	add    $0x20,%esp
  800fc2:	85 c0                	test   %eax,%eax
  800fc4:	b9 00 00 00 00       	mov    $0x0,%ecx
  800fc9:	0f 4f c1             	cmovg  %ecx,%eax
  800fcc:	eb 1c                	jmp    800fea <fork+0x129>
		if (r < 0)
            return r;
    }
    else {
        r = sys_page_map(0, (void *)va, envid, (void *)va, PTE_P|PTE_U);
  800fce:	83 ec 0c             	sub    $0xc,%esp
  800fd1:	6a 05                	push   $0x5
  800fd3:	53                   	push   %ebx
  800fd4:	57                   	push   %edi
  800fd5:	53                   	push   %ebx
  800fd6:	6a 00                	push   $0x0
  800fd8:	e8 1f fc ff ff       	call   800bfc <sys_page_map>
  800fdd:	83 c4 20             	add    $0x20,%esp
  800fe0:	85 c0                	test   %eax,%eax
  800fe2:	b9 00 00 00 00       	mov    $0x0,%ecx
  800fe7:	0f 4f c1             	cmovg  %ecx,%eax
			if ((uvpt[PGNUM(addr)] & PTE_P) == PTE_P) {

				// For each writable or copy-on-write page
				if ((uvpt[PGNUM(addr)] & (PTE_W | PTE_COW)) != 0) {
					r = duppage(envid, pn);
					if (r < 0)
  800fea:	85 c0                	test   %eax,%eax
  800fec:	78 67                	js     801055 <fork+0x194>
        return 0;
	}

	// For each writable or copy-on-write page in its address space below UTOP, the parent calls duppage
	uint32_t addr;
	for (uint32_t pn = PGNUM(UTEXT); pn < PGNUM(USTACKTOP); pn++) {
  800fee:	83 c6 01             	add    $0x1,%esi
  800ff1:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  800ff7:	81 fe fe eb 0e 00    	cmp    $0xeebfe,%esi
  800ffd:	0f 85 17 ff ff ff    	jne    800f1a <fork+0x59>
  801003:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
		}
	}

	// allocate a fresh page in the child for the exception stack
	r = sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U | PTE_P | PTE_W);
  801006:	83 ec 04             	sub    $0x4,%esp
  801009:	6a 07                	push   $0x7
  80100b:	68 00 f0 bf ee       	push   $0xeebff000
  801010:	57                   	push   %edi
  801011:	e8 a3 fb ff ff       	call   800bb9 <sys_page_alloc>
	if (r < 0)
  801016:	83 c4 10             	add    $0x10,%esp
		return r;
  801019:	89 c2                	mov    %eax,%edx
		}
	}

	// allocate a fresh page in the child for the exception stack
	r = sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U | PTE_P | PTE_W);
	if (r < 0)
  80101b:	85 c0                	test   %eax,%eax
  80101d:	78 38                	js     801057 <fork+0x196>
		return r;

	// The parent sets the user page fault entrypoint for the child to look like its own
	extern void _pgfault_upcall(void);
	r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  80101f:	83 ec 08             	sub    $0x8,%esp
  801022:	68 93 1e 80 00       	push   $0x801e93
  801027:	57                   	push   %edi
  801028:	e8 d7 fc ff ff       	call   800d04 <sys_env_set_pgfault_upcall>
	if (r < 0)
  80102d:	83 c4 10             	add    $0x10,%esp
		return r;
  801030:	89 c2                	mov    %eax,%edx
		return r;

	// The parent sets the user page fault entrypoint for the child to look like its own
	extern void _pgfault_upcall(void);
	r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
	if (r < 0)
  801032:	85 c0                	test   %eax,%eax
  801034:	78 21                	js     801057 <fork+0x196>
		return r;

	// The child is now ready to run, so the parent marks it runnable
	r = sys_env_set_status(envid, ENV_RUNNABLE);
  801036:	83 ec 08             	sub    $0x8,%esp
  801039:	6a 02                	push   $0x2
  80103b:	57                   	push   %edi
  80103c:	e8 3f fc ff ff       	call   800c80 <sys_env_set_status>
	if (r < 0)
  801041:	83 c4 10             	add    $0x10,%esp
		return r;

	return envid;
  801044:	85 c0                	test   %eax,%eax
  801046:	0f 48 f8             	cmovs  %eax,%edi
  801049:	89 fa                	mov    %edi,%edx
  80104b:	eb 0a                	jmp    801057 <fork+0x196>

	set_pgfault_handler(pgfault);

	envid_t envid = sys_exofork();
	if (envid < 0)
		return envid;
  80104d:	89 c2                	mov    %eax,%edx
  80104f:	eb 06                	jmp    801057 <fork+0x196>
		sys_page_map(0, (void *)va, envid, (void *)va, PTE_SYSCALL);
	}
	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {

		// map the page copy-on-write into the address space of the child
        r = sys_page_map(0, (void *)va, envid, (void *)va, PTE_P|PTE_U|PTE_COW);
  801051:	89 c2                	mov    %eax,%edx
  801053:	eb 02                	jmp    801057 <fork+0x196>
  801055:	89 c2                	mov    %eax,%edx
	if (r < 0)
		return r;

	return envid;
	// panic("fork not implemented");
}
  801057:	89 d0                	mov    %edx,%eax
  801059:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80105c:	5b                   	pop    %ebx
  80105d:	5e                   	pop    %esi
  80105e:	5f                   	pop    %edi
  80105f:	5d                   	pop    %ebp
  801060:	c3                   	ret    

00801061 <sfork>:

// Challenge!
int
sfork(void)
{
  801061:	55                   	push   %ebp
  801062:	89 e5                	mov    %esp,%ebp
  801064:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801067:	68 eb 25 80 00       	push   $0x8025eb
  80106c:	68 ce 00 00 00       	push   $0xce
  801071:	68 c0 25 80 00       	push   $0x8025c0
  801076:	e8 dd f0 ff ff       	call   800158 <_panic>

0080107b <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80107b:	55                   	push   %ebp
  80107c:	89 e5                	mov    %esp,%ebp
  80107e:	56                   	push   %esi
  80107f:	53                   	push   %ebx
  801080:	8b 75 08             	mov    0x8(%ebp),%esi
  801083:	8b 45 0c             	mov    0xc(%ebp),%eax
  801086:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");

	// don't want to recv page
	if (pg == NULL)
  801089:	85 c0                	test   %eax,%eax
		pg = (void *)UTOP;
  80108b:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801090:	0f 44 c2             	cmove  %edx,%eax

	int err = sys_ipc_recv(pg);
  801093:	83 ec 0c             	sub    $0xc,%esp
  801096:	50                   	push   %eax
  801097:	e8 cd fc ff ff       	call   800d69 <sys_ipc_recv>

	if (from_env_store != NULL)
  80109c:	83 c4 10             	add    $0x10,%esp
  80109f:	85 f6                	test   %esi,%esi
  8010a1:	74 14                	je     8010b7 <ipc_recv+0x3c>
		*from_env_store = err < 0? 0 : thisenv->env_ipc_from;
  8010a3:	ba 00 00 00 00       	mov    $0x0,%edx
  8010a8:	85 c0                	test   %eax,%eax
  8010aa:	78 09                	js     8010b5 <ipc_recv+0x3a>
  8010ac:	8b 15 04 40 80 00    	mov    0x804004,%edx
  8010b2:	8b 52 74             	mov    0x74(%edx),%edx
  8010b5:	89 16                	mov    %edx,(%esi)
	
	if (perm_store != NULL)
  8010b7:	85 db                	test   %ebx,%ebx
  8010b9:	74 14                	je     8010cf <ipc_recv+0x54>
		*perm_store = err < 0? 0 : thisenv->env_ipc_perm;
  8010bb:	ba 00 00 00 00       	mov    $0x0,%edx
  8010c0:	85 c0                	test   %eax,%eax
  8010c2:	78 09                	js     8010cd <ipc_recv+0x52>
  8010c4:	8b 15 04 40 80 00    	mov    0x804004,%edx
  8010ca:	8b 52 78             	mov    0x78(%edx),%edx
  8010cd:	89 13                	mov    %edx,(%ebx)

	if (err < 0)
  8010cf:	85 c0                	test   %eax,%eax
  8010d1:	78 08                	js     8010db <ipc_recv+0x60>
		return err;
	return thisenv->env_ipc_value;
  8010d3:	a1 04 40 80 00       	mov    0x804004,%eax
  8010d8:	8b 40 70             	mov    0x70(%eax),%eax
}
  8010db:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8010de:	5b                   	pop    %ebx
  8010df:	5e                   	pop    %esi
  8010e0:	5d                   	pop    %ebp
  8010e1:	c3                   	ret    

008010e2 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8010e2:	55                   	push   %ebp
  8010e3:	89 e5                	mov    %esp,%ebp
  8010e5:	57                   	push   %edi
  8010e6:	56                   	push   %esi
  8010e7:	53                   	push   %ebx
  8010e8:	83 ec 0c             	sub    $0xc,%esp
  8010eb:	8b 7d 08             	mov    0x8(%ebp),%edi
  8010ee:	8b 75 0c             	mov    0xc(%ebp),%esi
  8010f1:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");

	// don't want to send page
	if (pg == NULL)
  8010f4:	85 db                	test   %ebx,%ebx
		pg = (void *)UTOP;
  8010f6:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  8010fb:	0f 44 d8             	cmove  %eax,%ebx
	
	int err = 0;
	
	do {

		err = sys_ipc_try_send(to_env, val, pg, perm);
  8010fe:	ff 75 14             	pushl  0x14(%ebp)
  801101:	53                   	push   %ebx
  801102:	56                   	push   %esi
  801103:	57                   	push   %edi
  801104:	e8 3d fc ff ff       	call   800d46 <sys_ipc_try_send>

		if (err < 0) {
  801109:	83 c4 10             	add    $0x10,%esp
  80110c:	85 c0                	test   %eax,%eax
  80110e:	79 1e                	jns    80112e <ipc_send+0x4c>
			if (err == -E_IPC_NOT_RECV)
  801110:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801113:	75 07                	jne    80111c <ipc_send+0x3a>
				sys_yield();
  801115:	e8 80 fa ff ff       	call   800b9a <sys_yield>
  80111a:	eb e2                	jmp    8010fe <ipc_send+0x1c>
			else 
				panic("ipc_send: %e", err);
  80111c:	50                   	push   %eax
  80111d:	68 01 26 80 00       	push   $0x802601
  801122:	6a 49                	push   $0x49
  801124:	68 0e 26 80 00       	push   $0x80260e
  801129:	e8 2a f0 ff ff       	call   800158 <_panic>
		}

	} while (err < 0);

}
  80112e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801131:	5b                   	pop    %ebx
  801132:	5e                   	pop    %esi
  801133:	5f                   	pop    %edi
  801134:	5d                   	pop    %ebp
  801135:	c3                   	ret    

00801136 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801136:	55                   	push   %ebp
  801137:	89 e5                	mov    %esp,%ebp
  801139:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80113c:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801141:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801144:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80114a:	8b 52 50             	mov    0x50(%edx),%edx
  80114d:	39 ca                	cmp    %ecx,%edx
  80114f:	75 0d                	jne    80115e <ipc_find_env+0x28>
			return envs[i].env_id;
  801151:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801154:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801159:	8b 40 48             	mov    0x48(%eax),%eax
  80115c:	eb 0f                	jmp    80116d <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80115e:	83 c0 01             	add    $0x1,%eax
  801161:	3d 00 04 00 00       	cmp    $0x400,%eax
  801166:	75 d9                	jne    801141 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801168:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80116d:	5d                   	pop    %ebp
  80116e:	c3                   	ret    

0080116f <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80116f:	55                   	push   %ebp
  801170:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801172:	8b 45 08             	mov    0x8(%ebp),%eax
  801175:	05 00 00 00 30       	add    $0x30000000,%eax
  80117a:	c1 e8 0c             	shr    $0xc,%eax
}
  80117d:	5d                   	pop    %ebp
  80117e:	c3                   	ret    

0080117f <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80117f:	55                   	push   %ebp
  801180:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801182:	8b 45 08             	mov    0x8(%ebp),%eax
  801185:	05 00 00 00 30       	add    $0x30000000,%eax
  80118a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80118f:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801194:	5d                   	pop    %ebp
  801195:	c3                   	ret    

00801196 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801196:	55                   	push   %ebp
  801197:	89 e5                	mov    %esp,%ebp
  801199:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80119c:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8011a1:	89 c2                	mov    %eax,%edx
  8011a3:	c1 ea 16             	shr    $0x16,%edx
  8011a6:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8011ad:	f6 c2 01             	test   $0x1,%dl
  8011b0:	74 11                	je     8011c3 <fd_alloc+0x2d>
  8011b2:	89 c2                	mov    %eax,%edx
  8011b4:	c1 ea 0c             	shr    $0xc,%edx
  8011b7:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8011be:	f6 c2 01             	test   $0x1,%dl
  8011c1:	75 09                	jne    8011cc <fd_alloc+0x36>
			*fd_store = fd;
  8011c3:	89 01                	mov    %eax,(%ecx)
			return 0;
  8011c5:	b8 00 00 00 00       	mov    $0x0,%eax
  8011ca:	eb 17                	jmp    8011e3 <fd_alloc+0x4d>
  8011cc:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8011d1:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8011d6:	75 c9                	jne    8011a1 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8011d8:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8011de:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8011e3:	5d                   	pop    %ebp
  8011e4:	c3                   	ret    

008011e5 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8011e5:	55                   	push   %ebp
  8011e6:	89 e5                	mov    %esp,%ebp
  8011e8:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8011eb:	83 f8 1f             	cmp    $0x1f,%eax
  8011ee:	77 36                	ja     801226 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8011f0:	c1 e0 0c             	shl    $0xc,%eax
  8011f3:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8011f8:	89 c2                	mov    %eax,%edx
  8011fa:	c1 ea 16             	shr    $0x16,%edx
  8011fd:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801204:	f6 c2 01             	test   $0x1,%dl
  801207:	74 24                	je     80122d <fd_lookup+0x48>
  801209:	89 c2                	mov    %eax,%edx
  80120b:	c1 ea 0c             	shr    $0xc,%edx
  80120e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801215:	f6 c2 01             	test   $0x1,%dl
  801218:	74 1a                	je     801234 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80121a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80121d:	89 02                	mov    %eax,(%edx)
	return 0;
  80121f:	b8 00 00 00 00       	mov    $0x0,%eax
  801224:	eb 13                	jmp    801239 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801226:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80122b:	eb 0c                	jmp    801239 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80122d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801232:	eb 05                	jmp    801239 <fd_lookup+0x54>
  801234:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801239:	5d                   	pop    %ebp
  80123a:	c3                   	ret    

0080123b <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80123b:	55                   	push   %ebp
  80123c:	89 e5                	mov    %esp,%ebp
  80123e:	83 ec 08             	sub    $0x8,%esp
  801241:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801244:	ba 98 26 80 00       	mov    $0x802698,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801249:	eb 13                	jmp    80125e <dev_lookup+0x23>
  80124b:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80124e:	39 08                	cmp    %ecx,(%eax)
  801250:	75 0c                	jne    80125e <dev_lookup+0x23>
			*dev = devtab[i];
  801252:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801255:	89 01                	mov    %eax,(%ecx)
			return 0;
  801257:	b8 00 00 00 00       	mov    $0x0,%eax
  80125c:	eb 2e                	jmp    80128c <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80125e:	8b 02                	mov    (%edx),%eax
  801260:	85 c0                	test   %eax,%eax
  801262:	75 e7                	jne    80124b <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801264:	a1 04 40 80 00       	mov    0x804004,%eax
  801269:	8b 40 48             	mov    0x48(%eax),%eax
  80126c:	83 ec 04             	sub    $0x4,%esp
  80126f:	51                   	push   %ecx
  801270:	50                   	push   %eax
  801271:	68 18 26 80 00       	push   $0x802618
  801276:	e8 b6 ef ff ff       	call   800231 <cprintf>
	*dev = 0;
  80127b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80127e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801284:	83 c4 10             	add    $0x10,%esp
  801287:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80128c:	c9                   	leave  
  80128d:	c3                   	ret    

0080128e <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80128e:	55                   	push   %ebp
  80128f:	89 e5                	mov    %esp,%ebp
  801291:	56                   	push   %esi
  801292:	53                   	push   %ebx
  801293:	83 ec 10             	sub    $0x10,%esp
  801296:	8b 75 08             	mov    0x8(%ebp),%esi
  801299:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80129c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80129f:	50                   	push   %eax
  8012a0:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8012a6:	c1 e8 0c             	shr    $0xc,%eax
  8012a9:	50                   	push   %eax
  8012aa:	e8 36 ff ff ff       	call   8011e5 <fd_lookup>
  8012af:	83 c4 08             	add    $0x8,%esp
  8012b2:	85 c0                	test   %eax,%eax
  8012b4:	78 05                	js     8012bb <fd_close+0x2d>
	    || fd != fd2)
  8012b6:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8012b9:	74 0c                	je     8012c7 <fd_close+0x39>
		return (must_exist ? r : 0);
  8012bb:	84 db                	test   %bl,%bl
  8012bd:	ba 00 00 00 00       	mov    $0x0,%edx
  8012c2:	0f 44 c2             	cmove  %edx,%eax
  8012c5:	eb 41                	jmp    801308 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8012c7:	83 ec 08             	sub    $0x8,%esp
  8012ca:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012cd:	50                   	push   %eax
  8012ce:	ff 36                	pushl  (%esi)
  8012d0:	e8 66 ff ff ff       	call   80123b <dev_lookup>
  8012d5:	89 c3                	mov    %eax,%ebx
  8012d7:	83 c4 10             	add    $0x10,%esp
  8012da:	85 c0                	test   %eax,%eax
  8012dc:	78 1a                	js     8012f8 <fd_close+0x6a>
		if (dev->dev_close)
  8012de:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012e1:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8012e4:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8012e9:	85 c0                	test   %eax,%eax
  8012eb:	74 0b                	je     8012f8 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8012ed:	83 ec 0c             	sub    $0xc,%esp
  8012f0:	56                   	push   %esi
  8012f1:	ff d0                	call   *%eax
  8012f3:	89 c3                	mov    %eax,%ebx
  8012f5:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8012f8:	83 ec 08             	sub    $0x8,%esp
  8012fb:	56                   	push   %esi
  8012fc:	6a 00                	push   $0x0
  8012fe:	e8 3b f9 ff ff       	call   800c3e <sys_page_unmap>
	return r;
  801303:	83 c4 10             	add    $0x10,%esp
  801306:	89 d8                	mov    %ebx,%eax
}
  801308:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80130b:	5b                   	pop    %ebx
  80130c:	5e                   	pop    %esi
  80130d:	5d                   	pop    %ebp
  80130e:	c3                   	ret    

0080130f <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80130f:	55                   	push   %ebp
  801310:	89 e5                	mov    %esp,%ebp
  801312:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801315:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801318:	50                   	push   %eax
  801319:	ff 75 08             	pushl  0x8(%ebp)
  80131c:	e8 c4 fe ff ff       	call   8011e5 <fd_lookup>
  801321:	83 c4 08             	add    $0x8,%esp
  801324:	85 c0                	test   %eax,%eax
  801326:	78 10                	js     801338 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801328:	83 ec 08             	sub    $0x8,%esp
  80132b:	6a 01                	push   $0x1
  80132d:	ff 75 f4             	pushl  -0xc(%ebp)
  801330:	e8 59 ff ff ff       	call   80128e <fd_close>
  801335:	83 c4 10             	add    $0x10,%esp
}
  801338:	c9                   	leave  
  801339:	c3                   	ret    

0080133a <close_all>:

void
close_all(void)
{
  80133a:	55                   	push   %ebp
  80133b:	89 e5                	mov    %esp,%ebp
  80133d:	53                   	push   %ebx
  80133e:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801341:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801346:	83 ec 0c             	sub    $0xc,%esp
  801349:	53                   	push   %ebx
  80134a:	e8 c0 ff ff ff       	call   80130f <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80134f:	83 c3 01             	add    $0x1,%ebx
  801352:	83 c4 10             	add    $0x10,%esp
  801355:	83 fb 20             	cmp    $0x20,%ebx
  801358:	75 ec                	jne    801346 <close_all+0xc>
		close(i);
}
  80135a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80135d:	c9                   	leave  
  80135e:	c3                   	ret    

0080135f <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80135f:	55                   	push   %ebp
  801360:	89 e5                	mov    %esp,%ebp
  801362:	57                   	push   %edi
  801363:	56                   	push   %esi
  801364:	53                   	push   %ebx
  801365:	83 ec 2c             	sub    $0x2c,%esp
  801368:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80136b:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80136e:	50                   	push   %eax
  80136f:	ff 75 08             	pushl  0x8(%ebp)
  801372:	e8 6e fe ff ff       	call   8011e5 <fd_lookup>
  801377:	83 c4 08             	add    $0x8,%esp
  80137a:	85 c0                	test   %eax,%eax
  80137c:	0f 88 c1 00 00 00    	js     801443 <dup+0xe4>
		return r;
	close(newfdnum);
  801382:	83 ec 0c             	sub    $0xc,%esp
  801385:	56                   	push   %esi
  801386:	e8 84 ff ff ff       	call   80130f <close>

	newfd = INDEX2FD(newfdnum);
  80138b:	89 f3                	mov    %esi,%ebx
  80138d:	c1 e3 0c             	shl    $0xc,%ebx
  801390:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801396:	83 c4 04             	add    $0x4,%esp
  801399:	ff 75 e4             	pushl  -0x1c(%ebp)
  80139c:	e8 de fd ff ff       	call   80117f <fd2data>
  8013a1:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8013a3:	89 1c 24             	mov    %ebx,(%esp)
  8013a6:	e8 d4 fd ff ff       	call   80117f <fd2data>
  8013ab:	83 c4 10             	add    $0x10,%esp
  8013ae:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8013b1:	89 f8                	mov    %edi,%eax
  8013b3:	c1 e8 16             	shr    $0x16,%eax
  8013b6:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8013bd:	a8 01                	test   $0x1,%al
  8013bf:	74 37                	je     8013f8 <dup+0x99>
  8013c1:	89 f8                	mov    %edi,%eax
  8013c3:	c1 e8 0c             	shr    $0xc,%eax
  8013c6:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8013cd:	f6 c2 01             	test   $0x1,%dl
  8013d0:	74 26                	je     8013f8 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8013d2:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8013d9:	83 ec 0c             	sub    $0xc,%esp
  8013dc:	25 07 0e 00 00       	and    $0xe07,%eax
  8013e1:	50                   	push   %eax
  8013e2:	ff 75 d4             	pushl  -0x2c(%ebp)
  8013e5:	6a 00                	push   $0x0
  8013e7:	57                   	push   %edi
  8013e8:	6a 00                	push   $0x0
  8013ea:	e8 0d f8 ff ff       	call   800bfc <sys_page_map>
  8013ef:	89 c7                	mov    %eax,%edi
  8013f1:	83 c4 20             	add    $0x20,%esp
  8013f4:	85 c0                	test   %eax,%eax
  8013f6:	78 2e                	js     801426 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8013f8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8013fb:	89 d0                	mov    %edx,%eax
  8013fd:	c1 e8 0c             	shr    $0xc,%eax
  801400:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801407:	83 ec 0c             	sub    $0xc,%esp
  80140a:	25 07 0e 00 00       	and    $0xe07,%eax
  80140f:	50                   	push   %eax
  801410:	53                   	push   %ebx
  801411:	6a 00                	push   $0x0
  801413:	52                   	push   %edx
  801414:	6a 00                	push   $0x0
  801416:	e8 e1 f7 ff ff       	call   800bfc <sys_page_map>
  80141b:	89 c7                	mov    %eax,%edi
  80141d:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801420:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801422:	85 ff                	test   %edi,%edi
  801424:	79 1d                	jns    801443 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801426:	83 ec 08             	sub    $0x8,%esp
  801429:	53                   	push   %ebx
  80142a:	6a 00                	push   $0x0
  80142c:	e8 0d f8 ff ff       	call   800c3e <sys_page_unmap>
	sys_page_unmap(0, nva);
  801431:	83 c4 08             	add    $0x8,%esp
  801434:	ff 75 d4             	pushl  -0x2c(%ebp)
  801437:	6a 00                	push   $0x0
  801439:	e8 00 f8 ff ff       	call   800c3e <sys_page_unmap>
	return r;
  80143e:	83 c4 10             	add    $0x10,%esp
  801441:	89 f8                	mov    %edi,%eax
}
  801443:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801446:	5b                   	pop    %ebx
  801447:	5e                   	pop    %esi
  801448:	5f                   	pop    %edi
  801449:	5d                   	pop    %ebp
  80144a:	c3                   	ret    

0080144b <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80144b:	55                   	push   %ebp
  80144c:	89 e5                	mov    %esp,%ebp
  80144e:	53                   	push   %ebx
  80144f:	83 ec 14             	sub    $0x14,%esp
  801452:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801455:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801458:	50                   	push   %eax
  801459:	53                   	push   %ebx
  80145a:	e8 86 fd ff ff       	call   8011e5 <fd_lookup>
  80145f:	83 c4 08             	add    $0x8,%esp
  801462:	89 c2                	mov    %eax,%edx
  801464:	85 c0                	test   %eax,%eax
  801466:	78 6d                	js     8014d5 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801468:	83 ec 08             	sub    $0x8,%esp
  80146b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80146e:	50                   	push   %eax
  80146f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801472:	ff 30                	pushl  (%eax)
  801474:	e8 c2 fd ff ff       	call   80123b <dev_lookup>
  801479:	83 c4 10             	add    $0x10,%esp
  80147c:	85 c0                	test   %eax,%eax
  80147e:	78 4c                	js     8014cc <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801480:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801483:	8b 42 08             	mov    0x8(%edx),%eax
  801486:	83 e0 03             	and    $0x3,%eax
  801489:	83 f8 01             	cmp    $0x1,%eax
  80148c:	75 21                	jne    8014af <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80148e:	a1 04 40 80 00       	mov    0x804004,%eax
  801493:	8b 40 48             	mov    0x48(%eax),%eax
  801496:	83 ec 04             	sub    $0x4,%esp
  801499:	53                   	push   %ebx
  80149a:	50                   	push   %eax
  80149b:	68 5c 26 80 00       	push   $0x80265c
  8014a0:	e8 8c ed ff ff       	call   800231 <cprintf>
		return -E_INVAL;
  8014a5:	83 c4 10             	add    $0x10,%esp
  8014a8:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8014ad:	eb 26                	jmp    8014d5 <read+0x8a>
	}
	if (!dev->dev_read)
  8014af:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014b2:	8b 40 08             	mov    0x8(%eax),%eax
  8014b5:	85 c0                	test   %eax,%eax
  8014b7:	74 17                	je     8014d0 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8014b9:	83 ec 04             	sub    $0x4,%esp
  8014bc:	ff 75 10             	pushl  0x10(%ebp)
  8014bf:	ff 75 0c             	pushl  0xc(%ebp)
  8014c2:	52                   	push   %edx
  8014c3:	ff d0                	call   *%eax
  8014c5:	89 c2                	mov    %eax,%edx
  8014c7:	83 c4 10             	add    $0x10,%esp
  8014ca:	eb 09                	jmp    8014d5 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014cc:	89 c2                	mov    %eax,%edx
  8014ce:	eb 05                	jmp    8014d5 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8014d0:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8014d5:	89 d0                	mov    %edx,%eax
  8014d7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014da:	c9                   	leave  
  8014db:	c3                   	ret    

008014dc <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8014dc:	55                   	push   %ebp
  8014dd:	89 e5                	mov    %esp,%ebp
  8014df:	57                   	push   %edi
  8014e0:	56                   	push   %esi
  8014e1:	53                   	push   %ebx
  8014e2:	83 ec 0c             	sub    $0xc,%esp
  8014e5:	8b 7d 08             	mov    0x8(%ebp),%edi
  8014e8:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8014eb:	bb 00 00 00 00       	mov    $0x0,%ebx
  8014f0:	eb 21                	jmp    801513 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8014f2:	83 ec 04             	sub    $0x4,%esp
  8014f5:	89 f0                	mov    %esi,%eax
  8014f7:	29 d8                	sub    %ebx,%eax
  8014f9:	50                   	push   %eax
  8014fa:	89 d8                	mov    %ebx,%eax
  8014fc:	03 45 0c             	add    0xc(%ebp),%eax
  8014ff:	50                   	push   %eax
  801500:	57                   	push   %edi
  801501:	e8 45 ff ff ff       	call   80144b <read>
		if (m < 0)
  801506:	83 c4 10             	add    $0x10,%esp
  801509:	85 c0                	test   %eax,%eax
  80150b:	78 10                	js     80151d <readn+0x41>
			return m;
		if (m == 0)
  80150d:	85 c0                	test   %eax,%eax
  80150f:	74 0a                	je     80151b <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801511:	01 c3                	add    %eax,%ebx
  801513:	39 f3                	cmp    %esi,%ebx
  801515:	72 db                	jb     8014f2 <readn+0x16>
  801517:	89 d8                	mov    %ebx,%eax
  801519:	eb 02                	jmp    80151d <readn+0x41>
  80151b:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80151d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801520:	5b                   	pop    %ebx
  801521:	5e                   	pop    %esi
  801522:	5f                   	pop    %edi
  801523:	5d                   	pop    %ebp
  801524:	c3                   	ret    

00801525 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801525:	55                   	push   %ebp
  801526:	89 e5                	mov    %esp,%ebp
  801528:	53                   	push   %ebx
  801529:	83 ec 14             	sub    $0x14,%esp
  80152c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80152f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801532:	50                   	push   %eax
  801533:	53                   	push   %ebx
  801534:	e8 ac fc ff ff       	call   8011e5 <fd_lookup>
  801539:	83 c4 08             	add    $0x8,%esp
  80153c:	89 c2                	mov    %eax,%edx
  80153e:	85 c0                	test   %eax,%eax
  801540:	78 68                	js     8015aa <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801542:	83 ec 08             	sub    $0x8,%esp
  801545:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801548:	50                   	push   %eax
  801549:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80154c:	ff 30                	pushl  (%eax)
  80154e:	e8 e8 fc ff ff       	call   80123b <dev_lookup>
  801553:	83 c4 10             	add    $0x10,%esp
  801556:	85 c0                	test   %eax,%eax
  801558:	78 47                	js     8015a1 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80155a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80155d:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801561:	75 21                	jne    801584 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801563:	a1 04 40 80 00       	mov    0x804004,%eax
  801568:	8b 40 48             	mov    0x48(%eax),%eax
  80156b:	83 ec 04             	sub    $0x4,%esp
  80156e:	53                   	push   %ebx
  80156f:	50                   	push   %eax
  801570:	68 78 26 80 00       	push   $0x802678
  801575:	e8 b7 ec ff ff       	call   800231 <cprintf>
		return -E_INVAL;
  80157a:	83 c4 10             	add    $0x10,%esp
  80157d:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801582:	eb 26                	jmp    8015aa <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801584:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801587:	8b 52 0c             	mov    0xc(%edx),%edx
  80158a:	85 d2                	test   %edx,%edx
  80158c:	74 17                	je     8015a5 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80158e:	83 ec 04             	sub    $0x4,%esp
  801591:	ff 75 10             	pushl  0x10(%ebp)
  801594:	ff 75 0c             	pushl  0xc(%ebp)
  801597:	50                   	push   %eax
  801598:	ff d2                	call   *%edx
  80159a:	89 c2                	mov    %eax,%edx
  80159c:	83 c4 10             	add    $0x10,%esp
  80159f:	eb 09                	jmp    8015aa <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015a1:	89 c2                	mov    %eax,%edx
  8015a3:	eb 05                	jmp    8015aa <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8015a5:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8015aa:	89 d0                	mov    %edx,%eax
  8015ac:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015af:	c9                   	leave  
  8015b0:	c3                   	ret    

008015b1 <seek>:

int
seek(int fdnum, off_t offset)
{
  8015b1:	55                   	push   %ebp
  8015b2:	89 e5                	mov    %esp,%ebp
  8015b4:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8015b7:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8015ba:	50                   	push   %eax
  8015bb:	ff 75 08             	pushl  0x8(%ebp)
  8015be:	e8 22 fc ff ff       	call   8011e5 <fd_lookup>
  8015c3:	83 c4 08             	add    $0x8,%esp
  8015c6:	85 c0                	test   %eax,%eax
  8015c8:	78 0e                	js     8015d8 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8015ca:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8015cd:	8b 55 0c             	mov    0xc(%ebp),%edx
  8015d0:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8015d3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8015d8:	c9                   	leave  
  8015d9:	c3                   	ret    

008015da <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8015da:	55                   	push   %ebp
  8015db:	89 e5                	mov    %esp,%ebp
  8015dd:	53                   	push   %ebx
  8015de:	83 ec 14             	sub    $0x14,%esp
  8015e1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015e4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015e7:	50                   	push   %eax
  8015e8:	53                   	push   %ebx
  8015e9:	e8 f7 fb ff ff       	call   8011e5 <fd_lookup>
  8015ee:	83 c4 08             	add    $0x8,%esp
  8015f1:	89 c2                	mov    %eax,%edx
  8015f3:	85 c0                	test   %eax,%eax
  8015f5:	78 65                	js     80165c <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015f7:	83 ec 08             	sub    $0x8,%esp
  8015fa:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015fd:	50                   	push   %eax
  8015fe:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801601:	ff 30                	pushl  (%eax)
  801603:	e8 33 fc ff ff       	call   80123b <dev_lookup>
  801608:	83 c4 10             	add    $0x10,%esp
  80160b:	85 c0                	test   %eax,%eax
  80160d:	78 44                	js     801653 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80160f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801612:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801616:	75 21                	jne    801639 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801618:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80161d:	8b 40 48             	mov    0x48(%eax),%eax
  801620:	83 ec 04             	sub    $0x4,%esp
  801623:	53                   	push   %ebx
  801624:	50                   	push   %eax
  801625:	68 38 26 80 00       	push   $0x802638
  80162a:	e8 02 ec ff ff       	call   800231 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80162f:	83 c4 10             	add    $0x10,%esp
  801632:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801637:	eb 23                	jmp    80165c <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801639:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80163c:	8b 52 18             	mov    0x18(%edx),%edx
  80163f:	85 d2                	test   %edx,%edx
  801641:	74 14                	je     801657 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801643:	83 ec 08             	sub    $0x8,%esp
  801646:	ff 75 0c             	pushl  0xc(%ebp)
  801649:	50                   	push   %eax
  80164a:	ff d2                	call   *%edx
  80164c:	89 c2                	mov    %eax,%edx
  80164e:	83 c4 10             	add    $0x10,%esp
  801651:	eb 09                	jmp    80165c <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801653:	89 c2                	mov    %eax,%edx
  801655:	eb 05                	jmp    80165c <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801657:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  80165c:	89 d0                	mov    %edx,%eax
  80165e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801661:	c9                   	leave  
  801662:	c3                   	ret    

00801663 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801663:	55                   	push   %ebp
  801664:	89 e5                	mov    %esp,%ebp
  801666:	53                   	push   %ebx
  801667:	83 ec 14             	sub    $0x14,%esp
  80166a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80166d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801670:	50                   	push   %eax
  801671:	ff 75 08             	pushl  0x8(%ebp)
  801674:	e8 6c fb ff ff       	call   8011e5 <fd_lookup>
  801679:	83 c4 08             	add    $0x8,%esp
  80167c:	89 c2                	mov    %eax,%edx
  80167e:	85 c0                	test   %eax,%eax
  801680:	78 58                	js     8016da <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801682:	83 ec 08             	sub    $0x8,%esp
  801685:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801688:	50                   	push   %eax
  801689:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80168c:	ff 30                	pushl  (%eax)
  80168e:	e8 a8 fb ff ff       	call   80123b <dev_lookup>
  801693:	83 c4 10             	add    $0x10,%esp
  801696:	85 c0                	test   %eax,%eax
  801698:	78 37                	js     8016d1 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80169a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80169d:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8016a1:	74 32                	je     8016d5 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8016a3:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8016a6:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8016ad:	00 00 00 
	stat->st_isdir = 0;
  8016b0:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8016b7:	00 00 00 
	stat->st_dev = dev;
  8016ba:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8016c0:	83 ec 08             	sub    $0x8,%esp
  8016c3:	53                   	push   %ebx
  8016c4:	ff 75 f0             	pushl  -0x10(%ebp)
  8016c7:	ff 50 14             	call   *0x14(%eax)
  8016ca:	89 c2                	mov    %eax,%edx
  8016cc:	83 c4 10             	add    $0x10,%esp
  8016cf:	eb 09                	jmp    8016da <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016d1:	89 c2                	mov    %eax,%edx
  8016d3:	eb 05                	jmp    8016da <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8016d5:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8016da:	89 d0                	mov    %edx,%eax
  8016dc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016df:	c9                   	leave  
  8016e0:	c3                   	ret    

008016e1 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8016e1:	55                   	push   %ebp
  8016e2:	89 e5                	mov    %esp,%ebp
  8016e4:	56                   	push   %esi
  8016e5:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8016e6:	83 ec 08             	sub    $0x8,%esp
  8016e9:	6a 00                	push   $0x0
  8016eb:	ff 75 08             	pushl  0x8(%ebp)
  8016ee:	e8 d6 01 00 00       	call   8018c9 <open>
  8016f3:	89 c3                	mov    %eax,%ebx
  8016f5:	83 c4 10             	add    $0x10,%esp
  8016f8:	85 c0                	test   %eax,%eax
  8016fa:	78 1b                	js     801717 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8016fc:	83 ec 08             	sub    $0x8,%esp
  8016ff:	ff 75 0c             	pushl  0xc(%ebp)
  801702:	50                   	push   %eax
  801703:	e8 5b ff ff ff       	call   801663 <fstat>
  801708:	89 c6                	mov    %eax,%esi
	close(fd);
  80170a:	89 1c 24             	mov    %ebx,(%esp)
  80170d:	e8 fd fb ff ff       	call   80130f <close>
	return r;
  801712:	83 c4 10             	add    $0x10,%esp
  801715:	89 f0                	mov    %esi,%eax
}
  801717:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80171a:	5b                   	pop    %ebx
  80171b:	5e                   	pop    %esi
  80171c:	5d                   	pop    %ebp
  80171d:	c3                   	ret    

0080171e <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80171e:	55                   	push   %ebp
  80171f:	89 e5                	mov    %esp,%ebp
  801721:	56                   	push   %esi
  801722:	53                   	push   %ebx
  801723:	89 c6                	mov    %eax,%esi
  801725:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801727:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80172e:	75 12                	jne    801742 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801730:	83 ec 0c             	sub    $0xc,%esp
  801733:	6a 01                	push   $0x1
  801735:	e8 fc f9 ff ff       	call   801136 <ipc_find_env>
  80173a:	a3 00 40 80 00       	mov    %eax,0x804000
  80173f:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801742:	6a 07                	push   $0x7
  801744:	68 00 50 80 00       	push   $0x805000
  801749:	56                   	push   %esi
  80174a:	ff 35 00 40 80 00    	pushl  0x804000
  801750:	e8 8d f9 ff ff       	call   8010e2 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801755:	83 c4 0c             	add    $0xc,%esp
  801758:	6a 00                	push   $0x0
  80175a:	53                   	push   %ebx
  80175b:	6a 00                	push   $0x0
  80175d:	e8 19 f9 ff ff       	call   80107b <ipc_recv>
}
  801762:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801765:	5b                   	pop    %ebx
  801766:	5e                   	pop    %esi
  801767:	5d                   	pop    %ebp
  801768:	c3                   	ret    

00801769 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801769:	55                   	push   %ebp
  80176a:	89 e5                	mov    %esp,%ebp
  80176c:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80176f:	8b 45 08             	mov    0x8(%ebp),%eax
  801772:	8b 40 0c             	mov    0xc(%eax),%eax
  801775:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80177a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80177d:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801782:	ba 00 00 00 00       	mov    $0x0,%edx
  801787:	b8 02 00 00 00       	mov    $0x2,%eax
  80178c:	e8 8d ff ff ff       	call   80171e <fsipc>
}
  801791:	c9                   	leave  
  801792:	c3                   	ret    

00801793 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801793:	55                   	push   %ebp
  801794:	89 e5                	mov    %esp,%ebp
  801796:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801799:	8b 45 08             	mov    0x8(%ebp),%eax
  80179c:	8b 40 0c             	mov    0xc(%eax),%eax
  80179f:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8017a4:	ba 00 00 00 00       	mov    $0x0,%edx
  8017a9:	b8 06 00 00 00       	mov    $0x6,%eax
  8017ae:	e8 6b ff ff ff       	call   80171e <fsipc>
}
  8017b3:	c9                   	leave  
  8017b4:	c3                   	ret    

008017b5 <devfile_stat>:

}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8017b5:	55                   	push   %ebp
  8017b6:	89 e5                	mov    %esp,%ebp
  8017b8:	53                   	push   %ebx
  8017b9:	83 ec 04             	sub    $0x4,%esp
  8017bc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8017bf:	8b 45 08             	mov    0x8(%ebp),%eax
  8017c2:	8b 40 0c             	mov    0xc(%eax),%eax
  8017c5:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8017ca:	ba 00 00 00 00       	mov    $0x0,%edx
  8017cf:	b8 05 00 00 00       	mov    $0x5,%eax
  8017d4:	e8 45 ff ff ff       	call   80171e <fsipc>
  8017d9:	85 c0                	test   %eax,%eax
  8017db:	78 2c                	js     801809 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8017dd:	83 ec 08             	sub    $0x8,%esp
  8017e0:	68 00 50 80 00       	push   $0x805000
  8017e5:	53                   	push   %ebx
  8017e6:	e8 cb ef ff ff       	call   8007b6 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8017eb:	a1 80 50 80 00       	mov    0x805080,%eax
  8017f0:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8017f6:	a1 84 50 80 00       	mov    0x805084,%eax
  8017fb:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801801:	83 c4 10             	add    $0x10,%esp
  801804:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801809:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80180c:	c9                   	leave  
  80180d:	c3                   	ret    

0080180e <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  80180e:	55                   	push   %ebp
  80180f:	89 e5                	mov    %esp,%ebp
  801811:	83 ec 0c             	sub    $0xc,%esp
  801814:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	// panic("devfile_write not implemented");

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801817:	8b 55 08             	mov    0x8(%ebp),%edx
  80181a:	8b 52 0c             	mov    0xc(%edx),%edx
  80181d:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  801823:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  801828:	50                   	push   %eax
  801829:	ff 75 0c             	pushl  0xc(%ebp)
  80182c:	68 08 50 80 00       	push   $0x805008
  801831:	e8 12 f1 ff ff       	call   800948 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  801836:	ba 00 00 00 00       	mov    $0x0,%edx
  80183b:	b8 04 00 00 00       	mov    $0x4,%eax
  801840:	e8 d9 fe ff ff       	call   80171e <fsipc>

}
  801845:	c9                   	leave  
  801846:	c3                   	ret    

00801847 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801847:	55                   	push   %ebp
  801848:	89 e5                	mov    %esp,%ebp
  80184a:	56                   	push   %esi
  80184b:	53                   	push   %ebx
  80184c:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80184f:	8b 45 08             	mov    0x8(%ebp),%eax
  801852:	8b 40 0c             	mov    0xc(%eax),%eax
  801855:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80185a:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801860:	ba 00 00 00 00       	mov    $0x0,%edx
  801865:	b8 03 00 00 00       	mov    $0x3,%eax
  80186a:	e8 af fe ff ff       	call   80171e <fsipc>
  80186f:	89 c3                	mov    %eax,%ebx
  801871:	85 c0                	test   %eax,%eax
  801873:	78 4b                	js     8018c0 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801875:	39 c6                	cmp    %eax,%esi
  801877:	73 16                	jae    80188f <devfile_read+0x48>
  801879:	68 a8 26 80 00       	push   $0x8026a8
  80187e:	68 af 26 80 00       	push   $0x8026af
  801883:	6a 7c                	push   $0x7c
  801885:	68 c4 26 80 00       	push   $0x8026c4
  80188a:	e8 c9 e8 ff ff       	call   800158 <_panic>
	assert(r <= PGSIZE);
  80188f:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801894:	7e 16                	jle    8018ac <devfile_read+0x65>
  801896:	68 cf 26 80 00       	push   $0x8026cf
  80189b:	68 af 26 80 00       	push   $0x8026af
  8018a0:	6a 7d                	push   $0x7d
  8018a2:	68 c4 26 80 00       	push   $0x8026c4
  8018a7:	e8 ac e8 ff ff       	call   800158 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8018ac:	83 ec 04             	sub    $0x4,%esp
  8018af:	50                   	push   %eax
  8018b0:	68 00 50 80 00       	push   $0x805000
  8018b5:	ff 75 0c             	pushl  0xc(%ebp)
  8018b8:	e8 8b f0 ff ff       	call   800948 <memmove>
	return r;
  8018bd:	83 c4 10             	add    $0x10,%esp
}
  8018c0:	89 d8                	mov    %ebx,%eax
  8018c2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018c5:	5b                   	pop    %ebx
  8018c6:	5e                   	pop    %esi
  8018c7:	5d                   	pop    %ebp
  8018c8:	c3                   	ret    

008018c9 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8018c9:	55                   	push   %ebp
  8018ca:	89 e5                	mov    %esp,%ebp
  8018cc:	53                   	push   %ebx
  8018cd:	83 ec 20             	sub    $0x20,%esp
  8018d0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8018d3:	53                   	push   %ebx
  8018d4:	e8 a4 ee ff ff       	call   80077d <strlen>
  8018d9:	83 c4 10             	add    $0x10,%esp
  8018dc:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8018e1:	7f 67                	jg     80194a <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8018e3:	83 ec 0c             	sub    $0xc,%esp
  8018e6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018e9:	50                   	push   %eax
  8018ea:	e8 a7 f8 ff ff       	call   801196 <fd_alloc>
  8018ef:	83 c4 10             	add    $0x10,%esp
		return r;
  8018f2:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8018f4:	85 c0                	test   %eax,%eax
  8018f6:	78 57                	js     80194f <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8018f8:	83 ec 08             	sub    $0x8,%esp
  8018fb:	53                   	push   %ebx
  8018fc:	68 00 50 80 00       	push   $0x805000
  801901:	e8 b0 ee ff ff       	call   8007b6 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801906:	8b 45 0c             	mov    0xc(%ebp),%eax
  801909:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80190e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801911:	b8 01 00 00 00       	mov    $0x1,%eax
  801916:	e8 03 fe ff ff       	call   80171e <fsipc>
  80191b:	89 c3                	mov    %eax,%ebx
  80191d:	83 c4 10             	add    $0x10,%esp
  801920:	85 c0                	test   %eax,%eax
  801922:	79 14                	jns    801938 <open+0x6f>
		fd_close(fd, 0);
  801924:	83 ec 08             	sub    $0x8,%esp
  801927:	6a 00                	push   $0x0
  801929:	ff 75 f4             	pushl  -0xc(%ebp)
  80192c:	e8 5d f9 ff ff       	call   80128e <fd_close>
		return r;
  801931:	83 c4 10             	add    $0x10,%esp
  801934:	89 da                	mov    %ebx,%edx
  801936:	eb 17                	jmp    80194f <open+0x86>
	}

	return fd2num(fd);
  801938:	83 ec 0c             	sub    $0xc,%esp
  80193b:	ff 75 f4             	pushl  -0xc(%ebp)
  80193e:	e8 2c f8 ff ff       	call   80116f <fd2num>
  801943:	89 c2                	mov    %eax,%edx
  801945:	83 c4 10             	add    $0x10,%esp
  801948:	eb 05                	jmp    80194f <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  80194a:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  80194f:	89 d0                	mov    %edx,%eax
  801951:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801954:	c9                   	leave  
  801955:	c3                   	ret    

00801956 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801956:	55                   	push   %ebp
  801957:	89 e5                	mov    %esp,%ebp
  801959:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80195c:	ba 00 00 00 00       	mov    $0x0,%edx
  801961:	b8 08 00 00 00       	mov    $0x8,%eax
  801966:	e8 b3 fd ff ff       	call   80171e <fsipc>
}
  80196b:	c9                   	leave  
  80196c:	c3                   	ret    

0080196d <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  80196d:	55                   	push   %ebp
  80196e:	89 e5                	mov    %esp,%ebp
  801970:	56                   	push   %esi
  801971:	53                   	push   %ebx
  801972:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801975:	83 ec 0c             	sub    $0xc,%esp
  801978:	ff 75 08             	pushl  0x8(%ebp)
  80197b:	e8 ff f7 ff ff       	call   80117f <fd2data>
  801980:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801982:	83 c4 08             	add    $0x8,%esp
  801985:	68 db 26 80 00       	push   $0x8026db
  80198a:	53                   	push   %ebx
  80198b:	e8 26 ee ff ff       	call   8007b6 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801990:	8b 46 04             	mov    0x4(%esi),%eax
  801993:	2b 06                	sub    (%esi),%eax
  801995:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80199b:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8019a2:	00 00 00 
	stat->st_dev = &devpipe;
  8019a5:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  8019ac:	30 80 00 
	return 0;
}
  8019af:	b8 00 00 00 00       	mov    $0x0,%eax
  8019b4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019b7:	5b                   	pop    %ebx
  8019b8:	5e                   	pop    %esi
  8019b9:	5d                   	pop    %ebp
  8019ba:	c3                   	ret    

008019bb <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8019bb:	55                   	push   %ebp
  8019bc:	89 e5                	mov    %esp,%ebp
  8019be:	53                   	push   %ebx
  8019bf:	83 ec 0c             	sub    $0xc,%esp
  8019c2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8019c5:	53                   	push   %ebx
  8019c6:	6a 00                	push   $0x0
  8019c8:	e8 71 f2 ff ff       	call   800c3e <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8019cd:	89 1c 24             	mov    %ebx,(%esp)
  8019d0:	e8 aa f7 ff ff       	call   80117f <fd2data>
  8019d5:	83 c4 08             	add    $0x8,%esp
  8019d8:	50                   	push   %eax
  8019d9:	6a 00                	push   $0x0
  8019db:	e8 5e f2 ff ff       	call   800c3e <sys_page_unmap>
}
  8019e0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019e3:	c9                   	leave  
  8019e4:	c3                   	ret    

008019e5 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8019e5:	55                   	push   %ebp
  8019e6:	89 e5                	mov    %esp,%ebp
  8019e8:	57                   	push   %edi
  8019e9:	56                   	push   %esi
  8019ea:	53                   	push   %ebx
  8019eb:	83 ec 1c             	sub    $0x1c,%esp
  8019ee:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8019f1:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8019f3:	a1 04 40 80 00       	mov    0x804004,%eax
  8019f8:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  8019fb:	83 ec 0c             	sub    $0xc,%esp
  8019fe:	ff 75 e0             	pushl  -0x20(%ebp)
  801a01:	e8 b1 04 00 00       	call   801eb7 <pageref>
  801a06:	89 c3                	mov    %eax,%ebx
  801a08:	89 3c 24             	mov    %edi,(%esp)
  801a0b:	e8 a7 04 00 00       	call   801eb7 <pageref>
  801a10:	83 c4 10             	add    $0x10,%esp
  801a13:	39 c3                	cmp    %eax,%ebx
  801a15:	0f 94 c1             	sete   %cl
  801a18:	0f b6 c9             	movzbl %cl,%ecx
  801a1b:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801a1e:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801a24:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801a27:	39 ce                	cmp    %ecx,%esi
  801a29:	74 1b                	je     801a46 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801a2b:	39 c3                	cmp    %eax,%ebx
  801a2d:	75 c4                	jne    8019f3 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801a2f:	8b 42 58             	mov    0x58(%edx),%eax
  801a32:	ff 75 e4             	pushl  -0x1c(%ebp)
  801a35:	50                   	push   %eax
  801a36:	56                   	push   %esi
  801a37:	68 e2 26 80 00       	push   $0x8026e2
  801a3c:	e8 f0 e7 ff ff       	call   800231 <cprintf>
  801a41:	83 c4 10             	add    $0x10,%esp
  801a44:	eb ad                	jmp    8019f3 <_pipeisclosed+0xe>
	}
}
  801a46:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801a49:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a4c:	5b                   	pop    %ebx
  801a4d:	5e                   	pop    %esi
  801a4e:	5f                   	pop    %edi
  801a4f:	5d                   	pop    %ebp
  801a50:	c3                   	ret    

00801a51 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801a51:	55                   	push   %ebp
  801a52:	89 e5                	mov    %esp,%ebp
  801a54:	57                   	push   %edi
  801a55:	56                   	push   %esi
  801a56:	53                   	push   %ebx
  801a57:	83 ec 28             	sub    $0x28,%esp
  801a5a:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801a5d:	56                   	push   %esi
  801a5e:	e8 1c f7 ff ff       	call   80117f <fd2data>
  801a63:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a65:	83 c4 10             	add    $0x10,%esp
  801a68:	bf 00 00 00 00       	mov    $0x0,%edi
  801a6d:	eb 4b                	jmp    801aba <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801a6f:	89 da                	mov    %ebx,%edx
  801a71:	89 f0                	mov    %esi,%eax
  801a73:	e8 6d ff ff ff       	call   8019e5 <_pipeisclosed>
  801a78:	85 c0                	test   %eax,%eax
  801a7a:	75 48                	jne    801ac4 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801a7c:	e8 19 f1 ff ff       	call   800b9a <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801a81:	8b 43 04             	mov    0x4(%ebx),%eax
  801a84:	8b 0b                	mov    (%ebx),%ecx
  801a86:	8d 51 20             	lea    0x20(%ecx),%edx
  801a89:	39 d0                	cmp    %edx,%eax
  801a8b:	73 e2                	jae    801a6f <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801a8d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a90:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801a94:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801a97:	89 c2                	mov    %eax,%edx
  801a99:	c1 fa 1f             	sar    $0x1f,%edx
  801a9c:	89 d1                	mov    %edx,%ecx
  801a9e:	c1 e9 1b             	shr    $0x1b,%ecx
  801aa1:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801aa4:	83 e2 1f             	and    $0x1f,%edx
  801aa7:	29 ca                	sub    %ecx,%edx
  801aa9:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801aad:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801ab1:	83 c0 01             	add    $0x1,%eax
  801ab4:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ab7:	83 c7 01             	add    $0x1,%edi
  801aba:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801abd:	75 c2                	jne    801a81 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801abf:	8b 45 10             	mov    0x10(%ebp),%eax
  801ac2:	eb 05                	jmp    801ac9 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801ac4:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801ac9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801acc:	5b                   	pop    %ebx
  801acd:	5e                   	pop    %esi
  801ace:	5f                   	pop    %edi
  801acf:	5d                   	pop    %ebp
  801ad0:	c3                   	ret    

00801ad1 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801ad1:	55                   	push   %ebp
  801ad2:	89 e5                	mov    %esp,%ebp
  801ad4:	57                   	push   %edi
  801ad5:	56                   	push   %esi
  801ad6:	53                   	push   %ebx
  801ad7:	83 ec 18             	sub    $0x18,%esp
  801ada:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801add:	57                   	push   %edi
  801ade:	e8 9c f6 ff ff       	call   80117f <fd2data>
  801ae3:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ae5:	83 c4 10             	add    $0x10,%esp
  801ae8:	bb 00 00 00 00       	mov    $0x0,%ebx
  801aed:	eb 3d                	jmp    801b2c <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801aef:	85 db                	test   %ebx,%ebx
  801af1:	74 04                	je     801af7 <devpipe_read+0x26>
				return i;
  801af3:	89 d8                	mov    %ebx,%eax
  801af5:	eb 44                	jmp    801b3b <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801af7:	89 f2                	mov    %esi,%edx
  801af9:	89 f8                	mov    %edi,%eax
  801afb:	e8 e5 fe ff ff       	call   8019e5 <_pipeisclosed>
  801b00:	85 c0                	test   %eax,%eax
  801b02:	75 32                	jne    801b36 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801b04:	e8 91 f0 ff ff       	call   800b9a <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801b09:	8b 06                	mov    (%esi),%eax
  801b0b:	3b 46 04             	cmp    0x4(%esi),%eax
  801b0e:	74 df                	je     801aef <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801b10:	99                   	cltd   
  801b11:	c1 ea 1b             	shr    $0x1b,%edx
  801b14:	01 d0                	add    %edx,%eax
  801b16:	83 e0 1f             	and    $0x1f,%eax
  801b19:	29 d0                	sub    %edx,%eax
  801b1b:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801b20:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b23:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801b26:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b29:	83 c3 01             	add    $0x1,%ebx
  801b2c:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801b2f:	75 d8                	jne    801b09 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801b31:	8b 45 10             	mov    0x10(%ebp),%eax
  801b34:	eb 05                	jmp    801b3b <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801b36:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801b3b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b3e:	5b                   	pop    %ebx
  801b3f:	5e                   	pop    %esi
  801b40:	5f                   	pop    %edi
  801b41:	5d                   	pop    %ebp
  801b42:	c3                   	ret    

00801b43 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801b43:	55                   	push   %ebp
  801b44:	89 e5                	mov    %esp,%ebp
  801b46:	56                   	push   %esi
  801b47:	53                   	push   %ebx
  801b48:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801b4b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b4e:	50                   	push   %eax
  801b4f:	e8 42 f6 ff ff       	call   801196 <fd_alloc>
  801b54:	83 c4 10             	add    $0x10,%esp
  801b57:	89 c2                	mov    %eax,%edx
  801b59:	85 c0                	test   %eax,%eax
  801b5b:	0f 88 2c 01 00 00    	js     801c8d <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b61:	83 ec 04             	sub    $0x4,%esp
  801b64:	68 07 04 00 00       	push   $0x407
  801b69:	ff 75 f4             	pushl  -0xc(%ebp)
  801b6c:	6a 00                	push   $0x0
  801b6e:	e8 46 f0 ff ff       	call   800bb9 <sys_page_alloc>
  801b73:	83 c4 10             	add    $0x10,%esp
  801b76:	89 c2                	mov    %eax,%edx
  801b78:	85 c0                	test   %eax,%eax
  801b7a:	0f 88 0d 01 00 00    	js     801c8d <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801b80:	83 ec 0c             	sub    $0xc,%esp
  801b83:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801b86:	50                   	push   %eax
  801b87:	e8 0a f6 ff ff       	call   801196 <fd_alloc>
  801b8c:	89 c3                	mov    %eax,%ebx
  801b8e:	83 c4 10             	add    $0x10,%esp
  801b91:	85 c0                	test   %eax,%eax
  801b93:	0f 88 e2 00 00 00    	js     801c7b <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b99:	83 ec 04             	sub    $0x4,%esp
  801b9c:	68 07 04 00 00       	push   $0x407
  801ba1:	ff 75 f0             	pushl  -0x10(%ebp)
  801ba4:	6a 00                	push   $0x0
  801ba6:	e8 0e f0 ff ff       	call   800bb9 <sys_page_alloc>
  801bab:	89 c3                	mov    %eax,%ebx
  801bad:	83 c4 10             	add    $0x10,%esp
  801bb0:	85 c0                	test   %eax,%eax
  801bb2:	0f 88 c3 00 00 00    	js     801c7b <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801bb8:	83 ec 0c             	sub    $0xc,%esp
  801bbb:	ff 75 f4             	pushl  -0xc(%ebp)
  801bbe:	e8 bc f5 ff ff       	call   80117f <fd2data>
  801bc3:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bc5:	83 c4 0c             	add    $0xc,%esp
  801bc8:	68 07 04 00 00       	push   $0x407
  801bcd:	50                   	push   %eax
  801bce:	6a 00                	push   $0x0
  801bd0:	e8 e4 ef ff ff       	call   800bb9 <sys_page_alloc>
  801bd5:	89 c3                	mov    %eax,%ebx
  801bd7:	83 c4 10             	add    $0x10,%esp
  801bda:	85 c0                	test   %eax,%eax
  801bdc:	0f 88 89 00 00 00    	js     801c6b <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801be2:	83 ec 0c             	sub    $0xc,%esp
  801be5:	ff 75 f0             	pushl  -0x10(%ebp)
  801be8:	e8 92 f5 ff ff       	call   80117f <fd2data>
  801bed:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801bf4:	50                   	push   %eax
  801bf5:	6a 00                	push   $0x0
  801bf7:	56                   	push   %esi
  801bf8:	6a 00                	push   $0x0
  801bfa:	e8 fd ef ff ff       	call   800bfc <sys_page_map>
  801bff:	89 c3                	mov    %eax,%ebx
  801c01:	83 c4 20             	add    $0x20,%esp
  801c04:	85 c0                	test   %eax,%eax
  801c06:	78 55                	js     801c5d <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801c08:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801c0e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c11:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801c13:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c16:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801c1d:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801c23:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c26:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801c28:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c2b:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801c32:	83 ec 0c             	sub    $0xc,%esp
  801c35:	ff 75 f4             	pushl  -0xc(%ebp)
  801c38:	e8 32 f5 ff ff       	call   80116f <fd2num>
  801c3d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c40:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801c42:	83 c4 04             	add    $0x4,%esp
  801c45:	ff 75 f0             	pushl  -0x10(%ebp)
  801c48:	e8 22 f5 ff ff       	call   80116f <fd2num>
  801c4d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c50:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801c53:	83 c4 10             	add    $0x10,%esp
  801c56:	ba 00 00 00 00       	mov    $0x0,%edx
  801c5b:	eb 30                	jmp    801c8d <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801c5d:	83 ec 08             	sub    $0x8,%esp
  801c60:	56                   	push   %esi
  801c61:	6a 00                	push   $0x0
  801c63:	e8 d6 ef ff ff       	call   800c3e <sys_page_unmap>
  801c68:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801c6b:	83 ec 08             	sub    $0x8,%esp
  801c6e:	ff 75 f0             	pushl  -0x10(%ebp)
  801c71:	6a 00                	push   $0x0
  801c73:	e8 c6 ef ff ff       	call   800c3e <sys_page_unmap>
  801c78:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801c7b:	83 ec 08             	sub    $0x8,%esp
  801c7e:	ff 75 f4             	pushl  -0xc(%ebp)
  801c81:	6a 00                	push   $0x0
  801c83:	e8 b6 ef ff ff       	call   800c3e <sys_page_unmap>
  801c88:	83 c4 10             	add    $0x10,%esp
  801c8b:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801c8d:	89 d0                	mov    %edx,%eax
  801c8f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c92:	5b                   	pop    %ebx
  801c93:	5e                   	pop    %esi
  801c94:	5d                   	pop    %ebp
  801c95:	c3                   	ret    

00801c96 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801c96:	55                   	push   %ebp
  801c97:	89 e5                	mov    %esp,%ebp
  801c99:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801c9c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c9f:	50                   	push   %eax
  801ca0:	ff 75 08             	pushl  0x8(%ebp)
  801ca3:	e8 3d f5 ff ff       	call   8011e5 <fd_lookup>
  801ca8:	83 c4 10             	add    $0x10,%esp
  801cab:	85 c0                	test   %eax,%eax
  801cad:	78 18                	js     801cc7 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801caf:	83 ec 0c             	sub    $0xc,%esp
  801cb2:	ff 75 f4             	pushl  -0xc(%ebp)
  801cb5:	e8 c5 f4 ff ff       	call   80117f <fd2data>
	return _pipeisclosed(fd, p);
  801cba:	89 c2                	mov    %eax,%edx
  801cbc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cbf:	e8 21 fd ff ff       	call   8019e5 <_pipeisclosed>
  801cc4:	83 c4 10             	add    $0x10,%esp
}
  801cc7:	c9                   	leave  
  801cc8:	c3                   	ret    

00801cc9 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801cc9:	55                   	push   %ebp
  801cca:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801ccc:	b8 00 00 00 00       	mov    $0x0,%eax
  801cd1:	5d                   	pop    %ebp
  801cd2:	c3                   	ret    

00801cd3 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801cd3:	55                   	push   %ebp
  801cd4:	89 e5                	mov    %esp,%ebp
  801cd6:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801cd9:	68 fa 26 80 00       	push   $0x8026fa
  801cde:	ff 75 0c             	pushl  0xc(%ebp)
  801ce1:	e8 d0 ea ff ff       	call   8007b6 <strcpy>
	return 0;
}
  801ce6:	b8 00 00 00 00       	mov    $0x0,%eax
  801ceb:	c9                   	leave  
  801cec:	c3                   	ret    

00801ced <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801ced:	55                   	push   %ebp
  801cee:	89 e5                	mov    %esp,%ebp
  801cf0:	57                   	push   %edi
  801cf1:	56                   	push   %esi
  801cf2:	53                   	push   %ebx
  801cf3:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801cf9:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801cfe:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d04:	eb 2d                	jmp    801d33 <devcons_write+0x46>
		m = n - tot;
  801d06:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801d09:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801d0b:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801d0e:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801d13:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801d16:	83 ec 04             	sub    $0x4,%esp
  801d19:	53                   	push   %ebx
  801d1a:	03 45 0c             	add    0xc(%ebp),%eax
  801d1d:	50                   	push   %eax
  801d1e:	57                   	push   %edi
  801d1f:	e8 24 ec ff ff       	call   800948 <memmove>
		sys_cputs(buf, m);
  801d24:	83 c4 08             	add    $0x8,%esp
  801d27:	53                   	push   %ebx
  801d28:	57                   	push   %edi
  801d29:	e8 cf ed ff ff       	call   800afd <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d2e:	01 de                	add    %ebx,%esi
  801d30:	83 c4 10             	add    $0x10,%esp
  801d33:	89 f0                	mov    %esi,%eax
  801d35:	3b 75 10             	cmp    0x10(%ebp),%esi
  801d38:	72 cc                	jb     801d06 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801d3a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d3d:	5b                   	pop    %ebx
  801d3e:	5e                   	pop    %esi
  801d3f:	5f                   	pop    %edi
  801d40:	5d                   	pop    %ebp
  801d41:	c3                   	ret    

00801d42 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801d42:	55                   	push   %ebp
  801d43:	89 e5                	mov    %esp,%ebp
  801d45:	83 ec 08             	sub    $0x8,%esp
  801d48:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801d4d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801d51:	74 2a                	je     801d7d <devcons_read+0x3b>
  801d53:	eb 05                	jmp    801d5a <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801d55:	e8 40 ee ff ff       	call   800b9a <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801d5a:	e8 bc ed ff ff       	call   800b1b <sys_cgetc>
  801d5f:	85 c0                	test   %eax,%eax
  801d61:	74 f2                	je     801d55 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801d63:	85 c0                	test   %eax,%eax
  801d65:	78 16                	js     801d7d <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801d67:	83 f8 04             	cmp    $0x4,%eax
  801d6a:	74 0c                	je     801d78 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801d6c:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d6f:	88 02                	mov    %al,(%edx)
	return 1;
  801d71:	b8 01 00 00 00       	mov    $0x1,%eax
  801d76:	eb 05                	jmp    801d7d <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801d78:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801d7d:	c9                   	leave  
  801d7e:	c3                   	ret    

00801d7f <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801d7f:	55                   	push   %ebp
  801d80:	89 e5                	mov    %esp,%ebp
  801d82:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801d85:	8b 45 08             	mov    0x8(%ebp),%eax
  801d88:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801d8b:	6a 01                	push   $0x1
  801d8d:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801d90:	50                   	push   %eax
  801d91:	e8 67 ed ff ff       	call   800afd <sys_cputs>
}
  801d96:	83 c4 10             	add    $0x10,%esp
  801d99:	c9                   	leave  
  801d9a:	c3                   	ret    

00801d9b <getchar>:

int
getchar(void)
{
  801d9b:	55                   	push   %ebp
  801d9c:	89 e5                	mov    %esp,%ebp
  801d9e:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801da1:	6a 01                	push   $0x1
  801da3:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801da6:	50                   	push   %eax
  801da7:	6a 00                	push   $0x0
  801da9:	e8 9d f6 ff ff       	call   80144b <read>
	if (r < 0)
  801dae:	83 c4 10             	add    $0x10,%esp
  801db1:	85 c0                	test   %eax,%eax
  801db3:	78 0f                	js     801dc4 <getchar+0x29>
		return r;
	if (r < 1)
  801db5:	85 c0                	test   %eax,%eax
  801db7:	7e 06                	jle    801dbf <getchar+0x24>
		return -E_EOF;
	return c;
  801db9:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801dbd:	eb 05                	jmp    801dc4 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801dbf:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801dc4:	c9                   	leave  
  801dc5:	c3                   	ret    

00801dc6 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801dc6:	55                   	push   %ebp
  801dc7:	89 e5                	mov    %esp,%ebp
  801dc9:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801dcc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801dcf:	50                   	push   %eax
  801dd0:	ff 75 08             	pushl  0x8(%ebp)
  801dd3:	e8 0d f4 ff ff       	call   8011e5 <fd_lookup>
  801dd8:	83 c4 10             	add    $0x10,%esp
  801ddb:	85 c0                	test   %eax,%eax
  801ddd:	78 11                	js     801df0 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801ddf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801de2:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801de8:	39 10                	cmp    %edx,(%eax)
  801dea:	0f 94 c0             	sete   %al
  801ded:	0f b6 c0             	movzbl %al,%eax
}
  801df0:	c9                   	leave  
  801df1:	c3                   	ret    

00801df2 <opencons>:

int
opencons(void)
{
  801df2:	55                   	push   %ebp
  801df3:	89 e5                	mov    %esp,%ebp
  801df5:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801df8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801dfb:	50                   	push   %eax
  801dfc:	e8 95 f3 ff ff       	call   801196 <fd_alloc>
  801e01:	83 c4 10             	add    $0x10,%esp
		return r;
  801e04:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801e06:	85 c0                	test   %eax,%eax
  801e08:	78 3e                	js     801e48 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801e0a:	83 ec 04             	sub    $0x4,%esp
  801e0d:	68 07 04 00 00       	push   $0x407
  801e12:	ff 75 f4             	pushl  -0xc(%ebp)
  801e15:	6a 00                	push   $0x0
  801e17:	e8 9d ed ff ff       	call   800bb9 <sys_page_alloc>
  801e1c:	83 c4 10             	add    $0x10,%esp
		return r;
  801e1f:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801e21:	85 c0                	test   %eax,%eax
  801e23:	78 23                	js     801e48 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801e25:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801e2b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e2e:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801e30:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e33:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801e3a:	83 ec 0c             	sub    $0xc,%esp
  801e3d:	50                   	push   %eax
  801e3e:	e8 2c f3 ff ff       	call   80116f <fd2num>
  801e43:	89 c2                	mov    %eax,%edx
  801e45:	83 c4 10             	add    $0x10,%esp
}
  801e48:	89 d0                	mov    %edx,%eax
  801e4a:	c9                   	leave  
  801e4b:	c3                   	ret    

00801e4c <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801e4c:	55                   	push   %ebp
  801e4d:	89 e5                	mov    %esp,%ebp
  801e4f:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801e52:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801e59:	75 2e                	jne    801e89 <set_pgfault_handler+0x3d>
		// First time through!
		// LAB 4: Your code here.
		// panic("set_pgfault_handler not implemented");

		sys_page_alloc(sys_getenvid(), (void *) (UXSTACKTOP - PGSIZE), PTE_SYSCALL);
  801e5b:	e8 1b ed ff ff       	call   800b7b <sys_getenvid>
  801e60:	83 ec 04             	sub    $0x4,%esp
  801e63:	68 07 0e 00 00       	push   $0xe07
  801e68:	68 00 f0 bf ee       	push   $0xeebff000
  801e6d:	50                   	push   %eax
  801e6e:	e8 46 ed ff ff       	call   800bb9 <sys_page_alloc>
		sys_env_set_pgfault_upcall(sys_getenvid(), _pgfault_upcall);
  801e73:	e8 03 ed ff ff       	call   800b7b <sys_getenvid>
  801e78:	83 c4 08             	add    $0x8,%esp
  801e7b:	68 93 1e 80 00       	push   $0x801e93
  801e80:	50                   	push   %eax
  801e81:	e8 7e ee ff ff       	call   800d04 <sys_env_set_pgfault_upcall>
  801e86:	83 c4 10             	add    $0x10,%esp
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801e89:	8b 45 08             	mov    0x8(%ebp),%eax
  801e8c:	a3 00 60 80 00       	mov    %eax,0x806000
}
  801e91:	c9                   	leave  
  801e92:	c3                   	ret    

00801e93 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801e93:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801e94:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801e99:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801e9b:	83 c4 04             	add    $0x4,%esp
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.

	movl 48(%esp), %eax		// trap-time esp
  801e9e:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl 40(%esp), %ebx		// trap-time eip
  801ea2:	8b 5c 24 28          	mov    0x28(%esp),%ebx

	// load eip into esp-4
	// in order to return to trap-time eip later, in the meantime not changing trap-time esp
	movl %ebx, -4(%eax)	
  801ea6:	89 58 fc             	mov    %ebx,-0x4(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.

	addl $8, %esp 			// esp now points to trap-time registers
  801ea9:	83 c4 08             	add    $0x8,%esp
	popal					// pop to all registers
  801eac:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

	addl $4, %esp			// esp now points to trap-time eflags
  801ead:	83 c4 04             	add    $0x4,%esp
	popfl					// pop to eflags
  801eb0:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.

	popl %esp				// pop to esp
  801eb1:	5c                   	pop    %esp
	// subl $4, %esp		// arithmetic operation will change eflags!!!
	lea -4(%esp), %esp		// subl $4, %esp
  801eb2:	8d 64 24 fc          	lea    -0x4(%esp),%esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.

	ret
  801eb6:	c3                   	ret    

00801eb7 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801eb7:	55                   	push   %ebp
  801eb8:	89 e5                	mov    %esp,%ebp
  801eba:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801ebd:	89 d0                	mov    %edx,%eax
  801ebf:	c1 e8 16             	shr    $0x16,%eax
  801ec2:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801ec9:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801ece:	f6 c1 01             	test   $0x1,%cl
  801ed1:	74 1d                	je     801ef0 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801ed3:	c1 ea 0c             	shr    $0xc,%edx
  801ed6:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801edd:	f6 c2 01             	test   $0x1,%dl
  801ee0:	74 0e                	je     801ef0 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801ee2:	c1 ea 0c             	shr    $0xc,%edx
  801ee5:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801eec:	ef 
  801eed:	0f b7 c0             	movzwl %ax,%eax
}
  801ef0:	5d                   	pop    %ebp
  801ef1:	c3                   	ret    
  801ef2:	66 90                	xchg   %ax,%ax
  801ef4:	66 90                	xchg   %ax,%ax
  801ef6:	66 90                	xchg   %ax,%ax
  801ef8:	66 90                	xchg   %ax,%ax
  801efa:	66 90                	xchg   %ax,%ax
  801efc:	66 90                	xchg   %ax,%ax
  801efe:	66 90                	xchg   %ax,%ax

00801f00 <__udivdi3>:
  801f00:	55                   	push   %ebp
  801f01:	57                   	push   %edi
  801f02:	56                   	push   %esi
  801f03:	53                   	push   %ebx
  801f04:	83 ec 1c             	sub    $0x1c,%esp
  801f07:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801f0b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801f0f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801f13:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801f17:	85 f6                	test   %esi,%esi
  801f19:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801f1d:	89 ca                	mov    %ecx,%edx
  801f1f:	89 f8                	mov    %edi,%eax
  801f21:	75 3d                	jne    801f60 <__udivdi3+0x60>
  801f23:	39 cf                	cmp    %ecx,%edi
  801f25:	0f 87 c5 00 00 00    	ja     801ff0 <__udivdi3+0xf0>
  801f2b:	85 ff                	test   %edi,%edi
  801f2d:	89 fd                	mov    %edi,%ebp
  801f2f:	75 0b                	jne    801f3c <__udivdi3+0x3c>
  801f31:	b8 01 00 00 00       	mov    $0x1,%eax
  801f36:	31 d2                	xor    %edx,%edx
  801f38:	f7 f7                	div    %edi
  801f3a:	89 c5                	mov    %eax,%ebp
  801f3c:	89 c8                	mov    %ecx,%eax
  801f3e:	31 d2                	xor    %edx,%edx
  801f40:	f7 f5                	div    %ebp
  801f42:	89 c1                	mov    %eax,%ecx
  801f44:	89 d8                	mov    %ebx,%eax
  801f46:	89 cf                	mov    %ecx,%edi
  801f48:	f7 f5                	div    %ebp
  801f4a:	89 c3                	mov    %eax,%ebx
  801f4c:	89 d8                	mov    %ebx,%eax
  801f4e:	89 fa                	mov    %edi,%edx
  801f50:	83 c4 1c             	add    $0x1c,%esp
  801f53:	5b                   	pop    %ebx
  801f54:	5e                   	pop    %esi
  801f55:	5f                   	pop    %edi
  801f56:	5d                   	pop    %ebp
  801f57:	c3                   	ret    
  801f58:	90                   	nop
  801f59:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801f60:	39 ce                	cmp    %ecx,%esi
  801f62:	77 74                	ja     801fd8 <__udivdi3+0xd8>
  801f64:	0f bd fe             	bsr    %esi,%edi
  801f67:	83 f7 1f             	xor    $0x1f,%edi
  801f6a:	0f 84 98 00 00 00    	je     802008 <__udivdi3+0x108>
  801f70:	bb 20 00 00 00       	mov    $0x20,%ebx
  801f75:	89 f9                	mov    %edi,%ecx
  801f77:	89 c5                	mov    %eax,%ebp
  801f79:	29 fb                	sub    %edi,%ebx
  801f7b:	d3 e6                	shl    %cl,%esi
  801f7d:	89 d9                	mov    %ebx,%ecx
  801f7f:	d3 ed                	shr    %cl,%ebp
  801f81:	89 f9                	mov    %edi,%ecx
  801f83:	d3 e0                	shl    %cl,%eax
  801f85:	09 ee                	or     %ebp,%esi
  801f87:	89 d9                	mov    %ebx,%ecx
  801f89:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801f8d:	89 d5                	mov    %edx,%ebp
  801f8f:	8b 44 24 08          	mov    0x8(%esp),%eax
  801f93:	d3 ed                	shr    %cl,%ebp
  801f95:	89 f9                	mov    %edi,%ecx
  801f97:	d3 e2                	shl    %cl,%edx
  801f99:	89 d9                	mov    %ebx,%ecx
  801f9b:	d3 e8                	shr    %cl,%eax
  801f9d:	09 c2                	or     %eax,%edx
  801f9f:	89 d0                	mov    %edx,%eax
  801fa1:	89 ea                	mov    %ebp,%edx
  801fa3:	f7 f6                	div    %esi
  801fa5:	89 d5                	mov    %edx,%ebp
  801fa7:	89 c3                	mov    %eax,%ebx
  801fa9:	f7 64 24 0c          	mull   0xc(%esp)
  801fad:	39 d5                	cmp    %edx,%ebp
  801faf:	72 10                	jb     801fc1 <__udivdi3+0xc1>
  801fb1:	8b 74 24 08          	mov    0x8(%esp),%esi
  801fb5:	89 f9                	mov    %edi,%ecx
  801fb7:	d3 e6                	shl    %cl,%esi
  801fb9:	39 c6                	cmp    %eax,%esi
  801fbb:	73 07                	jae    801fc4 <__udivdi3+0xc4>
  801fbd:	39 d5                	cmp    %edx,%ebp
  801fbf:	75 03                	jne    801fc4 <__udivdi3+0xc4>
  801fc1:	83 eb 01             	sub    $0x1,%ebx
  801fc4:	31 ff                	xor    %edi,%edi
  801fc6:	89 d8                	mov    %ebx,%eax
  801fc8:	89 fa                	mov    %edi,%edx
  801fca:	83 c4 1c             	add    $0x1c,%esp
  801fcd:	5b                   	pop    %ebx
  801fce:	5e                   	pop    %esi
  801fcf:	5f                   	pop    %edi
  801fd0:	5d                   	pop    %ebp
  801fd1:	c3                   	ret    
  801fd2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801fd8:	31 ff                	xor    %edi,%edi
  801fda:	31 db                	xor    %ebx,%ebx
  801fdc:	89 d8                	mov    %ebx,%eax
  801fde:	89 fa                	mov    %edi,%edx
  801fe0:	83 c4 1c             	add    $0x1c,%esp
  801fe3:	5b                   	pop    %ebx
  801fe4:	5e                   	pop    %esi
  801fe5:	5f                   	pop    %edi
  801fe6:	5d                   	pop    %ebp
  801fe7:	c3                   	ret    
  801fe8:	90                   	nop
  801fe9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801ff0:	89 d8                	mov    %ebx,%eax
  801ff2:	f7 f7                	div    %edi
  801ff4:	31 ff                	xor    %edi,%edi
  801ff6:	89 c3                	mov    %eax,%ebx
  801ff8:	89 d8                	mov    %ebx,%eax
  801ffa:	89 fa                	mov    %edi,%edx
  801ffc:	83 c4 1c             	add    $0x1c,%esp
  801fff:	5b                   	pop    %ebx
  802000:	5e                   	pop    %esi
  802001:	5f                   	pop    %edi
  802002:	5d                   	pop    %ebp
  802003:	c3                   	ret    
  802004:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802008:	39 ce                	cmp    %ecx,%esi
  80200a:	72 0c                	jb     802018 <__udivdi3+0x118>
  80200c:	31 db                	xor    %ebx,%ebx
  80200e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802012:	0f 87 34 ff ff ff    	ja     801f4c <__udivdi3+0x4c>
  802018:	bb 01 00 00 00       	mov    $0x1,%ebx
  80201d:	e9 2a ff ff ff       	jmp    801f4c <__udivdi3+0x4c>
  802022:	66 90                	xchg   %ax,%ax
  802024:	66 90                	xchg   %ax,%ax
  802026:	66 90                	xchg   %ax,%ax
  802028:	66 90                	xchg   %ax,%ax
  80202a:	66 90                	xchg   %ax,%ax
  80202c:	66 90                	xchg   %ax,%ax
  80202e:	66 90                	xchg   %ax,%ax

00802030 <__umoddi3>:
  802030:	55                   	push   %ebp
  802031:	57                   	push   %edi
  802032:	56                   	push   %esi
  802033:	53                   	push   %ebx
  802034:	83 ec 1c             	sub    $0x1c,%esp
  802037:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80203b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80203f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802043:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802047:	85 d2                	test   %edx,%edx
  802049:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80204d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802051:	89 f3                	mov    %esi,%ebx
  802053:	89 3c 24             	mov    %edi,(%esp)
  802056:	89 74 24 04          	mov    %esi,0x4(%esp)
  80205a:	75 1c                	jne    802078 <__umoddi3+0x48>
  80205c:	39 f7                	cmp    %esi,%edi
  80205e:	76 50                	jbe    8020b0 <__umoddi3+0x80>
  802060:	89 c8                	mov    %ecx,%eax
  802062:	89 f2                	mov    %esi,%edx
  802064:	f7 f7                	div    %edi
  802066:	89 d0                	mov    %edx,%eax
  802068:	31 d2                	xor    %edx,%edx
  80206a:	83 c4 1c             	add    $0x1c,%esp
  80206d:	5b                   	pop    %ebx
  80206e:	5e                   	pop    %esi
  80206f:	5f                   	pop    %edi
  802070:	5d                   	pop    %ebp
  802071:	c3                   	ret    
  802072:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802078:	39 f2                	cmp    %esi,%edx
  80207a:	89 d0                	mov    %edx,%eax
  80207c:	77 52                	ja     8020d0 <__umoddi3+0xa0>
  80207e:	0f bd ea             	bsr    %edx,%ebp
  802081:	83 f5 1f             	xor    $0x1f,%ebp
  802084:	75 5a                	jne    8020e0 <__umoddi3+0xb0>
  802086:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80208a:	0f 82 e0 00 00 00    	jb     802170 <__umoddi3+0x140>
  802090:	39 0c 24             	cmp    %ecx,(%esp)
  802093:	0f 86 d7 00 00 00    	jbe    802170 <__umoddi3+0x140>
  802099:	8b 44 24 08          	mov    0x8(%esp),%eax
  80209d:	8b 54 24 04          	mov    0x4(%esp),%edx
  8020a1:	83 c4 1c             	add    $0x1c,%esp
  8020a4:	5b                   	pop    %ebx
  8020a5:	5e                   	pop    %esi
  8020a6:	5f                   	pop    %edi
  8020a7:	5d                   	pop    %ebp
  8020a8:	c3                   	ret    
  8020a9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8020b0:	85 ff                	test   %edi,%edi
  8020b2:	89 fd                	mov    %edi,%ebp
  8020b4:	75 0b                	jne    8020c1 <__umoddi3+0x91>
  8020b6:	b8 01 00 00 00       	mov    $0x1,%eax
  8020bb:	31 d2                	xor    %edx,%edx
  8020bd:	f7 f7                	div    %edi
  8020bf:	89 c5                	mov    %eax,%ebp
  8020c1:	89 f0                	mov    %esi,%eax
  8020c3:	31 d2                	xor    %edx,%edx
  8020c5:	f7 f5                	div    %ebp
  8020c7:	89 c8                	mov    %ecx,%eax
  8020c9:	f7 f5                	div    %ebp
  8020cb:	89 d0                	mov    %edx,%eax
  8020cd:	eb 99                	jmp    802068 <__umoddi3+0x38>
  8020cf:	90                   	nop
  8020d0:	89 c8                	mov    %ecx,%eax
  8020d2:	89 f2                	mov    %esi,%edx
  8020d4:	83 c4 1c             	add    $0x1c,%esp
  8020d7:	5b                   	pop    %ebx
  8020d8:	5e                   	pop    %esi
  8020d9:	5f                   	pop    %edi
  8020da:	5d                   	pop    %ebp
  8020db:	c3                   	ret    
  8020dc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8020e0:	8b 34 24             	mov    (%esp),%esi
  8020e3:	bf 20 00 00 00       	mov    $0x20,%edi
  8020e8:	89 e9                	mov    %ebp,%ecx
  8020ea:	29 ef                	sub    %ebp,%edi
  8020ec:	d3 e0                	shl    %cl,%eax
  8020ee:	89 f9                	mov    %edi,%ecx
  8020f0:	89 f2                	mov    %esi,%edx
  8020f2:	d3 ea                	shr    %cl,%edx
  8020f4:	89 e9                	mov    %ebp,%ecx
  8020f6:	09 c2                	or     %eax,%edx
  8020f8:	89 d8                	mov    %ebx,%eax
  8020fa:	89 14 24             	mov    %edx,(%esp)
  8020fd:	89 f2                	mov    %esi,%edx
  8020ff:	d3 e2                	shl    %cl,%edx
  802101:	89 f9                	mov    %edi,%ecx
  802103:	89 54 24 04          	mov    %edx,0x4(%esp)
  802107:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80210b:	d3 e8                	shr    %cl,%eax
  80210d:	89 e9                	mov    %ebp,%ecx
  80210f:	89 c6                	mov    %eax,%esi
  802111:	d3 e3                	shl    %cl,%ebx
  802113:	89 f9                	mov    %edi,%ecx
  802115:	89 d0                	mov    %edx,%eax
  802117:	d3 e8                	shr    %cl,%eax
  802119:	89 e9                	mov    %ebp,%ecx
  80211b:	09 d8                	or     %ebx,%eax
  80211d:	89 d3                	mov    %edx,%ebx
  80211f:	89 f2                	mov    %esi,%edx
  802121:	f7 34 24             	divl   (%esp)
  802124:	89 d6                	mov    %edx,%esi
  802126:	d3 e3                	shl    %cl,%ebx
  802128:	f7 64 24 04          	mull   0x4(%esp)
  80212c:	39 d6                	cmp    %edx,%esi
  80212e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802132:	89 d1                	mov    %edx,%ecx
  802134:	89 c3                	mov    %eax,%ebx
  802136:	72 08                	jb     802140 <__umoddi3+0x110>
  802138:	75 11                	jne    80214b <__umoddi3+0x11b>
  80213a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80213e:	73 0b                	jae    80214b <__umoddi3+0x11b>
  802140:	2b 44 24 04          	sub    0x4(%esp),%eax
  802144:	1b 14 24             	sbb    (%esp),%edx
  802147:	89 d1                	mov    %edx,%ecx
  802149:	89 c3                	mov    %eax,%ebx
  80214b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80214f:	29 da                	sub    %ebx,%edx
  802151:	19 ce                	sbb    %ecx,%esi
  802153:	89 f9                	mov    %edi,%ecx
  802155:	89 f0                	mov    %esi,%eax
  802157:	d3 e0                	shl    %cl,%eax
  802159:	89 e9                	mov    %ebp,%ecx
  80215b:	d3 ea                	shr    %cl,%edx
  80215d:	89 e9                	mov    %ebp,%ecx
  80215f:	d3 ee                	shr    %cl,%esi
  802161:	09 d0                	or     %edx,%eax
  802163:	89 f2                	mov    %esi,%edx
  802165:	83 c4 1c             	add    $0x1c,%esp
  802168:	5b                   	pop    %ebx
  802169:	5e                   	pop    %esi
  80216a:	5f                   	pop    %edi
  80216b:	5d                   	pop    %ebp
  80216c:	c3                   	ret    
  80216d:	8d 76 00             	lea    0x0(%esi),%esi
  802170:	29 f9                	sub    %edi,%ecx
  802172:	19 d6                	sbb    %edx,%esi
  802174:	89 74 24 04          	mov    %esi,0x4(%esp)
  802178:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80217c:	e9 18 ff ff ff       	jmp    802099 <__umoddi3+0x69>
