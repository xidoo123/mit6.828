
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
  800047:	e8 b8 0f 00 00       	call   801004 <ipc_recv>
  80004c:	89 c3                	mov    %eax,%ebx
	cprintf("CPU %d: %d ", thisenv->env_cpunum, p);
  80004e:	a1 04 40 80 00       	mov    0x804004,%eax
  800053:	8b 40 5c             	mov    0x5c(%eax),%eax
  800056:	83 c4 0c             	add    $0xc,%esp
  800059:	53                   	push   %ebx
  80005a:	50                   	push   %eax
  80005b:	68 00 21 80 00       	push   $0x802100
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
  800074:	68 0c 21 80 00       	push   $0x80210c
  800079:	6a 1a                	push   $0x1a
  80007b:	68 15 21 80 00       	push   $0x802115
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
  800094:	e8 6b 0f 00 00       	call   801004 <ipc_recv>
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
  8000ab:	e8 bb 0f 00 00       	call   80106b <ipc_send>
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
  8000c6:	68 0c 21 80 00       	push   $0x80210c
  8000cb:	6a 2d                	push   $0x2d
  8000cd:	68 15 21 80 00       	push   $0x802115
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
  8000eb:	e8 7b 0f 00 00       	call   80106b <ipc_send>
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
  800144:	e8 7a 11 00 00       	call   8012c3 <close_all>
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
  800176:	68 30 21 80 00       	push   $0x802130
  80017b:	e8 b1 00 00 00       	call   800231 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800180:	83 c4 18             	add    $0x18,%esp
  800183:	53                   	push   %ebx
  800184:	ff 75 10             	pushl  0x10(%ebp)
  800187:	e8 54 00 00 00       	call   8001e0 <vcprintf>
	cprintf("\n");
  80018c:	c7 04 24 51 26 80 00 	movl   $0x802651,(%esp)
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
  800294:	e8 c7 1b 00 00       	call   801e60 <__udivdi3>
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
  8002d7:	e8 b4 1c 00 00       	call   801f90 <__umoddi3>
  8002dc:	83 c4 14             	add    $0x14,%esp
  8002df:	0f be 80 53 21 80 00 	movsbl 0x802153(%eax),%eax
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
  8003db:	ff 24 85 a0 22 80 00 	jmp    *0x8022a0(,%eax,4)
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
  80049f:	8b 14 85 00 24 80 00 	mov    0x802400(,%eax,4),%edx
  8004a6:	85 d2                	test   %edx,%edx
  8004a8:	75 18                	jne    8004c2 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8004aa:	50                   	push   %eax
  8004ab:	68 6b 21 80 00       	push   $0x80216b
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
  8004c3:	68 2a 26 80 00       	push   $0x80262a
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
  8004e7:	b8 64 21 80 00       	mov    $0x802164,%eax
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
  800b62:	68 5f 24 80 00       	push   $0x80245f
  800b67:	6a 23                	push   $0x23
  800b69:	68 7c 24 80 00       	push   $0x80247c
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
  800be3:	68 5f 24 80 00       	push   $0x80245f
  800be8:	6a 23                	push   $0x23
  800bea:	68 7c 24 80 00       	push   $0x80247c
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
  800c25:	68 5f 24 80 00       	push   $0x80245f
  800c2a:	6a 23                	push   $0x23
  800c2c:	68 7c 24 80 00       	push   $0x80247c
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
  800c67:	68 5f 24 80 00       	push   $0x80245f
  800c6c:	6a 23                	push   $0x23
  800c6e:	68 7c 24 80 00       	push   $0x80247c
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
  800ca9:	68 5f 24 80 00       	push   $0x80245f
  800cae:	6a 23                	push   $0x23
  800cb0:	68 7c 24 80 00       	push   $0x80247c
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
  800ceb:	68 5f 24 80 00       	push   $0x80245f
  800cf0:	6a 23                	push   $0x23
  800cf2:	68 7c 24 80 00       	push   $0x80247c
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
  800d2d:	68 5f 24 80 00       	push   $0x80245f
  800d32:	6a 23                	push   $0x23
  800d34:	68 7c 24 80 00       	push   $0x80247c
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
  800d91:	68 5f 24 80 00       	push   $0x80245f
  800d96:	6a 23                	push   $0x23
  800d98:	68 7c 24 80 00       	push   $0x80247c
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
  800dce:	68 8c 24 80 00       	push   $0x80248c
  800dd3:	6a 1e                	push   $0x1e
  800dd5:	68 20 25 80 00       	push   $0x802520
  800dda:	e8 79 f3 ff ff       	call   800158 <_panic>

	// LAB 4: Your code here.

	// panic("pgfault not implemented");

	addr = ROUNDDOWN(addr, PGSIZE);
  800ddf:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	envid_t envid = sys_getenvid();
  800de5:	e8 91 fd ff ff       	call   800b7b <sys_getenvid>
  800dea:	89 c6                	mov    %eax,%esi

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
  800e04:	68 b8 24 80 00       	push   $0x8024b8
  800e09:	6a 31                	push   $0x31
  800e0b:	68 20 25 80 00       	push   $0x802520
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
  800e44:	68 dc 24 80 00       	push   $0x8024dc
  800e49:	6a 39                	push   $0x39
  800e4b:	68 20 25 80 00       	push   $0x802520
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
  800e6b:	68 00 25 80 00       	push   $0x802500
  800e70:	6a 3e                	push   $0x3e
  800e72:	68 20 25 80 00       	push   $0x802520
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
  800e91:	e8 20 0f 00 00       	call   801db6 <set_pgfault_handler>
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
  800ea2:	0f 88 3a 01 00 00    	js     800fe2 <fork+0x15f>
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
  800ecd:	b8 00 00 00 00       	mov    $0x0,%eax
  800ed2:	e9 0b 01 00 00       	jmp    800fe2 <fork+0x15f>
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
  800eea:	0f 84 99 00 00 00    	je     800f89 <fork+0x106>
			
			// if real PTE exists
			if ((uvpt[PGNUM(addr)] & PTE_P) == PTE_P) {
  800ef0:	89 d8                	mov    %ebx,%eax
  800ef2:	c1 e8 0c             	shr    $0xc,%eax
  800ef5:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800efc:	f6 c2 01             	test   $0x1,%dl
  800eff:	0f 84 84 00 00 00    	je     800f89 <fork+0x106>

				// For each writable or copy-on-write page
				if ((uvpt[PGNUM(addr)] & (PTE_W | PTE_COW)) != 0) {
  800f05:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f0c:	a9 02 08 00 00       	test   $0x802,%eax
  800f11:	74 76                	je     800f89 <fork+0x106>
	// r = envid2env(envid, &env, 1);
	// if (r < 0)
	// 	return r;	// E_BAD_ENV
	// envid_t parent_envid = env->env_parent_id;
	
	if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {
  800f13:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800f1a:	a8 02                	test   $0x2,%al
  800f1c:	75 0c                	jne    800f2a <fork+0xa7>
  800f1e:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800f25:	f6 c4 08             	test   $0x8,%ah
  800f28:	74 3f                	je     800f69 <fork+0xe6>

		// map the page copy-on-write into the address space of the child
        r = sys_page_map(0, (void *)va, envid, (void *)va, PTE_P|PTE_U|PTE_COW);
  800f2a:	83 ec 0c             	sub    $0xc,%esp
  800f2d:	68 05 08 00 00       	push   $0x805
  800f32:	53                   	push   %ebx
  800f33:	57                   	push   %edi
  800f34:	53                   	push   %ebx
  800f35:	6a 00                	push   $0x0
  800f37:	e8 c0 fc ff ff       	call   800bfc <sys_page_map>
		if (r < 0)
  800f3c:	83 c4 20             	add    $0x20,%esp
  800f3f:	85 c0                	test   %eax,%eax
  800f41:	0f 88 9b 00 00 00    	js     800fe2 <fork+0x15f>
            return r;

		// remap the page copy-on-write in its own(parent) address space
        r = sys_page_map(0, (void *)va, 0, (void *)va, PTE_P|PTE_U|PTE_COW);
  800f47:	83 ec 0c             	sub    $0xc,%esp
  800f4a:	68 05 08 00 00       	push   $0x805
  800f4f:	53                   	push   %ebx
  800f50:	6a 00                	push   $0x0
  800f52:	53                   	push   %ebx
  800f53:	6a 00                	push   $0x0
  800f55:	e8 a2 fc ff ff       	call   800bfc <sys_page_map>
  800f5a:	83 c4 20             	add    $0x20,%esp
  800f5d:	85 c0                	test   %eax,%eax
  800f5f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f64:	0f 4f c1             	cmovg  %ecx,%eax
  800f67:	eb 1c                	jmp    800f85 <fork+0x102>
		if (r < 0)
            return r;
    }
    else {
        r = sys_page_map(0, (void *)va, envid, (void *)va, PTE_P|PTE_U);
  800f69:	83 ec 0c             	sub    $0xc,%esp
  800f6c:	6a 05                	push   $0x5
  800f6e:	53                   	push   %ebx
  800f6f:	57                   	push   %edi
  800f70:	53                   	push   %ebx
  800f71:	6a 00                	push   $0x0
  800f73:	e8 84 fc ff ff       	call   800bfc <sys_page_map>
  800f78:	83 c4 20             	add    $0x20,%esp
  800f7b:	85 c0                	test   %eax,%eax
  800f7d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f82:	0f 4f c1             	cmovg  %ecx,%eax
			if ((uvpt[PGNUM(addr)] & PTE_P) == PTE_P) {

				// For each writable or copy-on-write page
				if ((uvpt[PGNUM(addr)] & (PTE_W | PTE_COW)) != 0) {
					r = duppage(envid, pn);
					if (r < 0)
  800f85:	85 c0                	test   %eax,%eax
  800f87:	78 59                	js     800fe2 <fork+0x15f>
        return 0;
	}

	// For each writable or copy-on-write page in its address space below UTOP, the parent calls duppage
	uint32_t addr;
	for (uint32_t pn = PGNUM(UTEXT); pn < PGNUM(USTACKTOP); pn++) {
  800f89:	83 c6 01             	add    $0x1,%esi
  800f8c:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  800f92:	81 fe fe eb 0e 00    	cmp    $0xeebfe,%esi
  800f98:	0f 85 3e ff ff ff    	jne    800edc <fork+0x59>
  800f9e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
		}
	}

	// allocate a fresh page in the child for the exception stack
	r = sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U | PTE_P | PTE_W);
  800fa1:	83 ec 04             	sub    $0x4,%esp
  800fa4:	6a 07                	push   $0x7
  800fa6:	68 00 f0 bf ee       	push   $0xeebff000
  800fab:	57                   	push   %edi
  800fac:	e8 08 fc ff ff       	call   800bb9 <sys_page_alloc>
	if (r < 0)
  800fb1:	83 c4 10             	add    $0x10,%esp
  800fb4:	85 c0                	test   %eax,%eax
  800fb6:	78 2a                	js     800fe2 <fork+0x15f>
		return r;

	// The parent sets the user page fault entrypoint for the child to look like its own
	extern void _pgfault_upcall(void);
	r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  800fb8:	83 ec 08             	sub    $0x8,%esp
  800fbb:	68 fd 1d 80 00       	push   $0x801dfd
  800fc0:	57                   	push   %edi
  800fc1:	e8 3e fd ff ff       	call   800d04 <sys_env_set_pgfault_upcall>
	if (r < 0)
  800fc6:	83 c4 10             	add    $0x10,%esp
  800fc9:	85 c0                	test   %eax,%eax
  800fcb:	78 15                	js     800fe2 <fork+0x15f>
		return r;

	// The child is now ready to run, so the parent marks it runnable
	r = sys_env_set_status(envid, ENV_RUNNABLE);
  800fcd:	83 ec 08             	sub    $0x8,%esp
  800fd0:	6a 02                	push   $0x2
  800fd2:	57                   	push   %edi
  800fd3:	e8 a8 fc ff ff       	call   800c80 <sys_env_set_status>
	if (r < 0)
  800fd8:	83 c4 10             	add    $0x10,%esp
		return r;

	return envid;
  800fdb:	85 c0                	test   %eax,%eax
  800fdd:	0f 49 c7             	cmovns %edi,%eax
  800fe0:	eb 00                	jmp    800fe2 <fork+0x15f>
	// panic("fork not implemented");
}
  800fe2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fe5:	5b                   	pop    %ebx
  800fe6:	5e                   	pop    %esi
  800fe7:	5f                   	pop    %edi
  800fe8:	5d                   	pop    %ebp
  800fe9:	c3                   	ret    

00800fea <sfork>:

// Challenge!
int
sfork(void)
{
  800fea:	55                   	push   %ebp
  800feb:	89 e5                	mov    %esp,%ebp
  800fed:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  800ff0:	68 2b 25 80 00       	push   $0x80252b
  800ff5:	68 c3 00 00 00       	push   $0xc3
  800ffa:	68 20 25 80 00       	push   $0x802520
  800fff:	e8 54 f1 ff ff       	call   800158 <_panic>

00801004 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801004:	55                   	push   %ebp
  801005:	89 e5                	mov    %esp,%ebp
  801007:	56                   	push   %esi
  801008:	53                   	push   %ebx
  801009:	8b 75 08             	mov    0x8(%ebp),%esi
  80100c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80100f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");

	// don't want to recv page
	if (pg == NULL)
  801012:	85 c0                	test   %eax,%eax
		pg = (void *)UTOP;
  801014:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801019:	0f 44 c2             	cmove  %edx,%eax

	int err = sys_ipc_recv(pg);
  80101c:	83 ec 0c             	sub    $0xc,%esp
  80101f:	50                   	push   %eax
  801020:	e8 44 fd ff ff       	call   800d69 <sys_ipc_recv>

	if (from_env_store != NULL)
  801025:	83 c4 10             	add    $0x10,%esp
  801028:	85 f6                	test   %esi,%esi
  80102a:	74 14                	je     801040 <ipc_recv+0x3c>
		*from_env_store = err < 0? 0 : thisenv->env_ipc_from;
  80102c:	ba 00 00 00 00       	mov    $0x0,%edx
  801031:	85 c0                	test   %eax,%eax
  801033:	78 09                	js     80103e <ipc_recv+0x3a>
  801035:	8b 15 04 40 80 00    	mov    0x804004,%edx
  80103b:	8b 52 74             	mov    0x74(%edx),%edx
  80103e:	89 16                	mov    %edx,(%esi)
	
	if (perm_store != NULL)
  801040:	85 db                	test   %ebx,%ebx
  801042:	74 14                	je     801058 <ipc_recv+0x54>
		*perm_store = err < 0? 0 : thisenv->env_ipc_perm;
  801044:	ba 00 00 00 00       	mov    $0x0,%edx
  801049:	85 c0                	test   %eax,%eax
  80104b:	78 09                	js     801056 <ipc_recv+0x52>
  80104d:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801053:	8b 52 78             	mov    0x78(%edx),%edx
  801056:	89 13                	mov    %edx,(%ebx)

	if (err < 0)
  801058:	85 c0                	test   %eax,%eax
  80105a:	78 08                	js     801064 <ipc_recv+0x60>
		return err;
	return thisenv->env_ipc_value;
  80105c:	a1 04 40 80 00       	mov    0x804004,%eax
  801061:	8b 40 70             	mov    0x70(%eax),%eax
}
  801064:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801067:	5b                   	pop    %ebx
  801068:	5e                   	pop    %esi
  801069:	5d                   	pop    %ebp
  80106a:	c3                   	ret    

0080106b <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80106b:	55                   	push   %ebp
  80106c:	89 e5                	mov    %esp,%ebp
  80106e:	57                   	push   %edi
  80106f:	56                   	push   %esi
  801070:	53                   	push   %ebx
  801071:	83 ec 0c             	sub    $0xc,%esp
  801074:	8b 7d 08             	mov    0x8(%ebp),%edi
  801077:	8b 75 0c             	mov    0xc(%ebp),%esi
  80107a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");

	// don't want to send page
	if (pg == NULL)
  80107d:	85 db                	test   %ebx,%ebx
		pg = (void *)UTOP;
  80107f:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801084:	0f 44 d8             	cmove  %eax,%ebx
	
	int err = 0;
	
	do {

		err = sys_ipc_try_send(to_env, val, pg, perm);
  801087:	ff 75 14             	pushl  0x14(%ebp)
  80108a:	53                   	push   %ebx
  80108b:	56                   	push   %esi
  80108c:	57                   	push   %edi
  80108d:	e8 b4 fc ff ff       	call   800d46 <sys_ipc_try_send>

		if (err < 0) {
  801092:	83 c4 10             	add    $0x10,%esp
  801095:	85 c0                	test   %eax,%eax
  801097:	79 1e                	jns    8010b7 <ipc_send+0x4c>
			if (err == -E_IPC_NOT_RECV)
  801099:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80109c:	75 07                	jne    8010a5 <ipc_send+0x3a>
				sys_yield();
  80109e:	e8 f7 fa ff ff       	call   800b9a <sys_yield>
  8010a3:	eb e2                	jmp    801087 <ipc_send+0x1c>
			else 
				panic("ipc_send: %e", err);
  8010a5:	50                   	push   %eax
  8010a6:	68 41 25 80 00       	push   $0x802541
  8010ab:	6a 49                	push   $0x49
  8010ad:	68 4e 25 80 00       	push   $0x80254e
  8010b2:	e8 a1 f0 ff ff       	call   800158 <_panic>
		}

	} while (err < 0);

}
  8010b7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010ba:	5b                   	pop    %ebx
  8010bb:	5e                   	pop    %esi
  8010bc:	5f                   	pop    %edi
  8010bd:	5d                   	pop    %ebp
  8010be:	c3                   	ret    

