
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
  800047:	e8 4f 10 00 00       	call   80109b <ipc_recv>
  80004c:	89 c3                	mov    %eax,%ebx
	cprintf("CPU %d: %d ", thisenv->env_cpunum, p);
  80004e:	a1 08 40 80 00       	mov    0x804008,%eax
  800053:	8b 40 5c             	mov    0x5c(%eax),%eax
  800056:	83 c4 0c             	add    $0xc,%esp
  800059:	53                   	push   %ebx
  80005a:	50                   	push   %eax
  80005b:	68 20 26 80 00       	push   $0x802620
  800060:	e8 cc 01 00 00       	call   800231 <cprintf>

	// fork a right neighbor to continue the chain
	if ((id = fork()) < 0)
  800065:	e8 7a 0e 00 00       	call   800ee4 <fork>
  80006a:	89 c7                	mov    %eax,%edi
  80006c:	83 c4 10             	add    $0x10,%esp
  80006f:	85 c0                	test   %eax,%eax
  800071:	79 12                	jns    800085 <primeproc+0x52>
		panic("fork: %e", id);
  800073:	50                   	push   %eax
  800074:	68 2c 26 80 00       	push   $0x80262c
  800079:	6a 1a                	push   $0x1a
  80007b:	68 35 26 80 00       	push   $0x802635
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
  800094:	e8 02 10 00 00       	call   80109b <ipc_recv>
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
  8000ab:	e8 52 10 00 00       	call   801102 <ipc_send>
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
  8000ba:	e8 25 0e 00 00       	call   800ee4 <fork>
  8000bf:	89 c6                	mov    %eax,%esi
  8000c1:	85 c0                	test   %eax,%eax
  8000c3:	79 12                	jns    8000d7 <umain+0x22>
		panic("fork: %e", id);
  8000c5:	50                   	push   %eax
  8000c6:	68 2c 26 80 00       	push   $0x80262c
  8000cb:	6a 2d                	push   $0x2d
  8000cd:	68 35 26 80 00       	push   $0x802635
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
  8000eb:	e8 12 10 00 00       	call   801102 <ipc_send>
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
  800144:	e8 11 12 00 00       	call   80135a <close_all>
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
  800176:	68 50 26 80 00       	push   $0x802650
  80017b:	e8 b1 00 00 00       	call   800231 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800180:	83 c4 18             	add    $0x18,%esp
  800183:	53                   	push   %ebx
  800184:	ff 75 10             	pushl  0x10(%ebp)
  800187:	e8 54 00 00 00       	call   8001e0 <vcprintf>
	cprintf("\n");
  80018c:	c7 04 24 90 2b 80 00 	movl   $0x802b90,(%esp)
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
  800294:	e8 e7 20 00 00       	call   802380 <__udivdi3>
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
  8002d7:	e8 d4 21 00 00       	call   8024b0 <__umoddi3>
  8002dc:	83 c4 14             	add    $0x14,%esp
  8002df:	0f be 80 73 26 80 00 	movsbl 0x802673(%eax),%eax
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
  8003db:	ff 24 85 c0 27 80 00 	jmp    *0x8027c0(,%eax,4)
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
  80049f:	8b 14 85 20 29 80 00 	mov    0x802920(,%eax,4),%edx
  8004a6:	85 d2                	test   %edx,%edx
  8004a8:	75 18                	jne    8004c2 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8004aa:	50                   	push   %eax
  8004ab:	68 8b 26 80 00       	push   $0x80268b
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
  8004c3:	68 25 2b 80 00       	push   $0x802b25
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
  8004e7:	b8 84 26 80 00       	mov    $0x802684,%eax
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
  800b62:	68 7f 29 80 00       	push   $0x80297f
  800b67:	6a 23                	push   $0x23
  800b69:	68 9c 29 80 00       	push   $0x80299c
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
  800be3:	68 7f 29 80 00       	push   $0x80297f
  800be8:	6a 23                	push   $0x23
  800bea:	68 9c 29 80 00       	push   $0x80299c
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
  800c25:	68 7f 29 80 00       	push   $0x80297f
  800c2a:	6a 23                	push   $0x23
  800c2c:	68 9c 29 80 00       	push   $0x80299c
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
  800c67:	68 7f 29 80 00       	push   $0x80297f
  800c6c:	6a 23                	push   $0x23
  800c6e:	68 9c 29 80 00       	push   $0x80299c
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
  800ca9:	68 7f 29 80 00       	push   $0x80297f
  800cae:	6a 23                	push   $0x23
  800cb0:	68 9c 29 80 00       	push   $0x80299c
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
  800ceb:	68 7f 29 80 00       	push   $0x80297f
  800cf0:	6a 23                	push   $0x23
  800cf2:	68 9c 29 80 00       	push   $0x80299c
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
  800d2d:	68 7f 29 80 00       	push   $0x80297f
  800d32:	6a 23                	push   $0x23
  800d34:	68 9c 29 80 00       	push   $0x80299c
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
  800d91:	68 7f 29 80 00       	push   $0x80297f
  800d96:	6a 23                	push   $0x23
  800d98:	68 9c 29 80 00       	push   $0x80299c
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

00800dc9 <sys_e1000_try_send>:

int
sys_e1000_try_send(void *data, uint32_t len)
{
  800dc9:	55                   	push   %ebp
  800dca:	89 e5                	mov    %esp,%ebp
  800dcc:	57                   	push   %edi
  800dcd:	56                   	push   %esi
  800dce:	53                   	push   %ebx
  800dcf:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dd2:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dd7:	b8 0f 00 00 00       	mov    $0xf,%eax
  800ddc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ddf:	8b 55 08             	mov    0x8(%ebp),%edx
  800de2:	89 df                	mov    %ebx,%edi
  800de4:	89 de                	mov    %ebx,%esi
  800de6:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800de8:	85 c0                	test   %eax,%eax
  800dea:	7e 17                	jle    800e03 <sys_e1000_try_send+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dec:	83 ec 0c             	sub    $0xc,%esp
  800def:	50                   	push   %eax
  800df0:	6a 0f                	push   $0xf
  800df2:	68 7f 29 80 00       	push   $0x80297f
  800df7:	6a 23                	push   $0x23
  800df9:	68 9c 29 80 00       	push   $0x80299c
  800dfe:	e8 55 f3 ff ff       	call   800158 <_panic>

int
sys_e1000_try_send(void *data, uint32_t len)
{
	return syscall(SYS_e1000_try_send, 1, (uint32_t)data, len, 0, 0, 0);
}
  800e03:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e06:	5b                   	pop    %ebx
  800e07:	5e                   	pop    %esi
  800e08:	5f                   	pop    %edi
  800e09:	5d                   	pop    %ebp
  800e0a:	c3                   	ret    

00800e0b <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800e0b:	55                   	push   %ebp
  800e0c:	89 e5                	mov    %esp,%ebp
  800e0e:	56                   	push   %esi
  800e0f:	53                   	push   %ebx
  800e10:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800e13:	8b 18                	mov    (%eax),%ebx
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.

	if ((err & FEC_WR) != FEC_WR && ((uvpt[PGNUM(addr)] & PTE_COW) != PTE_COW)) {
  800e15:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800e19:	75 25                	jne    800e40 <pgfault+0x35>
  800e1b:	89 d8                	mov    %ebx,%eax
  800e1d:	c1 e8 0c             	shr    $0xc,%eax
  800e20:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800e27:	f6 c4 08             	test   $0x8,%ah
  800e2a:	75 14                	jne    800e40 <pgfault+0x35>
		panic("pgfault: not due to a write or a COW page");
  800e2c:	83 ec 04             	sub    $0x4,%esp
  800e2f:	68 ac 29 80 00       	push   $0x8029ac
  800e34:	6a 1e                	push   $0x1e
  800e36:	68 40 2a 80 00       	push   $0x802a40
  800e3b:	e8 18 f3 ff ff       	call   800158 <_panic>

	// LAB 4: Your code here.

	// panic("pgfault not implemented");

	addr = ROUNDDOWN(addr, PGSIZE);
  800e40:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	envid_t envid = sys_getenvid();
  800e46:	e8 30 fd ff ff       	call   800b7b <sys_getenvid>
  800e4b:	89 c6                	mov    %eax,%esi

	// envid = 0;

	// Allocate a new page, map it at a temporary location (PFTEMP)
	r = sys_page_alloc(envid, (void *)PFTEMP, PTE_U | PTE_P | PTE_W);
  800e4d:	83 ec 04             	sub    $0x4,%esp
  800e50:	6a 07                	push   $0x7
  800e52:	68 00 f0 7f 00       	push   $0x7ff000
  800e57:	50                   	push   %eax
  800e58:	e8 5c fd ff ff       	call   800bb9 <sys_page_alloc>
	if (r < 0)
  800e5d:	83 c4 10             	add    $0x10,%esp
  800e60:	85 c0                	test   %eax,%eax
  800e62:	79 12                	jns    800e76 <pgfault+0x6b>
		panic("pgfault: sys_page_alloc failed: %e\n", r);
  800e64:	50                   	push   %eax
  800e65:	68 d8 29 80 00       	push   $0x8029d8
  800e6a:	6a 33                	push   $0x33
  800e6c:	68 40 2a 80 00       	push   $0x802a40
  800e71:	e8 e2 f2 ff ff       	call   800158 <_panic>
	
	// copy the data from the old page to the new page
	memcpy((void *) PFTEMP, (const void *) addr, PGSIZE);
  800e76:	83 ec 04             	sub    $0x4,%esp
  800e79:	68 00 10 00 00       	push   $0x1000
  800e7e:	53                   	push   %ebx
  800e7f:	68 00 f0 7f 00       	push   $0x7ff000
  800e84:	e8 27 fb ff ff       	call   8009b0 <memcpy>

	// move the new page to the old page's address
	r = sys_page_map(envid, (void *) PFTEMP, envid, addr, PTE_U | PTE_P | PTE_W);
  800e89:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800e90:	53                   	push   %ebx
  800e91:	56                   	push   %esi
  800e92:	68 00 f0 7f 00       	push   $0x7ff000
  800e97:	56                   	push   %esi
  800e98:	e8 5f fd ff ff       	call   800bfc <sys_page_map>
	if (r < 0)
  800e9d:	83 c4 20             	add    $0x20,%esp
  800ea0:	85 c0                	test   %eax,%eax
  800ea2:	79 12                	jns    800eb6 <pgfault+0xab>
		panic("pgfault: sys_page_map failed: %e\n", r);
  800ea4:	50                   	push   %eax
  800ea5:	68 fc 29 80 00       	push   $0x8029fc
  800eaa:	6a 3b                	push   $0x3b
  800eac:	68 40 2a 80 00       	push   $0x802a40
  800eb1:	e8 a2 f2 ff ff       	call   800158 <_panic>

	// unmap temporary region
	r = sys_page_unmap(envid, (void *) PFTEMP);
  800eb6:	83 ec 08             	sub    $0x8,%esp
  800eb9:	68 00 f0 7f 00       	push   $0x7ff000
  800ebe:	56                   	push   %esi
  800ebf:	e8 7a fd ff ff       	call   800c3e <sys_page_unmap>
	if (r < 0)
  800ec4:	83 c4 10             	add    $0x10,%esp
  800ec7:	85 c0                	test   %eax,%eax
  800ec9:	79 12                	jns    800edd <pgfault+0xd2>
        panic("pgfault: page unmap failed: %e\n", r);
  800ecb:	50                   	push   %eax
  800ecc:	68 20 2a 80 00       	push   $0x802a20
  800ed1:	6a 40                	push   $0x40
  800ed3:	68 40 2a 80 00       	push   $0x802a40
  800ed8:	e8 7b f2 ff ff       	call   800158 <_panic>
}
  800edd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ee0:	5b                   	pop    %ebx
  800ee1:	5e                   	pop    %esi
  800ee2:	5d                   	pop    %ebp
  800ee3:	c3                   	ret    

00800ee4 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800ee4:	55                   	push   %ebp
  800ee5:	89 e5                	mov    %esp,%ebp
  800ee7:	57                   	push   %edi
  800ee8:	56                   	push   %esi
  800ee9:	53                   	push   %ebx
  800eea:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	// cprintf("[fork]\n");
	int r;

	set_pgfault_handler(pgfault);
  800eed:	68 0b 0e 80 00       	push   $0x800e0b
  800ef2:	e8 dc 13 00 00       	call   8022d3 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800ef7:	b8 07 00 00 00       	mov    $0x7,%eax
  800efc:	cd 30                	int    $0x30

	envid_t envid = sys_exofork();
	if (envid < 0)
  800efe:	83 c4 10             	add    $0x10,%esp
  800f01:	85 c0                	test   %eax,%eax
  800f03:	0f 88 64 01 00 00    	js     80106d <fork+0x189>
  800f09:	bb 00 00 80 00       	mov    $0x800000,%ebx
  800f0e:	be 00 08 00 00       	mov    $0x800,%esi
		return envid;

	// fix "thisenv" in the child process
	if (envid == 0) {
  800f13:	85 c0                	test   %eax,%eax
  800f15:	75 21                	jne    800f38 <fork+0x54>
		thisenv = &envs[ENVX(sys_getenvid())];
  800f17:	e8 5f fc ff ff       	call   800b7b <sys_getenvid>
  800f1c:	25 ff 03 00 00       	and    $0x3ff,%eax
  800f21:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800f24:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800f29:	a3 08 40 80 00       	mov    %eax,0x804008
        return 0;
  800f2e:	ba 00 00 00 00       	mov    $0x0,%edx
  800f33:	e9 3f 01 00 00       	jmp    801077 <fork+0x193>
  800f38:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800f3b:	89 c7                	mov    %eax,%edi
	for (uint32_t pn = PGNUM(UTEXT); pn < PGNUM(USTACKTOP); pn++) {

		addr = pn * PGSIZE;

		// if level-2 page exists
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P) {
  800f3d:	89 d8                	mov    %ebx,%eax
  800f3f:	c1 e8 16             	shr    $0x16,%eax
  800f42:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f49:	a8 01                	test   $0x1,%al
  800f4b:	0f 84 bd 00 00 00    	je     80100e <fork+0x12a>
			
			// if real PTE exists
			if ((uvpt[PGNUM(addr)] & PTE_P) == PTE_P) {
  800f51:	89 d8                	mov    %ebx,%eax
  800f53:	c1 e8 0c             	shr    $0xc,%eax
  800f56:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f5d:	f6 c2 01             	test   $0x1,%dl
  800f60:	0f 84 a8 00 00 00    	je     80100e <fork+0x12a>

				// For each writable or copy-on-write page
				// if ((uvpt[PGNUM(addr)] & (PTE_W | PTE_COW)) != 0) {
				if ((uvpt[PGNUM(addr)] & PTE_U) != 0) {
  800f66:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f6d:	a8 04                	test   $0x4,%al
  800f6f:	0f 84 99 00 00 00    	je     80100e <fork+0x12a>
	// r = envid2env(envid, &env, 1);
	// if (r < 0)
	// 	return r;	// E_BAD_ENV
	// envid_t parent_envid = env->env_parent_id;

	if (uvpt[pn] & PTE_SHARE) {
  800f75:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800f7c:	f6 c4 04             	test   $0x4,%ah
  800f7f:	74 17                	je     800f98 <fork+0xb4>
		sys_page_map(0, (void *)va, envid, (void *)va, PTE_SYSCALL);
  800f81:	83 ec 0c             	sub    $0xc,%esp
  800f84:	68 07 0e 00 00       	push   $0xe07
  800f89:	53                   	push   %ebx
  800f8a:	57                   	push   %edi
  800f8b:	53                   	push   %ebx
  800f8c:	6a 00                	push   $0x0
  800f8e:	e8 69 fc ff ff       	call   800bfc <sys_page_map>
  800f93:	83 c4 20             	add    $0x20,%esp
  800f96:	eb 76                	jmp    80100e <fork+0x12a>
	}
	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {
  800f98:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800f9f:	a8 02                	test   $0x2,%al
  800fa1:	75 0c                	jne    800faf <fork+0xcb>
  800fa3:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800faa:	f6 c4 08             	test   $0x8,%ah
  800fad:	74 3f                	je     800fee <fork+0x10a>

		// map the page copy-on-write into the address space of the child
        r = sys_page_map(0, (void *)va, envid, (void *)va, PTE_P|PTE_U|PTE_COW);
  800faf:	83 ec 0c             	sub    $0xc,%esp
  800fb2:	68 05 08 00 00       	push   $0x805
  800fb7:	53                   	push   %ebx
  800fb8:	57                   	push   %edi
  800fb9:	53                   	push   %ebx
  800fba:	6a 00                	push   $0x0
  800fbc:	e8 3b fc ff ff       	call   800bfc <sys_page_map>
		if (r < 0)
  800fc1:	83 c4 20             	add    $0x20,%esp
  800fc4:	85 c0                	test   %eax,%eax
  800fc6:	0f 88 a5 00 00 00    	js     801071 <fork+0x18d>
            return r;

		// remap the page copy-on-write in its own(parent) address space
        r = sys_page_map(0, (void *)va, 0, (void *)va, PTE_P|PTE_U|PTE_COW);
  800fcc:	83 ec 0c             	sub    $0xc,%esp
  800fcf:	68 05 08 00 00       	push   $0x805
  800fd4:	53                   	push   %ebx
  800fd5:	6a 00                	push   $0x0
  800fd7:	53                   	push   %ebx
  800fd8:	6a 00                	push   $0x0
  800fda:	e8 1d fc ff ff       	call   800bfc <sys_page_map>
  800fdf:	83 c4 20             	add    $0x20,%esp
  800fe2:	85 c0                	test   %eax,%eax
  800fe4:	b9 00 00 00 00       	mov    $0x0,%ecx
  800fe9:	0f 4f c1             	cmovg  %ecx,%eax
  800fec:	eb 1c                	jmp    80100a <fork+0x126>
		if (r < 0)
            return r;
    }
    else {
        r = sys_page_map(0, (void *)va, envid, (void *)va, PTE_P|PTE_U);
  800fee:	83 ec 0c             	sub    $0xc,%esp
  800ff1:	6a 05                	push   $0x5
  800ff3:	53                   	push   %ebx
  800ff4:	57                   	push   %edi
  800ff5:	53                   	push   %ebx
  800ff6:	6a 00                	push   $0x0
  800ff8:	e8 ff fb ff ff       	call   800bfc <sys_page_map>
  800ffd:	83 c4 20             	add    $0x20,%esp
  801000:	85 c0                	test   %eax,%eax
  801002:	b9 00 00 00 00       	mov    $0x0,%ecx
  801007:	0f 4f c1             	cmovg  %ecx,%eax

				// For each writable or copy-on-write page
				// if ((uvpt[PGNUM(addr)] & (PTE_W | PTE_COW)) != 0) {
				if ((uvpt[PGNUM(addr)] & PTE_U) != 0) {
					r = duppage(envid, pn);
					if (r < 0)
  80100a:	85 c0                	test   %eax,%eax
  80100c:	78 67                	js     801075 <fork+0x191>
        return 0;
	}

	// For each writable or copy-on-write page in its address space below UTOP, the parent calls duppage
	uint32_t addr;
	for (uint32_t pn = PGNUM(UTEXT); pn < PGNUM(USTACKTOP); pn++) {
  80100e:	83 c6 01             	add    $0x1,%esi
  801011:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801017:	81 fe fe eb 0e 00    	cmp    $0xeebfe,%esi
  80101d:	0f 85 1a ff ff ff    	jne    800f3d <fork+0x59>
  801023:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
		}
	}

	// allocate a fresh page in the child for the exception stack
	r = sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U | PTE_P | PTE_W);
  801026:	83 ec 04             	sub    $0x4,%esp
  801029:	6a 07                	push   $0x7
  80102b:	68 00 f0 bf ee       	push   $0xeebff000
  801030:	57                   	push   %edi
  801031:	e8 83 fb ff ff       	call   800bb9 <sys_page_alloc>
	if (r < 0)
  801036:	83 c4 10             	add    $0x10,%esp
		return r;
  801039:	89 c2                	mov    %eax,%edx
		}
	}

	// allocate a fresh page in the child for the exception stack
	r = sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U | PTE_P | PTE_W);
	if (r < 0)
  80103b:	85 c0                	test   %eax,%eax
  80103d:	78 38                	js     801077 <fork+0x193>
		return r;

	// The parent sets the user page fault entrypoint for the child to look like its own
	extern void _pgfault_upcall(void);
	r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  80103f:	83 ec 08             	sub    $0x8,%esp
  801042:	68 1a 23 80 00       	push   $0x80231a
  801047:	57                   	push   %edi
  801048:	e8 b7 fc ff ff       	call   800d04 <sys_env_set_pgfault_upcall>
	if (r < 0)
  80104d:	83 c4 10             	add    $0x10,%esp
		return r;
  801050:	89 c2                	mov    %eax,%edx
		return r;

	// The parent sets the user page fault entrypoint for the child to look like its own
	extern void _pgfault_upcall(void);
	r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
	if (r < 0)
  801052:	85 c0                	test   %eax,%eax
  801054:	78 21                	js     801077 <fork+0x193>
		return r;

	// The child is now ready to run, so the parent marks it runnable
	r = sys_env_set_status(envid, ENV_RUNNABLE);
  801056:	83 ec 08             	sub    $0x8,%esp
  801059:	6a 02                	push   $0x2
  80105b:	57                   	push   %edi
  80105c:	e8 1f fc ff ff       	call   800c80 <sys_env_set_status>
	if (r < 0)
  801061:	83 c4 10             	add    $0x10,%esp
		return r;

	return envid;
  801064:	85 c0                	test   %eax,%eax
  801066:	0f 48 f8             	cmovs  %eax,%edi
  801069:	89 fa                	mov    %edi,%edx
  80106b:	eb 0a                	jmp    801077 <fork+0x193>

	set_pgfault_handler(pgfault);

	envid_t envid = sys_exofork();
	if (envid < 0)
		return envid;
  80106d:	89 c2                	mov    %eax,%edx
  80106f:	eb 06                	jmp    801077 <fork+0x193>
		sys_page_map(0, (void *)va, envid, (void *)va, PTE_SYSCALL);
	}
	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {

		// map the page copy-on-write into the address space of the child
        r = sys_page_map(0, (void *)va, envid, (void *)va, PTE_P|PTE_U|PTE_COW);
  801071:	89 c2                	mov    %eax,%edx
  801073:	eb 02                	jmp    801077 <fork+0x193>
  801075:	89 c2                	mov    %eax,%edx
	if (r < 0)
		return r;

	return envid;
	// panic("fork not implemented");
}
  801077:	89 d0                	mov    %edx,%eax
  801079:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80107c:	5b                   	pop    %ebx
  80107d:	5e                   	pop    %esi
  80107e:	5f                   	pop    %edi
  80107f:	5d                   	pop    %ebp
  801080:	c3                   	ret    

00801081 <sfork>:

// Challenge!
int
sfork(void)
{
  801081:	55                   	push   %ebp
  801082:	89 e5                	mov    %esp,%ebp
  801084:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801087:	68 4b 2a 80 00       	push   $0x802a4b
  80108c:	68 c9 00 00 00       	push   $0xc9
  801091:	68 40 2a 80 00       	push   $0x802a40
  801096:	e8 bd f0 ff ff       	call   800158 <_panic>

0080109b <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80109b:	55                   	push   %ebp
  80109c:	89 e5                	mov    %esp,%ebp
  80109e:	56                   	push   %esi
  80109f:	53                   	push   %ebx
  8010a0:	8b 75 08             	mov    0x8(%ebp),%esi
  8010a3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8010a6:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");

	// don't want to recv page
	if (pg == NULL)
  8010a9:	85 c0                	test   %eax,%eax
		pg = (void *)UTOP;
  8010ab:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  8010b0:	0f 44 c2             	cmove  %edx,%eax

	int err = sys_ipc_recv(pg);
  8010b3:	83 ec 0c             	sub    $0xc,%esp
  8010b6:	50                   	push   %eax
  8010b7:	e8 ad fc ff ff       	call   800d69 <sys_ipc_recv>

	if (from_env_store != NULL)
  8010bc:	83 c4 10             	add    $0x10,%esp
  8010bf:	85 f6                	test   %esi,%esi
  8010c1:	74 14                	je     8010d7 <ipc_recv+0x3c>
		*from_env_store = err < 0? 0 : thisenv->env_ipc_from;
  8010c3:	ba 00 00 00 00       	mov    $0x0,%edx
  8010c8:	85 c0                	test   %eax,%eax
  8010ca:	78 09                	js     8010d5 <ipc_recv+0x3a>
  8010cc:	8b 15 08 40 80 00    	mov    0x804008,%edx
  8010d2:	8b 52 74             	mov    0x74(%edx),%edx
  8010d5:	89 16                	mov    %edx,(%esi)
	
	if (perm_store != NULL)
  8010d7:	85 db                	test   %ebx,%ebx
  8010d9:	74 14                	je     8010ef <ipc_recv+0x54>
		*perm_store = err < 0? 0 : thisenv->env_ipc_perm;
  8010db:	ba 00 00 00 00       	mov    $0x0,%edx
  8010e0:	85 c0                	test   %eax,%eax
  8010e2:	78 09                	js     8010ed <ipc_recv+0x52>
  8010e4:	8b 15 08 40 80 00    	mov    0x804008,%edx
  8010ea:	8b 52 78             	mov    0x78(%edx),%edx
  8010ed:	89 13                	mov    %edx,(%ebx)

	if (err < 0)
  8010ef:	85 c0                	test   %eax,%eax
  8010f1:	78 08                	js     8010fb <ipc_recv+0x60>
		return err;
	return thisenv->env_ipc_value;
  8010f3:	a1 08 40 80 00       	mov    0x804008,%eax
  8010f8:	8b 40 70             	mov    0x70(%eax),%eax
}
  8010fb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8010fe:	5b                   	pop    %ebx
  8010ff:	5e                   	pop    %esi
  801100:	5d                   	pop    %ebp
  801101:	c3                   	ret    

00801102 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801102:	55                   	push   %ebp
  801103:	89 e5                	mov    %esp,%ebp
  801105:	57                   	push   %edi
  801106:	56                   	push   %esi
  801107:	53                   	push   %ebx
  801108:	83 ec 0c             	sub    $0xc,%esp
  80110b:	8b 7d 08             	mov    0x8(%ebp),%edi
  80110e:	8b 75 0c             	mov    0xc(%ebp),%esi
  801111:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");

	// don't want to send page
	if (pg == NULL)
  801114:	85 db                	test   %ebx,%ebx
		pg = (void *)UTOP;
  801116:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  80111b:	0f 44 d8             	cmove  %eax,%ebx
	
	int err = 0;
	
	do {

		err = sys_ipc_try_send(to_env, val, pg, perm);
  80111e:	ff 75 14             	pushl  0x14(%ebp)
  801121:	53                   	push   %ebx
  801122:	56                   	push   %esi
  801123:	57                   	push   %edi
  801124:	e8 1d fc ff ff       	call   800d46 <sys_ipc_try_send>

		if (err < 0) {
  801129:	83 c4 10             	add    $0x10,%esp
  80112c:	85 c0                	test   %eax,%eax
  80112e:	79 1e                	jns    80114e <ipc_send+0x4c>
			if (err == -E_IPC_NOT_RECV)
  801130:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801133:	75 07                	jne    80113c <ipc_send+0x3a>
				sys_yield();
  801135:	e8 60 fa ff ff       	call   800b9a <sys_yield>
  80113a:	eb e2                	jmp    80111e <ipc_send+0x1c>
			else 
				panic("ipc_send: %e", err);
  80113c:	50                   	push   %eax
  80113d:	68 61 2a 80 00       	push   $0x802a61
  801142:	6a 49                	push   $0x49
  801144:	68 6e 2a 80 00       	push   $0x802a6e
  801149:	e8 0a f0 ff ff       	call   800158 <_panic>
		}

	} while (err < 0);

}
  80114e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801151:	5b                   	pop    %ebx
  801152:	5e                   	pop    %esi
  801153:	5f                   	pop    %edi
  801154:	5d                   	pop    %ebp
  801155:	c3                   	ret    

00801156 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801156:	55                   	push   %ebp
  801157:	89 e5                	mov    %esp,%ebp
  801159:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80115c:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801161:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801164:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80116a:	8b 52 50             	mov    0x50(%edx),%edx
  80116d:	39 ca                	cmp    %ecx,%edx
  80116f:	75 0d                	jne    80117e <ipc_find_env+0x28>
			return envs[i].env_id;
  801171:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801174:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801179:	8b 40 48             	mov    0x48(%eax),%eax
  80117c:	eb 0f                	jmp    80118d <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80117e:	83 c0 01             	add    $0x1,%eax
  801181:	3d 00 04 00 00       	cmp    $0x400,%eax
  801186:	75 d9                	jne    801161 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801188:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80118d:	5d                   	pop    %ebp
  80118e:	c3                   	ret    

0080118f <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80118f:	55                   	push   %ebp
  801190:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801192:	8b 45 08             	mov    0x8(%ebp),%eax
  801195:	05 00 00 00 30       	add    $0x30000000,%eax
  80119a:	c1 e8 0c             	shr    $0xc,%eax
}
  80119d:	5d                   	pop    %ebp
  80119e:	c3                   	ret    

0080119f <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80119f:	55                   	push   %ebp
  8011a0:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8011a2:	8b 45 08             	mov    0x8(%ebp),%eax
  8011a5:	05 00 00 00 30       	add    $0x30000000,%eax
  8011aa:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8011af:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8011b4:	5d                   	pop    %ebp
  8011b5:	c3                   	ret    

008011b6 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8011b6:	55                   	push   %ebp
  8011b7:	89 e5                	mov    %esp,%ebp
  8011b9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011bc:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8011c1:	89 c2                	mov    %eax,%edx
  8011c3:	c1 ea 16             	shr    $0x16,%edx
  8011c6:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8011cd:	f6 c2 01             	test   $0x1,%dl
  8011d0:	74 11                	je     8011e3 <fd_alloc+0x2d>
  8011d2:	89 c2                	mov    %eax,%edx
  8011d4:	c1 ea 0c             	shr    $0xc,%edx
  8011d7:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8011de:	f6 c2 01             	test   $0x1,%dl
  8011e1:	75 09                	jne    8011ec <fd_alloc+0x36>
			*fd_store = fd;
  8011e3:	89 01                	mov    %eax,(%ecx)
			return 0;
  8011e5:	b8 00 00 00 00       	mov    $0x0,%eax
  8011ea:	eb 17                	jmp    801203 <fd_alloc+0x4d>
  8011ec:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8011f1:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8011f6:	75 c9                	jne    8011c1 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8011f8:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8011fe:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801203:	5d                   	pop    %ebp
  801204:	c3                   	ret    

00801205 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801205:	55                   	push   %ebp
  801206:	89 e5                	mov    %esp,%ebp
  801208:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80120b:	83 f8 1f             	cmp    $0x1f,%eax
  80120e:	77 36                	ja     801246 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801210:	c1 e0 0c             	shl    $0xc,%eax
  801213:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801218:	89 c2                	mov    %eax,%edx
  80121a:	c1 ea 16             	shr    $0x16,%edx
  80121d:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801224:	f6 c2 01             	test   $0x1,%dl
  801227:	74 24                	je     80124d <fd_lookup+0x48>
  801229:	89 c2                	mov    %eax,%edx
  80122b:	c1 ea 0c             	shr    $0xc,%edx
  80122e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801235:	f6 c2 01             	test   $0x1,%dl
  801238:	74 1a                	je     801254 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80123a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80123d:	89 02                	mov    %eax,(%edx)
	return 0;
  80123f:	b8 00 00 00 00       	mov    $0x0,%eax
  801244:	eb 13                	jmp    801259 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801246:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80124b:	eb 0c                	jmp    801259 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80124d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801252:	eb 05                	jmp    801259 <fd_lookup+0x54>
  801254:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801259:	5d                   	pop    %ebp
  80125a:	c3                   	ret    