008010bf <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8010bf:	55                   	push   %ebp
  8010c0:	89 e5                	mov    %esp,%ebp
  8010c2:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8010c5:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8010ca:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8010cd:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8010d3:	8b 52 50             	mov    0x50(%edx),%edx
  8010d6:	39 ca                	cmp    %ecx,%edx
  8010d8:	75 0d                	jne    8010e7 <ipc_find_env+0x28>
			return envs[i].env_id;
  8010da:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8010dd:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8010e2:	8b 40 48             	mov    0x48(%eax),%eax
  8010e5:	eb 0f                	jmp    8010f6 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8010e7:	83 c0 01             	add    $0x1,%eax
  8010ea:	3d 00 04 00 00       	cmp    $0x400,%eax
  8010ef:	75 d9                	jne    8010ca <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8010f1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8010f6:	5d                   	pop    %ebp
  8010f7:	c3                   	ret    

008010f8 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8010f8:	55                   	push   %ebp
  8010f9:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8010fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8010fe:	05 00 00 00 30       	add    $0x30000000,%eax
  801103:	c1 e8 0c             	shr    $0xc,%eax
}
  801106:	5d                   	pop    %ebp
  801107:	c3                   	ret    

00801108 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801108:	55                   	push   %ebp
  801109:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  80110b:	8b 45 08             	mov    0x8(%ebp),%eax
  80110e:	05 00 00 00 30       	add    $0x30000000,%eax
  801113:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801118:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80111d:	5d                   	pop    %ebp
  80111e:	c3                   	ret    

0080111f <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80111f:	55                   	push   %ebp
  801120:	89 e5                	mov    %esp,%ebp
  801122:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801125:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80112a:	89 c2                	mov    %eax,%edx
  80112c:	c1 ea 16             	shr    $0x16,%edx
  80112f:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801136:	f6 c2 01             	test   $0x1,%dl
  801139:	74 11                	je     80114c <fd_alloc+0x2d>
  80113b:	89 c2                	mov    %eax,%edx
  80113d:	c1 ea 0c             	shr    $0xc,%edx
  801140:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801147:	f6 c2 01             	test   $0x1,%dl
  80114a:	75 09                	jne    801155 <fd_alloc+0x36>
			*fd_store = fd;
  80114c:	89 01                	mov    %eax,(%ecx)
			return 0;
  80114e:	b8 00 00 00 00       	mov    $0x0,%eax
  801153:	eb 17                	jmp    80116c <fd_alloc+0x4d>
  801155:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80115a:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80115f:	75 c9                	jne    80112a <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801161:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801167:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80116c:	5d                   	pop    %ebp
  80116d:	c3                   	ret    

0080116e <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80116e:	55                   	push   %ebp
  80116f:	89 e5                	mov    %esp,%ebp
  801171:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801174:	83 f8 1f             	cmp    $0x1f,%eax
  801177:	77 36                	ja     8011af <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801179:	c1 e0 0c             	shl    $0xc,%eax
  80117c:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801181:	89 c2                	mov    %eax,%edx
  801183:	c1 ea 16             	shr    $0x16,%edx
  801186:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80118d:	f6 c2 01             	test   $0x1,%dl
  801190:	74 24                	je     8011b6 <fd_lookup+0x48>
  801192:	89 c2                	mov    %eax,%edx
  801194:	c1 ea 0c             	shr    $0xc,%edx
  801197:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80119e:	f6 c2 01             	test   $0x1,%dl
  8011a1:	74 1a                	je     8011bd <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8011a3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011a6:	89 02                	mov    %eax,(%edx)
	return 0;
  8011a8:	b8 00 00 00 00       	mov    $0x0,%eax
  8011ad:	eb 13                	jmp    8011c2 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8011af:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011b4:	eb 0c                	jmp    8011c2 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8011b6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011bb:	eb 05                	jmp    8011c2 <fd_lookup+0x54>
  8011bd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8011c2:	5d                   	pop    %ebp
  8011c3:	c3                   	ret    

008011c4 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8011c4:	55                   	push   %ebp
  8011c5:	89 e5                	mov    %esp,%ebp
  8011c7:	83 ec 08             	sub    $0x8,%esp
  8011ca:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011cd:	ba d8 25 80 00       	mov    $0x8025d8,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8011d2:	eb 13                	jmp    8011e7 <dev_lookup+0x23>
  8011d4:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8011d7:	39 08                	cmp    %ecx,(%eax)
  8011d9:	75 0c                	jne    8011e7 <dev_lookup+0x23>
			*dev = devtab[i];
  8011db:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011de:	89 01                	mov    %eax,(%ecx)
			return 0;
  8011e0:	b8 00 00 00 00       	mov    $0x0,%eax
  8011e5:	eb 2e                	jmp    801215 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8011e7:	8b 02                	mov    (%edx),%eax
  8011e9:	85 c0                	test   %eax,%eax
  8011eb:	75 e7                	jne    8011d4 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8011ed:	a1 04 40 80 00       	mov    0x804004,%eax
  8011f2:	8b 40 48             	mov    0x48(%eax),%eax
  8011f5:	83 ec 04             	sub    $0x4,%esp
  8011f8:	51                   	push   %ecx
  8011f9:	50                   	push   %eax
  8011fa:	68 58 25 80 00       	push   $0x802558
  8011ff:	e8 2d f0 ff ff       	call   800231 <cprintf>
	*dev = 0;
  801204:	8b 45 0c             	mov    0xc(%ebp),%eax
  801207:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80120d:	83 c4 10             	add    $0x10,%esp
  801210:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801215:	c9                   	leave  
  801216:	c3                   	ret    

00801217 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801217:	55                   	push   %ebp
  801218:	89 e5                	mov    %esp,%ebp
  80121a:	56                   	push   %esi
  80121b:	53                   	push   %ebx
  80121c:	83 ec 10             	sub    $0x10,%esp
  80121f:	8b 75 08             	mov    0x8(%ebp),%esi
  801222:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801225:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801228:	50                   	push   %eax
  801229:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80122f:	c1 e8 0c             	shr    $0xc,%eax
  801232:	50                   	push   %eax
  801233:	e8 36 ff ff ff       	call   80116e <fd_lookup>
  801238:	83 c4 08             	add    $0x8,%esp
  80123b:	85 c0                	test   %eax,%eax
  80123d:	78 05                	js     801244 <fd_close+0x2d>
	    || fd != fd2)
  80123f:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801242:	74 0c                	je     801250 <fd_close+0x39>
		return (must_exist ? r : 0);
  801244:	84 db                	test   %bl,%bl
  801246:	ba 00 00 00 00       	mov    $0x0,%edx
  80124b:	0f 44 c2             	cmove  %edx,%eax
  80124e:	eb 41                	jmp    801291 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801250:	83 ec 08             	sub    $0x8,%esp
  801253:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801256:	50                   	push   %eax
  801257:	ff 36                	pushl  (%esi)
  801259:	e8 66 ff ff ff       	call   8011c4 <dev_lookup>
  80125e:	89 c3                	mov    %eax,%ebx
  801260:	83 c4 10             	add    $0x10,%esp
  801263:	85 c0                	test   %eax,%eax
  801265:	78 1a                	js     801281 <fd_close+0x6a>
		if (dev->dev_close)
  801267:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80126a:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  80126d:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801272:	85 c0                	test   %eax,%eax
  801274:	74 0b                	je     801281 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801276:	83 ec 0c             	sub    $0xc,%esp
  801279:	56                   	push   %esi
  80127a:	ff d0                	call   *%eax
  80127c:	89 c3                	mov    %eax,%ebx
  80127e:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801281:	83 ec 08             	sub    $0x8,%esp
  801284:	56                   	push   %esi
  801285:	6a 00                	push   $0x0
  801287:	e8 b2 f9 ff ff       	call   800c3e <sys_page_unmap>
	return r;
  80128c:	83 c4 10             	add    $0x10,%esp
  80128f:	89 d8                	mov    %ebx,%eax
}
  801291:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801294:	5b                   	pop    %ebx
  801295:	5e                   	pop    %esi
  801296:	5d                   	pop    %ebp
  801297:	c3                   	ret    

00801298 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801298:	55                   	push   %ebp
  801299:	89 e5                	mov    %esp,%ebp
  80129b:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80129e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012a1:	50                   	push   %eax
  8012a2:	ff 75 08             	pushl  0x8(%ebp)
  8012a5:	e8 c4 fe ff ff       	call   80116e <fd_lookup>
  8012aa:	83 c4 08             	add    $0x8,%esp
  8012ad:	85 c0                	test   %eax,%eax
  8012af:	78 10                	js     8012c1 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8012b1:	83 ec 08             	sub    $0x8,%esp
  8012b4:	6a 01                	push   $0x1
  8012b6:	ff 75 f4             	pushl  -0xc(%ebp)
  8012b9:	e8 59 ff ff ff       	call   801217 <fd_close>
  8012be:	83 c4 10             	add    $0x10,%esp
}
  8012c1:	c9                   	leave  
  8012c2:	c3                   	ret    

008012c3 <close_all>:

void
close_all(void)
{
  8012c3:	55                   	push   %ebp
  8012c4:	89 e5                	mov    %esp,%ebp
  8012c6:	53                   	push   %ebx
  8012c7:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8012ca:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8012cf:	83 ec 0c             	sub    $0xc,%esp
  8012d2:	53                   	push   %ebx
  8012d3:	e8 c0 ff ff ff       	call   801298 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8012d8:	83 c3 01             	add    $0x1,%ebx
  8012db:	83 c4 10             	add    $0x10,%esp
  8012de:	83 fb 20             	cmp    $0x20,%ebx
  8012e1:	75 ec                	jne    8012cf <close_all+0xc>
		close(i);
}
  8012e3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012e6:	c9                   	leave  
  8012e7:	c3                   	ret    

008012e8 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8012e8:	55                   	push   %ebp
  8012e9:	89 e5                	mov    %esp,%ebp
  8012eb:	57                   	push   %edi
  8012ec:	56                   	push   %esi
  8012ed:	53                   	push   %ebx
  8012ee:	83 ec 2c             	sub    $0x2c,%esp
  8012f1:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8012f4:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8012f7:	50                   	push   %eax
  8012f8:	ff 75 08             	pushl  0x8(%ebp)
  8012fb:	e8 6e fe ff ff       	call   80116e <fd_lookup>
  801300:	83 c4 08             	add    $0x8,%esp
  801303:	85 c0                	test   %eax,%eax
  801305:	0f 88 c1 00 00 00    	js     8013cc <dup+0xe4>
		return r;
	close(newfdnum);
  80130b:	83 ec 0c             	sub    $0xc,%esp
  80130e:	56                   	push   %esi
  80130f:	e8 84 ff ff ff       	call   801298 <close>

	newfd = INDEX2FD(newfdnum);
  801314:	89 f3                	mov    %esi,%ebx
  801316:	c1 e3 0c             	shl    $0xc,%ebx
  801319:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  80131f:	83 c4 04             	add    $0x4,%esp
  801322:	ff 75 e4             	pushl  -0x1c(%ebp)
  801325:	e8 de fd ff ff       	call   801108 <fd2data>
  80132a:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  80132c:	89 1c 24             	mov    %ebx,(%esp)
  80132f:	e8 d4 fd ff ff       	call   801108 <fd2data>
  801334:	83 c4 10             	add    $0x10,%esp
  801337:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80133a:	89 f8                	mov    %edi,%eax
  80133c:	c1 e8 16             	shr    $0x16,%eax
  80133f:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801346:	a8 01                	test   $0x1,%al
  801348:	74 37                	je     801381 <dup+0x99>
  80134a:	89 f8                	mov    %edi,%eax
  80134c:	c1 e8 0c             	shr    $0xc,%eax
  80134f:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801356:	f6 c2 01             	test   $0x1,%dl
  801359:	74 26                	je     801381 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80135b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801362:	83 ec 0c             	sub    $0xc,%esp
  801365:	25 07 0e 00 00       	and    $0xe07,%eax
  80136a:	50                   	push   %eax
  80136b:	ff 75 d4             	pushl  -0x2c(%ebp)
  80136e:	6a 00                	push   $0x0
  801370:	57                   	push   %edi
  801371:	6a 00                	push   $0x0
  801373:	e8 84 f8 ff ff       	call   800bfc <sys_page_map>
  801378:	89 c7                	mov    %eax,%edi
  80137a:	83 c4 20             	add    $0x20,%esp
  80137d:	85 c0                	test   %eax,%eax
  80137f:	78 2e                	js     8013af <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801381:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801384:	89 d0                	mov    %edx,%eax
  801386:	c1 e8 0c             	shr    $0xc,%eax
  801389:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801390:	83 ec 0c             	sub    $0xc,%esp
  801393:	25 07 0e 00 00       	and    $0xe07,%eax
  801398:	50                   	push   %eax
  801399:	53                   	push   %ebx
  80139a:	6a 00                	push   $0x0
  80139c:	52                   	push   %edx
  80139d:	6a 00                	push   $0x0
  80139f:	e8 58 f8 ff ff       	call   800bfc <sys_page_map>
  8013a4:	89 c7                	mov    %eax,%edi
  8013a6:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8013a9:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8013ab:	85 ff                	test   %edi,%edi
  8013ad:	79 1d                	jns    8013cc <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8013af:	83 ec 08             	sub    $0x8,%esp
  8013b2:	53                   	push   %ebx
  8013b3:	6a 00                	push   $0x0
  8013b5:	e8 84 f8 ff ff       	call   800c3e <sys_page_unmap>
	sys_page_unmap(0, nva);
  8013ba:	83 c4 08             	add    $0x8,%esp
  8013bd:	ff 75 d4             	pushl  -0x2c(%ebp)
  8013c0:	6a 00                	push   $0x0
  8013c2:	e8 77 f8 ff ff       	call   800c3e <sys_page_unmap>
	return r;
  8013c7:	83 c4 10             	add    $0x10,%esp
  8013ca:	89 f8                	mov    %edi,%eax
}
  8013cc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013cf:	5b                   	pop    %ebx
  8013d0:	5e                   	pop    %esi
  8013d1:	5f                   	pop    %edi
  8013d2:	5d                   	pop    %ebp
  8013d3:	c3                   	ret    

008013d4 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8013d4:	55                   	push   %ebp
  8013d5:	89 e5                	mov    %esp,%ebp
  8013d7:	53                   	push   %ebx
  8013d8:	83 ec 14             	sub    $0x14,%esp
  8013db:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013de:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013e1:	50                   	push   %eax
  8013e2:	53                   	push   %ebx
  8013e3:	e8 86 fd ff ff       	call   80116e <fd_lookup>
  8013e8:	83 c4 08             	add    $0x8,%esp
  8013eb:	89 c2                	mov    %eax,%edx
  8013ed:	85 c0                	test   %eax,%eax
  8013ef:	78 6d                	js     80145e <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013f1:	83 ec 08             	sub    $0x8,%esp
  8013f4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013f7:	50                   	push   %eax
  8013f8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013fb:	ff 30                	pushl  (%eax)
  8013fd:	e8 c2 fd ff ff       	call   8011c4 <dev_lookup>
  801402:	83 c4 10             	add    $0x10,%esp
  801405:	85 c0                	test   %eax,%eax
  801407:	78 4c                	js     801455 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801409:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80140c:	8b 42 08             	mov    0x8(%edx),%eax
  80140f:	83 e0 03             	and    $0x3,%eax
  801412:	83 f8 01             	cmp    $0x1,%eax
  801415:	75 21                	jne    801438 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801417:	a1 04 40 80 00       	mov    0x804004,%eax
  80141c:	8b 40 48             	mov    0x48(%eax),%eax
  80141f:	83 ec 04             	sub    $0x4,%esp
  801422:	53                   	push   %ebx
  801423:	50                   	push   %eax
  801424:	68 9c 25 80 00       	push   $0x80259c
  801429:	e8 03 ee ff ff       	call   800231 <cprintf>
		return -E_INVAL;
  80142e:	83 c4 10             	add    $0x10,%esp
  801431:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801436:	eb 26                	jmp    80145e <read+0x8a>
	}
	if (!dev->dev_read)
  801438:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80143b:	8b 40 08             	mov    0x8(%eax),%eax
  80143e:	85 c0                	test   %eax,%eax
  801440:	74 17                	je     801459 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801442:	83 ec 04             	sub    $0x4,%esp
  801445:	ff 75 10             	pushl  0x10(%ebp)
  801448:	ff 75 0c             	pushl  0xc(%ebp)
  80144b:	52                   	push   %edx
  80144c:	ff d0                	call   *%eax
  80144e:	89 c2                	mov    %eax,%edx
  801450:	83 c4 10             	add    $0x10,%esp
  801453:	eb 09                	jmp    80145e <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801455:	89 c2                	mov    %eax,%edx
  801457:	eb 05                	jmp    80145e <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801459:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  80145e:	89 d0                	mov    %edx,%eax
  801460:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801463:	c9                   	leave  
  801464:	c3                   	ret    

00801465 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801465:	55                   	push   %ebp
  801466:	89 e5                	mov    %esp,%ebp
  801468:	57                   	push   %edi
  801469:	56                   	push   %esi
  80146a:	53                   	push   %ebx
  80146b:	83 ec 0c             	sub    $0xc,%esp
  80146e:	8b 7d 08             	mov    0x8(%ebp),%edi
  801471:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801474:	bb 00 00 00 00       	mov    $0x0,%ebx
  801479:	eb 21                	jmp    80149c <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80147b:	83 ec 04             	sub    $0x4,%esp
  80147e:	89 f0                	mov    %esi,%eax
  801480:	29 d8                	sub    %ebx,%eax
  801482:	50                   	push   %eax
  801483:	89 d8                	mov    %ebx,%eax
  801485:	03 45 0c             	add    0xc(%ebp),%eax
  801488:	50                   	push   %eax
  801489:	57                   	push   %edi
  80148a:	e8 45 ff ff ff       	call   8013d4 <read>
		if (m < 0)
  80148f:	83 c4 10             	add    $0x10,%esp
  801492:	85 c0                	test   %eax,%eax
  801494:	78 10                	js     8014a6 <readn+0x41>
			return m;
		if (m == 0)
  801496:	85 c0                	test   %eax,%eax
  801498:	74 0a                	je     8014a4 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80149a:	01 c3                	add    %eax,%ebx
  80149c:	39 f3                	cmp    %esi,%ebx
  80149e:	72 db                	jb     80147b <readn+0x16>
  8014a0:	89 d8                	mov    %ebx,%eax
  8014a2:	eb 02                	jmp    8014a6 <readn+0x41>
  8014a4:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8014a6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014a9:	5b                   	pop    %ebx
  8014aa:	5e                   	pop    %esi
  8014ab:	5f                   	pop    %edi
  8014ac:	5d                   	pop    %ebp
  8014ad:	c3                   	ret    