0080125b <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80125b:	55                   	push   %ebp
  80125c:	89 e5                	mov    %esp,%ebp
  80125e:	83 ec 08             	sub    $0x8,%esp
  801261:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801264:	ba f8 2a 80 00       	mov    $0x802af8,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801269:	eb 13                	jmp    80127e <dev_lookup+0x23>
  80126b:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80126e:	39 08                	cmp    %ecx,(%eax)
  801270:	75 0c                	jne    80127e <dev_lookup+0x23>
			*dev = devtab[i];
  801272:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801275:	89 01                	mov    %eax,(%ecx)
			return 0;
  801277:	b8 00 00 00 00       	mov    $0x0,%eax
  80127c:	eb 2e                	jmp    8012ac <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80127e:	8b 02                	mov    (%edx),%eax
  801280:	85 c0                	test   %eax,%eax
  801282:	75 e7                	jne    80126b <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801284:	a1 08 40 80 00       	mov    0x804008,%eax
  801289:	8b 40 48             	mov    0x48(%eax),%eax
  80128c:	83 ec 04             	sub    $0x4,%esp
  80128f:	51                   	push   %ecx
  801290:	50                   	push   %eax
  801291:	68 78 2a 80 00       	push   $0x802a78
  801296:	e8 96 ef ff ff       	call   800231 <cprintf>
	*dev = 0;
  80129b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80129e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8012a4:	83 c4 10             	add    $0x10,%esp
  8012a7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8012ac:	c9                   	leave  
  8012ad:	c3                   	ret    

008012ae <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8012ae:	55                   	push   %ebp
  8012af:	89 e5                	mov    %esp,%ebp
  8012b1:	56                   	push   %esi
  8012b2:	53                   	push   %ebx
  8012b3:	83 ec 10             	sub    $0x10,%esp
  8012b6:	8b 75 08             	mov    0x8(%ebp),%esi
  8012b9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8012bc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012bf:	50                   	push   %eax
  8012c0:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8012c6:	c1 e8 0c             	shr    $0xc,%eax
  8012c9:	50                   	push   %eax
  8012ca:	e8 36 ff ff ff       	call   801205 <fd_lookup>
  8012cf:	83 c4 08             	add    $0x8,%esp
  8012d2:	85 c0                	test   %eax,%eax
  8012d4:	78 05                	js     8012db <fd_close+0x2d>
	    || fd != fd2)
  8012d6:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8012d9:	74 0c                	je     8012e7 <fd_close+0x39>
		return (must_exist ? r : 0);
  8012db:	84 db                	test   %bl,%bl
  8012dd:	ba 00 00 00 00       	mov    $0x0,%edx
  8012e2:	0f 44 c2             	cmove  %edx,%eax
  8012e5:	eb 41                	jmp    801328 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8012e7:	83 ec 08             	sub    $0x8,%esp
  8012ea:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012ed:	50                   	push   %eax
  8012ee:	ff 36                	pushl  (%esi)
  8012f0:	e8 66 ff ff ff       	call   80125b <dev_lookup>
  8012f5:	89 c3                	mov    %eax,%ebx
  8012f7:	83 c4 10             	add    $0x10,%esp
  8012fa:	85 c0                	test   %eax,%eax
  8012fc:	78 1a                	js     801318 <fd_close+0x6a>
		if (dev->dev_close)
  8012fe:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801301:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801304:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801309:	85 c0                	test   %eax,%eax
  80130b:	74 0b                	je     801318 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80130d:	83 ec 0c             	sub    $0xc,%esp
  801310:	56                   	push   %esi
  801311:	ff d0                	call   *%eax
  801313:	89 c3                	mov    %eax,%ebx
  801315:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801318:	83 ec 08             	sub    $0x8,%esp
  80131b:	56                   	push   %esi
  80131c:	6a 00                	push   $0x0
  80131e:	e8 1b f9 ff ff       	call   800c3e <sys_page_unmap>
	return r;
  801323:	83 c4 10             	add    $0x10,%esp
  801326:	89 d8                	mov    %ebx,%eax
}
  801328:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80132b:	5b                   	pop    %ebx
  80132c:	5e                   	pop    %esi
  80132d:	5d                   	pop    %ebp
  80132e:	c3                   	ret    

0080132f <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80132f:	55                   	push   %ebp
  801330:	89 e5                	mov    %esp,%ebp
  801332:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801335:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801338:	50                   	push   %eax
  801339:	ff 75 08             	pushl  0x8(%ebp)
  80133c:	e8 c4 fe ff ff       	call   801205 <fd_lookup>
  801341:	83 c4 08             	add    $0x8,%esp
  801344:	85 c0                	test   %eax,%eax
  801346:	78 10                	js     801358 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801348:	83 ec 08             	sub    $0x8,%esp
  80134b:	6a 01                	push   $0x1
  80134d:	ff 75 f4             	pushl  -0xc(%ebp)
  801350:	e8 59 ff ff ff       	call   8012ae <fd_close>
  801355:	83 c4 10             	add    $0x10,%esp
}
  801358:	c9                   	leave  
  801359:	c3                   	ret    

0080135a <close_all>:

void
close_all(void)
{
  80135a:	55                   	push   %ebp
  80135b:	89 e5                	mov    %esp,%ebp
  80135d:	53                   	push   %ebx
  80135e:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801361:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801366:	83 ec 0c             	sub    $0xc,%esp
  801369:	53                   	push   %ebx
  80136a:	e8 c0 ff ff ff       	call   80132f <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80136f:	83 c3 01             	add    $0x1,%ebx
  801372:	83 c4 10             	add    $0x10,%esp
  801375:	83 fb 20             	cmp    $0x20,%ebx
  801378:	75 ec                	jne    801366 <close_all+0xc>
		close(i);
}
  80137a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80137d:	c9                   	leave  
  80137e:	c3                   	ret    

0080137f <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80137f:	55                   	push   %ebp
  801380:	89 e5                	mov    %esp,%ebp
  801382:	57                   	push   %edi
  801383:	56                   	push   %esi
  801384:	53                   	push   %ebx
  801385:	83 ec 2c             	sub    $0x2c,%esp
  801388:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80138b:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80138e:	50                   	push   %eax
  80138f:	ff 75 08             	pushl  0x8(%ebp)
  801392:	e8 6e fe ff ff       	call   801205 <fd_lookup>
  801397:	83 c4 08             	add    $0x8,%esp
  80139a:	85 c0                	test   %eax,%eax
  80139c:	0f 88 c1 00 00 00    	js     801463 <dup+0xe4>
		return r;
	close(newfdnum);
  8013a2:	83 ec 0c             	sub    $0xc,%esp
  8013a5:	56                   	push   %esi
  8013a6:	e8 84 ff ff ff       	call   80132f <close>

	newfd = INDEX2FD(newfdnum);
  8013ab:	89 f3                	mov    %esi,%ebx
  8013ad:	c1 e3 0c             	shl    $0xc,%ebx
  8013b0:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8013b6:	83 c4 04             	add    $0x4,%esp
  8013b9:	ff 75 e4             	pushl  -0x1c(%ebp)
  8013bc:	e8 de fd ff ff       	call   80119f <fd2data>
  8013c1:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8013c3:	89 1c 24             	mov    %ebx,(%esp)
  8013c6:	e8 d4 fd ff ff       	call   80119f <fd2data>
  8013cb:	83 c4 10             	add    $0x10,%esp
  8013ce:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8013d1:	89 f8                	mov    %edi,%eax
  8013d3:	c1 e8 16             	shr    $0x16,%eax
  8013d6:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8013dd:	a8 01                	test   $0x1,%al
  8013df:	74 37                	je     801418 <dup+0x99>
  8013e1:	89 f8                	mov    %edi,%eax
  8013e3:	c1 e8 0c             	shr    $0xc,%eax
  8013e6:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8013ed:	f6 c2 01             	test   $0x1,%dl
  8013f0:	74 26                	je     801418 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8013f2:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8013f9:	83 ec 0c             	sub    $0xc,%esp
  8013fc:	25 07 0e 00 00       	and    $0xe07,%eax
  801401:	50                   	push   %eax
  801402:	ff 75 d4             	pushl  -0x2c(%ebp)
  801405:	6a 00                	push   $0x0
  801407:	57                   	push   %edi
  801408:	6a 00                	push   $0x0
  80140a:	e8 ed f7 ff ff       	call   800bfc <sys_page_map>
  80140f:	89 c7                	mov    %eax,%edi
  801411:	83 c4 20             	add    $0x20,%esp
  801414:	85 c0                	test   %eax,%eax
  801416:	78 2e                	js     801446 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801418:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80141b:	89 d0                	mov    %edx,%eax
  80141d:	c1 e8 0c             	shr    $0xc,%eax
  801420:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801427:	83 ec 0c             	sub    $0xc,%esp
  80142a:	25 07 0e 00 00       	and    $0xe07,%eax
  80142f:	50                   	push   %eax
  801430:	53                   	push   %ebx
  801431:	6a 00                	push   $0x0
  801433:	52                   	push   %edx
  801434:	6a 00                	push   $0x0
  801436:	e8 c1 f7 ff ff       	call   800bfc <sys_page_map>
  80143b:	89 c7                	mov    %eax,%edi
  80143d:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801440:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801442:	85 ff                	test   %edi,%edi
  801444:	79 1d                	jns    801463 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801446:	83 ec 08             	sub    $0x8,%esp
  801449:	53                   	push   %ebx
  80144a:	6a 00                	push   $0x0
  80144c:	e8 ed f7 ff ff       	call   800c3e <sys_page_unmap>
	sys_page_unmap(0, nva);
  801451:	83 c4 08             	add    $0x8,%esp
  801454:	ff 75 d4             	pushl  -0x2c(%ebp)
  801457:	6a 00                	push   $0x0
  801459:	e8 e0 f7 ff ff       	call   800c3e <sys_page_unmap>
	return r;
  80145e:	83 c4 10             	add    $0x10,%esp
  801461:	89 f8                	mov    %edi,%eax
}
  801463:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801466:	5b                   	pop    %ebx
  801467:	5e                   	pop    %esi
  801468:	5f                   	pop    %edi
  801469:	5d                   	pop    %ebp
  80146a:	c3                   	ret    

0080146b <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80146b:	55                   	push   %ebp
  80146c:	89 e5                	mov    %esp,%ebp
  80146e:	53                   	push   %ebx
  80146f:	83 ec 14             	sub    $0x14,%esp
  801472:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801475:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801478:	50                   	push   %eax
  801479:	53                   	push   %ebx
  80147a:	e8 86 fd ff ff       	call   801205 <fd_lookup>
  80147f:	83 c4 08             	add    $0x8,%esp
  801482:	89 c2                	mov    %eax,%edx
  801484:	85 c0                	test   %eax,%eax
  801486:	78 6d                	js     8014f5 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801488:	83 ec 08             	sub    $0x8,%esp
  80148b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80148e:	50                   	push   %eax
  80148f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801492:	ff 30                	pushl  (%eax)
  801494:	e8 c2 fd ff ff       	call   80125b <dev_lookup>
  801499:	83 c4 10             	add    $0x10,%esp
  80149c:	85 c0                	test   %eax,%eax
  80149e:	78 4c                	js     8014ec <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8014a0:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8014a3:	8b 42 08             	mov    0x8(%edx),%eax
  8014a6:	83 e0 03             	and    $0x3,%eax
  8014a9:	83 f8 01             	cmp    $0x1,%eax
  8014ac:	75 21                	jne    8014cf <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8014ae:	a1 08 40 80 00       	mov    0x804008,%eax
  8014b3:	8b 40 48             	mov    0x48(%eax),%eax
  8014b6:	83 ec 04             	sub    $0x4,%esp
  8014b9:	53                   	push   %ebx
  8014ba:	50                   	push   %eax
  8014bb:	68 bc 2a 80 00       	push   $0x802abc
  8014c0:	e8 6c ed ff ff       	call   800231 <cprintf>
		return -E_INVAL;
  8014c5:	83 c4 10             	add    $0x10,%esp
  8014c8:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8014cd:	eb 26                	jmp    8014f5 <read+0x8a>
	}
	if (!dev->dev_read)
  8014cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014d2:	8b 40 08             	mov    0x8(%eax),%eax
  8014d5:	85 c0                	test   %eax,%eax
  8014d7:	74 17                	je     8014f0 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8014d9:	83 ec 04             	sub    $0x4,%esp
  8014dc:	ff 75 10             	pushl  0x10(%ebp)
  8014df:	ff 75 0c             	pushl  0xc(%ebp)
  8014e2:	52                   	push   %edx
  8014e3:	ff d0                	call   *%eax
  8014e5:	89 c2                	mov    %eax,%edx
  8014e7:	83 c4 10             	add    $0x10,%esp
  8014ea:	eb 09                	jmp    8014f5 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014ec:	89 c2                	mov    %eax,%edx
  8014ee:	eb 05                	jmp    8014f5 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8014f0:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8014f5:	89 d0                	mov    %edx,%eax
  8014f7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014fa:	c9                   	leave  
  8014fb:	c3                   	ret    

008014fc <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8014fc:	55                   	push   %ebp
  8014fd:	89 e5                	mov    %esp,%ebp
  8014ff:	57                   	push   %edi
  801500:	56                   	push   %esi
  801501:	53                   	push   %ebx
  801502:	83 ec 0c             	sub    $0xc,%esp
  801505:	8b 7d 08             	mov    0x8(%ebp),%edi
  801508:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80150b:	bb 00 00 00 00       	mov    $0x0,%ebx
  801510:	eb 21                	jmp    801533 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801512:	83 ec 04             	sub    $0x4,%esp
  801515:	89 f0                	mov    %esi,%eax
  801517:	29 d8                	sub    %ebx,%eax
  801519:	50                   	push   %eax
  80151a:	89 d8                	mov    %ebx,%eax
  80151c:	03 45 0c             	add    0xc(%ebp),%eax
  80151f:	50                   	push   %eax
  801520:	57                   	push   %edi
  801521:	e8 45 ff ff ff       	call   80146b <read>
		if (m < 0)
  801526:	83 c4 10             	add    $0x10,%esp
  801529:	85 c0                	test   %eax,%eax
  80152b:	78 10                	js     80153d <readn+0x41>
			return m;
		if (m == 0)
  80152d:	85 c0                	test   %eax,%eax
  80152f:	74 0a                	je     80153b <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801531:	01 c3                	add    %eax,%ebx
  801533:	39 f3                	cmp    %esi,%ebx
  801535:	72 db                	jb     801512 <readn+0x16>
  801537:	89 d8                	mov    %ebx,%eax
  801539:	eb 02                	jmp    80153d <readn+0x41>
  80153b:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80153d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801540:	5b                   	pop    %ebx
  801541:	5e                   	pop    %esi
  801542:	5f                   	pop    %edi
  801543:	5d                   	pop    %ebp
  801544:	c3                   	ret    