008014ae <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8014ae:	55                   	push   %ebp
  8014af:	89 e5                	mov    %esp,%ebp
  8014b1:	53                   	push   %ebx
  8014b2:	83 ec 14             	sub    $0x14,%esp
  8014b5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014b8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014bb:	50                   	push   %eax
  8014bc:	53                   	push   %ebx
  8014bd:	e8 ac fc ff ff       	call   80116e <fd_lookup>
  8014c2:	83 c4 08             	add    $0x8,%esp
  8014c5:	89 c2                	mov    %eax,%edx
  8014c7:	85 c0                	test   %eax,%eax
  8014c9:	78 68                	js     801533 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014cb:	83 ec 08             	sub    $0x8,%esp
  8014ce:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014d1:	50                   	push   %eax
  8014d2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014d5:	ff 30                	pushl  (%eax)
  8014d7:	e8 e8 fc ff ff       	call   8011c4 <dev_lookup>
  8014dc:	83 c4 10             	add    $0x10,%esp
  8014df:	85 c0                	test   %eax,%eax
  8014e1:	78 47                	js     80152a <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8014e3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014e6:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8014ea:	75 21                	jne    80150d <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8014ec:	a1 04 40 80 00       	mov    0x804004,%eax
  8014f1:	8b 40 48             	mov    0x48(%eax),%eax
  8014f4:	83 ec 04             	sub    $0x4,%esp
  8014f7:	53                   	push   %ebx
  8014f8:	50                   	push   %eax
  8014f9:	68 b8 25 80 00       	push   $0x8025b8
  8014fe:	e8 2e ed ff ff       	call   800231 <cprintf>
		return -E_INVAL;
  801503:	83 c4 10             	add    $0x10,%esp
  801506:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80150b:	eb 26                	jmp    801533 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80150d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801510:	8b 52 0c             	mov    0xc(%edx),%edx
  801513:	85 d2                	test   %edx,%edx
  801515:	74 17                	je     80152e <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801517:	83 ec 04             	sub    $0x4,%esp
  80151a:	ff 75 10             	pushl  0x10(%ebp)
  80151d:	ff 75 0c             	pushl  0xc(%ebp)
  801520:	50                   	push   %eax
  801521:	ff d2                	call   *%edx
  801523:	89 c2                	mov    %eax,%edx
  801525:	83 c4 10             	add    $0x10,%esp
  801528:	eb 09                	jmp    801533 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80152a:	89 c2                	mov    %eax,%edx
  80152c:	eb 05                	jmp    801533 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80152e:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801533:	89 d0                	mov    %edx,%eax
  801535:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801538:	c9                   	leave  
  801539:	c3                   	ret    

0080153a <seek>:

int
seek(int fdnum, off_t offset)
{
  80153a:	55                   	push   %ebp
  80153b:	89 e5                	mov    %esp,%ebp
  80153d:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801540:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801543:	50                   	push   %eax
  801544:	ff 75 08             	pushl  0x8(%ebp)
  801547:	e8 22 fc ff ff       	call   80116e <fd_lookup>
  80154c:	83 c4 08             	add    $0x8,%esp
  80154f:	85 c0                	test   %eax,%eax
  801551:	78 0e                	js     801561 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801553:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801556:	8b 55 0c             	mov    0xc(%ebp),%edx
  801559:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80155c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801561:	c9                   	leave  
  801562:	c3                   	ret    

00801563 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801563:	55                   	push   %ebp
  801564:	89 e5                	mov    %esp,%ebp
  801566:	53                   	push   %ebx
  801567:	83 ec 14             	sub    $0x14,%esp
  80156a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80156d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801570:	50                   	push   %eax
  801571:	53                   	push   %ebx
  801572:	e8 f7 fb ff ff       	call   80116e <fd_lookup>
  801577:	83 c4 08             	add    $0x8,%esp
  80157a:	89 c2                	mov    %eax,%edx
  80157c:	85 c0                	test   %eax,%eax
  80157e:	78 65                	js     8015e5 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801580:	83 ec 08             	sub    $0x8,%esp
  801583:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801586:	50                   	push   %eax
  801587:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80158a:	ff 30                	pushl  (%eax)
  80158c:	e8 33 fc ff ff       	call   8011c4 <dev_lookup>
  801591:	83 c4 10             	add    $0x10,%esp
  801594:	85 c0                	test   %eax,%eax
  801596:	78 44                	js     8015dc <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801598:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80159b:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80159f:	75 21                	jne    8015c2 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8015a1:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8015a6:	8b 40 48             	mov    0x48(%eax),%eax
  8015a9:	83 ec 04             	sub    $0x4,%esp
  8015ac:	53                   	push   %ebx
  8015ad:	50                   	push   %eax
  8015ae:	68 78 25 80 00       	push   $0x802578
  8015b3:	e8 79 ec ff ff       	call   800231 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8015b8:	83 c4 10             	add    $0x10,%esp
  8015bb:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8015c0:	eb 23                	jmp    8015e5 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8015c2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015c5:	8b 52 18             	mov    0x18(%edx),%edx
  8015c8:	85 d2                	test   %edx,%edx
  8015ca:	74 14                	je     8015e0 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8015cc:	83 ec 08             	sub    $0x8,%esp
  8015cf:	ff 75 0c             	pushl  0xc(%ebp)
  8015d2:	50                   	push   %eax
  8015d3:	ff d2                	call   *%edx
  8015d5:	89 c2                	mov    %eax,%edx
  8015d7:	83 c4 10             	add    $0x10,%esp
  8015da:	eb 09                	jmp    8015e5 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015dc:	89 c2                	mov    %eax,%edx
  8015de:	eb 05                	jmp    8015e5 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8015e0:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8015e5:	89 d0                	mov    %edx,%eax
  8015e7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015ea:	c9                   	leave  
  8015eb:	c3                   	ret    

008015ec <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8015ec:	55                   	push   %ebp
  8015ed:	89 e5                	mov    %esp,%ebp
  8015ef:	53                   	push   %ebx
  8015f0:	83 ec 14             	sub    $0x14,%esp
  8015f3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015f6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015f9:	50                   	push   %eax
  8015fa:	ff 75 08             	pushl  0x8(%ebp)
  8015fd:	e8 6c fb ff ff       	call   80116e <fd_lookup>
  801602:	83 c4 08             	add    $0x8,%esp
  801605:	89 c2                	mov    %eax,%edx
  801607:	85 c0                	test   %eax,%eax
  801609:	78 58                	js     801663 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80160b:	83 ec 08             	sub    $0x8,%esp
  80160e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801611:	50                   	push   %eax
  801612:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801615:	ff 30                	pushl  (%eax)
  801617:	e8 a8 fb ff ff       	call   8011c4 <dev_lookup>
  80161c:	83 c4 10             	add    $0x10,%esp
  80161f:	85 c0                	test   %eax,%eax
  801621:	78 37                	js     80165a <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801623:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801626:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80162a:	74 32                	je     80165e <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80162c:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80162f:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801636:	00 00 00 
	stat->st_isdir = 0;
  801639:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801640:	00 00 00 
	stat->st_dev = dev;
  801643:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801649:	83 ec 08             	sub    $0x8,%esp
  80164c:	53                   	push   %ebx
  80164d:	ff 75 f0             	pushl  -0x10(%ebp)
  801650:	ff 50 14             	call   *0x14(%eax)
  801653:	89 c2                	mov    %eax,%edx
  801655:	83 c4 10             	add    $0x10,%esp
  801658:	eb 09                	jmp    801663 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80165a:	89 c2                	mov    %eax,%edx
  80165c:	eb 05                	jmp    801663 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80165e:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801663:	89 d0                	mov    %edx,%eax
  801665:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801668:	c9                   	leave  
  801669:	c3                   	ret    

0080166a <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80166a:	55                   	push   %ebp
  80166b:	89 e5                	mov    %esp,%ebp
  80166d:	56                   	push   %esi
  80166e:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80166f:	83 ec 08             	sub    $0x8,%esp
  801672:	6a 00                	push   $0x0
  801674:	ff 75 08             	pushl  0x8(%ebp)
  801677:	e8 b7 01 00 00       	call   801833 <open>
  80167c:	89 c3                	mov    %eax,%ebx
  80167e:	83 c4 10             	add    $0x10,%esp
  801681:	85 c0                	test   %eax,%eax
  801683:	78 1b                	js     8016a0 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801685:	83 ec 08             	sub    $0x8,%esp
  801688:	ff 75 0c             	pushl  0xc(%ebp)
  80168b:	50                   	push   %eax
  80168c:	e8 5b ff ff ff       	call   8015ec <fstat>
  801691:	89 c6                	mov    %eax,%esi
	close(fd);
  801693:	89 1c 24             	mov    %ebx,(%esp)
  801696:	e8 fd fb ff ff       	call   801298 <close>
	return r;
  80169b:	83 c4 10             	add    $0x10,%esp
  80169e:	89 f0                	mov    %esi,%eax
}
  8016a0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016a3:	5b                   	pop    %ebx
  8016a4:	5e                   	pop    %esi
  8016a5:	5d                   	pop    %ebp
  8016a6:	c3                   	ret    

008016a7 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8016a7:	55                   	push   %ebp
  8016a8:	89 e5                	mov    %esp,%ebp
  8016aa:	56                   	push   %esi
  8016ab:	53                   	push   %ebx
  8016ac:	89 c6                	mov    %eax,%esi
  8016ae:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8016b0:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8016b7:	75 12                	jne    8016cb <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8016b9:	83 ec 0c             	sub    $0xc,%esp
  8016bc:	6a 01                	push   $0x1
  8016be:	e8 fc f9 ff ff       	call   8010bf <ipc_find_env>
  8016c3:	a3 00 40 80 00       	mov    %eax,0x804000
  8016c8:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8016cb:	6a 07                	push   $0x7
  8016cd:	68 00 50 80 00       	push   $0x805000
  8016d2:	56                   	push   %esi
  8016d3:	ff 35 00 40 80 00    	pushl  0x804000
  8016d9:	e8 8d f9 ff ff       	call   80106b <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8016de:	83 c4 0c             	add    $0xc,%esp
  8016e1:	6a 00                	push   $0x0
  8016e3:	53                   	push   %ebx
  8016e4:	6a 00                	push   $0x0
  8016e6:	e8 19 f9 ff ff       	call   801004 <ipc_recv>
}
  8016eb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016ee:	5b                   	pop    %ebx
  8016ef:	5e                   	pop    %esi
  8016f0:	5d                   	pop    %ebp
  8016f1:	c3                   	ret    

008016f2 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8016f2:	55                   	push   %ebp
  8016f3:	89 e5                	mov    %esp,%ebp
  8016f5:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8016f8:	8b 45 08             	mov    0x8(%ebp),%eax
  8016fb:	8b 40 0c             	mov    0xc(%eax),%eax
  8016fe:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801703:	8b 45 0c             	mov    0xc(%ebp),%eax
  801706:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80170b:	ba 00 00 00 00       	mov    $0x0,%edx
  801710:	b8 02 00 00 00       	mov    $0x2,%eax
  801715:	e8 8d ff ff ff       	call   8016a7 <fsipc>
}
  80171a:	c9                   	leave  
  80171b:	c3                   	ret    

0080171c <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80171c:	55                   	push   %ebp
  80171d:	89 e5                	mov    %esp,%ebp
  80171f:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801722:	8b 45 08             	mov    0x8(%ebp),%eax
  801725:	8b 40 0c             	mov    0xc(%eax),%eax
  801728:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80172d:	ba 00 00 00 00       	mov    $0x0,%edx
  801732:	b8 06 00 00 00       	mov    $0x6,%eax
  801737:	e8 6b ff ff ff       	call   8016a7 <fsipc>
}
  80173c:	c9                   	leave  
  80173d:	c3                   	ret    

0080173e <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80173e:	55                   	push   %ebp
  80173f:	89 e5                	mov    %esp,%ebp
  801741:	53                   	push   %ebx
  801742:	83 ec 04             	sub    $0x4,%esp
  801745:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801748:	8b 45 08             	mov    0x8(%ebp),%eax
  80174b:	8b 40 0c             	mov    0xc(%eax),%eax
  80174e:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801753:	ba 00 00 00 00       	mov    $0x0,%edx
  801758:	b8 05 00 00 00       	mov    $0x5,%eax
  80175d:	e8 45 ff ff ff       	call   8016a7 <fsipc>
  801762:	85 c0                	test   %eax,%eax
  801764:	78 2c                	js     801792 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801766:	83 ec 08             	sub    $0x8,%esp
  801769:	68 00 50 80 00       	push   $0x805000
  80176e:	53                   	push   %ebx
  80176f:	e8 42 f0 ff ff       	call   8007b6 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801774:	a1 80 50 80 00       	mov    0x805080,%eax
  801779:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80177f:	a1 84 50 80 00       	mov    0x805084,%eax
  801784:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80178a:	83 c4 10             	add    $0x10,%esp
  80178d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801792:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801795:	c9                   	leave  
  801796:	c3                   	ret    

00801797 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801797:	55                   	push   %ebp
  801798:	89 e5                	mov    %esp,%ebp
  80179a:	83 ec 0c             	sub    $0xc,%esp
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	panic("devfile_write not implemented");
  80179d:	68 e8 25 80 00       	push   $0x8025e8
  8017a2:	68 90 00 00 00       	push   $0x90
  8017a7:	68 06 26 80 00       	push   $0x802606
  8017ac:	e8 a7 e9 ff ff       	call   800158 <_panic>

008017b1 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8017b1:	55                   	push   %ebp
  8017b2:	89 e5                	mov    %esp,%ebp
  8017b4:	56                   	push   %esi
  8017b5:	53                   	push   %ebx
  8017b6:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8017b9:	8b 45 08             	mov    0x8(%ebp),%eax
  8017bc:	8b 40 0c             	mov    0xc(%eax),%eax
  8017bf:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8017c4:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8017ca:	ba 00 00 00 00       	mov    $0x0,%edx
  8017cf:	b8 03 00 00 00       	mov    $0x3,%eax
  8017d4:	e8 ce fe ff ff       	call   8016a7 <fsipc>
  8017d9:	89 c3                	mov    %eax,%ebx
  8017db:	85 c0                	test   %eax,%eax
  8017dd:	78 4b                	js     80182a <devfile_read+0x79>
		return r;
	assert(r <= n);
  8017df:	39 c6                	cmp    %eax,%esi
  8017e1:	73 16                	jae    8017f9 <devfile_read+0x48>
  8017e3:	68 11 26 80 00       	push   $0x802611
  8017e8:	68 18 26 80 00       	push   $0x802618
  8017ed:	6a 7c                	push   $0x7c
  8017ef:	68 06 26 80 00       	push   $0x802606
  8017f4:	e8 5f e9 ff ff       	call   800158 <_panic>
	assert(r <= PGSIZE);
  8017f9:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8017fe:	7e 16                	jle    801816 <devfile_read+0x65>
  801800:	68 2d 26 80 00       	push   $0x80262d
  801805:	68 18 26 80 00       	push   $0x802618
  80180a:	6a 7d                	push   $0x7d
  80180c:	68 06 26 80 00       	push   $0x802606
  801811:	e8 42 e9 ff ff       	call   800158 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801816:	83 ec 04             	sub    $0x4,%esp
  801819:	50                   	push   %eax
  80181a:	68 00 50 80 00       	push   $0x805000
  80181f:	ff 75 0c             	pushl  0xc(%ebp)
  801822:	e8 21 f1 ff ff       	call   800948 <memmove>
	return r;
  801827:	83 c4 10             	add    $0x10,%esp
}
  80182a:	89 d8                	mov    %ebx,%eax
  80182c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80182f:	5b                   	pop    %ebx
  801830:	5e                   	pop    %esi
  801831:	5d                   	pop    %ebp
  801832:	c3                   	ret    

00801833 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801833:	55                   	push   %ebp
  801834:	89 e5                	mov    %esp,%ebp
  801836:	53                   	push   %ebx
  801837:	83 ec 20             	sub    $0x20,%esp
  80183a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  80183d:	53                   	push   %ebx
  80183e:	e8 3a ef ff ff       	call   80077d <strlen>
  801843:	83 c4 10             	add    $0x10,%esp
  801846:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80184b:	7f 67                	jg     8018b4 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80184d:	83 ec 0c             	sub    $0xc,%esp
  801850:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801853:	50                   	push   %eax
  801854:	e8 c6 f8 ff ff       	call   80111f <fd_alloc>
  801859:	83 c4 10             	add    $0x10,%esp
		return r;
  80185c:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80185e:	85 c0                	test   %eax,%eax
  801860:	78 57                	js     8018b9 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801862:	83 ec 08             	sub    $0x8,%esp
  801865:	53                   	push   %ebx
  801866:	68 00 50 80 00       	push   $0x805000
  80186b:	e8 46 ef ff ff       	call   8007b6 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801870:	8b 45 0c             	mov    0xc(%ebp),%eax
  801873:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801878:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80187b:	b8 01 00 00 00       	mov    $0x1,%eax
  801880:	e8 22 fe ff ff       	call   8016a7 <fsipc>
  801885:	89 c3                	mov    %eax,%ebx
  801887:	83 c4 10             	add    $0x10,%esp
  80188a:	85 c0                	test   %eax,%eax
  80188c:	79 14                	jns    8018a2 <open+0x6f>
		fd_close(fd, 0);
  80188e:	83 ec 08             	sub    $0x8,%esp
  801891:	6a 00                	push   $0x0
  801893:	ff 75 f4             	pushl  -0xc(%ebp)
  801896:	e8 7c f9 ff ff       	call   801217 <fd_close>
		return r;
  80189b:	83 c4 10             	add    $0x10,%esp
  80189e:	89 da                	mov    %ebx,%edx
  8018a0:	eb 17                	jmp    8018b9 <open+0x86>
	}

	return fd2num(fd);
  8018a2:	83 ec 0c             	sub    $0xc,%esp
  8018a5:	ff 75 f4             	pushl  -0xc(%ebp)
  8018a8:	e8 4b f8 ff ff       	call   8010f8 <fd2num>
  8018ad:	89 c2                	mov    %eax,%edx
  8018af:	83 c4 10             	add    $0x10,%esp
  8018b2:	eb 05                	jmp    8018b9 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8018b4:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8018b9:	89 d0                	mov    %edx,%eax
  8018bb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018be:	c9                   	leave  
  8018bf:	c3                   	ret    

008018c0 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8018c0:	55                   	push   %ebp
  8018c1:	89 e5                	mov    %esp,%ebp
  8018c3:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8018c6:	ba 00 00 00 00       	mov    $0x0,%edx
  8018cb:	b8 08 00 00 00       	mov    $0x8,%eax
  8018d0:	e8 d2 fd ff ff       	call   8016a7 <fsipc>
}
  8018d5:	c9                   	leave  
  8018d6:	c3                   	ret    

008018d7 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8018d7:	55                   	push   %ebp
  8018d8:	89 e5                	mov    %esp,%ebp
  8018da:	56                   	push   %esi
  8018db:	53                   	push   %ebx
  8018dc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8018df:	83 ec 0c             	sub    $0xc,%esp
  8018e2:	ff 75 08             	pushl  0x8(%ebp)
  8018e5:	e8 1e f8 ff ff       	call   801108 <fd2data>
  8018ea:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8018ec:	83 c4 08             	add    $0x8,%esp
  8018ef:	68 39 26 80 00       	push   $0x802639
  8018f4:	53                   	push   %ebx
  8018f5:	e8 bc ee ff ff       	call   8007b6 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8018fa:	8b 46 04             	mov    0x4(%esi),%eax
  8018fd:	2b 06                	sub    (%esi),%eax
  8018ff:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801905:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80190c:	00 00 00 
	stat->st_dev = &devpipe;
  80190f:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801916:	30 80 00 
	return 0;
}
  801919:	b8 00 00 00 00       	mov    $0x0,%eax
  80191e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801921:	5b                   	pop    %ebx
  801922:	5e                   	pop    %esi
  801923:	5d                   	pop    %ebp
  801924:	c3                   	ret    

00801925 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801925:	55                   	push   %ebp
  801926:	89 e5                	mov    %esp,%ebp
  801928:	53                   	push   %ebx
  801929:	83 ec 0c             	sub    $0xc,%esp
  80192c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  80192f:	53                   	push   %ebx
  801930:	6a 00                	push   $0x0
  801932:	e8 07 f3 ff ff       	call   800c3e <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801937:	89 1c 24             	mov    %ebx,(%esp)
  80193a:	e8 c9 f7 ff ff       	call   801108 <fd2data>
  80193f:	83 c4 08             	add    $0x8,%esp
  801942:	50                   	push   %eax
  801943:	6a 00                	push   $0x0
  801945:	e8 f4 f2 ff ff       	call   800c3e <sys_page_unmap>
}
  80194a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80194d:	c9                   	leave  
  80194e:	c3                   	ret    

0080194f <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  80194f:	55                   	push   %ebp
  801950:	89 e5                	mov    %esp,%ebp
  801952:	57                   	push   %edi
  801953:	56                   	push   %esi
  801954:	53                   	push   %ebx
  801955:	83 ec 1c             	sub    $0x1c,%esp
  801958:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80195b:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  80195d:	a1 04 40 80 00       	mov    0x804004,%eax
  801962:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801965:	83 ec 0c             	sub    $0xc,%esp
  801968:	ff 75 e0             	pushl  -0x20(%ebp)
  80196b:	e8 b1 04 00 00       	call   801e21 <pageref>
  801970:	89 c3                	mov    %eax,%ebx
  801972:	89 3c 24             	mov    %edi,(%esp)
  801975:	e8 a7 04 00 00       	call   801e21 <pageref>
  80197a:	83 c4 10             	add    $0x10,%esp
  80197d:	39 c3                	cmp    %eax,%ebx
  80197f:	0f 94 c1             	sete   %cl
  801982:	0f b6 c9             	movzbl %cl,%ecx
  801985:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801988:	8b 15 04 40 80 00    	mov    0x804004,%edx
  80198e:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801991:	39 ce                	cmp    %ecx,%esi
  801993:	74 1b                	je     8019b0 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801995:	39 c3                	cmp    %eax,%ebx
  801997:	75 c4                	jne    80195d <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801999:	8b 42 58             	mov    0x58(%edx),%eax
  80199c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80199f:	50                   	push   %eax
  8019a0:	56                   	push   %esi
  8019a1:	68 40 26 80 00       	push   $0x802640
  8019a6:	e8 86 e8 ff ff       	call   800231 <cprintf>
  8019ab:	83 c4 10             	add    $0x10,%esp
  8019ae:	eb ad                	jmp    80195d <_pipeisclosed+0xe>
	}
}
  8019b0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8019b3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8019b6:	5b                   	pop    %ebx
  8019b7:	5e                   	pop    %esi
  8019b8:	5f                   	pop    %edi
  8019b9:	5d                   	pop    %ebp
  8019ba:	c3                   	ret    