00801545 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801545:	55                   	push   %ebp
  801546:	89 e5                	mov    %esp,%ebp
  801548:	53                   	push   %ebx
  801549:	83 ec 14             	sub    $0x14,%esp
  80154c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80154f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801552:	50                   	push   %eax
  801553:	53                   	push   %ebx
  801554:	e8 ac fc ff ff       	call   801205 <fd_lookup>
  801559:	83 c4 08             	add    $0x8,%esp
  80155c:	89 c2                	mov    %eax,%edx
  80155e:	85 c0                	test   %eax,%eax
  801560:	78 68                	js     8015ca <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801562:	83 ec 08             	sub    $0x8,%esp
  801565:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801568:	50                   	push   %eax
  801569:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80156c:	ff 30                	pushl  (%eax)
  80156e:	e8 e8 fc ff ff       	call   80125b <dev_lookup>
  801573:	83 c4 10             	add    $0x10,%esp
  801576:	85 c0                	test   %eax,%eax
  801578:	78 47                	js     8015c1 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80157a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80157d:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801581:	75 21                	jne    8015a4 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801583:	a1 08 40 80 00       	mov    0x804008,%eax
  801588:	8b 40 48             	mov    0x48(%eax),%eax
  80158b:	83 ec 04             	sub    $0x4,%esp
  80158e:	53                   	push   %ebx
  80158f:	50                   	push   %eax
  801590:	68 d8 2a 80 00       	push   $0x802ad8
  801595:	e8 97 ec ff ff       	call   800231 <cprintf>
		return -E_INVAL;
  80159a:	83 c4 10             	add    $0x10,%esp
  80159d:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8015a2:	eb 26                	jmp    8015ca <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8015a4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015a7:	8b 52 0c             	mov    0xc(%edx),%edx
  8015aa:	85 d2                	test   %edx,%edx
  8015ac:	74 17                	je     8015c5 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8015ae:	83 ec 04             	sub    $0x4,%esp
  8015b1:	ff 75 10             	pushl  0x10(%ebp)
  8015b4:	ff 75 0c             	pushl  0xc(%ebp)
  8015b7:	50                   	push   %eax
  8015b8:	ff d2                	call   *%edx
  8015ba:	89 c2                	mov    %eax,%edx
  8015bc:	83 c4 10             	add    $0x10,%esp
  8015bf:	eb 09                	jmp    8015ca <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015c1:	89 c2                	mov    %eax,%edx
  8015c3:	eb 05                	jmp    8015ca <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8015c5:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8015ca:	89 d0                	mov    %edx,%eax
  8015cc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015cf:	c9                   	leave  
  8015d0:	c3                   	ret    

008015d1 <seek>:

int
seek(int fdnum, off_t offset)
{
  8015d1:	55                   	push   %ebp
  8015d2:	89 e5                	mov    %esp,%ebp
  8015d4:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8015d7:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8015da:	50                   	push   %eax
  8015db:	ff 75 08             	pushl  0x8(%ebp)
  8015de:	e8 22 fc ff ff       	call   801205 <fd_lookup>
  8015e3:	83 c4 08             	add    $0x8,%esp
  8015e6:	85 c0                	test   %eax,%eax
  8015e8:	78 0e                	js     8015f8 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8015ea:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8015ed:	8b 55 0c             	mov    0xc(%ebp),%edx
  8015f0:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8015f3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8015f8:	c9                   	leave  
  8015f9:	c3                   	ret    

008015fa <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8015fa:	55                   	push   %ebp
  8015fb:	89 e5                	mov    %esp,%ebp
  8015fd:	53                   	push   %ebx
  8015fe:	83 ec 14             	sub    $0x14,%esp
  801601:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801604:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801607:	50                   	push   %eax
  801608:	53                   	push   %ebx
  801609:	e8 f7 fb ff ff       	call   801205 <fd_lookup>
  80160e:	83 c4 08             	add    $0x8,%esp
  801611:	89 c2                	mov    %eax,%edx
  801613:	85 c0                	test   %eax,%eax
  801615:	78 65                	js     80167c <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801617:	83 ec 08             	sub    $0x8,%esp
  80161a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80161d:	50                   	push   %eax
  80161e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801621:	ff 30                	pushl  (%eax)
  801623:	e8 33 fc ff ff       	call   80125b <dev_lookup>
  801628:	83 c4 10             	add    $0x10,%esp
  80162b:	85 c0                	test   %eax,%eax
  80162d:	78 44                	js     801673 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80162f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801632:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801636:	75 21                	jne    801659 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801638:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80163d:	8b 40 48             	mov    0x48(%eax),%eax
  801640:	83 ec 04             	sub    $0x4,%esp
  801643:	53                   	push   %ebx
  801644:	50                   	push   %eax
  801645:	68 98 2a 80 00       	push   $0x802a98
  80164a:	e8 e2 eb ff ff       	call   800231 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80164f:	83 c4 10             	add    $0x10,%esp
  801652:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801657:	eb 23                	jmp    80167c <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801659:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80165c:	8b 52 18             	mov    0x18(%edx),%edx
  80165f:	85 d2                	test   %edx,%edx
  801661:	74 14                	je     801677 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801663:	83 ec 08             	sub    $0x8,%esp
  801666:	ff 75 0c             	pushl  0xc(%ebp)
  801669:	50                   	push   %eax
  80166a:	ff d2                	call   *%edx
  80166c:	89 c2                	mov    %eax,%edx
  80166e:	83 c4 10             	add    $0x10,%esp
  801671:	eb 09                	jmp    80167c <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801673:	89 c2                	mov    %eax,%edx
  801675:	eb 05                	jmp    80167c <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801677:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  80167c:	89 d0                	mov    %edx,%eax
  80167e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801681:	c9                   	leave  
  801682:	c3                   	ret    

00801683 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801683:	55                   	push   %ebp
  801684:	89 e5                	mov    %esp,%ebp
  801686:	53                   	push   %ebx
  801687:	83 ec 14             	sub    $0x14,%esp
  80168a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80168d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801690:	50                   	push   %eax
  801691:	ff 75 08             	pushl  0x8(%ebp)
  801694:	e8 6c fb ff ff       	call   801205 <fd_lookup>
  801699:	83 c4 08             	add    $0x8,%esp
  80169c:	89 c2                	mov    %eax,%edx
  80169e:	85 c0                	test   %eax,%eax
  8016a0:	78 58                	js     8016fa <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016a2:	83 ec 08             	sub    $0x8,%esp
  8016a5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016a8:	50                   	push   %eax
  8016a9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016ac:	ff 30                	pushl  (%eax)
  8016ae:	e8 a8 fb ff ff       	call   80125b <dev_lookup>
  8016b3:	83 c4 10             	add    $0x10,%esp
  8016b6:	85 c0                	test   %eax,%eax
  8016b8:	78 37                	js     8016f1 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8016ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016bd:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8016c1:	74 32                	je     8016f5 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8016c3:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8016c6:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8016cd:	00 00 00 
	stat->st_isdir = 0;
  8016d0:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8016d7:	00 00 00 
	stat->st_dev = dev;
  8016da:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8016e0:	83 ec 08             	sub    $0x8,%esp
  8016e3:	53                   	push   %ebx
  8016e4:	ff 75 f0             	pushl  -0x10(%ebp)
  8016e7:	ff 50 14             	call   *0x14(%eax)
  8016ea:	89 c2                	mov    %eax,%edx
  8016ec:	83 c4 10             	add    $0x10,%esp
  8016ef:	eb 09                	jmp    8016fa <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016f1:	89 c2                	mov    %eax,%edx
  8016f3:	eb 05                	jmp    8016fa <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8016f5:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8016fa:	89 d0                	mov    %edx,%eax
  8016fc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016ff:	c9                   	leave  
  801700:	c3                   	ret    

00801701 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801701:	55                   	push   %ebp
  801702:	89 e5                	mov    %esp,%ebp
  801704:	56                   	push   %esi
  801705:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801706:	83 ec 08             	sub    $0x8,%esp
  801709:	6a 00                	push   $0x0
  80170b:	ff 75 08             	pushl  0x8(%ebp)
  80170e:	e8 d6 01 00 00       	call   8018e9 <open>
  801713:	89 c3                	mov    %eax,%ebx
  801715:	83 c4 10             	add    $0x10,%esp
  801718:	85 c0                	test   %eax,%eax
  80171a:	78 1b                	js     801737 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80171c:	83 ec 08             	sub    $0x8,%esp
  80171f:	ff 75 0c             	pushl  0xc(%ebp)
  801722:	50                   	push   %eax
  801723:	e8 5b ff ff ff       	call   801683 <fstat>
  801728:	89 c6                	mov    %eax,%esi
	close(fd);
  80172a:	89 1c 24             	mov    %ebx,(%esp)
  80172d:	e8 fd fb ff ff       	call   80132f <close>
	return r;
  801732:	83 c4 10             	add    $0x10,%esp
  801735:	89 f0                	mov    %esi,%eax
}
  801737:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80173a:	5b                   	pop    %ebx
  80173b:	5e                   	pop    %esi
  80173c:	5d                   	pop    %ebp
  80173d:	c3                   	ret    

0080173e <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80173e:	55                   	push   %ebp
  80173f:	89 e5                	mov    %esp,%ebp
  801741:	56                   	push   %esi
  801742:	53                   	push   %ebx
  801743:	89 c6                	mov    %eax,%esi
  801745:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801747:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80174e:	75 12                	jne    801762 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801750:	83 ec 0c             	sub    $0xc,%esp
  801753:	6a 01                	push   $0x1
  801755:	e8 fc f9 ff ff       	call   801156 <ipc_find_env>
  80175a:	a3 00 40 80 00       	mov    %eax,0x804000
  80175f:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801762:	6a 07                	push   $0x7
  801764:	68 00 50 80 00       	push   $0x805000
  801769:	56                   	push   %esi
  80176a:	ff 35 00 40 80 00    	pushl  0x804000
  801770:	e8 8d f9 ff ff       	call   801102 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801775:	83 c4 0c             	add    $0xc,%esp
  801778:	6a 00                	push   $0x0
  80177a:	53                   	push   %ebx
  80177b:	6a 00                	push   $0x0
  80177d:	e8 19 f9 ff ff       	call   80109b <ipc_recv>
}
  801782:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801785:	5b                   	pop    %ebx
  801786:	5e                   	pop    %esi
  801787:	5d                   	pop    %ebp
  801788:	c3                   	ret    

00801789 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801789:	55                   	push   %ebp
  80178a:	89 e5                	mov    %esp,%ebp
  80178c:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80178f:	8b 45 08             	mov    0x8(%ebp),%eax
  801792:	8b 40 0c             	mov    0xc(%eax),%eax
  801795:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80179a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80179d:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8017a2:	ba 00 00 00 00       	mov    $0x0,%edx
  8017a7:	b8 02 00 00 00       	mov    $0x2,%eax
  8017ac:	e8 8d ff ff ff       	call   80173e <fsipc>
}
  8017b1:	c9                   	leave  
  8017b2:	c3                   	ret    

008017b3 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8017b3:	55                   	push   %ebp
  8017b4:	89 e5                	mov    %esp,%ebp
  8017b6:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8017b9:	8b 45 08             	mov    0x8(%ebp),%eax
  8017bc:	8b 40 0c             	mov    0xc(%eax),%eax
  8017bf:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8017c4:	ba 00 00 00 00       	mov    $0x0,%edx
  8017c9:	b8 06 00 00 00       	mov    $0x6,%eax
  8017ce:	e8 6b ff ff ff       	call   80173e <fsipc>
}
  8017d3:	c9                   	leave  
  8017d4:	c3                   	ret    

008017d5 <devfile_stat>:

}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8017d5:	55                   	push   %ebp
  8017d6:	89 e5                	mov    %esp,%ebp
  8017d8:	53                   	push   %ebx
  8017d9:	83 ec 04             	sub    $0x4,%esp
  8017dc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8017df:	8b 45 08             	mov    0x8(%ebp),%eax
  8017e2:	8b 40 0c             	mov    0xc(%eax),%eax
  8017e5:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8017ea:	ba 00 00 00 00       	mov    $0x0,%edx
  8017ef:	b8 05 00 00 00       	mov    $0x5,%eax
  8017f4:	e8 45 ff ff ff       	call   80173e <fsipc>
  8017f9:	85 c0                	test   %eax,%eax
  8017fb:	78 2c                	js     801829 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8017fd:	83 ec 08             	sub    $0x8,%esp
  801800:	68 00 50 80 00       	push   $0x805000
  801805:	53                   	push   %ebx
  801806:	e8 ab ef ff ff       	call   8007b6 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80180b:	a1 80 50 80 00       	mov    0x805080,%eax
  801810:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801816:	a1 84 50 80 00       	mov    0x805084,%eax
  80181b:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801821:	83 c4 10             	add    $0x10,%esp
  801824:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801829:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80182c:	c9                   	leave  
  80182d:	c3                   	ret    

0080182e <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  80182e:	55                   	push   %ebp
  80182f:	89 e5                	mov    %esp,%ebp
  801831:	83 ec 0c             	sub    $0xc,%esp
  801834:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	// panic("devfile_write not implemented");

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801837:	8b 55 08             	mov    0x8(%ebp),%edx
  80183a:	8b 52 0c             	mov    0xc(%edx),%edx
  80183d:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  801843:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  801848:	50                   	push   %eax
  801849:	ff 75 0c             	pushl  0xc(%ebp)
  80184c:	68 08 50 80 00       	push   $0x805008
  801851:	e8 f2 f0 ff ff       	call   800948 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  801856:	ba 00 00 00 00       	mov    $0x0,%edx
  80185b:	b8 04 00 00 00       	mov    $0x4,%eax
  801860:	e8 d9 fe ff ff       	call   80173e <fsipc>

}
  801865:	c9                   	leave  
  801866:	c3                   	ret    

00801867 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801867:	55                   	push   %ebp
  801868:	89 e5                	mov    %esp,%ebp
  80186a:	56                   	push   %esi
  80186b:	53                   	push   %ebx
  80186c:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80186f:	8b 45 08             	mov    0x8(%ebp),%eax
  801872:	8b 40 0c             	mov    0xc(%eax),%eax
  801875:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80187a:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801880:	ba 00 00 00 00       	mov    $0x0,%edx
  801885:	b8 03 00 00 00       	mov    $0x3,%eax
  80188a:	e8 af fe ff ff       	call   80173e <fsipc>
  80188f:	89 c3                	mov    %eax,%ebx
  801891:	85 c0                	test   %eax,%eax
  801893:	78 4b                	js     8018e0 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801895:	39 c6                	cmp    %eax,%esi
  801897:	73 16                	jae    8018af <devfile_read+0x48>
  801899:	68 0c 2b 80 00       	push   $0x802b0c
  80189e:	68 13 2b 80 00       	push   $0x802b13
  8018a3:	6a 7c                	push   $0x7c
  8018a5:	68 28 2b 80 00       	push   $0x802b28
  8018aa:	e8 a9 e8 ff ff       	call   800158 <_panic>
	assert(r <= PGSIZE);
  8018af:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8018b4:	7e 16                	jle    8018cc <devfile_read+0x65>
  8018b6:	68 33 2b 80 00       	push   $0x802b33
  8018bb:	68 13 2b 80 00       	push   $0x802b13
  8018c0:	6a 7d                	push   $0x7d
  8018c2:	68 28 2b 80 00       	push   $0x802b28
  8018c7:	e8 8c e8 ff ff       	call   800158 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8018cc:	83 ec 04             	sub    $0x4,%esp
  8018cf:	50                   	push   %eax
  8018d0:	68 00 50 80 00       	push   $0x805000
  8018d5:	ff 75 0c             	pushl  0xc(%ebp)
  8018d8:	e8 6b f0 ff ff       	call   800948 <memmove>
	return r;
  8018dd:	83 c4 10             	add    $0x10,%esp
}
  8018e0:	89 d8                	mov    %ebx,%eax
  8018e2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018e5:	5b                   	pop    %ebx
  8018e6:	5e                   	pop    %esi
  8018e7:	5d                   	pop    %ebp
  8018e8:	c3                   	ret    