008019bb <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8019bb:	55                   	push   %ebp
  8019bc:	89 e5                	mov    %esp,%ebp
  8019be:	57                   	push   %edi
  8019bf:	56                   	push   %esi
  8019c0:	53                   	push   %ebx
  8019c1:	83 ec 28             	sub    $0x28,%esp
  8019c4:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8019c7:	56                   	push   %esi
  8019c8:	e8 3b f7 ff ff       	call   801108 <fd2data>
  8019cd:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8019cf:	83 c4 10             	add    $0x10,%esp
  8019d2:	bf 00 00 00 00       	mov    $0x0,%edi
  8019d7:	eb 4b                	jmp    801a24 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8019d9:	89 da                	mov    %ebx,%edx
  8019db:	89 f0                	mov    %esi,%eax
  8019dd:	e8 6d ff ff ff       	call   80194f <_pipeisclosed>
  8019e2:	85 c0                	test   %eax,%eax
  8019e4:	75 48                	jne    801a2e <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8019e6:	e8 af f1 ff ff       	call   800b9a <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8019eb:	8b 43 04             	mov    0x4(%ebx),%eax
  8019ee:	8b 0b                	mov    (%ebx),%ecx
  8019f0:	8d 51 20             	lea    0x20(%ecx),%edx
  8019f3:	39 d0                	cmp    %edx,%eax
  8019f5:	73 e2                	jae    8019d9 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8019f7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8019fa:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  8019fe:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801a01:	89 c2                	mov    %eax,%edx
  801a03:	c1 fa 1f             	sar    $0x1f,%edx
  801a06:	89 d1                	mov    %edx,%ecx
  801a08:	c1 e9 1b             	shr    $0x1b,%ecx
  801a0b:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801a0e:	83 e2 1f             	and    $0x1f,%edx
  801a11:	29 ca                	sub    %ecx,%edx
  801a13:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801a17:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801a1b:	83 c0 01             	add    $0x1,%eax
  801a1e:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a21:	83 c7 01             	add    $0x1,%edi
  801a24:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801a27:	75 c2                	jne    8019eb <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801a29:	8b 45 10             	mov    0x10(%ebp),%eax
  801a2c:	eb 05                	jmp    801a33 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801a2e:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801a33:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a36:	5b                   	pop    %ebx
  801a37:	5e                   	pop    %esi
  801a38:	5f                   	pop    %edi
  801a39:	5d                   	pop    %ebp
  801a3a:	c3                   	ret    

00801a3b <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801a3b:	55                   	push   %ebp
  801a3c:	89 e5                	mov    %esp,%ebp
  801a3e:	57                   	push   %edi
  801a3f:	56                   	push   %esi
  801a40:	53                   	push   %ebx
  801a41:	83 ec 18             	sub    $0x18,%esp
  801a44:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801a47:	57                   	push   %edi
  801a48:	e8 bb f6 ff ff       	call   801108 <fd2data>
  801a4d:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a4f:	83 c4 10             	add    $0x10,%esp
  801a52:	bb 00 00 00 00       	mov    $0x0,%ebx
  801a57:	eb 3d                	jmp    801a96 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801a59:	85 db                	test   %ebx,%ebx
  801a5b:	74 04                	je     801a61 <devpipe_read+0x26>
				return i;
  801a5d:	89 d8                	mov    %ebx,%eax
  801a5f:	eb 44                	jmp    801aa5 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801a61:	89 f2                	mov    %esi,%edx
  801a63:	89 f8                	mov    %edi,%eax
  801a65:	e8 e5 fe ff ff       	call   80194f <_pipeisclosed>
  801a6a:	85 c0                	test   %eax,%eax
  801a6c:	75 32                	jne    801aa0 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801a6e:	e8 27 f1 ff ff       	call   800b9a <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801a73:	8b 06                	mov    (%esi),%eax
  801a75:	3b 46 04             	cmp    0x4(%esi),%eax
  801a78:	74 df                	je     801a59 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801a7a:	99                   	cltd   
  801a7b:	c1 ea 1b             	shr    $0x1b,%edx
  801a7e:	01 d0                	add    %edx,%eax
  801a80:	83 e0 1f             	and    $0x1f,%eax
  801a83:	29 d0                	sub    %edx,%eax
  801a85:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801a8a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a8d:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801a90:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a93:	83 c3 01             	add    $0x1,%ebx
  801a96:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801a99:	75 d8                	jne    801a73 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801a9b:	8b 45 10             	mov    0x10(%ebp),%eax
  801a9e:	eb 05                	jmp    801aa5 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801aa0:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801aa5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801aa8:	5b                   	pop    %ebx
  801aa9:	5e                   	pop    %esi
  801aaa:	5f                   	pop    %edi
  801aab:	5d                   	pop    %ebp
  801aac:	c3                   	ret    

00801aad <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801aad:	55                   	push   %ebp
  801aae:	89 e5                	mov    %esp,%ebp
  801ab0:	56                   	push   %esi
  801ab1:	53                   	push   %ebx
  801ab2:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801ab5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ab8:	50                   	push   %eax
  801ab9:	e8 61 f6 ff ff       	call   80111f <fd_alloc>
  801abe:	83 c4 10             	add    $0x10,%esp
  801ac1:	89 c2                	mov    %eax,%edx
  801ac3:	85 c0                	test   %eax,%eax
  801ac5:	0f 88 2c 01 00 00    	js     801bf7 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801acb:	83 ec 04             	sub    $0x4,%esp
  801ace:	68 07 04 00 00       	push   $0x407
  801ad3:	ff 75 f4             	pushl  -0xc(%ebp)
  801ad6:	6a 00                	push   $0x0
  801ad8:	e8 dc f0 ff ff       	call   800bb9 <sys_page_alloc>
  801add:	83 c4 10             	add    $0x10,%esp
  801ae0:	89 c2                	mov    %eax,%edx
  801ae2:	85 c0                	test   %eax,%eax
  801ae4:	0f 88 0d 01 00 00    	js     801bf7 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801aea:	83 ec 0c             	sub    $0xc,%esp
  801aed:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801af0:	50                   	push   %eax
  801af1:	e8 29 f6 ff ff       	call   80111f <fd_alloc>
  801af6:	89 c3                	mov    %eax,%ebx
  801af8:	83 c4 10             	add    $0x10,%esp
  801afb:	85 c0                	test   %eax,%eax
  801afd:	0f 88 e2 00 00 00    	js     801be5 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b03:	83 ec 04             	sub    $0x4,%esp
  801b06:	68 07 04 00 00       	push   $0x407
  801b0b:	ff 75 f0             	pushl  -0x10(%ebp)
  801b0e:	6a 00                	push   $0x0
  801b10:	e8 a4 f0 ff ff       	call   800bb9 <sys_page_alloc>
  801b15:	89 c3                	mov    %eax,%ebx
  801b17:	83 c4 10             	add    $0x10,%esp
  801b1a:	85 c0                	test   %eax,%eax
  801b1c:	0f 88 c3 00 00 00    	js     801be5 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801b22:	83 ec 0c             	sub    $0xc,%esp
  801b25:	ff 75 f4             	pushl  -0xc(%ebp)
  801b28:	e8 db f5 ff ff       	call   801108 <fd2data>
  801b2d:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b2f:	83 c4 0c             	add    $0xc,%esp
  801b32:	68 07 04 00 00       	push   $0x407
  801b37:	50                   	push   %eax
  801b38:	6a 00                	push   $0x0
  801b3a:	e8 7a f0 ff ff       	call   800bb9 <sys_page_alloc>
  801b3f:	89 c3                	mov    %eax,%ebx
  801b41:	83 c4 10             	add    $0x10,%esp
  801b44:	85 c0                	test   %eax,%eax
  801b46:	0f 88 89 00 00 00    	js     801bd5 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b4c:	83 ec 0c             	sub    $0xc,%esp
  801b4f:	ff 75 f0             	pushl  -0x10(%ebp)
  801b52:	e8 b1 f5 ff ff       	call   801108 <fd2data>
  801b57:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801b5e:	50                   	push   %eax
  801b5f:	6a 00                	push   $0x0
  801b61:	56                   	push   %esi
  801b62:	6a 00                	push   $0x0
  801b64:	e8 93 f0 ff ff       	call   800bfc <sys_page_map>
  801b69:	89 c3                	mov    %eax,%ebx
  801b6b:	83 c4 20             	add    $0x20,%esp
  801b6e:	85 c0                	test   %eax,%eax
  801b70:	78 55                	js     801bc7 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801b72:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801b78:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b7b:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801b7d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b80:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801b87:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801b8d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b90:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801b92:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b95:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801b9c:	83 ec 0c             	sub    $0xc,%esp
  801b9f:	ff 75 f4             	pushl  -0xc(%ebp)
  801ba2:	e8 51 f5 ff ff       	call   8010f8 <fd2num>
  801ba7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801baa:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801bac:	83 c4 04             	add    $0x4,%esp
  801baf:	ff 75 f0             	pushl  -0x10(%ebp)
  801bb2:	e8 41 f5 ff ff       	call   8010f8 <fd2num>
  801bb7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801bba:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801bbd:	83 c4 10             	add    $0x10,%esp
  801bc0:	ba 00 00 00 00       	mov    $0x0,%edx
  801bc5:	eb 30                	jmp    801bf7 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801bc7:	83 ec 08             	sub    $0x8,%esp
  801bca:	56                   	push   %esi
  801bcb:	6a 00                	push   $0x0
  801bcd:	e8 6c f0 ff ff       	call   800c3e <sys_page_unmap>
  801bd2:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801bd5:	83 ec 08             	sub    $0x8,%esp
  801bd8:	ff 75 f0             	pushl  -0x10(%ebp)
  801bdb:	6a 00                	push   $0x0
  801bdd:	e8 5c f0 ff ff       	call   800c3e <sys_page_unmap>
  801be2:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801be5:	83 ec 08             	sub    $0x8,%esp
  801be8:	ff 75 f4             	pushl  -0xc(%ebp)
  801beb:	6a 00                	push   $0x0
  801bed:	e8 4c f0 ff ff       	call   800c3e <sys_page_unmap>
  801bf2:	83 c4 10             	add    $0x10,%esp
  801bf5:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801bf7:	89 d0                	mov    %edx,%eax
  801bf9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801bfc:	5b                   	pop    %ebx
  801bfd:	5e                   	pop    %esi
  801bfe:	5d                   	pop    %ebp
  801bff:	c3                   	ret    

00801c00 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801c00:	55                   	push   %ebp
  801c01:	89 e5                	mov    %esp,%ebp
  801c03:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801c06:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c09:	50                   	push   %eax
  801c0a:	ff 75 08             	pushl  0x8(%ebp)
  801c0d:	e8 5c f5 ff ff       	call   80116e <fd_lookup>
  801c12:	83 c4 10             	add    $0x10,%esp
  801c15:	85 c0                	test   %eax,%eax
  801c17:	78 18                	js     801c31 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801c19:	83 ec 0c             	sub    $0xc,%esp
  801c1c:	ff 75 f4             	pushl  -0xc(%ebp)
  801c1f:	e8 e4 f4 ff ff       	call   801108 <fd2data>
	return _pipeisclosed(fd, p);
  801c24:	89 c2                	mov    %eax,%edx
  801c26:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c29:	e8 21 fd ff ff       	call   80194f <_pipeisclosed>
  801c2e:	83 c4 10             	add    $0x10,%esp
}
  801c31:	c9                   	leave  
  801c32:	c3                   	ret    

00801c33 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801c33:	55                   	push   %ebp
  801c34:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801c36:	b8 00 00 00 00       	mov    $0x0,%eax
  801c3b:	5d                   	pop    %ebp
  801c3c:	c3                   	ret    

00801c3d <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801c3d:	55                   	push   %ebp
  801c3e:	89 e5                	mov    %esp,%ebp
  801c40:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801c43:	68 58 26 80 00       	push   $0x802658
  801c48:	ff 75 0c             	pushl  0xc(%ebp)
  801c4b:	e8 66 eb ff ff       	call   8007b6 <strcpy>
	return 0;
}
  801c50:	b8 00 00 00 00       	mov    $0x0,%eax
  801c55:	c9                   	leave  
  801c56:	c3                   	ret    

00801c57 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801c57:	55                   	push   %ebp
  801c58:	89 e5                	mov    %esp,%ebp
  801c5a:	57                   	push   %edi
  801c5b:	56                   	push   %esi
  801c5c:	53                   	push   %ebx
  801c5d:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801c63:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801c68:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801c6e:	eb 2d                	jmp    801c9d <devcons_write+0x46>
		m = n - tot;
  801c70:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801c73:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801c75:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801c78:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801c7d:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801c80:	83 ec 04             	sub    $0x4,%esp
  801c83:	53                   	push   %ebx
  801c84:	03 45 0c             	add    0xc(%ebp),%eax
  801c87:	50                   	push   %eax
  801c88:	57                   	push   %edi
  801c89:	e8 ba ec ff ff       	call   800948 <memmove>
		sys_cputs(buf, m);
  801c8e:	83 c4 08             	add    $0x8,%esp
  801c91:	53                   	push   %ebx
  801c92:	57                   	push   %edi
  801c93:	e8 65 ee ff ff       	call   800afd <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801c98:	01 de                	add    %ebx,%esi
  801c9a:	83 c4 10             	add    $0x10,%esp
  801c9d:	89 f0                	mov    %esi,%eax
  801c9f:	3b 75 10             	cmp    0x10(%ebp),%esi
  801ca2:	72 cc                	jb     801c70 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801ca4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ca7:	5b                   	pop    %ebx
  801ca8:	5e                   	pop    %esi
  801ca9:	5f                   	pop    %edi
  801caa:	5d                   	pop    %ebp
  801cab:	c3                   	ret    

00801cac <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801cac:	55                   	push   %ebp
  801cad:	89 e5                	mov    %esp,%ebp
  801caf:	83 ec 08             	sub    $0x8,%esp
  801cb2:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801cb7:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801cbb:	74 2a                	je     801ce7 <devcons_read+0x3b>
  801cbd:	eb 05                	jmp    801cc4 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801cbf:	e8 d6 ee ff ff       	call   800b9a <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801cc4:	e8 52 ee ff ff       	call   800b1b <sys_cgetc>
  801cc9:	85 c0                	test   %eax,%eax
  801ccb:	74 f2                	je     801cbf <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801ccd:	85 c0                	test   %eax,%eax
  801ccf:	78 16                	js     801ce7 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801cd1:	83 f8 04             	cmp    $0x4,%eax
  801cd4:	74 0c                	je     801ce2 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801cd6:	8b 55 0c             	mov    0xc(%ebp),%edx
  801cd9:	88 02                	mov    %al,(%edx)
	return 1;
  801cdb:	b8 01 00 00 00       	mov    $0x1,%eax
  801ce0:	eb 05                	jmp    801ce7 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801ce2:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801ce7:	c9                   	leave  
  801ce8:	c3                   	ret    

00801ce9 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801ce9:	55                   	push   %ebp
  801cea:	89 e5                	mov    %esp,%ebp
  801cec:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801cef:	8b 45 08             	mov    0x8(%ebp),%eax
  801cf2:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801cf5:	6a 01                	push   $0x1
  801cf7:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801cfa:	50                   	push   %eax
  801cfb:	e8 fd ed ff ff       	call   800afd <sys_cputs>
}
  801d00:	83 c4 10             	add    $0x10,%esp
  801d03:	c9                   	leave  
  801d04:	c3                   	ret    

00801d05 <getchar>:

int
getchar(void)
{
  801d05:	55                   	push   %ebp
  801d06:	89 e5                	mov    %esp,%ebp
  801d08:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801d0b:	6a 01                	push   $0x1
  801d0d:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801d10:	50                   	push   %eax
  801d11:	6a 00                	push   $0x0
  801d13:	e8 bc f6 ff ff       	call   8013d4 <read>
	if (r < 0)
  801d18:	83 c4 10             	add    $0x10,%esp
  801d1b:	85 c0                	test   %eax,%eax
  801d1d:	78 0f                	js     801d2e <getchar+0x29>
		return r;
	if (r < 1)
  801d1f:	85 c0                	test   %eax,%eax
  801d21:	7e 06                	jle    801d29 <getchar+0x24>
		return -E_EOF;
	return c;
  801d23:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801d27:	eb 05                	jmp    801d2e <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801d29:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801d2e:	c9                   	leave  
  801d2f:	c3                   	ret    

00801d30 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801d30:	55                   	push   %ebp
  801d31:	89 e5                	mov    %esp,%ebp
  801d33:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801d36:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d39:	50                   	push   %eax
  801d3a:	ff 75 08             	pushl  0x8(%ebp)
  801d3d:	e8 2c f4 ff ff       	call   80116e <fd_lookup>
  801d42:	83 c4 10             	add    $0x10,%esp
  801d45:	85 c0                	test   %eax,%eax
  801d47:	78 11                	js     801d5a <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801d49:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d4c:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801d52:	39 10                	cmp    %edx,(%eax)
  801d54:	0f 94 c0             	sete   %al
  801d57:	0f b6 c0             	movzbl %al,%eax
}
  801d5a:	c9                   	leave  
  801d5b:	c3                   	ret    

00801d5c <opencons>:

int
opencons(void)
{
  801d5c:	55                   	push   %ebp
  801d5d:	89 e5                	mov    %esp,%ebp
  801d5f:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801d62:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d65:	50                   	push   %eax
  801d66:	e8 b4 f3 ff ff       	call   80111f <fd_alloc>
  801d6b:	83 c4 10             	add    $0x10,%esp
		return r;
  801d6e:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801d70:	85 c0                	test   %eax,%eax
  801d72:	78 3e                	js     801db2 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801d74:	83 ec 04             	sub    $0x4,%esp
  801d77:	68 07 04 00 00       	push   $0x407
  801d7c:	ff 75 f4             	pushl  -0xc(%ebp)
  801d7f:	6a 00                	push   $0x0
  801d81:	e8 33 ee ff ff       	call   800bb9 <sys_page_alloc>
  801d86:	83 c4 10             	add    $0x10,%esp
		return r;
  801d89:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801d8b:	85 c0                	test   %eax,%eax
  801d8d:	78 23                	js     801db2 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801d8f:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801d95:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d98:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801d9a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d9d:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801da4:	83 ec 0c             	sub    $0xc,%esp
  801da7:	50                   	push   %eax
  801da8:	e8 4b f3 ff ff       	call   8010f8 <fd2num>
  801dad:	89 c2                	mov    %eax,%edx
  801daf:	83 c4 10             	add    $0x10,%esp
}
  801db2:	89 d0                	mov    %edx,%eax
  801db4:	c9                   	leave  
  801db5:	c3                   	ret    

00801db6 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801db6:	55                   	push   %ebp
  801db7:	89 e5                	mov    %esp,%ebp
  801db9:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801dbc:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801dc3:	75 2e                	jne    801df3 <set_pgfault_handler+0x3d>
		// First time through!
		// LAB 4: Your code here.
		// panic("set_pgfault_handler not implemented");

		sys_page_alloc(sys_getenvid(), (void *) (UXSTACKTOP - PGSIZE), PTE_SYSCALL);
  801dc5:	e8 b1 ed ff ff       	call   800b7b <sys_getenvid>
  801dca:	83 ec 04             	sub    $0x4,%esp
  801dcd:	68 07 0e 00 00       	push   $0xe07
  801dd2:	68 00 f0 bf ee       	push   $0xeebff000
  801dd7:	50                   	push   %eax
  801dd8:	e8 dc ed ff ff       	call   800bb9 <sys_page_alloc>
		sys_env_set_pgfault_upcall(sys_getenvid(), _pgfault_upcall);
  801ddd:	e8 99 ed ff ff       	call   800b7b <sys_getenvid>
  801de2:	83 c4 08             	add    $0x8,%esp
  801de5:	68 fd 1d 80 00       	push   $0x801dfd
  801dea:	50                   	push   %eax
  801deb:	e8 14 ef ff ff       	call   800d04 <sys_env_set_pgfault_upcall>
  801df0:	83 c4 10             	add    $0x10,%esp
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801df3:	8b 45 08             	mov    0x8(%ebp),%eax
  801df6:	a3 00 60 80 00       	mov    %eax,0x806000
}
  801dfb:	c9                   	leave  
  801dfc:	c3                   	ret    

00801dfd <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801dfd:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801dfe:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801e03:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801e05:	83 c4 04             	add    $0x4,%esp
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.

	movl 48(%esp), %eax		// trap-time esp
  801e08:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl 40(%esp), %ebx		// trap-time eip
  801e0c:	8b 5c 24 28          	mov    0x28(%esp),%ebx

	// load eip into esp-4
	// in order to return to trap-time eip later, in the meantime not changing trap-time esp
	movl %ebx, -4(%eax)	
  801e10:	89 58 fc             	mov    %ebx,-0x4(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.

	addl $8, %esp 			// esp now points to trap-time registers
  801e13:	83 c4 08             	add    $0x8,%esp
	popal					// pop to all registers
  801e16:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

	addl $4, %esp			// esp now points to trap-time eflags
  801e17:	83 c4 04             	add    $0x4,%esp
	popfl					// pop to eflags
  801e1a:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.

	popl %esp				// pop to esp
  801e1b:	5c                   	pop    %esp
	// subl $4, %esp		// arithmetic operation will change eflags!!!
	lea -4(%esp), %esp		// subl $4, %esp
  801e1c:	8d 64 24 fc          	lea    -0x4(%esp),%esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.

	ret
  801e20:	c3                   	ret    

00801e21 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801e21:	55                   	push   %ebp
  801e22:	89 e5                	mov    %esp,%ebp
  801e24:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801e27:	89 d0                	mov    %edx,%eax
  801e29:	c1 e8 16             	shr    $0x16,%eax
  801e2c:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801e33:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801e38:	f6 c1 01             	test   $0x1,%cl
  801e3b:	74 1d                	je     801e5a <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801e3d:	c1 ea 0c             	shr    $0xc,%edx
  801e40:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801e47:	f6 c2 01             	test   $0x1,%dl
  801e4a:	74 0e                	je     801e5a <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801e4c:	c1 ea 0c             	shr    $0xc,%edx
  801e4f:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801e56:	ef 
  801e57:	0f b7 c0             	movzwl %ax,%eax
}
  801e5a:	5d                   	pop    %ebp
  801e5b:	c3                   	ret    
  801e5c:	66 90                	xchg   %ax,%ax
  801e5e:	66 90                	xchg   %ax,%ax