008018e9 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8018e9:	55                   	push   %ebp
  8018ea:	89 e5                	mov    %esp,%ebp
  8018ec:	53                   	push   %ebx
  8018ed:	83 ec 20             	sub    $0x20,%esp
  8018f0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8018f3:	53                   	push   %ebx
  8018f4:	e8 84 ee ff ff       	call   80077d <strlen>
  8018f9:	83 c4 10             	add    $0x10,%esp
  8018fc:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801901:	7f 67                	jg     80196a <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801903:	83 ec 0c             	sub    $0xc,%esp
  801906:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801909:	50                   	push   %eax
  80190a:	e8 a7 f8 ff ff       	call   8011b6 <fd_alloc>
  80190f:	83 c4 10             	add    $0x10,%esp
		return r;
  801912:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801914:	85 c0                	test   %eax,%eax
  801916:	78 57                	js     80196f <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801918:	83 ec 08             	sub    $0x8,%esp
  80191b:	53                   	push   %ebx
  80191c:	68 00 50 80 00       	push   $0x805000
  801921:	e8 90 ee ff ff       	call   8007b6 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801926:	8b 45 0c             	mov    0xc(%ebp),%eax
  801929:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80192e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801931:	b8 01 00 00 00       	mov    $0x1,%eax
  801936:	e8 03 fe ff ff       	call   80173e <fsipc>
  80193b:	89 c3                	mov    %eax,%ebx
  80193d:	83 c4 10             	add    $0x10,%esp
  801940:	85 c0                	test   %eax,%eax
  801942:	79 14                	jns    801958 <open+0x6f>
		fd_close(fd, 0);
  801944:	83 ec 08             	sub    $0x8,%esp
  801947:	6a 00                	push   $0x0
  801949:	ff 75 f4             	pushl  -0xc(%ebp)
  80194c:	e8 5d f9 ff ff       	call   8012ae <fd_close>
		return r;
  801951:	83 c4 10             	add    $0x10,%esp
  801954:	89 da                	mov    %ebx,%edx
  801956:	eb 17                	jmp    80196f <open+0x86>
	}

	return fd2num(fd);
  801958:	83 ec 0c             	sub    $0xc,%esp
  80195b:	ff 75 f4             	pushl  -0xc(%ebp)
  80195e:	e8 2c f8 ff ff       	call   80118f <fd2num>
  801963:	89 c2                	mov    %eax,%edx
  801965:	83 c4 10             	add    $0x10,%esp
  801968:	eb 05                	jmp    80196f <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  80196a:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  80196f:	89 d0                	mov    %edx,%eax
  801971:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801974:	c9                   	leave  
  801975:	c3                   	ret    

00801976 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801976:	55                   	push   %ebp
  801977:	89 e5                	mov    %esp,%ebp
  801979:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80197c:	ba 00 00 00 00       	mov    $0x0,%edx
  801981:	b8 08 00 00 00       	mov    $0x8,%eax
  801986:	e8 b3 fd ff ff       	call   80173e <fsipc>
}
  80198b:	c9                   	leave  
  80198c:	c3                   	ret    

0080198d <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  80198d:	55                   	push   %ebp
  80198e:	89 e5                	mov    %esp,%ebp
  801990:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  801993:	68 3f 2b 80 00       	push   $0x802b3f
  801998:	ff 75 0c             	pushl  0xc(%ebp)
  80199b:	e8 16 ee ff ff       	call   8007b6 <strcpy>
	return 0;
}
  8019a0:	b8 00 00 00 00       	mov    $0x0,%eax
  8019a5:	c9                   	leave  
  8019a6:	c3                   	ret    

008019a7 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  8019a7:	55                   	push   %ebp
  8019a8:	89 e5                	mov    %esp,%ebp
  8019aa:	53                   	push   %ebx
  8019ab:	83 ec 10             	sub    $0x10,%esp
  8019ae:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  8019b1:	53                   	push   %ebx
  8019b2:	e8 87 09 00 00       	call   80233e <pageref>
  8019b7:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  8019ba:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  8019bf:	83 f8 01             	cmp    $0x1,%eax
  8019c2:	75 10                	jne    8019d4 <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  8019c4:	83 ec 0c             	sub    $0xc,%esp
  8019c7:	ff 73 0c             	pushl  0xc(%ebx)
  8019ca:	e8 c0 02 00 00       	call   801c8f <nsipc_close>
  8019cf:	89 c2                	mov    %eax,%edx
  8019d1:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  8019d4:	89 d0                	mov    %edx,%eax
  8019d6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019d9:	c9                   	leave  
  8019da:	c3                   	ret    

008019db <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  8019db:	55                   	push   %ebp
  8019dc:	89 e5                	mov    %esp,%ebp
  8019de:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  8019e1:	6a 00                	push   $0x0
  8019e3:	ff 75 10             	pushl  0x10(%ebp)
  8019e6:	ff 75 0c             	pushl  0xc(%ebp)
  8019e9:	8b 45 08             	mov    0x8(%ebp),%eax
  8019ec:	ff 70 0c             	pushl  0xc(%eax)
  8019ef:	e8 78 03 00 00       	call   801d6c <nsipc_send>
}
  8019f4:	c9                   	leave  
  8019f5:	c3                   	ret    

008019f6 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  8019f6:	55                   	push   %ebp
  8019f7:	89 e5                	mov    %esp,%ebp
  8019f9:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  8019fc:	6a 00                	push   $0x0
  8019fe:	ff 75 10             	pushl  0x10(%ebp)
  801a01:	ff 75 0c             	pushl  0xc(%ebp)
  801a04:	8b 45 08             	mov    0x8(%ebp),%eax
  801a07:	ff 70 0c             	pushl  0xc(%eax)
  801a0a:	e8 f1 02 00 00       	call   801d00 <nsipc_recv>
}
  801a0f:	c9                   	leave  
  801a10:	c3                   	ret    

00801a11 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801a11:	55                   	push   %ebp
  801a12:	89 e5                	mov    %esp,%ebp
  801a14:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801a17:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801a1a:	52                   	push   %edx
  801a1b:	50                   	push   %eax
  801a1c:	e8 e4 f7 ff ff       	call   801205 <fd_lookup>
  801a21:	83 c4 10             	add    $0x10,%esp
  801a24:	85 c0                	test   %eax,%eax
  801a26:	78 17                	js     801a3f <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801a28:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a2b:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  801a31:	39 08                	cmp    %ecx,(%eax)
  801a33:	75 05                	jne    801a3a <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801a35:	8b 40 0c             	mov    0xc(%eax),%eax
  801a38:	eb 05                	jmp    801a3f <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801a3a:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801a3f:	c9                   	leave  
  801a40:	c3                   	ret    

00801a41 <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  801a41:	55                   	push   %ebp
  801a42:	89 e5                	mov    %esp,%ebp
  801a44:	56                   	push   %esi
  801a45:	53                   	push   %ebx
  801a46:	83 ec 1c             	sub    $0x1c,%esp
  801a49:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801a4b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a4e:	50                   	push   %eax
  801a4f:	e8 62 f7 ff ff       	call   8011b6 <fd_alloc>
  801a54:	89 c3                	mov    %eax,%ebx
  801a56:	83 c4 10             	add    $0x10,%esp
  801a59:	85 c0                	test   %eax,%eax
  801a5b:	78 1b                	js     801a78 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801a5d:	83 ec 04             	sub    $0x4,%esp
  801a60:	68 07 04 00 00       	push   $0x407
  801a65:	ff 75 f4             	pushl  -0xc(%ebp)
  801a68:	6a 00                	push   $0x0
  801a6a:	e8 4a f1 ff ff       	call   800bb9 <sys_page_alloc>
  801a6f:	89 c3                	mov    %eax,%ebx
  801a71:	83 c4 10             	add    $0x10,%esp
  801a74:	85 c0                	test   %eax,%eax
  801a76:	79 10                	jns    801a88 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  801a78:	83 ec 0c             	sub    $0xc,%esp
  801a7b:	56                   	push   %esi
  801a7c:	e8 0e 02 00 00       	call   801c8f <nsipc_close>
		return r;
  801a81:	83 c4 10             	add    $0x10,%esp
  801a84:	89 d8                	mov    %ebx,%eax
  801a86:	eb 24                	jmp    801aac <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801a88:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801a8e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a91:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801a93:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a96:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801a9d:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801aa0:	83 ec 0c             	sub    $0xc,%esp
  801aa3:	50                   	push   %eax
  801aa4:	e8 e6 f6 ff ff       	call   80118f <fd2num>
  801aa9:	83 c4 10             	add    $0x10,%esp
}
  801aac:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801aaf:	5b                   	pop    %ebx
  801ab0:	5e                   	pop    %esi
  801ab1:	5d                   	pop    %ebp
  801ab2:	c3                   	ret    

00801ab3 <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801ab3:	55                   	push   %ebp
  801ab4:	89 e5                	mov    %esp,%ebp
  801ab6:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801ab9:	8b 45 08             	mov    0x8(%ebp),%eax
  801abc:	e8 50 ff ff ff       	call   801a11 <fd2sockid>
		return r;
  801ac1:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  801ac3:	85 c0                	test   %eax,%eax
  801ac5:	78 1f                	js     801ae6 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801ac7:	83 ec 04             	sub    $0x4,%esp
  801aca:	ff 75 10             	pushl  0x10(%ebp)
  801acd:	ff 75 0c             	pushl  0xc(%ebp)
  801ad0:	50                   	push   %eax
  801ad1:	e8 12 01 00 00       	call   801be8 <nsipc_accept>
  801ad6:	83 c4 10             	add    $0x10,%esp
		return r;
  801ad9:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801adb:	85 c0                	test   %eax,%eax
  801add:	78 07                	js     801ae6 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  801adf:	e8 5d ff ff ff       	call   801a41 <alloc_sockfd>
  801ae4:	89 c1                	mov    %eax,%ecx
}
  801ae6:	89 c8                	mov    %ecx,%eax
  801ae8:	c9                   	leave  
  801ae9:	c3                   	ret    

00801aea <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801aea:	55                   	push   %ebp
  801aeb:	89 e5                	mov    %esp,%ebp
  801aed:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801af0:	8b 45 08             	mov    0x8(%ebp),%eax
  801af3:	e8 19 ff ff ff       	call   801a11 <fd2sockid>
  801af8:	85 c0                	test   %eax,%eax
  801afa:	78 12                	js     801b0e <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  801afc:	83 ec 04             	sub    $0x4,%esp
  801aff:	ff 75 10             	pushl  0x10(%ebp)
  801b02:	ff 75 0c             	pushl  0xc(%ebp)
  801b05:	50                   	push   %eax
  801b06:	e8 2d 01 00 00       	call   801c38 <nsipc_bind>
  801b0b:	83 c4 10             	add    $0x10,%esp
}
  801b0e:	c9                   	leave  
  801b0f:	c3                   	ret    

00801b10 <shutdown>:

int
shutdown(int s, int how)
{
  801b10:	55                   	push   %ebp
  801b11:	89 e5                	mov    %esp,%ebp
  801b13:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801b16:	8b 45 08             	mov    0x8(%ebp),%eax
  801b19:	e8 f3 fe ff ff       	call   801a11 <fd2sockid>
  801b1e:	85 c0                	test   %eax,%eax
  801b20:	78 0f                	js     801b31 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801b22:	83 ec 08             	sub    $0x8,%esp
  801b25:	ff 75 0c             	pushl  0xc(%ebp)
  801b28:	50                   	push   %eax
  801b29:	e8 3f 01 00 00       	call   801c6d <nsipc_shutdown>
  801b2e:	83 c4 10             	add    $0x10,%esp
}
  801b31:	c9                   	leave  
  801b32:	c3                   	ret    

00801b33 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801b33:	55                   	push   %ebp
  801b34:	89 e5                	mov    %esp,%ebp
  801b36:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801b39:	8b 45 08             	mov    0x8(%ebp),%eax
  801b3c:	e8 d0 fe ff ff       	call   801a11 <fd2sockid>
  801b41:	85 c0                	test   %eax,%eax
  801b43:	78 12                	js     801b57 <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  801b45:	83 ec 04             	sub    $0x4,%esp
  801b48:	ff 75 10             	pushl  0x10(%ebp)
  801b4b:	ff 75 0c             	pushl  0xc(%ebp)
  801b4e:	50                   	push   %eax
  801b4f:	e8 55 01 00 00       	call   801ca9 <nsipc_connect>
  801b54:	83 c4 10             	add    $0x10,%esp
}
  801b57:	c9                   	leave  
  801b58:	c3                   	ret    

00801b59 <listen>:

int
listen(int s, int backlog)
{
  801b59:	55                   	push   %ebp
  801b5a:	89 e5                	mov    %esp,%ebp
  801b5c:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801b5f:	8b 45 08             	mov    0x8(%ebp),%eax
  801b62:	e8 aa fe ff ff       	call   801a11 <fd2sockid>
  801b67:	85 c0                	test   %eax,%eax
  801b69:	78 0f                	js     801b7a <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801b6b:	83 ec 08             	sub    $0x8,%esp
  801b6e:	ff 75 0c             	pushl  0xc(%ebp)
  801b71:	50                   	push   %eax
  801b72:	e8 67 01 00 00       	call   801cde <nsipc_listen>
  801b77:	83 c4 10             	add    $0x10,%esp
}
  801b7a:	c9                   	leave  
  801b7b:	c3                   	ret    

00801b7c <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801b7c:	55                   	push   %ebp
  801b7d:	89 e5                	mov    %esp,%ebp
  801b7f:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801b82:	ff 75 10             	pushl  0x10(%ebp)
  801b85:	ff 75 0c             	pushl  0xc(%ebp)
  801b88:	ff 75 08             	pushl  0x8(%ebp)
  801b8b:	e8 3a 02 00 00       	call   801dca <nsipc_socket>
  801b90:	83 c4 10             	add    $0x10,%esp
  801b93:	85 c0                	test   %eax,%eax
  801b95:	78 05                	js     801b9c <socket+0x20>
		return r;
	return alloc_sockfd(r);
  801b97:	e8 a5 fe ff ff       	call   801a41 <alloc_sockfd>
}
  801b9c:	c9                   	leave  
  801b9d:	c3                   	ret    

00801b9e <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801b9e:	55                   	push   %ebp
  801b9f:	89 e5                	mov    %esp,%ebp
  801ba1:	53                   	push   %ebx
  801ba2:	83 ec 04             	sub    $0x4,%esp
  801ba5:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801ba7:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801bae:	75 12                	jne    801bc2 <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801bb0:	83 ec 0c             	sub    $0xc,%esp
  801bb3:	6a 02                	push   $0x2
  801bb5:	e8 9c f5 ff ff       	call   801156 <ipc_find_env>
  801bba:	a3 04 40 80 00       	mov    %eax,0x804004
  801bbf:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801bc2:	6a 07                	push   $0x7
  801bc4:	68 00 60 80 00       	push   $0x806000
  801bc9:	53                   	push   %ebx
  801bca:	ff 35 04 40 80 00    	pushl  0x804004
  801bd0:	e8 2d f5 ff ff       	call   801102 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801bd5:	83 c4 0c             	add    $0xc,%esp
  801bd8:	6a 00                	push   $0x0
  801bda:	6a 00                	push   $0x0
  801bdc:	6a 00                	push   $0x0
  801bde:	e8 b8 f4 ff ff       	call   80109b <ipc_recv>
}
  801be3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801be6:	c9                   	leave  
  801be7:	c3                   	ret    

00801be8 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801be8:	55                   	push   %ebp
  801be9:	89 e5                	mov    %esp,%ebp
  801beb:	56                   	push   %esi
  801bec:	53                   	push   %ebx
  801bed:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801bf0:	8b 45 08             	mov    0x8(%ebp),%eax
  801bf3:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801bf8:	8b 06                	mov    (%esi),%eax
  801bfa:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801bff:	b8 01 00 00 00       	mov    $0x1,%eax
  801c04:	e8 95 ff ff ff       	call   801b9e <nsipc>
  801c09:	89 c3                	mov    %eax,%ebx
  801c0b:	85 c0                	test   %eax,%eax
  801c0d:	78 20                	js     801c2f <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801c0f:	83 ec 04             	sub    $0x4,%esp
  801c12:	ff 35 10 60 80 00    	pushl  0x806010
  801c18:	68 00 60 80 00       	push   $0x806000
  801c1d:	ff 75 0c             	pushl  0xc(%ebp)
  801c20:	e8 23 ed ff ff       	call   800948 <memmove>
		*addrlen = ret->ret_addrlen;
  801c25:	a1 10 60 80 00       	mov    0x806010,%eax
  801c2a:	89 06                	mov    %eax,(%esi)
  801c2c:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  801c2f:	89 d8                	mov    %ebx,%eax
  801c31:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c34:	5b                   	pop    %ebx
  801c35:	5e                   	pop    %esi
  801c36:	5d                   	pop    %ebp
  801c37:	c3                   	ret    

00801c38 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801c38:	55                   	push   %ebp
  801c39:	89 e5                	mov    %esp,%ebp
  801c3b:	53                   	push   %ebx
  801c3c:	83 ec 08             	sub    $0x8,%esp
  801c3f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801c42:	8b 45 08             	mov    0x8(%ebp),%eax
  801c45:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801c4a:	53                   	push   %ebx
  801c4b:	ff 75 0c             	pushl  0xc(%ebp)
  801c4e:	68 04 60 80 00       	push   $0x806004
  801c53:	e8 f0 ec ff ff       	call   800948 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801c58:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801c5e:	b8 02 00 00 00       	mov    $0x2,%eax
  801c63:	e8 36 ff ff ff       	call   801b9e <nsipc>
}
  801c68:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c6b:	c9                   	leave  
  801c6c:	c3                   	ret    

00801c6d <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801c6d:	55                   	push   %ebp
  801c6e:	89 e5                	mov    %esp,%ebp
  801c70:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801c73:	8b 45 08             	mov    0x8(%ebp),%eax
  801c76:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801c7b:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c7e:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801c83:	b8 03 00 00 00       	mov    $0x3,%eax
  801c88:	e8 11 ff ff ff       	call   801b9e <nsipc>
}
  801c8d:	c9                   	leave  
  801c8e:	c3                   	ret    

00801c8f <nsipc_close>:

int
nsipc_close(int s)
{
  801c8f:	55                   	push   %ebp
  801c90:	89 e5                	mov    %esp,%ebp
  801c92:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801c95:	8b 45 08             	mov    0x8(%ebp),%eax
  801c98:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801c9d:	b8 04 00 00 00       	mov    $0x4,%eax
  801ca2:	e8 f7 fe ff ff       	call   801b9e <nsipc>
}
  801ca7:	c9                   	leave  
  801ca8:	c3                   	ret    

00801ca9 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801ca9:	55                   	push   %ebp
  801caa:	89 e5                	mov    %esp,%ebp
  801cac:	53                   	push   %ebx
  801cad:	83 ec 08             	sub    $0x8,%esp
  801cb0:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801cb3:	8b 45 08             	mov    0x8(%ebp),%eax
  801cb6:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801cbb:	53                   	push   %ebx
  801cbc:	ff 75 0c             	pushl  0xc(%ebp)
  801cbf:	68 04 60 80 00       	push   $0x806004
  801cc4:	e8 7f ec ff ff       	call   800948 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801cc9:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801ccf:	b8 05 00 00 00       	mov    $0x5,%eax
  801cd4:	e8 c5 fe ff ff       	call   801b9e <nsipc>
}
  801cd9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801cdc:	c9                   	leave  
  801cdd:	c3                   	ret    

00801cde <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801cde:	55                   	push   %ebp
  801cdf:	89 e5                	mov    %esp,%ebp
  801ce1:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801ce4:	8b 45 08             	mov    0x8(%ebp),%eax
  801ce7:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801cec:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cef:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801cf4:	b8 06 00 00 00       	mov    $0x6,%eax
  801cf9:	e8 a0 fe ff ff       	call   801b9e <nsipc>
}
  801cfe:	c9                   	leave  
  801cff:	c3                   	ret    

00801d00 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801d00:	55                   	push   %ebp
  801d01:	89 e5                	mov    %esp,%ebp
  801d03:	56                   	push   %esi
  801d04:	53                   	push   %ebx
  801d05:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801d08:	8b 45 08             	mov    0x8(%ebp),%eax
  801d0b:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801d10:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801d16:	8b 45 14             	mov    0x14(%ebp),%eax
  801d19:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801d1e:	b8 07 00 00 00       	mov    $0x7,%eax
  801d23:	e8 76 fe ff ff       	call   801b9e <nsipc>
  801d28:	89 c3                	mov    %eax,%ebx
  801d2a:	85 c0                	test   %eax,%eax
  801d2c:	78 35                	js     801d63 <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  801d2e:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801d33:	7f 04                	jg     801d39 <nsipc_recv+0x39>
  801d35:	39 c6                	cmp    %eax,%esi
  801d37:	7d 16                	jge    801d4f <nsipc_recv+0x4f>
  801d39:	68 4b 2b 80 00       	push   $0x802b4b
  801d3e:	68 13 2b 80 00       	push   $0x802b13
  801d43:	6a 62                	push   $0x62
  801d45:	68 60 2b 80 00       	push   $0x802b60
  801d4a:	e8 09 e4 ff ff       	call   800158 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801d4f:	83 ec 04             	sub    $0x4,%esp
  801d52:	50                   	push   %eax
  801d53:	68 00 60 80 00       	push   $0x806000
  801d58:	ff 75 0c             	pushl  0xc(%ebp)
  801d5b:	e8 e8 eb ff ff       	call   800948 <memmove>
  801d60:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801d63:	89 d8                	mov    %ebx,%eax
  801d65:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d68:	5b                   	pop    %ebx
  801d69:	5e                   	pop    %esi
  801d6a:	5d                   	pop    %ebp
  801d6b:	c3                   	ret    

00801d6c <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801d6c:	55                   	push   %ebp
  801d6d:	89 e5                	mov    %esp,%ebp
  801d6f:	53                   	push   %ebx
  801d70:	83 ec 04             	sub    $0x4,%esp
  801d73:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801d76:	8b 45 08             	mov    0x8(%ebp),%eax
  801d79:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801d7e:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801d84:	7e 16                	jle    801d9c <nsipc_send+0x30>
  801d86:	68 6c 2b 80 00       	push   $0x802b6c
  801d8b:	68 13 2b 80 00       	push   $0x802b13
  801d90:	6a 6d                	push   $0x6d
  801d92:	68 60 2b 80 00       	push   $0x802b60
  801d97:	e8 bc e3 ff ff       	call   800158 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801d9c:	83 ec 04             	sub    $0x4,%esp
  801d9f:	53                   	push   %ebx
  801da0:	ff 75 0c             	pushl  0xc(%ebp)
  801da3:	68 0c 60 80 00       	push   $0x80600c
  801da8:	e8 9b eb ff ff       	call   800948 <memmove>
	nsipcbuf.send.req_size = size;
  801dad:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801db3:	8b 45 14             	mov    0x14(%ebp),%eax
  801db6:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801dbb:	b8 08 00 00 00       	mov    $0x8,%eax
  801dc0:	e8 d9 fd ff ff       	call   801b9e <nsipc>
}
  801dc5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801dc8:	c9                   	leave  
  801dc9:	c3                   	ret    

00801dca <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801dca:	55                   	push   %ebp
  801dcb:	89 e5                	mov    %esp,%ebp
  801dcd:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801dd0:	8b 45 08             	mov    0x8(%ebp),%eax
  801dd3:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801dd8:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ddb:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801de0:	8b 45 10             	mov    0x10(%ebp),%eax
  801de3:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801de8:	b8 09 00 00 00       	mov    $0x9,%eax
  801ded:	e8 ac fd ff ff       	call   801b9e <nsipc>
}
  801df2:	c9                   	leave  
  801df3:	c3                   	ret    

00801df4 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801df4:	55                   	push   %ebp
  801df5:	89 e5                	mov    %esp,%ebp
  801df7:	56                   	push   %esi
  801df8:	53                   	push   %ebx
  801df9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801dfc:	83 ec 0c             	sub    $0xc,%esp
  801dff:	ff 75 08             	pushl  0x8(%ebp)
  801e02:	e8 98 f3 ff ff       	call   80119f <fd2data>
  801e07:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801e09:	83 c4 08             	add    $0x8,%esp
  801e0c:	68 78 2b 80 00       	push   $0x802b78
  801e11:	53                   	push   %ebx
  801e12:	e8 9f e9 ff ff       	call   8007b6 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801e17:	8b 46 04             	mov    0x4(%esi),%eax
  801e1a:	2b 06                	sub    (%esi),%eax
  801e1c:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801e22:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801e29:	00 00 00 
	stat->st_dev = &devpipe;
  801e2c:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801e33:	30 80 00 
	return 0;
}
  801e36:	b8 00 00 00 00       	mov    $0x0,%eax
  801e3b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e3e:	5b                   	pop    %ebx
  801e3f:	5e                   	pop    %esi
  801e40:	5d                   	pop    %ebp
  801e41:	c3                   	ret    

00801e42 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801e42:	55                   	push   %ebp
  801e43:	89 e5                	mov    %esp,%ebp
  801e45:	53                   	push   %ebx
  801e46:	83 ec 0c             	sub    $0xc,%esp
  801e49:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801e4c:	53                   	push   %ebx
  801e4d:	6a 00                	push   $0x0
  801e4f:	e8 ea ed ff ff       	call   800c3e <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801e54:	89 1c 24             	mov    %ebx,(%esp)
  801e57:	e8 43 f3 ff ff       	call   80119f <fd2data>
  801e5c:	83 c4 08             	add    $0x8,%esp
  801e5f:	50                   	push   %eax
  801e60:	6a 00                	push   $0x0
  801e62:	e8 d7 ed ff ff       	call   800c3e <sys_page_unmap>
}
  801e67:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801e6a:	c9                   	leave  
  801e6b:	c3                   	ret    

00801e6c <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801e6c:	55                   	push   %ebp
  801e6d:	89 e5                	mov    %esp,%ebp
  801e6f:	57                   	push   %edi
  801e70:	56                   	push   %esi
  801e71:	53                   	push   %ebx
  801e72:	83 ec 1c             	sub    $0x1c,%esp
  801e75:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801e78:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801e7a:	a1 08 40 80 00       	mov    0x804008,%eax
  801e7f:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801e82:	83 ec 0c             	sub    $0xc,%esp
  801e85:	ff 75 e0             	pushl  -0x20(%ebp)
  801e88:	e8 b1 04 00 00       	call   80233e <pageref>
  801e8d:	89 c3                	mov    %eax,%ebx
  801e8f:	89 3c 24             	mov    %edi,(%esp)
  801e92:	e8 a7 04 00 00       	call   80233e <pageref>
  801e97:	83 c4 10             	add    $0x10,%esp
  801e9a:	39 c3                	cmp    %eax,%ebx
  801e9c:	0f 94 c1             	sete   %cl
  801e9f:	0f b6 c9             	movzbl %cl,%ecx
  801ea2:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801ea5:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801eab:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801eae:	39 ce                	cmp    %ecx,%esi
  801eb0:	74 1b                	je     801ecd <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801eb2:	39 c3                	cmp    %eax,%ebx
  801eb4:	75 c4                	jne    801e7a <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801eb6:	8b 42 58             	mov    0x58(%edx),%eax
  801eb9:	ff 75 e4             	pushl  -0x1c(%ebp)
  801ebc:	50                   	push   %eax
  801ebd:	56                   	push   %esi
  801ebe:	68 7f 2b 80 00       	push   $0x802b7f
  801ec3:	e8 69 e3 ff ff       	call   800231 <cprintf>
  801ec8:	83 c4 10             	add    $0x10,%esp
  801ecb:	eb ad                	jmp    801e7a <_pipeisclosed+0xe>
	}
}
  801ecd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801ed0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ed3:	5b                   	pop    %ebx
  801ed4:	5e                   	pop    %esi
  801ed5:	5f                   	pop    %edi
  801ed6:	5d                   	pop    %ebp
  801ed7:	c3                   	ret    

00801ed8 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801ed8:	55                   	push   %ebp
  801ed9:	89 e5                	mov    %esp,%ebp
  801edb:	57                   	push   %edi
  801edc:	56                   	push   %esi
  801edd:	53                   	push   %ebx
  801ede:	83 ec 28             	sub    $0x28,%esp
  801ee1:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801ee4:	56                   	push   %esi
  801ee5:	e8 b5 f2 ff ff       	call   80119f <fd2data>
  801eea:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801eec:	83 c4 10             	add    $0x10,%esp
  801eef:	bf 00 00 00 00       	mov    $0x0,%edi
  801ef4:	eb 4b                	jmp    801f41 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801ef6:	89 da                	mov    %ebx,%edx
  801ef8:	89 f0                	mov    %esi,%eax
  801efa:	e8 6d ff ff ff       	call   801e6c <_pipeisclosed>
  801eff:	85 c0                	test   %eax,%eax
  801f01:	75 48                	jne    801f4b <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801f03:	e8 92 ec ff ff       	call   800b9a <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801f08:	8b 43 04             	mov    0x4(%ebx),%eax
  801f0b:	8b 0b                	mov    (%ebx),%ecx
  801f0d:	8d 51 20             	lea    0x20(%ecx),%edx
  801f10:	39 d0                	cmp    %edx,%eax
  801f12:	73 e2                	jae    801ef6 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801f14:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801f17:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801f1b:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801f1e:	89 c2                	mov    %eax,%edx
  801f20:	c1 fa 1f             	sar    $0x1f,%edx
  801f23:	89 d1                	mov    %edx,%ecx
  801f25:	c1 e9 1b             	shr    $0x1b,%ecx
  801f28:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801f2b:	83 e2 1f             	and    $0x1f,%edx
  801f2e:	29 ca                	sub    %ecx,%edx
  801f30:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801f34:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801f38:	83 c0 01             	add    $0x1,%eax
  801f3b:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801f3e:	83 c7 01             	add    $0x1,%edi
  801f41:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801f44:	75 c2                	jne    801f08 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801f46:	8b 45 10             	mov    0x10(%ebp),%eax
  801f49:	eb 05                	jmp    801f50 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801f4b:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801f50:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f53:	5b                   	pop    %ebx
  801f54:	5e                   	pop    %esi
  801f55:	5f                   	pop    %edi
  801f56:	5d                   	pop    %ebp
  801f57:	c3                   	ret    

00801f58 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801f58:	55                   	push   %ebp
  801f59:	89 e5                	mov    %esp,%ebp
  801f5b:	57                   	push   %edi
  801f5c:	56                   	push   %esi
  801f5d:	53                   	push   %ebx
  801f5e:	83 ec 18             	sub    $0x18,%esp
  801f61:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801f64:	57                   	push   %edi
  801f65:	e8 35 f2 ff ff       	call   80119f <fd2data>
  801f6a:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801f6c:	83 c4 10             	add    $0x10,%esp
  801f6f:	bb 00 00 00 00       	mov    $0x0,%ebx
  801f74:	eb 3d                	jmp    801fb3 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801f76:	85 db                	test   %ebx,%ebx
  801f78:	74 04                	je     801f7e <devpipe_read+0x26>
				return i;
  801f7a:	89 d8                	mov    %ebx,%eax
  801f7c:	eb 44                	jmp    801fc2 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801f7e:	89 f2                	mov    %esi,%edx
  801f80:	89 f8                	mov    %edi,%eax
  801f82:	e8 e5 fe ff ff       	call   801e6c <_pipeisclosed>
  801f87:	85 c0                	test   %eax,%eax
  801f89:	75 32                	jne    801fbd <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801f8b:	e8 0a ec ff ff       	call   800b9a <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801f90:	8b 06                	mov    (%esi),%eax
  801f92:	3b 46 04             	cmp    0x4(%esi),%eax
  801f95:	74 df                	je     801f76 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801f97:	99                   	cltd   
  801f98:	c1 ea 1b             	shr    $0x1b,%edx
  801f9b:	01 d0                	add    %edx,%eax
  801f9d:	83 e0 1f             	and    $0x1f,%eax
  801fa0:	29 d0                	sub    %edx,%eax
  801fa2:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801fa7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801faa:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801fad:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801fb0:	83 c3 01             	add    $0x1,%ebx
  801fb3:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801fb6:	75 d8                	jne    801f90 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801fb8:	8b 45 10             	mov    0x10(%ebp),%eax
  801fbb:	eb 05                	jmp    801fc2 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801fbd:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801fc2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801fc5:	5b                   	pop    %ebx
  801fc6:	5e                   	pop    %esi
  801fc7:	5f                   	pop    %edi
  801fc8:	5d                   	pop    %ebp
  801fc9:	c3                   	ret    