00801e60 <__udivdi3>:
  801e60:	55                   	push   %ebp
  801e61:	57                   	push   %edi
  801e62:	56                   	push   %esi
  801e63:	53                   	push   %ebx
  801e64:	83 ec 1c             	sub    $0x1c,%esp
  801e67:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801e6b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801e6f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801e73:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801e77:	85 f6                	test   %esi,%esi
  801e79:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801e7d:	89 ca                	mov    %ecx,%edx
  801e7f:	89 f8                	mov    %edi,%eax
  801e81:	75 3d                	jne    801ec0 <__udivdi3+0x60>
  801e83:	39 cf                	cmp    %ecx,%edi
  801e85:	0f 87 c5 00 00 00    	ja     801f50 <__udivdi3+0xf0>
  801e8b:	85 ff                	test   %edi,%edi
  801e8d:	89 fd                	mov    %edi,%ebp
  801e8f:	75 0b                	jne    801e9c <__udivdi3+0x3c>
  801e91:	b8 01 00 00 00       	mov    $0x1,%eax
  801e96:	31 d2                	xor    %edx,%edx
  801e98:	f7 f7                	div    %edi
  801e9a:	89 c5                	mov    %eax,%ebp
  801e9c:	89 c8                	mov    %ecx,%eax
  801e9e:	31 d2                	xor    %edx,%edx
  801ea0:	f7 f5                	div    %ebp
  801ea2:	89 c1                	mov    %eax,%ecx
  801ea4:	89 d8                	mov    %ebx,%eax
  801ea6:	89 cf                	mov    %ecx,%edi
  801ea8:	f7 f5                	div    %ebp
  801eaa:	89 c3                	mov    %eax,%ebx
  801eac:	89 d8                	mov    %ebx,%eax
  801eae:	89 fa                	mov    %edi,%edx
  801eb0:	83 c4 1c             	add    $0x1c,%esp
  801eb3:	5b                   	pop    %ebx
  801eb4:	5e                   	pop    %esi
  801eb5:	5f                   	pop    %edi
  801eb6:	5d                   	pop    %ebp
  801eb7:	c3                   	ret    
  801eb8:	90                   	nop
  801eb9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801ec0:	39 ce                	cmp    %ecx,%esi
  801ec2:	77 74                	ja     801f38 <__udivdi3+0xd8>
  801ec4:	0f bd fe             	bsr    %esi,%edi
  801ec7:	83 f7 1f             	xor    $0x1f,%edi
  801eca:	0f 84 98 00 00 00    	je     801f68 <__udivdi3+0x108>
  801ed0:	bb 20 00 00 00       	mov    $0x20,%ebx
  801ed5:	89 f9                	mov    %edi,%ecx
  801ed7:	89 c5                	mov    %eax,%ebp
  801ed9:	29 fb                	sub    %edi,%ebx
  801edb:	d3 e6                	shl    %cl,%esi
  801edd:	89 d9                	mov    %ebx,%ecx
  801edf:	d3 ed                	shr    %cl,%ebp
  801ee1:	89 f9                	mov    %edi,%ecx
  801ee3:	d3 e0                	shl    %cl,%eax
  801ee5:	09 ee                	or     %ebp,%esi
  801ee7:	89 d9                	mov    %ebx,%ecx
  801ee9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801eed:	89 d5                	mov    %edx,%ebp
  801eef:	8b 44 24 08          	mov    0x8(%esp),%eax
  801ef3:	d3 ed                	shr    %cl,%ebp
  801ef5:	89 f9                	mov    %edi,%ecx
  801ef7:	d3 e2                	shl    %cl,%edx
  801ef9:	89 d9                	mov    %ebx,%ecx
  801efb:	d3 e8                	shr    %cl,%eax
  801efd:	09 c2                	or     %eax,%edx
  801eff:	89 d0                	mov    %edx,%eax
  801f01:	89 ea                	mov    %ebp,%edx
  801f03:	f7 f6                	div    %esi
  801f05:	89 d5                	mov    %edx,%ebp
  801f07:	89 c3                	mov    %eax,%ebx
  801f09:	f7 64 24 0c          	mull   0xc(%esp)
  801f0d:	39 d5                	cmp    %edx,%ebp
  801f0f:	72 10                	jb     801f21 <__udivdi3+0xc1>
  801f11:	8b 74 24 08          	mov    0x8(%esp),%esi
  801f15:	89 f9                	mov    %edi,%ecx
  801f17:	d3 e6                	shl    %cl,%esi
  801f19:	39 c6                	cmp    %eax,%esi
  801f1b:	73 07                	jae    801f24 <__udivdi3+0xc4>
  801f1d:	39 d5                	cmp    %edx,%ebp
  801f1f:	75 03                	jne    801f24 <__udivdi3+0xc4>
  801f21:	83 eb 01             	sub    $0x1,%ebx
  801f24:	31 ff                	xor    %edi,%edi
  801f26:	89 d8                	mov    %ebx,%eax
  801f28:	89 fa                	mov    %edi,%edx
  801f2a:	83 c4 1c             	add    $0x1c,%esp
  801f2d:	5b                   	pop    %ebx
  801f2e:	5e                   	pop    %esi
  801f2f:	5f                   	pop    %edi
  801f30:	5d                   	pop    %ebp
  801f31:	c3                   	ret    
  801f32:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801f38:	31 ff                	xor    %edi,%edi
  801f3a:	31 db                	xor    %ebx,%ebx
  801f3c:	89 d8                	mov    %ebx,%eax
  801f3e:	89 fa                	mov    %edi,%edx
  801f40:	83 c4 1c             	add    $0x1c,%esp
  801f43:	5b                   	pop    %ebx
  801f44:	5e                   	pop    %esi
  801f45:	5f                   	pop    %edi
  801f46:	5d                   	pop    %ebp
  801f47:	c3                   	ret    
  801f48:	90                   	nop
  801f49:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801f50:	89 d8                	mov    %ebx,%eax
  801f52:	f7 f7                	div    %edi
  801f54:	31 ff                	xor    %edi,%edi
  801f56:	89 c3                	mov    %eax,%ebx
  801f58:	89 d8                	mov    %ebx,%eax
  801f5a:	89 fa                	mov    %edi,%edx
  801f5c:	83 c4 1c             	add    $0x1c,%esp
  801f5f:	5b                   	pop    %ebx
  801f60:	5e                   	pop    %esi
  801f61:	5f                   	pop    %edi
  801f62:	5d                   	pop    %ebp
  801f63:	c3                   	ret    
  801f64:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801f68:	39 ce                	cmp    %ecx,%esi
  801f6a:	72 0c                	jb     801f78 <__udivdi3+0x118>
  801f6c:	31 db                	xor    %ebx,%ebx
  801f6e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801f72:	0f 87 34 ff ff ff    	ja     801eac <__udivdi3+0x4c>
  801f78:	bb 01 00 00 00       	mov    $0x1,%ebx
  801f7d:	e9 2a ff ff ff       	jmp    801eac <__udivdi3+0x4c>
  801f82:	66 90                	xchg   %ax,%ax
  801f84:	66 90                	xchg   %ax,%ax
  801f86:	66 90                	xchg   %ax,%ax
  801f88:	66 90                	xchg   %ax,%ax
  801f8a:	66 90                	xchg   %ax,%ax
  801f8c:	66 90                	xchg   %ax,%ax
  801f8e:	66 90                	xchg   %ax,%ax

00801f90 <__umoddi3>:
  801f90:	55                   	push   %ebp
  801f91:	57                   	push   %edi
  801f92:	56                   	push   %esi
  801f93:	53                   	push   %ebx
  801f94:	83 ec 1c             	sub    $0x1c,%esp
  801f97:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801f9b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801f9f:	8b 74 24 34          	mov    0x34(%esp),%esi
  801fa3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801fa7:	85 d2                	test   %edx,%edx
  801fa9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801fad:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801fb1:	89 f3                	mov    %esi,%ebx
  801fb3:	89 3c 24             	mov    %edi,(%esp)
  801fb6:	89 74 24 04          	mov    %esi,0x4(%esp)
  801fba:	75 1c                	jne    801fd8 <__umoddi3+0x48>
  801fbc:	39 f7                	cmp    %esi,%edi
  801fbe:	76 50                	jbe    802010 <__umoddi3+0x80>
  801fc0:	89 c8                	mov    %ecx,%eax
  801fc2:	89 f2                	mov    %esi,%edx
  801fc4:	f7 f7                	div    %edi
  801fc6:	89 d0                	mov    %edx,%eax
  801fc8:	31 d2                	xor    %edx,%edx
  801fca:	83 c4 1c             	add    $0x1c,%esp
  801fcd:	5b                   	pop    %ebx
  801fce:	5e                   	pop    %esi
  801fcf:	5f                   	pop    %edi
  801fd0:	5d                   	pop    %ebp
  801fd1:	c3                   	ret    
  801fd2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801fd8:	39 f2                	cmp    %esi,%edx
  801fda:	89 d0                	mov    %edx,%eax
  801fdc:	77 52                	ja     802030 <__umoddi3+0xa0>
  801fde:	0f bd ea             	bsr    %edx,%ebp
  801fe1:	83 f5 1f             	xor    $0x1f,%ebp
  801fe4:	75 5a                	jne    802040 <__umoddi3+0xb0>
  801fe6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  801fea:	0f 82 e0 00 00 00    	jb     8020d0 <__umoddi3+0x140>
  801ff0:	39 0c 24             	cmp    %ecx,(%esp)
  801ff3:	0f 86 d7 00 00 00    	jbe    8020d0 <__umoddi3+0x140>
  801ff9:	8b 44 24 08          	mov    0x8(%esp),%eax
  801ffd:	8b 54 24 04          	mov    0x4(%esp),%edx
  802001:	83 c4 1c             	add    $0x1c,%esp
  802004:	5b                   	pop    %ebx
  802005:	5e                   	pop    %esi
  802006:	5f                   	pop    %edi
  802007:	5d                   	pop    %ebp
  802008:	c3                   	ret    
  802009:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802010:	85 ff                	test   %edi,%edi
  802012:	89 fd                	mov    %edi,%ebp
  802014:	75 0b                	jne    802021 <__umoddi3+0x91>
  802016:	b8 01 00 00 00       	mov    $0x1,%eax
  80201b:	31 d2                	xor    %edx,%edx
  80201d:	f7 f7                	div    %edi
  80201f:	89 c5                	mov    %eax,%ebp
  802021:	89 f0                	mov    %esi,%eax
  802023:	31 d2                	xor    %edx,%edx
  802025:	f7 f5                	div    %ebp
  802027:	89 c8                	mov    %ecx,%eax
  802029:	f7 f5                	div    %ebp
  80202b:	89 d0                	mov    %edx,%eax
  80202d:	eb 99                	jmp    801fc8 <__umoddi3+0x38>
  80202f:	90                   	nop
  802030:	89 c8                	mov    %ecx,%eax
  802032:	89 f2                	mov    %esi,%edx
  802034:	83 c4 1c             	add    $0x1c,%esp
  802037:	5b                   	pop    %ebx
  802038:	5e                   	pop    %esi
  802039:	5f                   	pop    %edi
  80203a:	5d                   	pop    %ebp
  80203b:	c3                   	ret    
  80203c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802040:	8b 34 24             	mov    (%esp),%esi
  802043:	bf 20 00 00 00       	mov    $0x20,%edi
  802048:	89 e9                	mov    %ebp,%ecx
  80204a:	29 ef                	sub    %ebp,%edi
  80204c:	d3 e0                	shl    %cl,%eax
  80204e:	89 f9                	mov    %edi,%ecx
  802050:	89 f2                	mov    %esi,%edx
  802052:	d3 ea                	shr    %cl,%edx
  802054:	89 e9                	mov    %ebp,%ecx
  802056:	09 c2                	or     %eax,%edx
  802058:	89 d8                	mov    %ebx,%eax
  80205a:	89 14 24             	mov    %edx,(%esp)
  80205d:	89 f2                	mov    %esi,%edx
  80205f:	d3 e2                	shl    %cl,%edx
  802061:	89 f9                	mov    %edi,%ecx
  802063:	89 54 24 04          	mov    %edx,0x4(%esp)
  802067:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80206b:	d3 e8                	shr    %cl,%eax
  80206d:	89 e9                	mov    %ebp,%ecx
  80206f:	89 c6                	mov    %eax,%esi
  802071:	d3 e3                	shl    %cl,%ebx
  802073:	89 f9                	mov    %edi,%ecx
  802075:	89 d0                	mov    %edx,%eax
  802077:	d3 e8                	shr    %cl,%eax
  802079:	89 e9                	mov    %ebp,%ecx
  80207b:	09 d8                	or     %ebx,%eax
  80207d:	89 d3                	mov    %edx,%ebx
  80207f:	89 f2                	mov    %esi,%edx
  802081:	f7 34 24             	divl   (%esp)
  802084:	89 d6                	mov    %edx,%esi
  802086:	d3 e3                	shl    %cl,%ebx
  802088:	f7 64 24 04          	mull   0x4(%esp)
  80208c:	39 d6                	cmp    %edx,%esi
  80208e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802092:	89 d1                	mov    %edx,%ecx
  802094:	89 c3                	mov    %eax,%ebx
  802096:	72 08                	jb     8020a0 <__umoddi3+0x110>
  802098:	75 11                	jne    8020ab <__umoddi3+0x11b>
  80209a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80209e:	73 0b                	jae    8020ab <__umoddi3+0x11b>
  8020a0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8020a4:	1b 14 24             	sbb    (%esp),%edx
  8020a7:	89 d1                	mov    %edx,%ecx
  8020a9:	89 c3                	mov    %eax,%ebx
  8020ab:	8b 54 24 08          	mov    0x8(%esp),%edx
  8020af:	29 da                	sub    %ebx,%edx
  8020b1:	19 ce                	sbb    %ecx,%esi
  8020b3:	89 f9                	mov    %edi,%ecx
  8020b5:	89 f0                	mov    %esi,%eax
  8020b7:	d3 e0                	shl    %cl,%eax
  8020b9:	89 e9                	mov    %ebp,%ecx
  8020bb:	d3 ea                	shr    %cl,%edx
  8020bd:	89 e9                	mov    %ebp,%ecx
  8020bf:	d3 ee                	shr    %cl,%esi
  8020c1:	09 d0                	or     %edx,%eax
  8020c3:	89 f2                	mov    %esi,%edx
  8020c5:	83 c4 1c             	add    $0x1c,%esp
  8020c8:	5b                   	pop    %ebx
  8020c9:	5e                   	pop    %esi
  8020ca:	5f                   	pop    %edi
  8020cb:	5d                   	pop    %ebp
  8020cc:	c3                   	ret    
  8020cd:	8d 76 00             	lea    0x0(%esi),%esi
  8020d0:	29 f9                	sub    %edi,%ecx
  8020d2:	19 d6                	sbb    %edx,%esi
  8020d4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8020d8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8020dc:	e9 18 ff ff ff       	jmp    801ff9 <__umoddi3+0x69>