00801fca <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801fca:	55                   	push   %ebp
  801fcb:	89 e5                	mov    %esp,%ebp
  801fcd:	56                   	push   %esi
  801fce:	53                   	push   %ebx
  801fcf:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801fd2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801fd5:	50                   	push   %eax
  801fd6:	e8 db f1 ff ff       	call   8011b6 <fd_alloc>
  801fdb:	83 c4 10             	add    $0x10,%esp
  801fde:	89 c2                	mov    %eax,%edx
  801fe0:	85 c0                	test   %eax,%eax
  801fe2:	0f 88 2c 01 00 00    	js     802114 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801fe8:	83 ec 04             	sub    $0x4,%esp
  801feb:	68 07 04 00 00       	push   $0x407
  801ff0:	ff 75 f4             	pushl  -0xc(%ebp)
  801ff3:	6a 00                	push   $0x0
  801ff5:	e8 bf eb ff ff       	call   800bb9 <sys_page_alloc>
  801ffa:	83 c4 10             	add    $0x10,%esp
  801ffd:	89 c2                	mov    %eax,%edx
  801fff:	85 c0                	test   %eax,%eax
  802001:	0f 88 0d 01 00 00    	js     802114 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  802007:	83 ec 0c             	sub    $0xc,%esp
  80200a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80200d:	50                   	push   %eax
  80200e:	e8 a3 f1 ff ff       	call   8011b6 <fd_alloc>
  802013:	89 c3                	mov    %eax,%ebx
  802015:	83 c4 10             	add    $0x10,%esp
  802018:	85 c0                	test   %eax,%eax
  80201a:	0f 88 e2 00 00 00    	js     802102 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802020:	83 ec 04             	sub    $0x4,%esp
  802023:	68 07 04 00 00       	push   $0x407
  802028:	ff 75 f0             	pushl  -0x10(%ebp)
  80202b:	6a 00                	push   $0x0
  80202d:	e8 87 eb ff ff       	call   800bb9 <sys_page_alloc>
  802032:	89 c3                	mov    %eax,%ebx
  802034:	83 c4 10             	add    $0x10,%esp
  802037:	85 c0                	test   %eax,%eax
  802039:	0f 88 c3 00 00 00    	js     802102 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  80203f:	83 ec 0c             	sub    $0xc,%esp
  802042:	ff 75 f4             	pushl  -0xc(%ebp)
  802045:	e8 55 f1 ff ff       	call   80119f <fd2data>
  80204a:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80204c:	83 c4 0c             	add    $0xc,%esp
  80204f:	68 07 04 00 00       	push   $0x407
  802054:	50                   	push   %eax
  802055:	6a 00                	push   $0x0
  802057:	e8 5d eb ff ff       	call   800bb9 <sys_page_alloc>
  80205c:	89 c3                	mov    %eax,%ebx
  80205e:	83 c4 10             	add    $0x10,%esp
  802061:	85 c0                	test   %eax,%eax
  802063:	0f 88 89 00 00 00    	js     8020f2 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802069:	83 ec 0c             	sub    $0xc,%esp
  80206c:	ff 75 f0             	pushl  -0x10(%ebp)
  80206f:	e8 2b f1 ff ff       	call   80119f <fd2data>
  802074:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  80207b:	50                   	push   %eax
  80207c:	6a 00                	push   $0x0
  80207e:	56                   	push   %esi
  80207f:	6a 00                	push   $0x0
  802081:	e8 76 eb ff ff       	call   800bfc <sys_page_map>
  802086:	89 c3                	mov    %eax,%ebx
  802088:	83 c4 20             	add    $0x20,%esp
  80208b:	85 c0                	test   %eax,%eax
  80208d:	78 55                	js     8020e4 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  80208f:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  802095:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802098:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  80209a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80209d:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8020a4:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8020aa:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8020ad:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8020af:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8020b2:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8020b9:	83 ec 0c             	sub    $0xc,%esp
  8020bc:	ff 75 f4             	pushl  -0xc(%ebp)
  8020bf:	e8 cb f0 ff ff       	call   80118f <fd2num>
  8020c4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8020c7:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8020c9:	83 c4 04             	add    $0x4,%esp
  8020cc:	ff 75 f0             	pushl  -0x10(%ebp)
  8020cf:	e8 bb f0 ff ff       	call   80118f <fd2num>
  8020d4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8020d7:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8020da:	83 c4 10             	add    $0x10,%esp
  8020dd:	ba 00 00 00 00       	mov    $0x0,%edx
  8020e2:	eb 30                	jmp    802114 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  8020e4:	83 ec 08             	sub    $0x8,%esp
  8020e7:	56                   	push   %esi
  8020e8:	6a 00                	push   $0x0
  8020ea:	e8 4f eb ff ff       	call   800c3e <sys_page_unmap>
  8020ef:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  8020f2:	83 ec 08             	sub    $0x8,%esp
  8020f5:	ff 75 f0             	pushl  -0x10(%ebp)
  8020f8:	6a 00                	push   $0x0
  8020fa:	e8 3f eb ff ff       	call   800c3e <sys_page_unmap>
  8020ff:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  802102:	83 ec 08             	sub    $0x8,%esp
  802105:	ff 75 f4             	pushl  -0xc(%ebp)
  802108:	6a 00                	push   $0x0
  80210a:	e8 2f eb ff ff       	call   800c3e <sys_page_unmap>
  80210f:	83 c4 10             	add    $0x10,%esp
  802112:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  802114:	89 d0                	mov    %edx,%eax
  802116:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802119:	5b                   	pop    %ebx
  80211a:	5e                   	pop    %esi
  80211b:	5d                   	pop    %ebp
  80211c:	c3                   	ret    

0080211d <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  80211d:	55                   	push   %ebp
  80211e:	89 e5                	mov    %esp,%ebp
  802120:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802123:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802126:	50                   	push   %eax
  802127:	ff 75 08             	pushl  0x8(%ebp)
  80212a:	e8 d6 f0 ff ff       	call   801205 <fd_lookup>
  80212f:	83 c4 10             	add    $0x10,%esp
  802132:	85 c0                	test   %eax,%eax
  802134:	78 18                	js     80214e <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  802136:	83 ec 0c             	sub    $0xc,%esp
  802139:	ff 75 f4             	pushl  -0xc(%ebp)
  80213c:	e8 5e f0 ff ff       	call   80119f <fd2data>
	return _pipeisclosed(fd, p);
  802141:	89 c2                	mov    %eax,%edx
  802143:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802146:	e8 21 fd ff ff       	call   801e6c <_pipeisclosed>
  80214b:	83 c4 10             	add    $0x10,%esp
}
  80214e:	c9                   	leave  
  80214f:	c3                   	ret    

00802150 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  802150:	55                   	push   %ebp
  802151:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  802153:	b8 00 00 00 00       	mov    $0x0,%eax
  802158:	5d                   	pop    %ebp
  802159:	c3                   	ret    

0080215a <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80215a:	55                   	push   %ebp
  80215b:	89 e5                	mov    %esp,%ebp
  80215d:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  802160:	68 97 2b 80 00       	push   $0x802b97
  802165:	ff 75 0c             	pushl  0xc(%ebp)
  802168:	e8 49 e6 ff ff       	call   8007b6 <strcpy>
	return 0;
}
  80216d:	b8 00 00 00 00       	mov    $0x0,%eax
  802172:	c9                   	leave  
  802173:	c3                   	ret    

00802174 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802174:	55                   	push   %ebp
  802175:	89 e5                	mov    %esp,%ebp
  802177:	57                   	push   %edi
  802178:	56                   	push   %esi
  802179:	53                   	push   %ebx
  80217a:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802180:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802185:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80218b:	eb 2d                	jmp    8021ba <devcons_write+0x46>
		m = n - tot;
  80218d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802190:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  802192:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  802195:	ba 7f 00 00 00       	mov    $0x7f,%edx
  80219a:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80219d:	83 ec 04             	sub    $0x4,%esp
  8021a0:	53                   	push   %ebx
  8021a1:	03 45 0c             	add    0xc(%ebp),%eax
  8021a4:	50                   	push   %eax
  8021a5:	57                   	push   %edi
  8021a6:	e8 9d e7 ff ff       	call   800948 <memmove>
		sys_cputs(buf, m);
  8021ab:	83 c4 08             	add    $0x8,%esp
  8021ae:	53                   	push   %ebx
  8021af:	57                   	push   %edi
  8021b0:	e8 48 e9 ff ff       	call   800afd <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8021b5:	01 de                	add    %ebx,%esi
  8021b7:	83 c4 10             	add    $0x10,%esp
  8021ba:	89 f0                	mov    %esi,%eax
  8021bc:	3b 75 10             	cmp    0x10(%ebp),%esi
  8021bf:	72 cc                	jb     80218d <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8021c1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8021c4:	5b                   	pop    %ebx
  8021c5:	5e                   	pop    %esi
  8021c6:	5f                   	pop    %edi
  8021c7:	5d                   	pop    %ebp
  8021c8:	c3                   	ret    

008021c9 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8021c9:	55                   	push   %ebp
  8021ca:	89 e5                	mov    %esp,%ebp
  8021cc:	83 ec 08             	sub    $0x8,%esp
  8021cf:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  8021d4:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8021d8:	74 2a                	je     802204 <devcons_read+0x3b>
  8021da:	eb 05                	jmp    8021e1 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8021dc:	e8 b9 e9 ff ff       	call   800b9a <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8021e1:	e8 35 e9 ff ff       	call   800b1b <sys_cgetc>
  8021e6:	85 c0                	test   %eax,%eax
  8021e8:	74 f2                	je     8021dc <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8021ea:	85 c0                	test   %eax,%eax
  8021ec:	78 16                	js     802204 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8021ee:	83 f8 04             	cmp    $0x4,%eax
  8021f1:	74 0c                	je     8021ff <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  8021f3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8021f6:	88 02                	mov    %al,(%edx)
	return 1;
  8021f8:	b8 01 00 00 00       	mov    $0x1,%eax
  8021fd:	eb 05                	jmp    802204 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8021ff:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  802204:	c9                   	leave  
  802205:	c3                   	ret    

00802206 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  802206:	55                   	push   %ebp
  802207:	89 e5                	mov    %esp,%ebp
  802209:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  80220c:	8b 45 08             	mov    0x8(%ebp),%eax
  80220f:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  802212:	6a 01                	push   $0x1
  802214:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802217:	50                   	push   %eax
  802218:	e8 e0 e8 ff ff       	call   800afd <sys_cputs>
}
  80221d:	83 c4 10             	add    $0x10,%esp
  802220:	c9                   	leave  
  802221:	c3                   	ret    

00802222 <getchar>:

int
getchar(void)
{
  802222:	55                   	push   %ebp
  802223:	89 e5                	mov    %esp,%ebp
  802225:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  802228:	6a 01                	push   $0x1
  80222a:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80222d:	50                   	push   %eax
  80222e:	6a 00                	push   $0x0
  802230:	e8 36 f2 ff ff       	call   80146b <read>
	if (r < 0)
  802235:	83 c4 10             	add    $0x10,%esp
  802238:	85 c0                	test   %eax,%eax
  80223a:	78 0f                	js     80224b <getchar+0x29>
		return r;
	if (r < 1)
  80223c:	85 c0                	test   %eax,%eax
  80223e:	7e 06                	jle    802246 <getchar+0x24>
		return -E_EOF;
	return c;
  802240:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  802244:	eb 05                	jmp    80224b <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  802246:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80224b:	c9                   	leave  
  80224c:	c3                   	ret    

0080224d <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  80224d:	55                   	push   %ebp
  80224e:	89 e5                	mov    %esp,%ebp
  802250:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802253:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802256:	50                   	push   %eax
  802257:	ff 75 08             	pushl  0x8(%ebp)
  80225a:	e8 a6 ef ff ff       	call   801205 <fd_lookup>
  80225f:	83 c4 10             	add    $0x10,%esp
  802262:	85 c0                	test   %eax,%eax
  802264:	78 11                	js     802277 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  802266:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802269:	8b 15 58 30 80 00    	mov    0x803058,%edx
  80226f:	39 10                	cmp    %edx,(%eax)
  802271:	0f 94 c0             	sete   %al
  802274:	0f b6 c0             	movzbl %al,%eax
}
  802277:	c9                   	leave  
  802278:	c3                   	ret    

00802279 <opencons>:

int
opencons(void)
{
  802279:	55                   	push   %ebp
  80227a:	89 e5                	mov    %esp,%ebp
  80227c:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80227f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802282:	50                   	push   %eax
  802283:	e8 2e ef ff ff       	call   8011b6 <fd_alloc>
  802288:	83 c4 10             	add    $0x10,%esp
		return r;
  80228b:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80228d:	85 c0                	test   %eax,%eax
  80228f:	78 3e                	js     8022cf <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802291:	83 ec 04             	sub    $0x4,%esp
  802294:	68 07 04 00 00       	push   $0x407
  802299:	ff 75 f4             	pushl  -0xc(%ebp)
  80229c:	6a 00                	push   $0x0
  80229e:	e8 16 e9 ff ff       	call   800bb9 <sys_page_alloc>
  8022a3:	83 c4 10             	add    $0x10,%esp
		return r;
  8022a6:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8022a8:	85 c0                	test   %eax,%eax
  8022aa:	78 23                	js     8022cf <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8022ac:	8b 15 58 30 80 00    	mov    0x803058,%edx
  8022b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022b5:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8022b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022ba:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8022c1:	83 ec 0c             	sub    $0xc,%esp
  8022c4:	50                   	push   %eax
  8022c5:	e8 c5 ee ff ff       	call   80118f <fd2num>
  8022ca:	89 c2                	mov    %eax,%edx
  8022cc:	83 c4 10             	add    $0x10,%esp
}
  8022cf:	89 d0                	mov    %edx,%eax
  8022d1:	c9                   	leave  
  8022d2:	c3                   	ret    

008022d3 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8022d3:	55                   	push   %ebp
  8022d4:	89 e5                	mov    %esp,%ebp
  8022d6:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  8022d9:	83 3d 00 70 80 00 00 	cmpl   $0x0,0x807000
  8022e0:	75 2e                	jne    802310 <set_pgfault_handler+0x3d>
		// First time through!
		// LAB 4: Your code here.
		// panic("set_pgfault_handler not implemented");

		sys_page_alloc(sys_getenvid(), (void *) (UXSTACKTOP - PGSIZE), PTE_SYSCALL);
  8022e2:	e8 94 e8 ff ff       	call   800b7b <sys_getenvid>
  8022e7:	83 ec 04             	sub    $0x4,%esp
  8022ea:	68 07 0e 00 00       	push   $0xe07
  8022ef:	68 00 f0 bf ee       	push   $0xeebff000
  8022f4:	50                   	push   %eax
  8022f5:	e8 bf e8 ff ff       	call   800bb9 <sys_page_alloc>
		sys_env_set_pgfault_upcall(sys_getenvid(), _pgfault_upcall);
  8022fa:	e8 7c e8 ff ff       	call   800b7b <sys_getenvid>
  8022ff:	83 c4 08             	add    $0x8,%esp
  802302:	68 1a 23 80 00       	push   $0x80231a
  802307:	50                   	push   %eax
  802308:	e8 f7 e9 ff ff       	call   800d04 <sys_env_set_pgfault_upcall>
  80230d:	83 c4 10             	add    $0x10,%esp
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802310:	8b 45 08             	mov    0x8(%ebp),%eax
  802313:	a3 00 70 80 00       	mov    %eax,0x807000
}
  802318:	c9                   	leave  
  802319:	c3                   	ret    

0080231a <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  80231a:	54                   	push   %esp
	movl _pgfault_handler, %eax
  80231b:	a1 00 70 80 00       	mov    0x807000,%eax
	call *%eax
  802320:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802322:	83 c4 04             	add    $0x4,%esp
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.

	movl 48(%esp), %eax		// trap-time esp
  802325:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl 40(%esp), %ebx		// trap-time eip
  802329:	8b 5c 24 28          	mov    0x28(%esp),%ebx

	// load eip into esp-4
	// in order to return to trap-time eip later, in the meantime not changing trap-time esp
	movl %ebx, -4(%eax)	
  80232d:	89 58 fc             	mov    %ebx,-0x4(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.

	addl $8, %esp 			// esp now points to trap-time registers
  802330:	83 c4 08             	add    $0x8,%esp
	popal					// pop to all registers
  802333:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

	addl $4, %esp			// esp now points to trap-time eflags
  802334:	83 c4 04             	add    $0x4,%esp
	popfl					// pop to eflags
  802337:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.

	popl %esp				// pop to esp
  802338:	5c                   	pop    %esp
	// subl $4, %esp		// arithmetic operation will change eflags!!!
	lea -4(%esp), %esp		// subl $4, %esp
  802339:	8d 64 24 fc          	lea    -0x4(%esp),%esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.

	ret
  80233d:	c3                   	ret    

0080233e <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80233e:	55                   	push   %ebp
  80233f:	89 e5                	mov    %esp,%ebp
  802341:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802344:	89 d0                	mov    %edx,%eax
  802346:	c1 e8 16             	shr    $0x16,%eax
  802349:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802350:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802355:	f6 c1 01             	test   $0x1,%cl
  802358:	74 1d                	je     802377 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  80235a:	c1 ea 0c             	shr    $0xc,%edx
  80235d:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802364:	f6 c2 01             	test   $0x1,%dl
  802367:	74 0e                	je     802377 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802369:	c1 ea 0c             	shr    $0xc,%edx
  80236c:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802373:	ef 
  802374:	0f b7 c0             	movzwl %ax,%eax
}
  802377:	5d                   	pop    %ebp
  802378:	c3                   	ret    
  802379:	66 90                	xchg   %ax,%ax
  80237b:	66 90                	xchg   %ax,%ax
  80237d:	66 90                	xchg   %ax,%ax
  80237f:	90                   	nop

00802380 <__udivdi3>:
  802380:	55                   	push   %ebp
  802381:	57                   	push   %edi
  802382:	56                   	push   %esi
  802383:	53                   	push   %ebx
  802384:	83 ec 1c             	sub    $0x1c,%esp
  802387:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80238b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80238f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802393:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802397:	85 f6                	test   %esi,%esi
  802399:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80239d:	89 ca                	mov    %ecx,%edx
  80239f:	89 f8                	mov    %edi,%eax
  8023a1:	75 3d                	jne    8023e0 <__udivdi3+0x60>
  8023a3:	39 cf                	cmp    %ecx,%edi
  8023a5:	0f 87 c5 00 00 00    	ja     802470 <__udivdi3+0xf0>
  8023ab:	85 ff                	test   %edi,%edi
  8023ad:	89 fd                	mov    %edi,%ebp
  8023af:	75 0b                	jne    8023bc <__udivdi3+0x3c>
  8023b1:	b8 01 00 00 00       	mov    $0x1,%eax
  8023b6:	31 d2                	xor    %edx,%edx
  8023b8:	f7 f7                	div    %edi
  8023ba:	89 c5                	mov    %eax,%ebp
  8023bc:	89 c8                	mov    %ecx,%eax
  8023be:	31 d2                	xor    %edx,%edx
  8023c0:	f7 f5                	div    %ebp
  8023c2:	89 c1                	mov    %eax,%ecx
  8023c4:	89 d8                	mov    %ebx,%eax
  8023c6:	89 cf                	mov    %ecx,%edi
  8023c8:	f7 f5                	div    %ebp
  8023ca:	89 c3                	mov    %eax,%ebx
  8023cc:	89 d8                	mov    %ebx,%eax
  8023ce:	89 fa                	mov    %edi,%edx
  8023d0:	83 c4 1c             	add    $0x1c,%esp
  8023d3:	5b                   	pop    %ebx
  8023d4:	5e                   	pop    %esi
  8023d5:	5f                   	pop    %edi
  8023d6:	5d                   	pop    %ebp
  8023d7:	c3                   	ret    
  8023d8:	90                   	nop
  8023d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8023e0:	39 ce                	cmp    %ecx,%esi
  8023e2:	77 74                	ja     802458 <__udivdi3+0xd8>
  8023e4:	0f bd fe             	bsr    %esi,%edi
  8023e7:	83 f7 1f             	xor    $0x1f,%edi
  8023ea:	0f 84 98 00 00 00    	je     802488 <__udivdi3+0x108>
  8023f0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8023f5:	89 f9                	mov    %edi,%ecx
  8023f7:	89 c5                	mov    %eax,%ebp
  8023f9:	29 fb                	sub    %edi,%ebx
  8023fb:	d3 e6                	shl    %cl,%esi
  8023fd:	89 d9                	mov    %ebx,%ecx
  8023ff:	d3 ed                	shr    %cl,%ebp
  802401:	89 f9                	mov    %edi,%ecx
  802403:	d3 e0                	shl    %cl,%eax
  802405:	09 ee                	or     %ebp,%esi
  802407:	89 d9                	mov    %ebx,%ecx
  802409:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80240d:	89 d5                	mov    %edx,%ebp
  80240f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802413:	d3 ed                	shr    %cl,%ebp
  802415:	89 f9                	mov    %edi,%ecx
  802417:	d3 e2                	shl    %cl,%edx
  802419:	89 d9                	mov    %ebx,%ecx
  80241b:	d3 e8                	shr    %cl,%eax
  80241d:	09 c2                	or     %eax,%edx
  80241f:	89 d0                	mov    %edx,%eax
  802421:	89 ea                	mov    %ebp,%edx
  802423:	f7 f6                	div    %esi
  802425:	89 d5                	mov    %edx,%ebp
  802427:	89 c3                	mov    %eax,%ebx
  802429:	f7 64 24 0c          	mull   0xc(%esp)
  80242d:	39 d5                	cmp    %edx,%ebp
  80242f:	72 10                	jb     802441 <__udivdi3+0xc1>
  802431:	8b 74 24 08          	mov    0x8(%esp),%esi
  802435:	89 f9                	mov    %edi,%ecx
  802437:	d3 e6                	shl    %cl,%esi
  802439:	39 c6                	cmp    %eax,%esi
  80243b:	73 07                	jae    802444 <__udivdi3+0xc4>
  80243d:	39 d5                	cmp    %edx,%ebp
  80243f:	75 03                	jne    802444 <__udivdi3+0xc4>
  802441:	83 eb 01             	sub    $0x1,%ebx
  802444:	31 ff                	xor    %edi,%edi
  802446:	89 d8                	mov    %ebx,%eax
  802448:	89 fa                	mov    %edi,%edx
  80244a:	83 c4 1c             	add    $0x1c,%esp
  80244d:	5b                   	pop    %ebx
  80244e:	5e                   	pop    %esi
  80244f:	5f                   	pop    %edi
  802450:	5d                   	pop    %ebp
  802451:	c3                   	ret    
  802452:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802458:	31 ff                	xor    %edi,%edi
  80245a:	31 db                	xor    %ebx,%ebx
  80245c:	89 d8                	mov    %ebx,%eax
  80245e:	89 fa                	mov    %edi,%edx
  802460:	83 c4 1c             	add    $0x1c,%esp
  802463:	5b                   	pop    %ebx
  802464:	5e                   	pop    %esi
  802465:	5f                   	pop    %edi
  802466:	5d                   	pop    %ebp
  802467:	c3                   	ret    
  802468:	90                   	nop
  802469:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802470:	89 d8                	mov    %ebx,%eax
  802472:	f7 f7                	div    %edi
  802474:	31 ff                	xor    %edi,%edi
  802476:	89 c3                	mov    %eax,%ebx
  802478:	89 d8                	mov    %ebx,%eax
  80247a:	89 fa                	mov    %edi,%edx
  80247c:	83 c4 1c             	add    $0x1c,%esp
  80247f:	5b                   	pop    %ebx
  802480:	5e                   	pop    %esi
  802481:	5f                   	pop    %edi
  802482:	5d                   	pop    %ebp
  802483:	c3                   	ret    
  802484:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802488:	39 ce                	cmp    %ecx,%esi
  80248a:	72 0c                	jb     802498 <__udivdi3+0x118>
  80248c:	31 db                	xor    %ebx,%ebx
  80248e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802492:	0f 87 34 ff ff ff    	ja     8023cc <__udivdi3+0x4c>
  802498:	bb 01 00 00 00       	mov    $0x1,%ebx
  80249d:	e9 2a ff ff ff       	jmp    8023cc <__udivdi3+0x4c>
  8024a2:	66 90                	xchg   %ax,%ax
  8024a4:	66 90                	xchg   %ax,%ax
  8024a6:	66 90                	xchg   %ax,%ax
  8024a8:	66 90                	xchg   %ax,%ax
  8024aa:	66 90                	xchg   %ax,%ax
  8024ac:	66 90                	xchg   %ax,%ax
  8024ae:	66 90                	xchg   %ax,%ax

008024b0 <__umoddi3>:
  8024b0:	55                   	push   %ebp
  8024b1:	57                   	push   %edi
  8024b2:	56                   	push   %esi
  8024b3:	53                   	push   %ebx
  8024b4:	83 ec 1c             	sub    $0x1c,%esp
  8024b7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8024bb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8024bf:	8b 74 24 34          	mov    0x34(%esp),%esi
  8024c3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8024c7:	85 d2                	test   %edx,%edx
  8024c9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8024cd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8024d1:	89 f3                	mov    %esi,%ebx
  8024d3:	89 3c 24             	mov    %edi,(%esp)
  8024d6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8024da:	75 1c                	jne    8024f8 <__umoddi3+0x48>
  8024dc:	39 f7                	cmp    %esi,%edi
  8024de:	76 50                	jbe    802530 <__umoddi3+0x80>
  8024e0:	89 c8                	mov    %ecx,%eax
  8024e2:	89 f2                	mov    %esi,%edx
  8024e4:	f7 f7                	div    %edi
  8024e6:	89 d0                	mov    %edx,%eax
  8024e8:	31 d2                	xor    %edx,%edx
  8024ea:	83 c4 1c             	add    $0x1c,%esp
  8024ed:	5b                   	pop    %ebx
  8024ee:	5e                   	pop    %esi
  8024ef:	5f                   	pop    %edi
  8024f0:	5d                   	pop    %ebp
  8024f1:	c3                   	ret    
  8024f2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8024f8:	39 f2                	cmp    %esi,%edx
  8024fa:	89 d0                	mov    %edx,%eax
  8024fc:	77 52                	ja     802550 <__umoddi3+0xa0>
  8024fe:	0f bd ea             	bsr    %edx,%ebp
  802501:	83 f5 1f             	xor    $0x1f,%ebp
  802504:	75 5a                	jne    802560 <__umoddi3+0xb0>
  802506:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80250a:	0f 82 e0 00 00 00    	jb     8025f0 <__umoddi3+0x140>
  802510:	39 0c 24             	cmp    %ecx,(%esp)
  802513:	0f 86 d7 00 00 00    	jbe    8025f0 <__umoddi3+0x140>
  802519:	8b 44 24 08          	mov    0x8(%esp),%eax
  80251d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802521:	83 c4 1c             	add    $0x1c,%esp
  802524:	5b                   	pop    %ebx
  802525:	5e                   	pop    %esi
  802526:	5f                   	pop    %edi
  802527:	5d                   	pop    %ebp
  802528:	c3                   	ret    
  802529:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802530:	85 ff                	test   %edi,%edi
  802532:	89 fd                	mov    %edi,%ebp
  802534:	75 0b                	jne    802541 <__umoddi3+0x91>
  802536:	b8 01 00 00 00       	mov    $0x1,%eax
  80253b:	31 d2                	xor    %edx,%edx
  80253d:	f7 f7                	div    %edi
  80253f:	89 c5                	mov    %eax,%ebp
  802541:	89 f0                	mov    %esi,%eax
  802543:	31 d2                	xor    %edx,%edx
  802545:	f7 f5                	div    %ebp
  802547:	89 c8                	mov    %ecx,%eax
  802549:	f7 f5                	div    %ebp
  80254b:	89 d0                	mov    %edx,%eax
  80254d:	eb 99                	jmp    8024e8 <__umoddi3+0x38>
  80254f:	90                   	nop
  802550:	89 c8                	mov    %ecx,%eax
  802552:	89 f2                	mov    %esi,%edx
  802554:	83 c4 1c             	add    $0x1c,%esp
  802557:	5b                   	pop    %ebx
  802558:	5e                   	pop    %esi
  802559:	5f                   	pop    %edi
  80255a:	5d                   	pop    %ebp
  80255b:	c3                   	ret    
  80255c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802560:	8b 34 24             	mov    (%esp),%esi
  802563:	bf 20 00 00 00       	mov    $0x20,%edi
  802568:	89 e9                	mov    %ebp,%ecx
  80256a:	29 ef                	sub    %ebp,%edi
  80256c:	d3 e0                	shl    %cl,%eax
  80256e:	89 f9                	mov    %edi,%ecx
  802570:	89 f2                	mov    %esi,%edx
  802572:	d3 ea                	shr    %cl,%edx
  802574:	89 e9                	mov    %ebp,%ecx
  802576:	09 c2                	or     %eax,%edx
  802578:	89 d8                	mov    %ebx,%eax
  80257a:	89 14 24             	mov    %edx,(%esp)
  80257d:	89 f2                	mov    %esi,%edx
  80257f:	d3 e2                	shl    %cl,%edx
  802581:	89 f9                	mov    %edi,%ecx
  802583:	89 54 24 04          	mov    %edx,0x4(%esp)
  802587:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80258b:	d3 e8                	shr    %cl,%eax
  80258d:	89 e9                	mov    %ebp,%ecx
  80258f:	89 c6                	mov    %eax,%esi
  802591:	d3 e3                	shl    %cl,%ebx
  802593:	89 f9                	mov    %edi,%ecx
  802595:	89 d0                	mov    %edx,%eax
  802597:	d3 e8                	shr    %cl,%eax
  802599:	89 e9                	mov    %ebp,%ecx
  80259b:	09 d8                	or     %ebx,%eax
  80259d:	89 d3                	mov    %edx,%ebx
  80259f:	89 f2                	mov    %esi,%edx
  8025a1:	f7 34 24             	divl   (%esp)
  8025a4:	89 d6                	mov    %edx,%esi
  8025a6:	d3 e3                	shl    %cl,%ebx
  8025a8:	f7 64 24 04          	mull   0x4(%esp)
  8025ac:	39 d6                	cmp    %edx,%esi
  8025ae:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8025b2:	89 d1                	mov    %edx,%ecx
  8025b4:	89 c3                	mov    %eax,%ebx
  8025b6:	72 08                	jb     8025c0 <__umoddi3+0x110>
  8025b8:	75 11                	jne    8025cb <__umoddi3+0x11b>
  8025ba:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8025be:	73 0b                	jae    8025cb <__umoddi3+0x11b>
  8025c0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8025c4:	1b 14 24             	sbb    (%esp),%edx
  8025c7:	89 d1                	mov    %edx,%ecx
  8025c9:	89 c3                	mov    %eax,%ebx
  8025cb:	8b 54 24 08          	mov    0x8(%esp),%edx
  8025cf:	29 da                	sub    %ebx,%edx
  8025d1:	19 ce                	sbb    %ecx,%esi
  8025d3:	89 f9                	mov    %edi,%ecx
  8025d5:	89 f0                	mov    %esi,%eax
  8025d7:	d3 e0                	shl    %cl,%eax
  8025d9:	89 e9                	mov    %ebp,%ecx
  8025db:	d3 ea                	shr    %cl,%edx
  8025dd:	89 e9                	mov    %ebp,%ecx
  8025df:	d3 ee                	shr    %cl,%esi
  8025e1:	09 d0                	or     %edx,%eax
  8025e3:	89 f2                	mov    %esi,%edx
  8025e5:	83 c4 1c             	add    $0x1c,%esp
  8025e8:	5b                   	pop    %ebx
  8025e9:	5e                   	pop    %esi
  8025ea:	5f                   	pop    %edi
  8025eb:	5d                   	pop    %ebp
  8025ec:	c3                   	ret    
  8025ed:	8d 76 00             	lea    0x0(%esi),%esi
  8025f0:	29 f9                	sub    %edi,%ecx
  8025f2:	19 d6                	sbb    %edx,%esi
  8025f4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8025f8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8025fc:	e9 18 ff ff ff       	jmp    802519 <__umoddi3+0x69>
